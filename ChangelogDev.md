# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

## General:
* Prefixed all private API with `__` (two underscores) to "hide" it from autocomplete.

## Core module:
* Moved in structs `BBMOD_BaseCamera` and `BBMOD_Camera` from the Camera module.
* Moved in enum `BBMOD_ECubeSide` and struct `BBMOD_Cubemap` from the Rendering/Cubemap submodule.
* Moved in struct `BBMOD_Renderer` from the Rendering/Renderer submodule.
* Added new struct `BBMOD_BaseRenderer`, which is a base struct for renderers.
* Added new struct `BBMOD_DefaultRenderer`, which inherits from `BBMOD_BaseRenderer` and implements the same functionality as `BBMOD_Renderer` did.
* **Struct `BBMOD_Renderer` now inherits from the new `BBMOD_DefaultRenderer` and is marked as deprecated! Please use `BBMOD_DefaultRenderer` instead.**
* Moved in struct `BBMOD_MeshBuilder` from the Mesh builder module.
* Moved in struct `BBMOD_Importer` from the Importer module.
* Moved in structs `BBMOD_LightmapMaterial` and `BBMOD_LightmapShader` from the Lightmap module.
* Added new structs `BBMOD_DefaultLightmapMaterial` and `BBMOD_DefaultLightmapShader`, which implement the same functionality as `BBMOD_LightmapMaterial` and `BBMOD_LightmapShader` did respectively.
* **Struct `BBMOD_LightmapMaterial` now inherits from the new `BBMOD_DefaultLightmapMaterial` and is marked as deprecated! Please use `BBMOD_DefaultLightmapMaterial` instead.**
* **Struct `BBMOD_LightmapShader` now inherits from the new `BBMOD_DefaultLightmapShader` and is marked as deprecated! Please use `BBMOD_DefaultLightmapShader` instead.**
* Moved in macros `BBMOD_VFORMAT_LIGHTMAP`, `BBMOD_SHADER_LIGHTMAP`, `BBMOD_SHADER_LIGHTMAP_DEPTH` and `BBMOD_MATERIAL_LIGHTMAP` from the Lightmap module.
* Added new macro `BBMOD_VFORMAT_DEFAULT_LIGHTMAP`, which is a vertex format of lightmapped models with two UV channels.
* **Macro `BBMOD_VFORMAT_LIGHTMAP` is now deprecated! Please use the new `BBMOD_VFORMAT_DEFAULT_LIGHTMAP` instead.**
* Added new macro `BBMOD_SHADER_DEFAULT_LIGHTMAP`, which is a shader for rendering lightmapped models with two UV channels.
* **Macro `BBMOD_SHADER_LIGHTMAP` is now deprecated! Please use the new `BBMOD_SHADER_DEFAULT_LIGHTMAP` instead.**
* Added new macro `BBMOD_SHADER_DEFAULT_DEPTH_LIGHTMAP`, which is a depth shader for lightmapped models with two UV channels.
* **Macro `BBMOD_SHADER_LIGHTMAP_DEPTH` is now deprecated! Please use the new `BBMOD_SHADER_DEFAULT_DEPTH_LIGHTMAP` instead.**
* Moved in functions `bbmod_lightmap_get` and `bbmod_lightmap_set` from the Lightmap module.
* **Renamed shader `BBMOD_ShLightmap` to `BBMOD_ShDefaultLightmap`!**
* **Renamed shader `BBMOD_ShLightmapDepth` to `BBMOD_ShDefaultDepthLightmap`!**
* Moved in macros `BBMOD_SHADER_DEPTH`, `BBMOD_SHADER_DEPTH_ANIMATED` and `BBMOD_SHADER_DEPTH_BATCHED` from the Rendering/Depth buffer submodule.
* Added new macros `BBMOD_SHADER_DEFAULT_DEPTH`, `BBMOD_SHADER_DEFAULT_DEPTH_ANIMATED` and `BBMOD_SHADER_DEFAULT_DEPTH_BATCHED`, which are shaders for rendering model depth.
* **Macros `BBMOD_SHADER_DEPTH`, `BBMOD_SHADER_DEPTH_ANIMATED` and `BBMOD_SHADER_DEPTH_BATCHED` are now deprecated. Please use the new `BBMOD_SHADER_DEFAULT_DEPTH`, `BBMOD_SHADER_DEFAULT_DEPTH_ANIMATED` and `BBMOD_SHADER_DEFAULT_DEPTH_BATCHED` respectively instead.**
* **Renamed shaders `BBMOD_ShDepth`, `BBMOD_ShDepthAnimated` and `BBMOD_ShDepthBatched` to `BBMOD_ShDefaultDepth`, `BBMOD_ShDefaultDepthAnimated` and `BBMOD_ShDefaultDepthBatched` respectively!**
* Moved in macros `BBMOD_VFORMAT_SPRITE`, `BBMOD_SHADER_SPRITE` and `BBMOD_MATERIAL_SPRITE` from the 2D module.
* Added new macro `BBMOD_VFORMAT_DEFAULT_SPRITE`, which is a vertex format of 2D sprites.
* **Macro `BBMOD_VFORMAT_SPRITE` is now deprecated! Please use the new `BBMOD_VFORMAT_DEFAULT_SPRITE` instead.**
* Added new macro `BBMOD_SHADER_DEFAULT_SPRITE`, which is a shader for 2D sprites.
* **Macro `BBMOD_SHADER_SPRITE` is now deprecated! Please use the new `BBMOD_SHADER_DEFAULT_SPRITE` instead.**
* Added new macro `BBMOD_MATERIAL_DEFAULT_SPRITE`, which is a material for 2D sprites.
* **Macro `BBMOD_MATERIAL_SPRITE` is now deprecated! Please use the new `BBMOD_MATERIAL_DEFAULT_SPRITE` instead.**
* **Renamed shader `BBMOD_ShSprite` to `BBMOD_ShDefaultSprite`!**
* **Renamed sprite `BBMOD_SprCheckerboard` to `BBMOD_SprDefaultBaseOpacity`!**
* **Removed variable `global.bbmod_render_queues`, which was obsolete!**
* Struct `BBMOD_Shader` now inherits from `BBMOD_Class`.

