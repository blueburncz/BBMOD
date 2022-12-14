# Changelog 3.16.0
This release is a preface to bigger new features to come that require some modifications to the library. It is being released earlier to give you, the users, more time to accommodate to the changes and us, the developers, to fix potential issues while we also work on the new features. Please make sure to read this changelog thoroughly before updating to this release!

## Feature highlights
### Modules reorganized
To make the structure of the library a lot simpler and to allow certain features planned for future releases, modules were reorganized, putting a lot of API into the Core module. The Core module now actually contains everything you need and the rest of the modules are things that add features on top of that.

### BBMOD DLL in the core
BBMOD DLL is now also a part of the Core module and it is no longer possible to change its location in the included files! This is because it could be utilized throughout other parts of the library when possible (e.g. to speed things up or enable features otherwise unsupported on certain platforms).

### Shader variants
Before it was not possible to share a single material between static, animated and dynamically batched models. Instead you had to create a separate copy of the material using a special dedicated shader. This issue has been resolved by adding **shader variants**. Each `BBMOD_Shader` can now have variants to be used with specific vertex formats. This means you can now use `BBMOD_MATERIAL_DEFAULT` for all three model kinds, without the `_ANIMATED` or `_BATCHED` suffix.

### Default renderer
To enable us to develop multiple rendering pipelines, `BBMOD_Renderer` was split into `BBMOD_BaseRenderer` and `BBMOD_DefaultRenderer`, the former being a base struct for all renderers and the latter being replacement for the old renderer. Everything regarding the default materials and the default renderer was put into a single folder.

### Vertex texture fetching support
GameMaker supports vertex texture fetching (VTF) on most platforms, known exceptions being PS4, PS5, Xbox and Windows. We would like to utilize VTF on desktop platforms in one of the future updates, so we are adding support for VTF on Windows through the BBMOD DLL. You can now use `bbmod_vtf_is_supported` to check if VTF is supported on the current platform and `bbmod_texture_set_stage_vs` to pass a texture to a vertex shader.

