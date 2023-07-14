/// @module Core

/// @func BBMOD_IMeshRenderQueue()
///
/// @interface
///
/// @implements {BBMOD_IDestructible}
///
/// @desc An interface for render queues that can draw meshes.
function BBMOD_IMeshRenderQueue()
{
	/// @func set_priority(_p)
	///
	/// @desc Changes the priority of the render queue. Render queues with lower
	/// priority come first in the array returned by {@link bbmod_render_queues_get}.
	///
	/// @param {Real} _p The new priority of the render queue.
	///
	/// @return {Struct.BBMOD_IMeshRenderQueue} Returns `self`.
	static set_priority = __bbmod_throw_not_implemented_exception;

	/// @func DrawMesh(_mesh, _material, _matrix)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMesh} command into the
	/// queue.
	///
	/// @param {Struct.BBMOD_Mesh} _mesh The mesh to draw.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array<Real>} _matrix The world matrix.
	///
	/// @return {Struct.BBMOD_IMeshRenderQueue} Returns `self`.
	static DrawMesh = __bbmod_throw_not_implemented_exception;

	/// @func DrawMeshAnimated(_mesh_material, _matrix, _boneTransform)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMeshAnimated} command into
	/// the queue.
	///
	/// @param {Struct.BBMOD_Mesh} _mesh The mesh to draw.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array<Real>} _matrix The world matrix.
	/// @param {Array<Real>} _boneTransform An array with bone transformation
	/// data.
	///
	/// @return {Struct.BBMOD_IMeshRenderQueue} Returns `self`.
	static DrawMeshAnimated = __bbmod_throw_not_implemented_exception;

	/// @func DrawMeshBatched(_mesh, _material, _matrix, _batchData)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMeshBatched} command into
	/// the queue.
	///
	/// @param {Struct.BBMOD_Mesh} _mesh The mesh to draw.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array<Real>} _matrix The world matrix.
	/// @param {Array<Real>, Array<Array<Real>>} _batchData Either a single array
	/// of batch data or an array of arrays of batch data.
	///
	/// @return {Struct.BBMOD_IMeshRenderQueue} Returns `self`.
	static DrawMeshBatched = __bbmod_throw_not_implemented_exception;

	/// @func is_empty()
	///
	/// @desc Checks whether the render queue is empty.
	///
	/// @return {Bool} Returns `true` if there are no commands in the render
	/// queue.
	static is_empty = __bbmod_throw_not_implemented_exception;

	/// @func has_commands(_renderPass)
	///
	/// @desc Checks whether the render queue has commands for given render pass.
	///
	/// @param {Real} _renderPass The render pass.
	///
	/// @return {Bool} Returns `true` if the render queue has commands for given
	/// render pass.
	///
	/// @see BBMOD_ERenderPass
	static has_commands = __bbmod_throw_not_implemented_exception;

	/// @func submit([_instances])
	///
	/// @desc Submits render commands.
	///
	/// @param {Id.DsList<Id.Instance>} [_instances] If specified then only
	/// meshes with an instance ID from the list are submitted. Defaults to
	/// `undefined`.
	///
	/// @return {Struct.BBMOD_IMeshRenderQueue} Returns `self`.
	///
	/// @see BBMOD_IMeshRenderQueue.has_commands
	/// @see BBMOD_IMeshRenderQueue.clear
	static submit = __bbmod_throw_not_implemented_exception;

	/// @func clear()
	///
	/// @desc Clears the render queue.
	///
	/// @return {Struct.BBMOD_IMeshRenderQueue} Returns `self`.
	static clear = __bbmod_throw_not_implemented_exception;

	static destroy = __bbmod_throw_not_implemented_exception;
}
