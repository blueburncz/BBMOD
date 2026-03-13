#!/usr/bin/env python3
"""
Script to ensure all BBMOD GML scripts have correct @module tags based on their IDE folder structure.

Rules:
1. Only process scripts in folders/BBMOD/
2. For Extras subfolder: use "Extras.SubfolderName" (two levels deep)
3. For everything else: use the main folder name (one level deep, e.g., "Core", "Physics")
4. Strip number prefixes from folder names (e.g., "1_Core" -> "Core")
"""

import os
import re
import json

def get_module_from_path(folder_path):
    """
    Extract the module name from a GameMaker folder path.

    Args:
        folder_path: Path like "folders/BBMOD/1_Core/Utils.yy"

    Returns:
        Module name like "Core" or "Extras.LayeredAnimationPlayer", or None if not in BBMOD folder
    """
    if not folder_path.startswith("folders/BBMOD/"):
        return None

    # Remove "folders/BBMOD/" prefix
    path_after_bbmod = folder_path[len("folders/BBMOD/"):]

    # Split into parts
    parts = path_after_bbmod.split("/")

    if not parts:
        return None

    # Remove number prefixes and .yy extension
    def clean_name(name):
        # Remove .yy extension
        name = name.replace(".yy", "")
        # Remove number prefix (e.g., "1_Core" -> "Core")
        name = re.sub(r'^\d+_', '', name)
        return name

    first_level = clean_name(parts[0])

    # Special handling for Extras - use two levels
    if first_level == "Extras" and len(parts) > 1:
        second_level = clean_name(parts[1])
        return f"Extras.{second_level}"

    # For everything else, use just the first level
    return first_level

def get_or_update_module_tag(gml_file, module_name):
    """
    Read a GML file and ensure it has the correct @module tag.

    Args:
        gml_file: Path to the .gml file
        module_name: The module name to set

    Returns:
        True if file was modified, False otherwise
    """
    if not os.path.exists(gml_file):
        return False

    with open(gml_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Check if file already has the correct @module tag
    correct_tag = f"/// @module {module_name}\n"

    # Find existing @module tag
    module_match = re.search(r'^/// @module (.+)$', content, re.MULTILINE)

    if module_match:
        existing_module = module_match.group(1)
        if existing_module == module_name:
            # Already correct
            return False

        # Replace existing module tag
        new_content = re.sub(
            r'^/// @module .+$',
            f'/// @module {module_name}',
            content,
            count=1,
            flags=re.MULTILINE
        )
    else:
        # No @module tag found, add it at the top
        new_content = f"/// @module {module_name}\n\n{content}"

    # Write back
    with open(gml_file, 'w', encoding='utf-8') as f:
        f.write(new_content)

    return True

def process_scripts(scripts_dir):
    """
    Process all scripts in the scripts directory.

    Args:
        scripts_dir: Path to BBMOD_GML/scripts directory
    """
    modified_count = 0
    skipped_count = 0
    error_count = 0

    # Iterate through all script directories
    for script_name in os.listdir(scripts_dir):
        script_dir = os.path.join(scripts_dir, script_name)

        if not os.path.isdir(script_dir):
            continue

        # Look for .yy and .gml files
        yy_file = os.path.join(script_dir, f"{script_name}.yy")
        gml_file = os.path.join(script_dir, f"{script_name}.gml")

        if not os.path.exists(yy_file):
            continue

        if not os.path.exists(gml_file):
            # Some scripts might not have a .gml file (just .yy)
            continue

        try:
            # Read the .yy file to get the folder path
            with open(yy_file, 'r', encoding='utf-8') as f:
                yy_content = f.read()

            # Parse JSON (GameMaker uses JSON with trailing commas, which is non-standard)
            # So we'll use regex to extract the path
            path_match = re.search(r'"path"\s*:\s*"([^"]+)"', yy_content)

            if not path_match:
                error_count += 1
                print(f"ERROR: Could not find path in {yy_file}")
                continue

            folder_path = path_match.group(1)
            module_name = get_module_from_path(folder_path)

            if module_name is None:
                # Not in BBMOD folder, skip
                skipped_count += 1
                continue

            # Update the .gml file
            was_modified = get_or_update_module_tag(gml_file, module_name)

            if was_modified:
                modified_count += 1
                print(f"Updated {script_name}.gml -> @module {module_name}")

        except Exception as e:
            error_count += 1
            print(f"ERROR processing {script_name}: {e}")

    print(f"\nSummary:")
    print(f"  Modified: {modified_count}")
    print(f"  Skipped (not in BBMOD folder): {skipped_count}")
    print(f"  Errors: {error_count}")

if __name__ == "__main__":
    scripts_dir = os.path.join(os.path.dirname(__file__), "BBMOD_GML", "scripts")

    if not os.path.exists(scripts_dir):
        print(f"ERROR: Scripts directory not found: {scripts_dir}")
        exit(1)

    print(f"Processing scripts in: {scripts_dir}\n")
    process_scripts(scripts_dir)
