#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from datetime import datetime, timezone
from pathlib import Path
import ctypes
import json
import os
import re
import subprocess
import sys
import threading
import time
import tkinter as tk
import traceback
import zipfile

# ==============================================================================
# Supported model file formats
# ==============================================================================
MODEL_EXTENSIONS = [
    ".fbx",
    ".glb",
    ".gltf",
    ".obj",
]

# ==============================================================================
# Regex patterns
# ==============================================================================
INCLUDE_PATTERN = re.compile(r"// +@include +(\w+)\n")
ENDINCLUDE_PATTERN = re.compile(r"// +@endinclude\n")


# ==============================================================================
# Cache helpers
# ==============================================================================
def check_and_update_cache(file_path, cache_key, args_str, cache):
    p = Path(file_path)
    stat = p.stat()

    mtime = datetime.fromtimestamp(stat.st_mtime, tz=timezone.utc).isoformat()

    size = stat.st_size

    current = {
        "mtime": mtime,
        "size": size,
        "args": args_str,
    }

    last = cache.get(cache_key)

    if last != current:
        cache[cache_key] = current
        return False  # File changed or new

    return True  # Same file as last run


# ==============================================================================
# Thread-safe UI helpers
# ==============================================================================
def set_progress_text(text):
    print(text)

    def _update():
        if canvas.winfo_exists():
            canvas.itemconfig(progress_text, text=text)

    root.after(0, _update)


def safe_close(delay_ms=0):
    def _close():
        if root.winfo_exists():
            root.destroy()

    root.after(delay_ms, _close)


# ==============================================================================
# Shader expansion logic
# ==============================================================================
def expand_shader(source_code, included_files, depth=0):
    search_pos = 0

    while True:
        include_match = INCLUDE_PATTERN.search(source_code, pos=search_pos)
        if not include_match:
            break

        if depth == 0:
            prefix = source_code[: include_match.span()[1]]
        else:
            prefix = source_code[: include_match.start()]

        endinclude_match = ENDINCLUDE_PATTERN.search(
            source_code, pos=include_match.span()[1]
        )

        if endinclude_match:
            suffix = source_code[endinclude_match.span()[1] :]
        else:
            suffix = source_code[include_match.span()[1] :]

        include_name = include_match.group(1)
        included_code = ""

        if include_name not in included_files:
            included_files.add(include_name)

            include_path = os.path.join(
                "..", "..", "shader_includes", f"{include_name}.glsl"
            )

            if os.path.exists(include_path):
                print("  " * (depth + 1) + f"Including '{include_name}.glsl'...")
                with open(include_path, "r", encoding="utf-8") as include_file:
                    included_code = include_file.read()

                included_code = (
                    expand_shader(included_code, included_files, depth + 1).strip()
                    + "\n"
                )
            else:
                print(
                    "  " * (depth + 1)
                    + f"ERROR: File '{include_name}.glsl' does not exist!"
                )
                included_code = f"#error Failed to include '{include_name}.glsl'!\n"

            if depth == 0:
                included_code += "// @endinclude\n"
        else:
            print(
                "  " * depth + f"Skipping '{include_name}.glsl' (already included)..."
            )

        source_code = prefix + included_code + suffix
        search_pos = len(prefix + included_code)

    return source_code


