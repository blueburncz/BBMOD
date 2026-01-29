import json5
import os
import re

EXTENSIONS = [
    (
        "BBMOD_CPP/src/Physics",
        "BBMOD_GML/extensions/BBMOD_Physics/BBMOD_Physics.yy",
        "BBMOD_Physics.ext",
    ),
    (
        "BBMOD_CPP/src/D3D11",
        "BBMOD_GML/extensions/BBMOD_D3D11/BBMOD_D3D11.yy",
        "BBMOD_D3D11.ext",
    ),
]

TYPE_MAP = {
    "char*": 1,
    "double": 2,
}

for src_dir, yy_path, ext_name in EXTENSIONS:
    # ==========================================================================
    # Parse exports
    # ==========================================================================
    functions = []

    for fname in os.listdir(src_dir):
        if not fname.startswith("exports"):
            continue
        fpath = os.path.join(src_dir, fname)
        with open(fpath, "r") as f:
            docs = ""
            for line in f.readlines():
                if line.startswith("///"):
                    docs += line
                else:
                    m = re.match(r"GM_EXPORT (double|char\*) (\w+)\(([^)]*)\)", line)
                    if m:
                        rtype = m.group(1)
                        name = m.group(2)
                        args_str = m.group(3)
                        arg_types = []
                        arg_names = []
                        if args_str != "":
                            args_split = args_str.split(", ")
                            args_list = [tuple(a.split(" ", 1)) for a in args_split]
                            for atype, aname in args_list:
                                arg_types.append(TYPE_MAP[atype])
                                arg_names.append(aname)

                        functions.append(
                            {
                                "$GMExtensionFunction": "",
                                "%Name": name,
                                "argCount": 0,
                                "args": arg_types,
                                "documentation": docs.rstrip(),
                                "externalName": name,
                                "help": f"{name}({', '.join(arg_names)})",
                                "hidden": False,
                                "kind": 4,
                                "name": name,
                                "resourceType": "GMExtensionFunction",
                                "resourceVersion": "2.0",
                                "returnType": TYPE_MAP[rtype],
                            }
                        )

                    docs = ""

    functions = sorted(functions, key=lambda d: d["name"])

    # ==========================================================================
    # Inject
    # ==========================================================================
    with open(yy_path, "r") as f:
        yy_new = json5.load(f)

    for f in yy_new["files"]:
        if f["filename"] == ext_name:
            f["functions"] = functions

    # print(json5.dumps(yy_new, quote_keys=True, indent=2))

    with open(yy_path, "w") as f:
        json5.dump(yy_new, f, quote_keys=True, indent=2)
