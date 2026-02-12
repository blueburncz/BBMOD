# Changelog 3.99.0

> This file is used to accumulate changes until 3.99.0 is released.

## Changelog 3.99.0-alpha1

### Asset pipeline

* Updated Assimp to [v6.0.2](https://github.com/assimp/assimp/releases/tag/v6.0.2).
* Added new option `-lf|--log-file=true|false` to BBMOD CLI, using which you can enable/disable creating a `_log.txt` file for converted models. Defaults to `true` (log file is enabled).
* Added new extension `BBMOD` to the *Core* module, which handles automatic shader includes and model conversion. **Requires Python3!**

### Resource management

* Added new method `remove(_resourceOrPath)` to `BBMOD_ResourceManager`, which removes a resource from the manager, keeping its reference count.
* Added new method `load_sync(_path[, _sha1])`, which synchronously loads a resource from a file or retrieves a reference to it, if it is already loaded.
* Added new method `load_async(_path[, _sha1[, _onLoad]])`, which asynchronously loads a resource from a file or retrieves a reference to it, if it is already loaded.
* Method `load` of `BBMOD_ResourceManager` is now **deprecated**! Please use method `BBMOD_ResourceManager.load_async` instead.
* Method `import` of `BBMOD_OBJImporter` now uses `BBMOD_ResourceManager.load_sync` instead of `load`.

### Animation playback

* Added new struct `BBMOD_LayeredAnimationPlayer`, which is an animation player with support for multiple layers, blending and masking. Compatible
only with animations with optimization level 0!
* Added new struct `BBMOD_AnimationLayer`, which is a single layer of a layered animation player. Each layer plays its own animation and can affect a selected portion of the skeleton. Individual layers can be mixed or additively blended together.
* Added new struct `BBMOD_SkeletonMask`, which is a struct that defines which nodes of a model are affected by an animation layer.
* Added new property `PlaybackSpeed` to `BBMOD_Animation`, which is used to play the animation at a faster/slower rate.
* Property `PlaybackSpeed` of `BBMOD_AnimationPlayer` no longer needs to be a positive value - reverse animation playback is now supported!

### Rendering

* Fixed rendering of gizmo on the screen when there are instances selected.
* Fixed SSAO sampling kernel not scaling with depth. You will need to increase `SSAORadius` to get the same look as before!
* Fixed energy conservation between diffuse and specular lighting in PBR shaders.
* Fixed shader compatibility with GMRT.

* Added new struct `BBMOD_Scene`, which stores scene settings like lights, reflection probes and fog.
* Added new function `bbmod_scene_get_default()`, which retrieves the default scene.
* Added new function `bbmod_scene_get_current()`, which retrieves the current scene.
* Added new function `bbmod_scene_set_current(_scene)`, which changes the current scene.

* Function `bbmod_fog_set` is now **deprecated**! Please use properties `BBMOD_Scene.FogColor`, `BBMOD_Scene.FogIntensity`, `BBMOD_Scene.FogStart` and `BBMOD_Scene.FogEnd` instead.
* Function `bbmod_fog_get_color` is now **deprecated**! Please use property `BBMOD_Scene.FogColor` instead.
* Function `bbmod_fog_set_color` is now **deprecated**! Please use property `BBMOD_Scene.FogColor` instead.
* Function `bbmod_fog_get_intensity` is now **deprecated**! Please use property `BBMOD_Scene.FogIntensity` instead.
* Function `bbmod_fog_set_intensity` is now **deprecated**! Please use property `BBMOD_Scene.FogIntensity` instead.
* Function `bbmod_fog_get_start` is now **deprecated**! Please use property `BBMOD_Scene.FogStart` instead.
* Function `bbmod_fog_set_start` is now **deprecated**! Please use property `BBMOD_Scene.FogStart` instead.
* Function `bbmod_fog_get_end` is now **deprecated**! Please use property `BBMOD_Scene.FogEnd` instead.
* Function `bbmod_fog_set_end` is now **deprecated**! Please use property `BBMOD_Scene.FogEnd` instead.
* Function `bbmod_light_ambient_set_dir` is now **deprecated**! Please use property `BBMOD_Scene.AmbientLightDirection` instead.
* Function `bbmod_light_ambient_get_dir` is now **deprecated**! Please use property `BBMOD_Scene.AmbientLightDirection` instead.
* Function `bbmod_light_ambient_set` is now **deprecated**! Please use properties `BBMOD_Scene.AmbientLightColorUp` and `BBMOD_Scene.AmbientLightColorDown` instead.
* Function `bbmod_light_ambient_get_up` is now **deprecated**! Please use property `BBMOD_Scene.AmbientLightColorUp` instead.
* Function `bbmod_light_ambient_set_up` is now **deprecated**! Please use property `BBMOD_Scene.AmbientLightColorUp` instead.
* Function `bbmod_light_ambient_get_down` is now **deprecated**! Please use property `BBMOD_Scene.AmbientLightColorDown` instead.
* Function `bbmod_light_ambient_set_down` is now **deprecated**! Please use property `BBMOD_Scene.AmbientLightColorDown` instead.
* Function `bbmod_light_ambient_get_affect_lightmaps` is now **deprecated**! Please use property `BBMOD_Scene.AmbientLightAffectLightmaps` instead.
* Function `bbmod_light_ambient_set_affect_lightmaps` is now **deprecated**! Please use property `BBMOD_Scene.AmbientLightAffectLightmaps` instead.
* Function `bbmod_light_directional_get` is now **deprecated**! Please use property `BBMOD_Scene.LightDirectional` instead.
* Function `bbmod_light_directional_set` is now **deprecated**! Please use property `BBMOD_Scene.LightDirectional` instead.
* Function `bbmod_light_punctual_add` is now **deprecated**! Please use method `BBMOD_Scene.add_punctual_light` instead.
* Function `bbmod_light_punctual_count` is now **deprecated**! Please use method `BBMOD_Scene.get_punctual_light_count` instead.
* Function `bbmod_light_punctual_get` is now **deprecated**! Please use method `BBMOD_Scene.get_punctual_light` instead.
* Function `bbmod_light_punctual_remove` is now **deprecated**! Please use method `BBMOD_Scene.remove_punctual_light` instead.
* Function `bbmod_light_punctual_remove_index` is now **deprecated**! Please use method `BBMOD_Scene.remove_punctual_light_index` instead.
* Function `bbmod_light_punctual_clear` is now **deprecated**! Please use method `BBMOD_Scene.clear_punctual_lights` instead.
* Function `bbmod_ibl_get` is now **deprecated**! Please use property `BBMOD_Scene.ImageBasedLight` instead.
* Function `bbmod_ibl_get` is now **deprecated**! Please use property `BBMOD_Scene.ImageBasedLight` instead.
* Function `bbmod_reflection_probe_add` is now **deprecated**! Please use method `BBMOD_Scene.add_reflection_probe` instead.
* Function `bbmod_reflection_probe_count` is now **deprecated**! Please use method `BBMOD_Scene.get_reflection_probe_count` instead.
* Function `bbmod_reflection_probe_get` is now **deprecated**! Please use method `BBMOD_Scene.get_reflection_probe` instead.
* Function `bbmod_reflection_probe_find` is now **deprecated**! Please use method `BBMOD_Scene.find_reflection_probe` instead.
* Function `bbmod_reflection_probe_remove` is now **deprecated**! Please use method `BBMOD_Scene.remove_reflection_probe` instead.
* Function `bbmod_reflection_probe_remove_index` is now **deprecated**! Please use method `BBMOD_Scene.remove_reflection_probe_index` instead.
* Function `bbmod_reflection_probe_clear` is now **deprecated**! Please use method `BBMOD_Scene.clear_reflection_probes` instead.
* Function `bbmod_lightmap_get` is now **deprecated**! Please use property `BBMOD_Scene.Lightmap` instead.
* Function `bbmod_lightmap_set` is now **deprecated**! Please use property `BBMOD_Scene.Lightmap` instead.

* **Moved** all contents of the *Rendering.SSAO* module to the *Core* module.

* **Moved** all contents of the *Rendering.Sky* module into a new module called *RGBMSky*.
* **Replaced** macro `BBMOD_MATERIAL_SKY` with a new one called `BBMOD_MATERIAL_SKY_RGBM`. The old one is kept for backwards compatibility, but is now **deprecated**!

* **Removed** module *Rendering*, as it become empty.

* Added new module *D3D11* and extension `BBMOD_D3D11`. Use function `bbmod_d3d11_init()` to initialize the extension. This is for **Windows only!**
* Added new module *VTF* for vertex texture fetching techniques. Moved functions `bbmod_vtf_is_supported` and `bbmod_texture_set_stage_vs` from *Core* into it.

### ColMesh

* Fixed function `bbmod_model_to_colmesh` ignoring node transforms when adding individual meshes to a ColMesh.
* Added functions `bbmod_mesh_to_colmesh2(_mesh, _colmesh[, _transform])` and `bbmod_model_to_colmesh(_model, _colmesh[, _transform])`, which can be used to add a `BBMOD_Mesh` or a `BBMOD_Model` into a ColMesh v2.
* ColMesh2 (commit `ba0c4facb193b04dc1ee0bc3ccff131c9eee120a`) is now included in the BBMOD package.

### Miscellaneous

* Added new function `bbmod_wrap_value(_value, _rangeMax)`, which wraps given value to range 0..max-1.
* Added new function `bbmod_get_scratch_buffer(_sizeMin)`, which returns a buffer that can be used for temporary storage. The buffer will be resized if the current size is smaller than the specified minimum size. The buffer is shared across all calls to this function, so it should not be used for long-term storage or in situations where multiple buffers are needed simultaneously.

* **Moved** enum `BBMOD_EPropertyType` and struct `BBMOD_Property` from the *Core* module into the *Save* module.

* **Moved** structs `BBMOD_Importer`, `BBMOD_MeshBuilder` and `BBMOD_Vertex` from the *Core* module into the *OBJImporter* module.

* Added new method `get_node_array()` to `BBMOD_Model`, which returns an array of all nodes of the model.
* Methods `get_material` and `set_material` of struct `BBMOD_Model` can now also accept the material index instead of the name of the slot.

* Using GameMaker's new function `matrix_inverse` in method `InverseSelf` of struct `BBMOD_Matrix` for better performance.
* Added new method `ToEuler` to `BBMOD_Quaternion`, which retrieves euler angles from the quaternion.

## WIP

> This section is for things that aren't finished and won't be released yet.

* Added new module *Physics*.