# ==============================================================================
# Main worker thread
# ==============================================================================
def main_program():
    try:
        time.sleep(0.25)
        print("=" * 80)
        print(f"Welcome to BBMOD {bbmod_version}!")

        # ======================================================================
        # Load conf and cache
        # ======================================================================
        project_dir = os.path.abspath(os.path.join("..", ".."))
        conf_path = os.path.join(project_dir, "bbmod.conf.json")
        cache_path = os.path.join(project_dir, "bbmod.cache.json")

        set_progress_text("Loading 'bbmod.conf.json'...")
        try:
            with open(conf_path, "r") as f:
                conf = json.load(f)
        except:
            conf = {}
        conf.setdefault("commonArgs", "-lf=false -zup=true")
        conf.setdefault("models", {})

        set_progress_text("Loading 'bbmod.cache.json'...")
        try:
            with open(cache_path, "r") as f:
                cache = json.load(f)
        except:
            cache = {}

        # ======================================================================
        # Unpack shader includes
        # ======================================================================
        set_progress_text("Unpacking 'shader_includes.zip'...")
        with zipfile.ZipFile("shader_includes.zip", "r") as zip_ref:
            zip_ref.extractall(project_dir)

        # ======================================================================
        # Expand shaders
        # ======================================================================
        shader_root = os.path.join(project_dir, "shaders")

        for root_dir, _, filenames in os.walk(shader_root):
            for filename in filenames:
                if not filename.endswith((".vsh", ".fsh")):
                    continue

                set_progress_text(f"Processing '{filename}'...")

                file_path = os.path.join(root_dir, filename)
                with open(file_path, "r", encoding="utf-8") as shader_file:
                    original_code = shader_file.read()

                included_files = set()
                expanded_code = expand_shader(original_code, included_files)

                if original_code != expanded_code:
                    with open(file_path, "w", encoding="utf-8") as shader_file:
                        shader_file.write(expanded_code)

        # ======================================================================
        # Convert models
        # ======================================================================
        common_args = conf.get("commonArgs", "").split(" ")
        common_args = [arg.strip() for arg in common_args]
        common_args = [arg for arg in common_args if arg != ""]
        common_args = sorted(list(set(common_args)))
        conf["commonArgs"] = " ".join(common_args)

        exe = os.path.abspath(
            "BBMOD.exe" if sys.platform.startswith("win") else "BBMOD"
        )
        exe_cwd = os.path.dirname(exe)
        assets_in_dir = os.path.join(project_dir, "assets")
        assets_out_dir = os.path.join(project_dir, "datafiles", "assets")
        os.makedirs(assets_in_dir, exist_ok=True)

        for root_dir, _, filenames in os.walk(assets_in_dir):
            for filename in filenames:
                if not os.path.splitext(filename)[1].lower() in MODEL_EXTENSIONS:
                    continue

                file_path_in = os.path.join(root_dir, filename)
                file_path_out = (
                    os.path.splitext(
                        file_path_in.replace(assets_in_dir, assets_out_dir, 1)
                    )[0]
                    + ".bbmod"
                )
                file_path_cache = os.path.relpath(
                    file_path_in, start=project_dir
                ).replace(os.sep, "/")

                conf["models"].setdefault(file_path_cache, {})

                # Normalize args
                args = conf["models"][file_path_cache].get("args", "").split(" ")
                args = [arg.strip() for arg in args]
                args = [arg for arg in args if arg != ""]

                args_str = " ".join(sorted(list(set(args))))
                conf["models"][file_path_cache]["args"] = args_str

                # Combine with common args and normalize again
                args = sorted(list(set(args + common_args)))
                args_str = " ".join(args)

                if check_and_update_cache(
                    file_path_in, file_path_cache, args_str, cache
                ) and os.path.exists(file_path_out):
                    set_progress_text(f"Skipping '{file_path_cache}' (cached)...")
                    continue

                set_progress_text(f"Converting '{file_path_cache}'...")

                os.makedirs(os.path.dirname(file_path_out), exist_ok=True)
                cmd = [exe, file_path_in, file_path_out] + args

                result = subprocess.run(cmd, cwd=exe_cwd)

                if result.returncode != 0:
                    pass

        # ======================================================================
        # Save conf and cache
        # ======================================================================
        set_progress_text("Saving 'bbmod.conf.json'...")
        with open(conf_path, "w") as f:
            json.dump(conf, f, indent=2, sort_keys=True)

        set_progress_text("Saving 'bbmod.cache.json'...")
        with open(cache_path, "w") as f:
            json.dump(cache, f, indent=2, sort_keys=True)

        set_progress_text("Done.")
        print("=" * 80)
        time.sleep(0.25)

    except Exception as e:
        set_progress_text(f"ERROR: {e}")
        traceback.print_exc()
        time.sleep(2)

    finally:
        safe_close()


# ==============================================================================
# Create splash screen
# ==============================================================================
try:
    ctypes.windll.shcore.SetProcessDpiAwareness(1)
except Exception:
    pass

root = tk.Tk()
root.overrideredirect(True)
root.configure(bg="black")

# Bring to front on macOS
if sys.platform == "darwin":
    root.lift()
    root.attributes("-topmost", True)

# Load splash image
splash = tk.PhotoImage(file="splash.gif")

# Keep reference alive
root.splash_image = splash

# Splash screen size
width = splash.width()
height = splash.height()

# Center window
screen_width = root.winfo_screenwidth()
screen_height = root.winfo_screenheight()
x = (screen_width // 2) - (width // 2)
y = (screen_height // 2) - (height // 2)
root.geometry(f"{width}x{height}+{x}+{y}")

# Canvas for splash + text
canvas = tk.Canvas(root, width=width, height=height, bg="black", highlightthickness=0)
canvas.pack()

# Draw splash
canvas.create_image(width // 2, height // 2, image=splash)

# Title and version
try:
    with open("BBMOD.yy", "r") as f:
        bbmod_version = re.findall(
            r"\"extensionVersion\":\"(\d+\.\d+\.\d+)\"", f.read()
        )[0]
except:
    bbmod_version = "3.x.y"

title_text = canvas.create_text(
    10, height - 80, text=f"BBMOD", anchor="w", fill="silver", font=("Sans", 10, "bold")
)

version_text = canvas.create_text(
    10,
    height - 60,
    text=f"Version {bbmod_version}",
    anchor="w",
    fill="silver",
    font=("Sans", 8),
)

# Progress text at bottom-left
progress_text = canvas.create_text(
    10, height - 20, text="Starting...", anchor="w", fill="white", font=("Sans", 9)
)

# Start worker thread
threading.Thread(target=main_program, daemon=True).start()

# Enter GUI loop
root.mainloop()
