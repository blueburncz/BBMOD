/// @enum An enumeration of all possible render commands.
enum BBMOD_ERenderCommand
{
	/// @member Applies a material if it has a shader that can be used in the
	/// current render pass.
	ApplyMaterial,
	/// @member Marks the beginning of a conditional block. Commands within this
	/// block are executed only if the last command was successfully executed.
	/// @example
	/// ```gml
	/// renderQueue.apply_material(material)
	///     .begin_conditional_block()
	///     // Commands here will be executed only if the material was applied...
	///     .end_conditional_block();
	/// ```
	/// @see BBMOD_ERenderCommand.EndConditionalBlock
	BeginConditionalBlock,
	/// @member Draws a mesh if its material can be used in the current render
	/// pass.
	DrawMesh,
	/// @member Draws an animated mesh if its material can be used in the current
	/// render pass.
	DrawMeshAnimated,
	/// @member Draws a dynamically batched mesh if its material can be used in
	/// the current render pass.
	DrawMeshBatched,
	/// @member Marks the end of a conditional block.
	/// @see BBMOD_ERenderCommand.BeginConditionalBlock
	EndConditionalBlock,
};
