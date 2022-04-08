# Changelog 3.2.0
This release brings a massive overhaul to render queues & render commands system,
as well as a new Terrain module, using which you can create heightmap based
terrains with five layers of materials controlled using a splatmap.

## GML API:
### General:
* Updated documented types to GameMaker 2022.3 style.
* **Removed all API that was previously marked as deprecated or obsolete!** Please make sure you are not using any of it before upgrading your project to this version.

### Core module:
* Fog in the default shaders is now affected by the color of ambient and directional lights.
* Added new enum `BBMOD_ERenderCommand`, which contains all possible render commands.
* Added new struct `BBMOD_RenderQueue`, which is a container for render commands.
* Struct `BBMOD_RenderCommand` is now obsolete. Please use methods of `BBMOD_RenderQueue` to create render commands.
* Added new property `BBMOD_BaseMaterial.RenderQueue`, which is the render queue used by the material.
* Added new function `bbmod_render_queue_get_default`, which returns the default render queue.
* Property `RenderCommands` and methods `has_commands`, `submit_queue` and `clear_queue` of `BBMOD_BaseMaterial` are now obsolete. Please use its `RenderQueue` property instead.
* Added new struct `BBMOD_Material`, which is now the base struct for all materials.
* Moved basic properties and methods from `BBMOD_BaseMaterial` to `BBMOD_Material`.
* Struct `BBMOD_BaseMaterial` now inherits from `BBMOD_Material`.
* Added new property `BBMOD_Material.AlphaBlend`, using which you can enable/disable alpha blending. This is by default **disabled**.
* Added new function `bbmod_gpu_get_default_state`, using which you can retrieve the default GPU state.
* Added new functions `bbmod_shader_clear_globals`, `bbmod_shader_get_global`, `bbmod_shader_set_global_f`, `bbmod_shader_set_global_f_array`, `bbmod_shader_set_global_f2`, `bbmod_shader_set_global_f3`, `bbmod_shader_set_global_f4`, `bbmod_shader_set_global_i`, `bbmod_shader_set_global_i_array`, `bbmod_shader_set_global_i2`, `bbmod_shader_set_global_i3`, `bbmod_shader_set_global_i4`, `bbmod_shader_set_global_matrix`, `bbmod_shader_set_global_matrix_array`, `bbmod_shader_set_global_sampler`, `bbmod_shader_set_global_sampler_filter`, `bbmod_shader_set_global_sampler_max_aniso`, `bbmod_shader_set_global_sampler_max_mip`, `bbmod_shader_set_global_sampler_min_mip`, `bbmod_shader_set_global_sampler_mip_bias`, `bbmod_shader_set_global_sampler_mip_enable`, `bbmod_shader_set_global_sampler_mip_filter`, `bbmod_shader_set_global_sampler_repeat` and `bbmod_shader_unset_global`, using which you can get, set and unset global shader uniforms.
* Properties `BBMOD_BaseShader.set_zfar` and `BBMOD_DefaultShader.set_shadowmap` are now obsolete. They were replaced by global shader uniforms.
* Fixed method `BBMOD_Vertex.to_vertex_buffer` when using vertex colors.

### Camera module:
* Fixed mouselook in Firefox.

### Terrain module:
* Added new module - Terrain.
* Added new struct `BBMOD_Terrain`.
* Added new macro `BBMOD_SHADER_TERRAIN`, which is a shader for terrain materials.
* Added new macro `BBMOD_MATERIAL_TERRAIN`, which is a base terrain material.
