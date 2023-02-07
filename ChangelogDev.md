# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

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
