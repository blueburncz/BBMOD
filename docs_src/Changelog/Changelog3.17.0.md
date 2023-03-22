# Changelog 3.17.0
This release mainly adds basic export of materials into BBMAT files to BBMOD CLI.

* BBMOD CLI's destructive options `--disable-uv2` (`-duv2`), `--disable-color` (`-dc`), `--flip-uv-y` (`-fuvy`), `--optimize-nodes` (`-on`), `--optimize-meshes` (`-ome`) and `--optimize-materials` (`-oma`) now default to `false`!
* Added new option `--export-materials` (`-em`) to BBMOD CLI, using which you can enable/disable export of materials to BBMAT files. Defaults to `true`.
* Added new methods `get_export_materials` and `set_export_materials` to `BBMOD_DLL`.
* Method `load` of `BBMOD_ResourceManager` now also automatically loads models' materials when BBMAT files are present.
* **Renamed** sprite `BBMOD_SprDefaultBaseOpacity` to `BBMOD_SprCheckerboard`.
* Materials `BBMOD_MATERIAL_DEFAULT` and `BBMOD_MATERIAL_DEFAULT_UNLIT` now use `BBMOD_SprWhite` as `BaseOpacity`.
* Added new function `bbmod_mrt_is_supported`, which checks whether multiple render targets are supported on the current platform.
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
* Fixed memory leak in `BBMOD_RenderQueue.destroy`.
* Fixed rendering errors on macOS (and possibly other OpenGL platforms) when image-based lighting is not used.
* Added new method `has_commands` to `BBMOD_RenderQueue`, which checks whether the render queue has commands for given render pass.
* Particle materials now use the `Aplha` render pass instead of `Forward`!
* Added new property `EnableTransitions` to `BBMOD_AnimationPlayer`, which enables/disables transitions between animations. By default this is enabled!
