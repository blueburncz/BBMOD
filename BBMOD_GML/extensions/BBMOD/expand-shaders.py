#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import ctypes
import os
import re
import threading
import time
import tkinter as tk
import traceback
import zipfile

# ==============================================================================
# Regex patterns
# ==============================================================================
INCLUDE_PATTERN = re.compile(r"// +@include +(\w+)\n")
ENDINCLUDE_PATTERN = re.compile(r"// +@endinclude\n")

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
            prefix = source_code[:include_match.span()[1]]
        else:
            prefix = source_code[:include_match.start()]

        endinclude_match = ENDINCLUDE_PATTERN.search(
            source_code, pos=include_match.span()[1]
        )

        if endinclude_match:
            suffix = source_code[endinclude_match.span()[1]:]
        else:
            suffix = source_code[include_match.span()[1]:]

        include_name = include_match.group(1)
        included_code = ""

        if include_name not in included_files:
            included_files.add(include_name)

            include_path = os.path.join(
                "..", "..", "shader_includes", f"{include_name}.glsl"
            )

            if os.path.exists(include_path):
                print("  " * (depth + 1) + f"Including {include_name}.glsl")
                with open(include_path, "r", encoding="utf-8") as include_file:
                    included_code = include_file.read()

                included_code = expand_shader(
                    included_code, included_files, depth + 1
                ).strip() + "\n"
            else:
                print(
                    "  " * (depth + 1) +
                    f"ERROR: File {include_name}.glsl does not exist!"
                )
                included_code = f"#error Failed to include {include_name}.glsl!\n"

            if depth == 0:
                included_code += "// @endinclude\n"
        else:
            print("  " * depth +
                  f"Skipping {include_name}.glsl (already included)")

        source_code = prefix + included_code + suffix
        search_pos = len(prefix + included_code)

    return source_code

# ==============================================================================
# Main worker thread
# ==============================================================================
def main_program():
    try:
        # ======================================================================
        # Unpack shader includes
        # ======================================================================
        print("=" * 80)
        set_progress_text("Unpacking shader_includes...")

        with zipfile.ZipFile("shader_includes.zip", "r") as zip_ref:
            zip_ref.extractall(os.path.join("..", ".."))

        # ======================================================================
        # Expand shaders
        # ======================================================================
        shader_root = os.path.join("..", "..", "shaders")

        for root_dir, _, filenames in os.walk(shader_root):
            for filename in filenames:
                if not filename.endswith((".vsh", ".fsh")):
                    continue

                set_progress_text(f"Expanding shader {filename}...")

                file_path = os.path.join(root_dir, filename)
                with open(file_path, "r", encoding="utf-8") as shader_file:
                    original_code = shader_file.read()

                included_files = set()
                expanded_code = expand_shader(original_code, included_files)

                if original_code != expanded_code:
                    with open(file_path, "w", encoding="utf-8") as shader_file:
                        shader_file.write(expanded_code)

        set_progress_text("Done.")
        print("=" * 80)
        time.sleep(0.5)

    except Exception as e:
        set_progress_text(f"Error: {e}")
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
canvas = tk.Canvas(
    root,
    width=width,
    height=height,
    bg="black",
    highlightthickness=0
)
canvas.pack()

# Draw splash
canvas.create_image(width // 2, height // 2, image=splash)

# Title and version
with open("BBMOD.yy", "r") as f:
    bbmod_version = re.findall(r"\"extensionVersion\":\"(\d+\.\d+\.\d+)\"", f.read())[0]

title_text = canvas.create_text(
    10,
    height - 80,
    text=f"BBMOD",
    anchor="w",
    fill="silver",
    font=("Sans", 10, "bold")
)

version_text = canvas.create_text(
    10,
    height - 60,
    text=f"Version {bbmod_version}",
    anchor="w",
    fill="silver",
    font=("Sans", 8)
)

# Progress text at bottom-left
progress_text = canvas.create_text(
    10,
    height - 20,
    text="Starting...",
    anchor="w",
    fill="white",
    font=("Sans", 9)
)

# Start worker thread
threading.Thread(target=main_program, daemon=True).start()

# Enter GUI loop
root.mainloop()
