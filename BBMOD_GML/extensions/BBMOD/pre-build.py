#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import ctypes
import os
import re
import sys
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

# Custom preprocessor directives
DEFINE_PATTERN = re.compile(r"// +@define +(\w+)(?:\s+(.+))?")
UNDEF_PATTERN = re.compile(r"// +@undef +(\w+)")
IF_PATTERN = re.compile(r"// +@if +(.+)")
IFDEF_PATTERN = re.compile(r"// +@ifdef +(\w+)")
IFNDEF_PATTERN = re.compile(r"// +@ifndef +(\w+)")
ELIF_PATTERN = re.compile(r"// +@elif +(.+)")
ELSE_PATTERN = re.compile(r"// +@else\b")
ENDIF_PATTERN = re.compile(r"// +@endif\b")




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
# Preprocessor expression evaluation
# ==============================================================================
def eval_condition(expr, defines):
    """Evaluate a boolean expression: defined(X), &&, ||, !, !=, numeric comparisons."""
    # Replace defined(NAME) with True or False
    expr = re.sub(
        r"\bdefined\s*\(\s*(\w+)\s*\)",
        lambda m: "True" if m.group(1) in defines else "False",
        expr,
    )
    # Substitute known define values
    for k, v in defines.items():
        if isinstance(v, bool):
            repl = "True" if v else "False"
        else:
            repl = str(v)
        expr = re.sub(r"\b" + re.escape(k) + r"\b", repl, expr)
    # Translate C/GLSL operators to Python
    expr = expr.replace("!=", "__NEQ__")
    expr = expr.replace("&&", " and ")
    expr = expr.replace("||", " or ")
    expr = re.sub(r"!(?!=)", " not ", expr)
    expr = expr.replace("__NEQ__", " != ")
    expr = re.sub(r"\btrue\b", "True", expr)
    expr = re.sub(r"\bfalse\b", "False", expr)
    try:
        return bool(eval(expr))  # nosec: input is shader source, not user data
    except Exception:
        return False


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
    """Process custom preprocessor directives (// @if, // @ifdef, etc.).

    defines is a dict mapping name to value (True for plain flags).
    All defines are resolved at build time; unknown names evaluate to False.
    """
    if defines is None:
        defines = {}

    lines = source_code.split('\n')
    result = []

    # condition_stack entries: (active, done)
    #   active - this branch is currently emitting lines
    #   done   - some branch in this if/elif/else chain has already been taken
    condition_stack = []

    def emitting():
        return all(active for (active, _) in condition_stack)

    for line in lines:
        stripped = line.strip()

        # -- @define NAME [value] --
        m = DEFINE_PATTERN.match(stripped)
        if m:
            if emitting():
                name = m.group(1)
                raw = (m.group(2) or "").strip()
                if not raw:
                    defines[name] = True
                else:
                    try:
                        defines[name] = int(raw)
                    except ValueError:
                        if raw == "true":
                            defines[name] = True
                        elif raw == "false":
                            defines[name] = False
                        else:
                            defines[name] = raw
                result.append(line)
            continue

        # -- @undef NAME --
        m = UNDEF_PATTERN.match(stripped)
        if m:
            if emitting():
                defines.pop(m.group(1), None)
            continue

        # -- @if <expr> --
        m = IF_PATTERN.match(stripped)
        if m:
            cond = emitting() and eval_condition(m.group(1), defines)
            condition_stack.append((cond, cond))
            continue

        # -- @ifdef NAME --
        m = IFDEF_PATTERN.match(stripped)
        if m:
            cond = emitting() and (m.group(1) in defines)
            condition_stack.append((cond, cond))
            continue

        # -- @ifndef NAME --
        m = IFNDEF_PATTERN.match(stripped)
        if m:
            cond = emitting() and (m.group(1) not in defines)
            condition_stack.append((cond, cond))
            continue

        # -- @elif <expr> --
        m = ELIF_PATTERN.match(stripped)
        if m:
            if condition_stack:
                _, done = condition_stack.pop()
                if done:
                    condition_stack.append((False, True))
                else:
                    cond = emitting() and eval_condition(m.group(1), defines)
                    condition_stack.append((cond, cond))
            continue

        # -- @else --
        if ELSE_PATTERN.match(stripped):
            if condition_stack:
                _, done = condition_stack.pop()
                active = emitting() and not done
                condition_stack.append((active, True))
            continue

        # -- @endif --
        if ENDIF_PATTERN.match(stripped):
            if condition_stack:
                condition_stack.pop()
            continue

        # Regular line
        if emitting():
            result.append(line)

    # Collapse consecutive blank lines
    filtered_result = []
    prev_blank = False
    for line in result:
        is_blank = line.strip() == ""
        if not (is_blank and prev_blank):
            filtered_result.append(line)
        prev_blank = is_blank

    return "\n".join(filtered_result)


def expand_shader(source_code, included_files, depth=0, defines=None):
    if defines is None:
        defines = {}

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

        project_dir = os.path.abspath(os.path.join("..", ".."))

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
                defines = {}
                preprocessed_code = preprocess_shader(original_code, defines)

                # Then expand includes
                included_files = set()
                expanded_code = expand_shader(preprocessed_code, included_files, depth=0, defines=defines)

                if original_code != expanded_code:
                    with open(file_path, "w", encoding="utf-8") as shader_file:
                        shader_file.write(expanded_code)

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
