# Changelog 3.0.0
This major release of BBMOD focuses on modularity of the GML library, increased animation playback performance and support for advanced rendering pipelines.

## General:
* Done a full switch from matrices to dual quaternions for node transforms and animation data.
* Interpolated animation frames are now precomputed offline during model conversion. Animation sampling rate is fully configurable.
* Added three levels of animation optimization. Higher optimization levels increase the animation playback performance but disable additional features like transforming nodes through code, node attachments or animation transitions.
* Done changes to the model and animation file format and increased their version from `2` to `3`.

## BBMOD CLI:
* Added new option `--optimize-animations` (`-oa`) using which you can configure the animation optimization level.
* Added new option `--sampling-rate` (`-sr`) using which you can configure the animation sampling rate (fps).

## BBMOD GUI:
* Added animation optimization level configuration.
* Added animation sampling rate configuration.

## GML API:
**General:**
* Moved included files from `./BBMOD` to `./Data/BBMOD`.
* Increased macro `BBMOD_VERSION` from `2` to `3`. It is not possible to load `*.bbmod` and `*.bbanim` files from previous versions.
* Removed all obsolete and deprecated functions etc.
* Split the library into multiple folders - modules. Each one of this module adds extra functionality, but the only module you need to import to be able to use BBMOD is the Core module.
* PBR is now its own module and it is no longer the default shader/material - you do not have to include it if you are going to use your own shaders.
* Renamed sprite `BBMOD_SprDefaultMaterial` to `BBMOD_SprCheckerboard` and removed its subimages except for the first one, which is the checkerboard texture.

**DLL:**
* Added new methods `get_optimize_animations` and `set_optimize_animations` to `BBMOD_DLL` using which you can configure the animation optimization level.
* Added new methods `get_sampling_rate` and `set_sampling_rate` to `BBMOD_DLL` using which you can configure the animation sampling rate (fps).

**Vertex format:**
* Added a new method `BBMOD_VertexFormat.get_byte_size`, which retrieves a size of a single vertex using the vertex format in bytes.
* Added new macros for `BBMOD_VFORMAT_DEFAULT`, `BBMOD_VFORMAT_DEFAULT_ANIMATED` and `BBMOD_VFORMAT_DEFAULT_BATCHED`, which are the default vertex formats for static, animated and dynamically batched models respectively.

**Mesh:**
* Converted legacy struct `BBMOD_EMesh` into a GMS2.3+ struct `BBMOD_Mesh`.
* Added a new property `VertexFormat` to `BBMOD_Mesh`. This is a `BBMOD_VertexFormat` that the mesh uses.

**Node:**
* Converted legacy struct `BBMOD_ENode` into a GMS2.3+ struct `BBMOD_Node`.
* Added a new property `Parent` to `BBMOD_Node`, which is the parent of the node or `undefined` if it is the root node.
* Added a new read-only property `IsBone` to `BBMOD_Node`, which tells whether the node or any node down the chain is a part of a skeleton. This is used to increase performance of animation playback.
* Added a new method `BBMOD_Node.set_skeleton` using which you can mark a node as a part of a skeleton node chain.
* Added a new read-only property `IsRenderable` to `BBMOD_Node`, which tells whether the node or any node down the chain has a mesh. This is used to increase performance of model rendering.
* Added a new method `BBMOD_Node.set_renderable` using which you can mark a node as renderable.

**Shaders and materials:**
* Renamed shaders `BBMOD_ShDefault`, `BBMOD_ShDefaultBatched` and `BBMOD_ShDefaultAnimated` to `BBMOD_ShPBR`, `BBMOD_ShPBRBatched` and `BBMOD_ShPBRAnimated` respectively.
* Added a new set of default shaders (with the same names as the original ones). These are basic pass-through shaders, much easier to customize than the PBR ones.
* Added a new struct `BBMOD_Shader`, which wraps regular GM shader resources.
* `BBMOD_Material` now accepts a `BBMOD_Shader` instead of a regular GM shader resource.
* Added a new struct `BBMOD_PBRMaterial` which inherits from `BBMOD_Material`. Moved PBR-only properties of `BBMOD_Material` to `BBMOD_PBRMaterial`.
* Renamed `BBMOD_Material`'s `RenderPath` property to `RenderPass`.
* Added a new function `bbmod_get_materials` which returns an array of all existing materials.
* Added a new read-only property `Priority` to `BBMOD_Material`. This property determines the order of materials in the array returned by `bbmod_get_materials`.
* Added a new method `BBMOD_Material.set_priority`, using which you can change the `Priority` property of a `BBMOD_Material`.
* Added new properties `TextureOffset` and `TextureScale` to `BBMOD_Material`, using which you can control its texture coordinates within a texture page.
* Method `BBMOD_Material.apply` now returns the `self` (`BBMOD_Material`) instead of a boolean.
* Added a new method `BBMOD_Material.copy` which copies the material's properties into another material.
* Added a new method `BBMOD_Material.set_base_opacity` using which you can change the material's base color and opacity using floats.
* Changed the default value of the `BBMOD_Material.OnApply` property from `bbmod_material_on_apply_default` to `undefined`.
* Removed function `bbmod_material_on_apply_default`. Setting shader uniforms and textures is now taken care of by the `BBMOD_Shader` struct.
* Added new macros `BBMOD_SHADER_DEFAULT`, `BBMOD_SHADER_DEFAULT_ANIMATED` and `BBMOD_SHADER_DEFAULT_BATCHED`, which are the default shaders for static, animated and dynamically batched models respectively.
* Added new macros `BBMOD_SHADER_PBR`, `BBMOD_SHADER_PBR_ANIMATED` and `BBMOD_SHADER_PBR_BATCHED`, which are PBR shaders for static, animated and dynamically batched models respectively.
* Added new macros `BBMOD_MATERIAL_PBR`, `BBMOD_MATERIAL_PBR_ANIMATED` and `BBMOD_MATERIAL_PBR_BATCHED`, which are PBR materials for static, animated and dynamically batched models respectively.

