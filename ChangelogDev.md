# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Added new struct `BBMOD_Scene`, which is used to compose models, terrain, lights, particle effects, cameras etc. into a single scene.
* Added new function `bbmod_scene_get_default`, which retrieves the default scene.
* Added new function `bbmod_scene_get_current`, which retrieves the scene that is currently being updated or rendered. If there is no such scene, the default scene is returned.
* Added new enum `BBMOD_ESceneNode`, which is an enumeration of scene node properties.
* Added new enum `BBMOD_ESceneNodeFlags`, which is an enumeration of all possible flags that a scene node can have.
* Added new macro `BBMOD_SCENE_NODE_ID_INVALID`, which is the ID used to tell that a scene node does not exist.
* Added new struct `BBMOD_SceneNodeDescriptor`, which is used in `BBMOD_Scene.create_node` to create a new scene node.
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
* Added new property `ClearColor` to `BBMOD_DeferredRenderer`, which is the color to clear the background with. Default value is `c_black`.
* Fixed normal vectors of backfaces being flipped incorrectly.
