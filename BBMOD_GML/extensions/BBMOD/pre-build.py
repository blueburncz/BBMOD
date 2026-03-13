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

# Custom preprocessor directives
DEFINE_PATTERN = re.compile(r"// +@define +(\w+)")
IFDEF_PATTERN = re.compile(r"// +@ifdef +(\w+)")
IFNDEF_PATTERN = re.compile(r"// +@ifndef +(\w+)")
ELSE_PATTERN = re.compile(r"// +@else")
ENDIF_PATTERN = re.compile(r"// +@endif")


# ==============================================================================
# Args helpers
# ==============================================================================
def parse_args(arg_string):
    result = {}
    for arg in arg_string.split():
        arg = arg.strip()
        if not arg:
            continue

        if "=" in arg:
            key, value = arg.split("=", 1)
            result[key] = value
        else:
            # handle flags without values like "-pt"
            result[arg] = None

    return result


def build_args(arg_dict, as_list=False):
    items = []
    for key in sorted(arg_dict.keys()):
        value = arg_dict[key]
        if value is None:
            items.append(key)
        else:
            items.append(f"{key}={value}")

    if as_list:
        return items
    return " ".join(items)


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
def get_line_indent(source_code, pos):
    """Get indentation of the line containing pos."""
    # Find start of line
    line_start = source_code.rfind('\n', 0, pos) + 1
    # Count leading whitespace
    indent = ""
    for i in range(line_start, pos):
        if source_code[i] in ' \t':
            indent += source_code[i]
        else:
            break
    return indent


def indent_code(code, indent):
    """Apply indentation to each non-empty line of code, preserving relative indentation."""
    if not indent:
        return code

    lines = code.split('\n')

    # Find minimum indentation level (ignoring empty lines)
    min_indent = None
    for line in lines:
        if line.strip():  # Non-empty line
            # Count leading whitespace
            leading = len(line) - len(line.lstrip())
            if min_indent is None or leading < min_indent:
                min_indent = leading

    # If all lines are empty, just return as-is
    if min_indent is None:
        return code

    # Remove base indentation and apply new indentation
    result = []
    for line in lines:
        if line.strip():  # Non-empty line
            # Remove base indentation, keep relative indentation
            dedented = line[min_indent:] if len(line) > min_indent else line.lstrip()
            result.append(indent + dedented.rstrip())  # rstrip to remove trailing whitespace
        else:  # Empty line - no indentation
            result.append('')

    return '\n'.join(result)


def preprocess_shader(source_code, defines=None):
    """Process custom preprocessor directives (// @ifdef, etc.)"""
    if defines is None:
        defines = set()

    # First pass: collect defines from // @define directives
    for match in DEFINE_PATTERN.finditer(source_code):
        defines.add(match.group(1))

    lines = source_code.split('\n')
    result = []
    condition_stack = []  # Stack of (condition_met, else_encountered)

    for line in lines:
        # Check for @define directive (already collected, keep in output)
        if DEFINE_PATTERN.match(line):
            result.append(line)
            continue

        # Check for @ifdef
        ifdef_match = IFDEF_PATTERN.match(line)
        if ifdef_match:
            define_name = ifdef_match.group(1)
            is_defined = define_name in defines
            condition_stack.append((is_defined, False))
            continue

        # Check for @ifndef
        ifndef_match = IFNDEF_PATTERN.match(line)
        if ifndef_match:
            define_name = ifndef_match.group(1)
            is_not_defined = define_name not in defines
            condition_stack.append((is_not_defined, False))
            continue

        # Check for @else
        if ELSE_PATTERN.match(line):
            if condition_stack:
                condition_met, _ = condition_stack.pop()
                # Flip the condition for else block
                condition_stack.append((not condition_met, True))
            continue

        # Check for @endif
        if ENDIF_PATTERN.match(line):
            if condition_stack:
                condition_stack.pop()
            continue

        # Determine if we should include this line
        include_line = True
        for condition_met, _ in condition_stack:
            if not condition_met:
                include_line = False
                break

        if include_line:
            result.append(line)

    # Collapse consecutive blank lines
    filtered_result = []
    prev_blank = False
    for line in result:
        is_blank = line.strip() == ''
        if not (is_blank and prev_blank):
            filtered_result.append(line)
        prev_blank = is_blank

    return '\n'.join(filtered_result)


def expand_shader(source_code, included_files, depth=0, defines=None):
    if defines is None:
        defines = set()

    search_pos = 0

    while True:
        include_match = INCLUDE_PATTERN.search(source_code, pos=search_pos)
        if not include_match:
            break

        # Get indentation of the @include line
        indent = get_line_indent(source_code, include_match.start())

        if depth == 0:
            prefix = source_code[: include_match.span()[1]]
        else:
            # For nested includes, don't include the indent in prefix
            # (it will be added by indent_code)
            prefix = source_code[: include_match.start() - len(indent)]

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
                    raw_code = include_file.read()

                # Preprocess custom directives first (pass defines from parent)
                preprocessed_code = preprocess_shader(raw_code, defines.copy())

                # Recursively expand nested includes (pass defines down)
                expanded_code = expand_shader(preprocessed_code, included_files, depth + 1, defines).strip()

                # Apply indentation to the included code
                # Add blank line before included content at depth 0 for readability
                if depth == 0:
                    included_code = "\n" + indent_code(expanded_code, indent) + "\n"
                else:
                    included_code = indent_code(expanded_code, indent) + "\n"
            else:
                print(
                    "  " * (depth + 1)
                    + f"ERROR: File '{include_name}.glsl' does not exist!"
                )
                included_code = indent + f"#error Failed to include '{include_name}.glsl'!\n"

            if depth == 0:
                included_code += indent + "// @endinclude\n"
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

                # First, preprocess custom directives (/// @ifdef, etc.)
                defines = set()
                preprocessed_code = preprocess_shader(original_code, defines)

                # Then expand includes
                included_files = set()
                expanded_code = expand_shader(preprocessed_code, included_files, depth=0, defines=defines)

                if original_code != expanded_code:
                    with open(file_path, "w", encoding="utf-8") as shader_file:
                        shader_file.write(expanded_code)

        # ======================================================================
        # Convert models
        # ======================================================================

        # Parse common args
        common_dict = parse_args(conf.get("commonArgs", ""))
        conf["commonArgs"] = build_args(common_dict)

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

                # Parse model args
                model_dict = parse_args(conf["models"][file_path_cache].get("args", ""))

                # Model args override common args
                combined = common_dict.copy()
                combined.update(model_dict)

                # Save normalized model args
                conf["models"][file_path_cache]["args"] = build_args(model_dict)

                # Final combined args string
                args = build_args(combined, as_list=True)
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
