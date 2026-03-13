#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Packs BBMOD_GML/shader_includes/*.glsl into
BBMOD_GML/extensions/BBMOD/shader_includes.zip.

Run this script whenever you add, remove, or modify files in shader_includes/.
"""
import os
import zipfile

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INCLUDES_DIR = os.path.join(SCRIPT_DIR, "BBMOD_GML", "shader_includes")
ZIP_PATH = os.path.join(SCRIPT_DIR, "BBMOD_GML", "extensions", "BBMOD", "shader_includes.zip")


def main():
    glsl_files = [f for f in os.listdir(INCLUDES_DIR) if f.endswith(".glsl")]

    if not glsl_files:
        print("No .glsl files found in shader_includes/ -- nothing to do.")
        return

    with zipfile.ZipFile(ZIP_PATH, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for filename in sorted(glsl_files):
            src = os.path.join(INCLUDES_DIR, filename)
            arcname = os.path.join("shader_includes", filename)
            zf.write(src, arcname)
            print(f"  + {arcname}")

    print(f"\nWrote {len(glsl_files)} file(s) to '{os.path.relpath(ZIP_PATH, SCRIPT_DIR)}'.")


if __name__ == "__main__":
    main()
