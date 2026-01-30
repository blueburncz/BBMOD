#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import re

INCLUDE_PATTERN = re.compile(r"// +@include +(\w+)\n")
ENDINCLUDE_PATTERN = re.compile(r"// +@endinclude\n")


def expand_shader(source_code, depth=0):
    search_pos = 0

    while True:
        include_match = INCLUDE_PATTERN.search(source_code, pos=search_pos)
        if not include_match:
            break

        if depth == 0:
            prefix = source_code[:include_match.span()[1]]  # Keep @include
        else:
            prefix = source_code[:include_match.start()]  # Remove @include

        endinclude_match = ENDINCLUDE_PATTERN.search(
            source_code, pos=include_match.span()[1]
        )

        if endinclude_match:
            suffix = source_code[endinclude_match.span()[1]:]  # Remove @endinclude
        else:
            suffix = source_code[include_match.span()[1]:]  # Nothing to remove

        include_name = include_match.group(1)
        included_code = ""

        if include_name not in included_files:
            included_files.append(include_name)

            include_path = os.path.join("shader_includes", f"{include_name}.glsl")
            if os.path.exists(include_path):
                print("  " * (depth + 1) + f"Including {include_name}.glsl")
                with open(include_path, "r") as include_file:
                    included_code = include_file.read()

                included_code = expand_shader(
                    included_code, depth + 1
                ).strip() + "\n"
            else:
                print("  " * (depth + 1) +
                      f"ERROR: File {include_name}.glsl does not exist!")
                included_code = f"#error Failed to include {include_name}.glsl!\n"
                if depth == 0:
                    included_code += "// @endinclude\n"
        else:
            print("  " * depth +
                  f"Skipping {include_name}.glsl (already included)")

        source_code = prefix + included_code + suffix
        search_pos = len(prefix + included_code)

    return source_code


print("=" * 80)
print("Expanding shaders...")

for root_dir, _, filenames in os.walk("shaders"):
    for filename in filenames:
        if not filename.endswith((".vsh", ".fsh")):
            continue

        file_path = os.path.join(root_dir, filename)
        print(file_path)

        with open(file_path, "r") as shader_file:
            original_code = shader_file.read()

        included_files = []
        expanded_code = expand_shader(original_code)

        if original_code != expanded_code:
            with open(file_path, "w") as shader_file:
                shader_file.write(expanded_code)

print("...done")
print("=" * 80)