## 2D module:
* **Removed the 2D module, as all its contents were moved to the Core module!**

## Camera module:
* **Removed the Camera module, as all its contents were moved to the Core module.**

## DLL module:
* Added new macro `BBMOD_DLL_IS_SUPPORTED`, which evalutes to `true` if BBMOD DLL is supported on the current platform.
* Added new macro `BBMOD_DLL_PATH`, which is the path to the BBMOD dynamic library.
* **Removed optional argument `_path` from `BBMOD_DLL`'s constructor. The new `BBMOD_DLL_PATH` is now always used instead!**
* The read-only property `Path` of `BBMOD_DLL` is now obsolete.

## Gizmo module:
* Moved in macro `BBMOD_SHADER_LIGHTMAP_INSTANCE_ID` from to Lightmap module.
* Added new macro `BBMOD_SHADER_INSTANCE_ID_LIGHTMAP`, which is a shader used when rendering instance IDs for lightmapped models.
* **Macro `BBMOD_SHADER_LIGHTMAP_INSTANCE_ID` is now deprecated! Please use the new `BBMOD_SHADER_INSTANCE_ID_LIGHTMAP` instead.**
* **Renamed shader `BBMOD_ShLightmapInstanceID` to `BBMOD_ShInstanceIDLightmap`!**

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
* **Removed the PBR submodule, since it was deprecated!**

### Renderer submodule:
* **Removed the Renderer submodule, as all its contents were moved to the Core module!**

## Resource manager module:
* **Removed the Resource manager module, as all its contents were moved to the Core module!**
