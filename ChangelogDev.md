# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Added new function `bbmod_mrt_is_supported`, which checks whether multiple render targets are supported on the current platform.
* Method `Transform` of structs `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4` now supports `BBMOD_Matrix` as an argument.
* Removed property `BBMOD_BaseRenderer.ShadowmapArea`, which was obsolete. Please use its counterpart `BBMOD_DirectionalLight.ShadowmapArea` before updating to this release.
* Removed property `BBMOD_BaseRenderer.ShadowmapResolution`, which was obsolete. Please use its counterpart `BBMOD_Light.ShadowmapResolution` before updating to this release.
* Removed property `BBMOD_BaseRenderer.UseAppSurface`, which was obsolete. Please use its counterpart `BBMOD_BaseRenderer.PostProcessor` before updating to this release.
* Removed property `BBMOD_Shader.Raw`, which was obsolete. Please use `BBMOD_Shader.get_variant` before updating to this release.
* Removed property `BBMOD_Shader.VertexFormat`, which was obsolete. Please use `BBMOD_Shader.has_variant` before updating to this release.
* Removed method `BBMOD_Shader.get_name`, which was obsolete. Please use `shader_get_name(shader.get_variant(vertexFormat))` before updating to this version.
* Removed method `BBMOD_Shader.get_uniform`, which was obsolete.
* Removed method `BBMOD_Shader.get_sampler_index`, which was obsolete.
* Removed property `BBMOD_BaseShader.MaxPointLights`, which was obsolete. Please use its counterpart `BBMOD_BaseShader.MaxPunctualLights` before updating to this version.
* Removed property `BBMOD_DLL.Path`, which was obsolete. Please use `BBMOD_DLL_PATH` before updating to this version.

DisableTextureCoords2 changed to false
DisableVertexColors changed to false
FlipTextureVertically changed to false
OptimizeMaterials changed to false
OptimizeNodes changed to false
OptimizeMeshes changed to false
added new ExportMaterials (default true)
Fixed memory leak in `BBMOD_RenderQueue.destroy`.
Added new methods `get_export_materials` and `set_export_materials` to `BBMOD_DLL`.

* Added new function `bbmod_blendmode_to_string`, which retrieves a name of a blend mode.
* Added new function `bbmod_blendmode_from_string`, which retrieves a blend mode from its name.
* Added new function `bbmod_cullmode_to_string`, which retrieves a name of a cull mode.
* Added new function `bbmod_cullmode_from_string`, which retrieves a cull mode from its name.
* Added new function `bbmod_cmpfunc_to_string`, which retrieves a name of a cmpfunc.
* Added new function `bbmod_cmpfunc_from_string`, which retrieves a cmpfunc from its name.
