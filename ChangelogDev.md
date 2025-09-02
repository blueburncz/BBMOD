# Changelog dev

> This file is used to accumulate changes before a changelog for a release is created.

* Added new struct `BBMOD_Environment`, which stores environment settings like lights, reflection probes and fog.
* Added new function `bbmod_environment_get_default()`, which retrieves the default environment.
* Added new function `bbmod_environment_get_current()`, which retrieves the current environment.
* Added new function `bbmod_environment_set_current(_env)`, which changes the current environment.

* Added new method `remove(_resourceOrPath)` to `BBMOD_ResourceManager`, which removes a resource from the manager, keeping its reference count.
* Added new method `load_sync(_path[, _sha1])`, which synchronously loads a resource from a file or retrieves a reference to it, if it is already loaded.
* Added new method `load_async(_path[, _sha1[, _onLoad]])`, which asynchronously loads a resource from a file or retrieves a reference to it, if it is already loaded.
* Method `load` of `BBMOD_ResourceManager` is now **deprecated**! Please use method `BBMOD_ResourceManager.load_async` instead.
* Method `import` of `BBMOD_OBJImporter` now uses `BBMOD_ResourceManager.load_sync` instead of `load`.

* Added new method `get_node_array()` to `BBMOD_Model`, which returns an array of all nodes of the model.

* Added new function `bbmod_wrap_value(_value, _rangeMax)`, which wraps given value to range 0..max-1.

* Added new property `PlaybackSpeed` to `BBMOD_Animation`, which is used to play the animation at a faster/slower rate.
* Added new struct `BBMOD_LayeredAnimationPlayer`, which is an animation player with support for multiple layers, blending and masking. Compatible
only with animations with optimization level 0!
* Added new struct `BBMOD_AnimationLayer`, which is a single layer of a layered animation player. Each layer plays its own animation and can affect a selected portion of the skeleton. Individual layers can be mixed or additively blended together.
* Added new struct `BBMOD_SkeletonMask`, which is a struct that defines which nodes of a model are affected by an animation layer.
* Property `PlaybackSpeed` of `BBMOD_AnimationPlayer` no longer needs to be a positive value - reverse animation playback is now supported!

* Using GameMaker's new function `matrix_inverse` in method `InverseSelf` of struct `BBMOD_Matrix`.

* Added new method `ToEuler` to `BBMOD_Quaternion`, which retrieves euler angles from the quaternion.

