/// @module Core

/// @enum Enumeration of all possible render commands.
enum BBMOD_ERenderCommand
{
	/// @member Applies a material if it has a shader that can be used in the
	/// current render pass.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	ApplyMaterial,
	/// @member Applies a material property block.
	/// @see BBMOD_MaterialPropertyBlock
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	ApplyMaterialProps,
	/// @member Marks the beginning of a conditional block. Commands within this
	/// block are executed only if the last command was successfully executed.
	/// @example
	/// ```gml
	/// renderQueue.ApplyMaterial(material, vertexFormat)
	///     .BeginConditionalBlock()
	///     // Commands here will be executed only if the material was applied...
	///     .EndConditionalBlock();
	/// ```
	/// @see BBMOD_ERenderCommand.EndConditionalBlock
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	BeginConditionalBlock,
	/// @member Executes a custom function.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	CallFunction,
	/// @member Checks if the current render pass is one of specified passes.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	CheckRenderPass,
	/// @member Draws a mesh if its material can be used in the current render
	/// pass.
	DrawMesh,
	/// @member Draws an animated mesh if its material can be used in the current
	/// render pass.
	DrawMeshAnimated,
	/// @member Draws a dynamically batched mesh if its material can be used in
	/// the current render pass.
	DrawMeshBatched,
	/// @member Draws terrain with multiple layers.
	DrawTerrain,
	/// @member Draws a sprites using the `draw_sprite` function.
	DrawSprite,
	/// @member Draws a sprite using the `draw_sprite_ext` function.
	DrawSpriteExt,
	/// @member Draws a sprite using the `draw_sprite_general` function.
	DrawSpriteGeneral,
	/// @member Draws a sprite using the `draw_sprite_part` function.
	DrawSpritePart,
	/// @member Draws a sprite using the `draw_sprite_part_ext` function.
	DrawSpritePartExt,
	/// @member Draws a sprite using the `draw_sprite_pos` function.
	DrawSpritePos,
	/// @member Draws a sprite using the `draw_sprite_stretched` function.
	DrawSpriteStretched,
	/// @member Draws a sprite using the `draw_sprite_stretched_ext` function.
	DrawSpriteStretchedExt,
	/// @member Draws a sprite using the `draw_sprite_tiled` function.
	DrawSpriteTiled,
	/// @member Draws a sprite using the `draw_sprite_tiled_ext` function.
	DrawSpriteTiledExt,
	/// @member Marks the end of a conditional block.
	/// @see BBMOD_ERenderCommand.BeginConditionalBlock
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	EndConditionalBlock,
	/// @member Pops the GPU state.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	PopGpuState,
	/// @member Pushes the GPU state.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	PushGpuState,
	/// @member Resets material.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	ResetMaterial,
	/// @member Resets current material property block.
	/// @see BBMOD_MaterialPropertyBlock
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	ResetMaterialProps,
	/// @member Resets shader.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	ResetShader,
	/// @member Enables/disables alpha testing.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuAlphaTestEnable,
	/// @member Configures the alpha testing threshold value.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuAlphaTestRef,
	/// @member Enables/disables alpha blending.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuBlendEnable,
	/// @member Sets a blend mode.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuBlendMode,
	/// @member Sets source and destination blend modes.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuBlendModeExt,
	/// @member Sets source and destination blend modes with separate blend modes
	/// for the alpha channel.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuBlendModeExtSepAlpha,
	/// @member Enables/disables writing into individual color channels.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuColorWriteEnable,
	/// @member Sets the culling mode.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuCullMode,
	/// @member Sets the z coordinate at which are sprites and text drawn.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuDepth,
	/// @member Configures fog.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuFog,
	/// @member Sets the GPU state.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuState,
	/// @member Enables/disables texture filtering.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexFilter,
	/// @member Enables/disables texture filtering for a specific sampler.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexFilterExt,
	/// @member Sets maximum anisotropy.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMaxAniso,
	/// @member Sets maximum anisotropy for a specific sampler.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMaxAnisoExt,
	/// @member Sets maximum mipmap level.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMaxMip,
	/// @member Sets maximum mipmap level for a specific sampler.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMaxMipExt,
	/// @member Sets minimum mipmap level.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMinMip,
	/// @member Sets minimum mipmap level for a specific sampler.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMinMipExt,
	/// @member Sets mipmapping bias.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMipBias,
	/// @member Sets mipmapping bias for a specific sampler.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMipBiasExt,
	/// @member Enables/disables mipmapping.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMipEnable,
	/// @member Enables/disables mipmapping for a specific sampler.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMipEnableExt,
	/// @member Sets mipmap filter function.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMipFilter,
	/// @member Sets mipmap filter function for a specific sampler.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexMipFilterExt,
	/// @member Enables/disables texture repeat.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexRepeat,
	/// @member Enables/disables texture repeat for a specific sampler.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuTexRepeatExt,
	/// @member Sets the depth buffer test function.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuZFunc,
	/// @member Enables/disables testing against the depth buffer.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuZTestEnable,
	/// @member Enables/disables writing to the depth buffer.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetGpuZWriteEnable,
	/// @member Sets current material property block.
	/// @see BBMOD_MaterialPropertyBlock
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetMaterialProps,
	/// @member Sets the projection matrix.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetProjectionMatrix,
	/// @member Sets a shader texture sampler.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetSampler,
	/// @member Sets a shader.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetShader,
	/// @member Sets a float shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformFloat,
	/// @member Sets a float2 shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformFloat2,
	/// @member Sets a float3 shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformFloat3,
	/// @member Sets a float4 shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformFloat4,
	/// @member Sets a float array shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformFloatArray,
	/// @member Sets an int shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformInt,
	/// @member Sets an int2 shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformInt2,
	/// @member Sets an int3 shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformInt3,
	/// @member Sets an int4 shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformInt4,
	/// @member Sets an int array shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformIntArray,
	/// @member Sets a matrix shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformMatrix,
	/// @member Sets a matrix array shader uniform.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetUniformMatrixArray,
	/// @member Sets the view matrix.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetViewMatrix,
	/// @member Sets the world matrix.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SetWorldMatrix,
	/// @member Submits another render queue.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SubmitRenderQueue,
	/// @member Submits a vertex buffer.
	/// @obsolete This command is obsolete. Use `Draw*` commands instead.
	SubmitVertexBuffer,
};