**Rendering:**
* Added a new struct `BBMOD_RenderCommand`.
* Added a new property `RenderCommands` to `BBMOD_Material`. This property is a list of `BBMOD_RenderCommand` structs that use the material.
* Renamed method `render` of `BBMOD_Model`, `BBMOD_DynamicBatch` and `BBMOD_StaticBatch` to `submit`. This method still immediately draws the model.
* Added a new method `render` to `BBMOD_Model`, `BBMOD_DynamicBatch` and `BBMOD_StaticBatch`, which enqueues the model for rendering.
* Renamed method `render_object` of `BBMOD_DynamicBatch` to `submit_object`. This method still immediately draws the dynamic batch.
* Added a new method `render_object` to `BBMOD_DynamicBatch`, which enqueues the dynamic batch for rendering.
* Added new methods `render([_materials])` and `submit([_materials])` to `BBMOD_AnimationPlayer`. These are shorthands for `model.render(materials, animationPlayer.get_transform())` and `model.submit(materials, animationPlayer.get_transform())` respectively.
* Added a new method `BBMOD_Material.submit_queue` using which you can submit all its render commands.
* Added a new macro `BBMOD_RENDER_SHADOWS`, which is a flag used to tell that a material is rendered in a shadow pass.

**Animations:**
* Removed legacy structs `BBMOD_EAnimationNode`, `BBMOD_EAnimationKey`, `BBMOD_EPositionKey`, `BBMOD_ERotationKey` and `BBMOD_EBone`. Animation data is now stored in a more optimal way.
* Removed property `InterpolateFrames` of `BBMOD_AnimationPlayer`. All frames are now precomputed.
* Removed property `AnimationStart` of `BBMOD_AnimationInstance`.
* Added methods `supports_attachments`, `supports_bone_transform` and `supports_transitions` to `BBMOD_Animation` using which you can check if the animation supports node attachments, bone transformations through code and transitions respectively. This is determined by the optimization level of the animation.
* Added new method `get_node_transform_from_frame` to `BBMOD_AnimationPlayer` using which you can retrieve a node's transform from the last played animation frame.
* Replaced property `OnEvent` of `BBMOD_AnimationPlayer` with methods `on_event` and `off_event`.
* Added new properties `Animation` and `AnimationLoops` to `BBMOD_AnimationPlayer` which is the last played animation and whether it loops respectively.
* Added new method `change` to `BBMOD_AnimationPlayer`. The animation player now remembers the last played animation and if a different one is passed it automatically transitions into it. This also triggers a new animation event `BBMOD_EV_ANIMATION_CHANGE`.
* Added a new macro `BBMOD_EV_ANIMATION_LOOP`, which is an event triggered by an animation player when the animation played loops and continues from the start.
* Added a new method `add_event` to `BBMOD_Animation` using which you can add a custom animation event triggered at a specific frame.

**Camera and renderer:**
* Added a new struct `BBMOD_Camera` which implements both first-person and third-person camera.
* Added a new struct `BBMOD_IRenderable` which defines an abstract interface of renderable objects. These can be rendered in the `BBMOD_Renderer` struct.
* Added a new struct `BBMOD_Renderer` which implements a basic render pipeline. This struct can be inherited from to define custom render pipelines.

**Mesh builder and model importer:**
* Added a new struct `BBMOD_Vertex`.
* Added a new struct `BBMOD_MeshBuilder`, using which you can create BBMOD meshes through code.
* Added a new struct `BBMOD_Importer`, which is a base struct for model importers.
* Added a new struct `BBMOD_OBJImporter`, which is an importer of `*.obj` models.

**Math library:**
* Removed CE dependency.
* Added new structs `BBMOD_Vec2`, `BBMOD_Vec3`, `BBMOD_Vec4`, `BBMOD_Quaternion` and `BBMOD_DualQuaternion`.

**Exceptions:**
* Renamed struct `BBMOD_Error` to `BBMOD_Exception`.
* Added a new struct `BBMOD_NotImplementedException`, which is an exception thrown in methods that do not have an implementation (generally in methods of abstract interfaces).

**Third-party libraries support:**
* Added functions `bbmod_mesh_to_colmesh` and `bbmod_model_to_colmesh` using wich you can add `BBMOD_Mesh`s and `BBMOD_Model`s to TheSnidr's [ColMesh](https://marketplace.yoyogames.com/assets/8130/colmesh), a popular library for 3D collisions.
