# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

## General:
* Prefixed all private API with `__` (two underscores) to "hide" it from autocomplete.

## Core module:
* Renamed sprite `BBMOD_SprCheckerboard` to `BBMOD_SprDefaultBaseOpacity`.

## DLL module:
* Added new macro `BBMOD_DLL_IS_SUPPORTED`, which evalutes to `true` if BBMOD DLL is supported on the current platform.
* Added new macro `BBMOD_DLL_PATH`, which is the path to the BBMOD dynamic library.
* Removed optional argument `_path` from `BBMOD_DLL`'s constructor. The new `BBMOD_DLL_PATH` is now always used instead!
* The read-only property `Path` of `BBMOD_DLL` is now obsolete.

## Raycast module:
* Added missing method `Reset` to `BBMOD_RaycastResult`, which resets its properties to their default values.
