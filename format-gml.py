#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import jsbeautifier
import json
import os
import re
import subprocess
import sys

VERSION_MAJOR = 1
VERSION_MINOR = 0
VERSION_PATCH = 1
VERSION_STRING = f"{VERSION_MAJOR}.{VERSION_MINOR}.{VERSION_PATCH}"

HELP_MESSAGE = """
Usage: format-gml [-h, -v, --validate, --staged, --all, --file FILE]

Arguments:
    -h         - Show this help message and exit.
    -v         - Show version and exit.
    --validate - Check whether all staged GML files are properly formatted and exit with status 0 on success or 1 on fail.
    --staged   - Format all staged GML files. This is the default option.
    --all      - Format all GML files in the repo.
    --file     - Format only given file.
"""[
    1:
]

OPTIONS_PATH = "./.jsbeautifyrc"

if os.path.exists(OPTIONS_PATH):
    with open(OPTIONS_PATH, "r") as f:
        OPTIONS = json.load(f)
else:
    OPTIONS = None


def beautify_file(filepath):
    res = jsbeautifier.beautify_file(filepath, OPTIONS)
    res = re.sub(r"\$[\s\n]+\"", '$"', res)
    res = re.sub(r"\@[\s\n]+\"", '@"', res)
    res = re.sub(r"\[[\s\n]+\@", '[@ ', res)
    res = re.sub(r"\[[\s\n]+\|", '[| ', res)
    res = re.sub(r"\[[\s\n]+\#", '[# ', res)
    res = re.sub(r"\[[\s\n]+\?", '[? ', res)
    res = re.sub(r"\[[\s\n]*\$", '[$ ', res)
    return res


def get_staged_files():
    # Run the git command
    result = subprocess.run(
        ["git", "diff", "--name-only", "--cached"],
        stdout=subprocess.PIPE,  # Capture output
        stderr=subprocess.PIPE,  # Capture errors
        text=True,
    )  # Return output as string

    # Check if there was an error
    if result.returncode != 0:
        print(f"Error: {result.stderr}")
        return []

    # Get the output (list of file paths)
    staged_files = result.stdout.strip().split("\n")

    # Remove any empty strings (in case no files are staged)
    return [file for file in staged_files if file]


def get_staged_file_contents(file_path):
    try:
        # Run the git show command to get the staged contents
        result = subprocess.run(
            ["git", "show", f":{file_path}"], capture_output=True, text=True, check=True
        )
        return result.stdout  # Return the staged file contents
    except subprocess.CalledProcessError as e:
        print(f"ERROR: {e}")
        exit(1)


if __name__ == "__main__":
    target = "--staged"
    filepath = None

    if len(sys.argv) > 1:
        target = sys.argv[1]

    if target == "--file":
        if len(sys.argv) > 2:
            filepath = sys.argv[2]
        else:
            print("Argument FILE not defined!")
            print(1)

    if target == "-h":
        print(HELP_MESSAGE)
    elif target == "-v":
        print(VERSION_STRING)
    elif target == "--validate":
        for filepath in get_staged_files():
            if filepath.endswith(".gml"):
                orig = get_staged_file_contents(filepath)
                res = beautify_file(filepath)
                if orig != res:
                    print(
                        f'ERROR: File "{filepath}" is not properly formatted!\n\nPlease run ./format-gml.py to fix formatting of all staged GML files and stage the changes before running commit again.'
                    )
                    exit(1)
    elif target == "--staged":
        for filepath in get_staged_files():
            if filepath.endswith(".gml"):
                res = beautify_file(filepath)
                with open(filepath, "w") as f:
                    f.write(res)
    elif target == "--all":
        for dirpath, _, filenames in os.walk("."):
            for filename in filenames:
                if filename.endswith(".gml"):
                    filepath = os.path.join(dirpath, filename)
                    res = beautify_file(filepath)
                    with open(filepath, "w") as f:
                        f.write(res)
    elif target == "--file":
        res = beautify_file(filepath)
        with open(filepath, "w") as f:
            f.write(res)
    else:
        print(f"Invalid target {target}! Run format-gml -h to display usage.")
        exit(1)