* Updated Assimp to [v6.0.2](https://github.com/assimp/assimp/releases/tag/v6.0.2).

* Function `bbmod_fog_set` is now **deprecated**! Please use properties `BBMOD_Environment.FogColor`, `BBMOD_Environment.FogIntensity`, `BBMOD_Environment.FogStart` and `BBMOD_Environment.FogEnd` instead.
* Function `bbmod_fog_get_color` is now **deprecated**! Please use property `BBMOD_Environment.FogColor` instead.
* Function `bbmod_fog_set_color` is now **deprecated**! Please use property `BBMOD_Environment.FogColor` instead.
* Function `bbmod_fog_get_intensity` is now **deprecated**! Please use property `BBMOD_Environment.FogIntensity` instead.
* Function `bbmod_fog_set_intensity` is now **deprecated**! Please use property `BBMOD_Environment.FogIntensity` instead.
* Function `bbmod_fog_get_start` is now **deprecated**! Please use property `BBMOD_Environment.FogStart` instead.
* Function `bbmod_fog_set_start` is now **deprecated**! Please use property `BBMOD_Environment.FogStart` instead.
* Function `bbmod_fog_get_end` is now **deprecated**! Please use property `BBMOD_Environment.FogEnd` instead.
* Function `bbmod_fog_set_end` is now **deprecated**! Please use property `BBMOD_Environment.FogEnd` instead.
* Function `bbmod_light_ambient_set_dir` is now **deprecated**! Please use property `BBMOD_Environment.AmbientLightDirection` instead.
* Function `bbmod_light_ambient_get_dir` is now **deprecated**! Please use property `BBMOD_Environment.AmbientLightDirection` instead.
* Function `bbmod_light_ambient_set` is now **deprecated**! Please use properties `BBMOD_Environment.AmbientLightColorUp` and `BBMOD_Environment.AmbientLightColorDown` instead.
* Function `bbmod_light_ambient_get_up` is now **deprecated**! Please use property `BBMOD_Environment.AmbientLightColorUp` instead.
* Function `bbmod_light_ambient_set_up` is now **deprecated**! Please use property `BBMOD_Environment.AmbientLightColorUp` instead.
* Function `bbmod_light_ambient_get_down` is now **deprecated**! Please use property `BBMOD_Environment.AmbientLightColorDown` instead.
* Function `bbmod_light_ambient_set_down` is now **deprecated**! Please use property `BBMOD_Environment.AmbientLightColorDown` instead.
* Function `bbmod_light_ambient_get_affect_lightmaps` is now **deprecated**! Please use property `BBMOD_Environment.AmbientLightAffectLightmaps` instead.
* Function `bbmod_light_ambient_set_affect_lightmaps` is now **deprecated**! Please use property `BBMOD_Environment.AmbientLightAffectLightmaps` instead.
* Function `bbmod_light_directional_get` is now **deprecated**! Please use property `BBMOD_Environment.LightDirectional` instead.
* Function `bbmod_light_directional_set` is now **deprecated**! Please use property `BBMOD_Environment.LightDirectional` instead.
* Function `bbmod_light_punctual_add` is now **deprecated**! Please use method `BBMOD_Environment.add_punctual_light` instead.
* Function `bbmod_light_punctual_count` is now **deprecated**! Please use method `BBMOD_Environment.get_punctual_light_count` instead.
* Function `bbmod_light_punctual_get` is now **deprecated**! Please use method `BBMOD_Environment.get_punctual_light` instead.
* Function `bbmod_light_punctual_remove` is now **deprecated**! Please use method `BBMOD_Environment.remove_punctual_light` instead.
* Function `bbmod_light_punctual_remove_index` is now **deprecated**! Please use method `BBMOD_Environment.remove_punctual_light_index` instead.
* Function `bbmod_light_punctual_clear` is now **deprecated**! Please use method `BBMOD_Environment.clear_punctual_lights` instead.
* Function `bbmod_ibl_get` is now **deprecated**! Please use property `BBMOD_Environment.ImageBasedLight` instead.
* Function `bbmod_ibl_get` is now **deprecated**! Please use property `BBMOD_Environment.ImageBasedLight` instead.
* Function `bbmod_reflection_probe_add` is now **deprecated**! Please use method `BBMOD_Environment.add_reflection_probe` instead.
* Function `bbmod_reflection_probe_count` is now **deprecated**! Please use method `BBMOD_Environment.get_reflection_probe_count` instead.
* Function `bbmod_reflection_probe_get` is now **deprecated**! Please use method `BBMOD_Environment.get_reflection_probe` instead.
* Function `bbmod_reflection_probe_find` is now **deprecated**! Please use method `BBMOD_Environment.find_reflection_probe` instead.
* Function `bbmod_reflection_probe_remove` is now **deprecated**! Please use method `BBMOD_Environment.remove_reflection_probe` instead.
* Function `bbmod_reflection_probe_remove_index` is now **deprecated**! Please use method `BBMOD_Environment.remove_reflection_probe_index` instead.
* Function `bbmod_reflection_probe_clear` is now **deprecated**! Please use method `BBMOD_Environment.clear_reflection_probes` instead.
* Function `bbmod_lightmap_get` is now **deprecated**! Please use property `BBMOD_Environment.Lightmap` instead.
* Function `bbmod_lightmap_set` is now **deprecated**! Please use property `BBMOD_Environment.Lightmap` instead.
