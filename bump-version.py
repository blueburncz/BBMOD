#!/usr/bin/env python3
import argparse
import os
import re
import subprocess
import sys
from typing import Iterable


VERSION_RE = re.compile(r"^(\d+)\.(\d+)\.(\d+)$")
DEFINES_REL_PATH = os.path.join(
    "BBMOD_GML", "scripts", "__bbmod_defines", "__bbmod_defines.gml"
)


def parse_version(version: str) -> tuple[int, int, int]:
    match = VERSION_RE.match(version)
    if not match:
        raise ValueError(
            f"Invalid version '{version}'. Expected 'major.minor.patch' (for example 3.23.1)."
        )
    return tuple(int(part) for part in match.groups())


def get_repo_files(repo_root: str) -> list[str]:
    try:
        result = subprocess.run(
            ["git", "ls-files"],
            cwd=repo_root,
            check=True,
            capture_output=True,
            text=True,
        )
        return [line for line in result.stdout.splitlines() if line.strip()]
    except Exception:
        files: list[str] = []
        for dirpath, _, filenames in os.walk(repo_root):
            if ".git" in dirpath.split(os.sep):
                continue
            for filename in filenames:
                files.append(os.path.relpath(os.path.join(dirpath, filename), repo_root))
        return files


def read_bytes(path: str) -> bytes:
    with open(path, "rb") as handle:
        return handle.read()


def write_bytes(path: str, data: bytes) -> None:
    with open(path, "wb") as handle:
        handle.write(data)


def update_release_macros(content: bytes, new_parts: tuple[int, int, int]) -> tuple[bytes, int]:
    updated = content
    replacements = 0
    values_by_name = {
        "MAJOR": str(new_parts[0]).encode("ascii"),
        "MINOR": str(new_parts[1]).encode("ascii"),
        "PATCH": str(new_parts[2]).encode("ascii"),
    }
    macro_names = ["MAJOR", "MINOR", "PATCH"]

    for name in macro_names:
        pattern = re.compile(
            rb"(^\s*#macro\s+BBMOD_RELEASE_" + name.encode("ascii") + rb"\s+)\d+",
            re.MULTILINE,
        )

        def _replace(match: re.Match[bytes]) -> bytes:
            return match.group(1) + values_by_name[name]

        updated, count = pattern.subn(_replace, updated, count=1)
        replacements += count

    return updated, replacements


def replace_version_occurrences(
    repo_root: str,
    files: Iterable[str],
    old_version: str,
    new_version: str,
    defines_rel_path: str,
    dry_run: bool,
) -> tuple[list[str], int, int]:
    old_bytes = old_version.encode("utf-8")
    new_bytes = new_version.encode("utf-8")
    changed_files: list[str] = []
    version_replacements = 0
    macro_replacements = 0

    for rel_path in files:
        abs_path = os.path.join(repo_root, rel_path)

        if not os.path.isfile(abs_path):
            continue

        original = read_bytes(abs_path)

        # Skip binary files to avoid corrupting assets.
        if b"\x00" in original:
            continue

        updated = original
        old_count = updated.count(old_bytes)
        if old_count:
            updated = updated.replace(old_bytes, new_bytes)
            version_replacements += old_count

        if os.path.normpath(rel_path) == os.path.normpath(defines_rel_path):
            updated, macro_count = update_release_macros(updated, parse_version(new_version))
            macro_replacements += macro_count

        if updated != original:
            changed_files.append(rel_path)
            if not dry_run:
                write_bytes(abs_path, updated)

    return changed_files, version_replacements, macro_replacements


def get_version_from_defines(defines_path: str) -> str:
    content = read_bytes(defines_path)
    patterns = {
        "major": re.compile(rb"^\s*#macro\s+BBMOD_RELEASE_MAJOR\s+(\d+)", re.MULTILINE),
        "minor": re.compile(rb"^\s*#macro\s+BBMOD_RELEASE_MINOR\s+(\d+)", re.MULTILINE),
        "patch": re.compile(rb"^\s*#macro\s+BBMOD_RELEASE_PATCH\s+(\d+)", re.MULTILINE),
    }

    values: dict[str, int] = {}
    for key, pattern in patterns.items():
        match = pattern.search(content)
        if not match:
            raise RuntimeError(
                "Could not read release version macros from " + os.path.relpath(defines_path)
            )
        values[key] = int(match.group(1))

    return f"{values['major']}.{values['minor']}.{values['patch']}"


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Bump BBMOD version strings across tracked files and update "
            "BBMOD_RELEASE_MAJOR/MINOR/PATCH macros."
        )
    )
    parser.add_argument(
        "new_version",
        help="New version in major.minor.patch format (for example 3.23.1).",
    )
    parser.add_argument(
        "old_version",
        nargs="?",
        help=(
            "Old version in major.minor.patch format. "
            "If omitted, it is read from __bbmod_defines.gml macros."
        ),
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would change without writing files.",
    )

    args = parser.parse_args()

    try:
        parse_version(args.new_version)
    except ValueError as error:
        print(f"ERROR: {error}")
        return 1

    repo_root = os.path.dirname(os.path.abspath(__file__))
    defines_path = os.path.join(repo_root, DEFINES_REL_PATH)

    if not os.path.isfile(defines_path):
        print(f"ERROR: Defines file not found: {DEFINES_REL_PATH}")
        return 1

    old_version = args.old_version
    if old_version is None:
        try:
            old_version = get_version_from_defines(defines_path)
        except RuntimeError as error:
            print(f"ERROR: {error}")
            return 1
    else:
        try:
            parse_version(old_version)
        except ValueError as error:
            print(f"ERROR: {error}")
            return 1

    if old_version == args.new_version:
        print("No changes needed: old and new versions are identical.")
        return 0

    files = get_repo_files(repo_root)
    changed_files, version_replacements, macro_replacements = replace_version_occurrences(
        repo_root=repo_root,
        files=files,
        old_version=old_version,
        new_version=args.new_version,
        defines_rel_path=DEFINES_REL_PATH,
        dry_run=args.dry_run,
    )

    action = "Would update" if args.dry_run else "Updated"
    print(f"{action} {len(changed_files)} file(s).")
    print(f"Version string replacements: {version_replacements}")
    print(f"Release macro replacements: {macro_replacements}")

    for rel_path in changed_files:
        print(f" - {rel_path}")

    if not changed_files:
        print(
            "No files changed. If needed, pass an explicit old version: "
            f"python bump-version.py {args.new_version} <old_version>"
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())