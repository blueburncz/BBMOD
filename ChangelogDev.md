# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

## General:
* Prefixed all private API with `__` (two underscores) to "hide" it from autocomplete.

## Core module:
* Renamed sprite `BBMOD_SprCheckerboard` to `BBMOD_SprDefaultBaseOpacity`.

## Raycast module:
* Added missing method `Reset` to `BBMOD_RaycastResult`, which resets its properties to their default values.
