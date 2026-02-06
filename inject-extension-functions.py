#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json5
import os
import re

EXTENSIONS = [
    (
        os.path.normpath("BBMOD_CPP/src/Physics"),
        os.path.normpath("BBMOD_GML/extensions/BBMOD_Physics/BBMOD_Physics.yy"),
        "BBMOD_Physics.ext",
    ),
    (
        os.path.normpath("BBMOD_CPP/src/D3D11"),
        os.path.normpath("BBMOD_GML/extensions/BBMOD_D3D11/BBMOD_D3D11.yy"),
        "BBMOD_D3D11.ext",
    ),
]

TYPE_MAP = {
    "char*": 1,
    "double": 2,
}

EXPORT_PATTERN = re.compile(r"GM_EXPORT (double|char\*) (\w+)\(([^)]*)\)")

for source_dir, yy_file_path, extension_filename in EXTENSIONS:
    print(f"Processing extension {extension_filename}...")

    # ==========================================================================
    # Parse exports
    # ==========================================================================
    functions = []

    for filename in os.listdir(source_dir):
        if not filename.startswith("exports"):
            continue

        file_path = os.path.join(source_dir, filename)
        with open(file_path, "r") as source_file:
            print(f"  Collecting functions from {file_path}")
            documentation = ""

            for line in source_file.readlines():
                if line.startswith("///"):
                    documentation += line
                else:
                    match = EXPORT_PATTERN.match(line)
                    if match:
                        return_type = match.group(1)
                        function_name = match.group(2)
                        args_string = match.group(3)

                        arg_types = []
                        arg_names = []

                        if args_string:
                            args_split = args_string.split(", ")
                            args_list = [tuple(arg.split(" ", 1)) for arg in args_split]

                            for arg_type, arg_name in args_list:
                                arg_types.append(TYPE_MAP[arg_type])
                                arg_names.append(arg_name)

                        functions.append(
                            {
                                "$GMExtensionFunction": "",
                                "%Name": function_name,
                                "argCount": 0,
                                "args": arg_types,
                                "documentation": documentation.rstrip(),
                                "externalName": function_name,
                                "help": f"{function_name}({', '.join(arg_names)})",
                                "hidden": False,
                                "kind": 4,
                                "name": function_name,
                                "resourceType": "GMExtensionFunction",
                                "resourceVersion": "2.0",
                                "returnType": TYPE_MAP[return_type],
                            }
                        )

                    documentation = ""

    functions = sorted(functions, key=lambda entry: entry["name"])

    # ==========================================================================
    # Inject
    # ==========================================================================
    with open(yy_file_path, "r") as yy_file:
        yy_data = json5.load(yy_file)

    for file_entry in yy_data["files"]:
        if file_entry["filename"] == extension_filename:
            file_entry["functions"] = functions

    # print(json5.dumps(yy_data, quote_keys=True, indent=2))

    with open(yy_file_path, "w") as yy_file:
        json5.dump(yy_data, yy_file, quote_keys=True, indent=2)

    print("...done")