## Scripting API changes
* Added missing method `Reset` to `BBMOD_RaycastResult`, which resets its properties to their default values.
* Prefixed all private API with `__` (two underscores) to "hide" it from autocomplete.
* Structs `BBMOD_Collider`, `BBMOD_Node`, `BBMOD_Vertex`, `BBMOD_VertexFormat`, `BBMOD_ParticleModule`, `BBMOD_Property` and `BBMOD_Shader` now inherit from `BBMOD_Class`.
* Added new macro `BBMOD_MAX_BONES`, which is the maximum number of bones a single model can have. Equals to 128.
* Added new method `set_node_rotation_post` to `BBMOD_AnimationPlayer`, which sets a post-rotation of a node.
* Added new macro `BBMOD_MAX_BATCH_VEC4S`, which is the maximum number of vec4 uniforms for dynamic batch data available in the default shaders.
* Added new function `bbmod_vtf_is_supported`, which checks if vertex texture fetching is supported on the current platform.
* Added new function `bbmod_texture_set_stage_vs`, which passes a texture to a vertex shader.
* Added new member `DepthOnly` to enum `BBMOD_ERenderPass`, which is a render pass where opaque objects are rendered into an off-screen depth buffer.
* Member `Deferred` of enum `BBMOD_ERenderPass` is now **deprecated**! Please use the new `DepthOnly` instead.
* Added new member `GBuffer` to enum `BBMOD_ERenderPass`, which is a render pass where opaque objects are rendered into a G-Buffer.
* Added new method `add_variant` to `BBMOD_Shader`, which adds a shader variant to be used with a specific vertex format.
* Added new method `has_variant` to `BBMOD_Shader`, which checks whether the shader has a variant for given vertex format.
* Property `VertexFormat` of `BBMOD_Shader` is now **obsolete**! Please use the new method `has_variant` instead.
* Arguments `_shader` and `_vertexFormat` of `BBMOD_Shader`'s constructor are now optional. If specified, then they are added to the shader with the new method `add_variant`.
* Added new method `get_variant` to `BBMOD_Shader`, which retrieves a shader variant for given vertex format.
* Property `Raw` of `BBMOD_Shader` is now **obsolete**! Please use the new method `get_variant` instead.
* Method `get_name` of `BBMOD_Shader` is now **obsolete** and will always return `undefined`!
* Method `is_compiled` of `BBMOD_Shader` now checks if **all its variants** are compiled!
* **Removed** deprecated methods, `set_uniform_f`, `set_uniform_f2`, `set_uniform_f3`, `set_uniform_f4`, `set_uniform_f_array`, `set_uniform_i`, `set_uniform_i2`, `set_uniform_i3`, `set_uniform_i4`, `set_uniform_i_array`, `set_uniform_matrix`, `set_uniform_matrix_array` and `set_sampler` of `BBMOD_Shader`!
* Methods `get_uniform` and `get_sampler_index` of `BBMOD_Shader` are now **obsolete** and will always return `-1`!
* **Method `set` of `BBMOD_Shader` now expects argument `_vertexFormat`, which is used to set a specific shader variant!**
* **Changed** signature of `BBMOD_RenderQueue.draw_mesh` to `draw_mesh(_vertexBuffer, _vertexFormat, _primitiveType, _materialIndex, _material, _matrix)`!
* **Changed** signature of `BBMOD_RenderQueue.draw_mesh_animated` to `draw_mesh_animated(_vertexBuffer, _vertexFormat, _primitiveType, _materialIndex, _material, _matrix, _boneTransform)`!
* **Changed** signature of `BBMOD_RenderQueue.draw_mesh_batched` to `draw_mesh_batched(_vertexBuffer, _vertexFormat, _primitiveType, _materialIndex, _material, _matrix, _batchData)`!
* Added new optional argument `_matrix` to `BBMOD_Model.render`, which is the world matrix to use when rendering the model. It defaults to `matrix_get(matrix_world)` when not specified.
* **Renamed** sprite `BBMOD_SprCheckerboard` to `BBMOD_SprDefaultBaseOpacity`!
* **Moved** macros `BBMOD_SHADER_DEPTH`, `BBMOD_SHADER_DEPTH_ANIMATED` and `BBMOD_SHADER_DEPTH_BATCHED` to the Core module!
* Added new macro `BBMOD_SHADER_DEFAULT_DEPTH`, which is a substitution for the old `BBMOD_SHADER_DEPTH`. It contains shader variants for vertex formats `BBMOD_VFORMAT_DEFAULT_ANIMATED`, `BBMOD_VFORMAT_DEFAULT_BATCHED` and `BBMOD_VFORMAT_DEFAULT_LIGHTMAP`.
* Macros `BBMOD_SHADER_DEPTH`, `BBMOD_SHADER_DEPTH_ANIMATED` and `BBMOD_SHADER_DEPTH_BATCHED` are now **deprecated**! Please use the new `BBMOD_SHADER_DEFAULT_DEPTH` instead.
* **Renamed** shaders `BBMOD_ShDepth`, `BBMOD_ShDepthAnimated` and `BBMOD_ShDepthBatched` to `BBMOD_ShDefaultDepth`, `BBMOD_ShDefaultDepthAnimated` and `BBMOD_ShDefaultDepthBatched` respectively!
* **Removed** the Rendering/Depth buffer submodule, since it became empty!
* **Moved** structs `BBMOD_LightmapMaterial` and `BBMOD_LightmapShader` to the Core module!
* Added new structs `BBMOD_DefaultLightmapMaterial` and `BBMOD_DefaultLightmapShader`, which are substitutions for `BBMOD_LightmapMaterial` and `BBMOD_LightmapShader` respectively.
* Struct `BBMOD_LightmapMaterial` now inherits from the new `BBMOD_DefaultLightmapMaterial` and is marked as **deprecated**! Please use `BBMOD_DefaultLightmapMaterial` instead.
* Struct `BBMOD_LightmapShader` now inherits from the new `BBMOD_DefaultLightmapShader` and is marked as **deprecated**! Please use `BBMOD_DefaultLightmapShader` instead.
* **Moved** macros `BBMOD_VFORMAT_LIGHTMAP`, `BBMOD_SHADER_LIGHTMAP`, `BBMOD_SHADER_LIGHTMAP_DEPTH` and `BBMOD_MATERIAL_LIGHTMAP` to the Core module!
* Added new macro `BBMOD_VFORMAT_DEFAULT_LIGHTMAP`, which is a vertex format of lightmapped models with two UV channels.
* Macro `BBMOD_VFORMAT_LIGHTMAP` is now **deprecated**! Please use the new `BBMOD_VFORMAT_DEFAULT_LIGHTMAP` instead.
* Added new macro `BBMOD_SHADER_DEFAULT_LIGHTMAP`, which is a shader for rendering lightmapped models with two UV channels.
* Macro `BBMOD_SHADER_LIGHTMAP` is now **deprecated**! Please use the new `BBMOD_SHADER_DEFAULT_LIGHTMAP` instead.
* Macro `BBMOD_SHADER_LIGHTMAP_DEPTH` is now **deprecated**! Please use the new `BBMOD_SHADER_DEFAULT_DEPTH` instead.
* **Moved** functions `bbmod_lightmap_get` and `bbmod_lightmap_set` to the Core module!
* **Renamed** shader `BBMOD_ShLightmap` to `BBMOD_ShDefaultLightmap`!
* **Renamed** shader `BBMOD_ShLightmapDepth` to `BBMOD_ShDefaultDepthLightmap`!
* **Moved** macros `BBMOD_VFORMAT_SPRITE`, `BBMOD_SHADER_SPRITE` and `BBMOD_MATERIAL_SPRITE` to the Core module!
* Added new macro `BBMOD_VFORMAT_DEFAULT_SPRITE`, which is a vertex format of 2D sprites.
* Macro `BBMOD_VFORMAT_SPRITE` is now **deprecated**! Please use the new `BBMOD_VFORMAT_DEFAULT_SPRITE` instead.
* Added new macro `BBMOD_SHADER_DEFAULT_SPRITE`, which is a shader for 2D sprites.
* Macro `BBMOD_SHADER_SPRITE` is now **deprecated**! Please use the new `BBMOD_SHADER_DEFAULT_SPRITE` instead.
* Added new macro `BBMOD_MATERIAL_DEFAULT_SPRITE`, which is a material for 2D sprites.
* Macro `BBMOD_MATERIAL_SPRITE` is now **deprecated**! Please use the new `BBMOD_MATERIAL_DEFAULT_SPRITE` instead.
* **Renamed** shader `BBMOD_ShSprite` to `BBMOD_ShDefaultSprite`!
* **Removed** the 2D module, since it became empty!
* **Moved** struct `BBMOD_Renderer` from to the Core module!
* Added new struct `BBMOD_BaseRenderer`, which is a base struct for renderers.
* Added new struct `BBMOD_DefaultRenderer`, which inherits from `BBMOD_BaseRenderer` and implements the same functionality as `BBMOD_Renderer` did.
* Struct `BBMOD_Renderer` now inherits from the new `BBMOD_DefaultRenderer` and is marked as **deprecated**! Please use `BBMOD_DefaultRenderer` instead.
* **Removed** the Rendering/Renderer submodule, since it became empty!
* **Removed** optional argument `_path` from `BBMOD_DLL`'s constructor. The new `BBMOD_DLL_PATH` is now always used instead!
* The read-only property `Path` of `BBMOD_DLL` is now **obsolete**!
* **Moved** contents of the DLL module to the Core module and **removed** the DLL module!
* Added new macro `BBMOD_DLL_IS_SUPPORTED`, which evaluates to `true` if BBMOD DLL is supported on the current platform and the dynamic library exists.
* Added new macro `BBMOD_DLL_PATH`, which is the path to the BBMOD dynamic library.
* Shader `BBMOD_SHADER_INSTANCE_ID` now contains variants for vertex formats `BBMOD_VFORMAT_DEFAULT_ANIMATED`, `BBMOD_VFORMAT_DEFAULT_BATCHED` and `BBMOD_VFORMAT_DEFAULT_LIGHTMAP`.
* Macros `BBMOD_SHADER_INSTANCE_ID_ANIMATED`, `BBMOD_SHADER_INSTANCE_ID_BATCHED` and `BBMOD_SHADER_LIGHTMAP_INSTANCE_ID` are now **deprecated**! Please use `BBMOD_SHADER_INSTANCE_ID` instead.
* **Renamed** shader `BBMOD_ShLightmapInstanceID` to `BBMOD_ShInstanceIDLightmap`!
* **Moved** shader `BBMOD_ShInstanceIDLightmap` and macro `BBMOD_SHADER_LIGHTMAP_INSTANCE_ID` to the Gizmo module!
* **Removed** the Lightmap module, since it became empty!
* **Moved** struct `BBMOD_ResourceManager` to the Core module!
* **Removed** the Resource manager module, since it became empty!
* **Moved** struct `BBMOD_MeshBuilder` to the Core module!
* **Removed** the Mesh builder module, since it became empty!
* **Moved** struct `BBMOD_Importer` to the Core module!
* **Renamed** the Importer module to "OBJ importer", as it now contains only struct `BBMOD_OBJImporter`!
* **Moved** structs `BBMOD_BaseCamera` and `BBMOD_Camera` to the Core module!
* **Removed** the Camera module, since it became empty!
* **Moved** enum `BBMOD_ECubeSide` and struct `BBMOD_Cubemap` to the Core module!
* **Removed** the Rendering/Cubemap submodule, since it became empty!
* **Removed** variable `global.bbmod_render_queues`, which was obsolete!
* **Removed** property `IsSkeleton` of `BBMOD_Node`, which was obsolete!
* **Removed** method `set_skeleton` of `BBMOD_Node`, which was obsolete!
* **Removed** the Rendering/PBR submodule, since it was deprecated!
