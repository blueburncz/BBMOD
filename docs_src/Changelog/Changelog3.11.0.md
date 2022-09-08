# Changelog 3.11.0
This release adds macOS support to BBMOD CLI (command line tool) and BBMOD DLL (dynamic library).

## CLI:
* BBMOD CLI is now also available on macOS. Previously only Windows was supported.

## GML API:
### Core module:
* Added method `set_material_index` to `BBMOD_BaseShader`, using which you can set the `bbmod_MaterialIndex` uniform.
* Added optional argument `_materialIndex` to methods `draw_mesh` and `draw_mesh_animated` of `BBMOD_RenderQueue`, which is the index of the current material.

### DLL module:
* DLL module now works also on macOS. Previously only Windows was supported.
* Default value of `_path` argument in `BBMOD_DLL`'s constructor now changes based on the platform.
