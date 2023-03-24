# Changelog 3.16.8
This release mainly adds support for automatic loading of model's materials from BBMAT files and a few other quality of life improvements. Please make sure to read the changelog thoroughly, as this release also removes obsolete API!

* Added new property `LoadMaterials` to `BBMOD_ResourceManager`, which allows method `load` to automatically load model's materials when BBMAT files with the material names are found in the same directory. By default this is enabled.
* **Renamed** sprite `BBMOD_SprDefaultBaseOpacity` to `BBMOD_SprCheckerboard`.
* Materials `BBMOD_MATERIAL_DEFAULT` and `BBMOD_MATERIAL_DEFAULT_UNLIT` now use `BBMOD_SprWhite` as `BaseOpacity`.
* Added new utility function `bbmod_mrt_is_supported`, which checks whether multiple render targets are supported on the current platform.
* Added new function `bbmod_blendmode_to_string`, which retrieves a name of a basic blend mode.
* Added new function `bbmod_blendmode_from_string`, which retrieves a basic blend mode from its name.
* Added new function `bbmod_cullmode_to_string`, which retrieves a name of a cull mode.
* Added new function `bbmod_cullmode_from_string`, which retrieves a cull mode from its name.
* Added new function `bbmod_cmpfunc_to_string`, which retrieves a name of a cmpfunc.
* Added new function `bbmod_cmpfunc_from_string`, which retrieves a cmpfunc from its name.
* Method `from_json` of `BBMOD_Material` now supports strings for properties `BlendMode`, `Culling` and `ZFunc`. E.g. "bm_add", "cull_clockwise" and "cmp_less" respectively, instead of their numeric values.
* Fixed method `from_json` of `BBMOD_Material` not using the `RenderQueue` property.
* Function `bbmod_path_is_relative` now returns `true` also for paths that don't begin with "/" or a drive (e.g. "C:\\") instead of just paths that begin with "." or "..".
* Added new functions `bbmod_light_ambient_set_dir` and `bbmod_light_ambient_get_dir`, using which you can set and retrieve the direction to the ambient light's upper hemisphere. By default this is `BBMOD_VEC3_UP` (i.e. vector `0, 0, 1`).
* Added optional argument `_dir` to method `BBMOD_BaseShader.set_ambient_light`, which is the direction to the ambient light's upper hemisphere. If not defined, then it defaults to the value set by the new `bbmod_light_ambient_set_dir`.
* Method `Transform` of structs `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4` now supports `BBMOD_Matrix` as an argument.
* Method `build` of `BBMOD_MeshBuilder` now also assigns `BboxMin` and `BboxMax` properties of the created mesh.
* Added new property `EnableTransitions` to `BBMOD_AnimationPlayer`, which enables/disables transitions between animations. By default this is enabled!
* Added new method `has_commands` to `BBMOD_RenderQueue`, which checks whether the render queue has commands for given render pass.
* Method `submit` of `BBMOD_RenderQueue` now exits early if it does not have any commands for the current render pass.
* Fixed memory leak in `BBMOD_RenderQueue.destroy`.
* Particle materials now use the `Alpha` render pass instead of `Forward`!
* Fixed rendering errors on macOS (and possibly other OpenGL platforms) when image-based lighting is not used.
* Fixed shader `BBMOD_SHADER_DEFAULT_UNLIT` and material `BBMOD_MATERIAL_DEFAULT_UNLIT` not being registered.
* **Removed** property `BBMOD_BaseRenderer.ShadowmapArea`, which was obsolete. Please use its counterpart `BBMOD_DirectionalLight.ShadowmapArea` before updating to this release.
* **Removed** property `BBMOD_BaseRenderer.ShadowmapResolution`, which was obsolete. Please use its counterpart `BBMOD_Light.ShadowmapResolution` before updating to this release.
* **Removed** property `BBMOD_BaseRenderer.UseAppSurface`, which was obsolete. Please use its counterpart `BBMOD_BaseRenderer.PostProcessor` before updating to this release.
* **Removed** property `BBMOD_Shader.Raw`, which was obsolete. Please use `BBMOD_Shader.get_variant` before updating to this release.
* **Removed** property `BBMOD_Shader.VertexFormat`, which was obsolete. Please use `BBMOD_Shader.has_variant` before updating to this release.
* **Removed** method `BBMOD_Shader.get_name`, which was obsolete. Please use `shader_get_name(shader.get_variant(vertexFormat))` before updating to this version.
* **Removed** method `BBMOD_Shader.get_uniform`, which was obsolete.
* **Removed** method `BBMOD_Shader.get_sampler_index`, which was obsolete.
* **Removed** property `BBMOD_BaseShader.MaxPointLights`, which was obsolete. Please use its counterpart `BBMOD_BaseShader.MaxPunctualLights` before updating to this version.
* **Removed** property `BBMOD_DLL.Path`, which was obsolete. Please use `BBMOD_DLL_PATH` before updating to this version.
