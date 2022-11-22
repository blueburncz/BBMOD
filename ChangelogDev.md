# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

## General:
* Prefixed all private API with `__` (two underscores) to "hide" it from autocomplete.

## Core module:
* **Renamed sprite `BBMOD_SprCheckerboard` to `BBMOD_SprDefaultBaseOpacity`!**
* Moved in structs `BBMOD_BaseCamera` and `BBMOD_Camera` from the Camera module.
* Moved in enum `BBMOD_ECubeSide` and struct `BBMOD_Cubemap` from the Rendering/Cubemap submodule.
* Moved in struct `BBMOD_Renderer` from the Rendering/Renderer submodule.
* Moved in struct `BBMOD_MeshBuilder` from the Mesh builder module.
* Moved in structs `BBMOD_LightmapMaterial`, `BBMOD_LightmapShader` from the Lightmap module.
* Moved in macros `BBMOD_VFORMAT_LIGHTMAP`, `BBMOD_SHADER_LIGHTMAP`, `BBMOD_SHADER_LIGHTMAP_DEPTH` and `BBMOD_MATERIAL_LIGHTMAP` from the Lightmap module.
* Moved in functions `bbmod_lightmap_get` and `bbmod_lightmap_set` from the Lightmap module.
* Moved in macros `BBMOD_SHADER_DEPTH`, `BBMOD_SHADER_DEPTH_ANIMATED` and `BBMOD_SHADER_DEPTH_BATCHED` from the Rendering/Depth buffer submodule.
* Moved in macros `BBMOD_VFORMAT_SPRITE`, `BBMOD_SHADER_SPRITE` and `BBMOD_MATERIAL_SPRITE` from the 2D module.
* Moved in struct `BBMOD_Importer` from the Importer module.
* Struct `BBMOD_Shader` now inherits from `BBMOD_Class`.
* **Removed variable `global.bbmod_render_queues`, which was obsolete!**

## 2D module:
* **Removed the 2D module, as all its contents were moved to the Core module!**

## Camera module:
* **Removed the Camera module, as all its contents were moved to the Core module.**

## DLL module:
* Added new macro `BBMOD_DLL_IS_SUPPORTED`, which evalutes to `true` if BBMOD DLL is supported on the current platform.
* Added new macro `BBMOD_DLL_PATH`, which is the path to the BBMOD dynamic library.
* Removed optional argument `_path` from `BBMOD_DLL`'s constructor. The new `BBMOD_DLL_PATH` is now always used instead!
* The read-only property `Path` of `BBMOD_DLL` is now obsolete.

## Gizmo module:
* Moved in macro `BBMOD_SHADER_LIGHTMAP_INSTANCE_ID` from to Lightmap module.
* Added new macro `BBMOD_SHADER_INSTANCE_ID_LIGHTMAP`, which is a shader used when rendering instance IDs for lightmapped models.
* Macro `BBMOD_SHADER_LIGHTMAP_INSTANCE_ID` is now obsolete, please use the new `BBMOD_SHADER_INSTANCE_ID_LIGHTMAP` instead.

## Imported module:
* **Renamed the Importer module to "OBJ importer", as it now contains only struct `BBMOD_OBJImporter`!**

## Lightmap module:
* **Removed the Lightmap module, as its contents were split between the Core module and the Gizmo module!**

## Mesh builder module:
* **Removed the Mesh builder module, as all its contents were moved to the Core module!**

## Raycast module:
* Added missing method `Reset` to `BBMOD_RaycastResult`, which resets its properties to their default values.

## Rendering module:
### Cubemap submodule:
* **Removed the Cubemap submodule, as all its contents were moved to the Core module!**

### Depth buffer submodule:
* **Removed the Depth buffer submodule, as all its contents were moved to the Core module!**

### PBR submodule:
* **Removed the PBR submodule, since it was obsolete!**

### Renderer submodule:
* **Removed the Renderer submodule, as all its contents were moved to the Core module!**

## Resource manager module:
* **Removed the Resource manager module, as all its contents were moved to the Core module!**
