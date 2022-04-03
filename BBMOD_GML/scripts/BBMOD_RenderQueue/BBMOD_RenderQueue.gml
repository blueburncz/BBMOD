/// @var {Array.Struct.BBMOD_RenderQueue} Array of all existing render queues.
/// @see BBMOD_RenderQueue
/// @readonly
global.bbmod_render_queues = [];

/// @func BBMOD_RenderQueue([_name])
/// @extends BBMOD_Class
/// @desc A cointainer of render commands.
/// @param {String/Undefined} [_name] The name of the render queue. Defaults to
/// "RenderQueue" + number of created render queues - 1, e.g. "RenderQueue0",
/// "RenderQueue1" etc.
/// @see BBMOD_ERenderCommand
function BBMOD_RenderQueue(_name=undefined)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	static IdNext = 0;

	/// @var {String} The name of the render queue. This can be useful for
	/// debugging purposes.
	Name = _name ?? ("RenderQueue" + string(IdNext++));

	/// @var {Id.DsList.Struct.BBMOD_RenderCommand}
	/// @private
	/// @see BBMOD_RenderCommand
	RenderCommands = ds_list_create();

	/// @var {Real}
	/// @readonly
	Priority = 0;

	/// @func set_priority(_p)
	/// @desc Changes the priority of the render queue. Render queues with lower
	/// priority come first in the {@link global.bbmod_render_queues} array.
	/// @param {Real} _p The new priority of the render queue.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_priority = function (_p) {
		gml_pragma("forceinline");
		Priority = _p;
		__bbmod_reindex_render_queues();
		return self;
	};

	/// @func draw_mesh(_vertexBuffer, _matrix, _material)
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMesh} command into the queue.
	/// @param {Id.VertexBuffer} _vertexBuffer The vertex buffer to draw.
	/// @param {Array.Real} _matrix The world matrix.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static draw_mesh = function (_vertexBuffer, _matrix, _material) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.DrawMesh,
			_material,
			_matrix,
			_vertexBuffer);
		return self;
	};

	/// @func draw_mesh_animated(_vertexBuffer, _matrix, _material, _boneTransform)
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMeshAnimated} command into the queue.
	/// @param {Id.VertexBuffer} _vertexBuffer The vertex buffer to draw.
	/// @param {Array.Real} _matrix The world matrix.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array.Real} _boneTransform An array with bone transformation data.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static draw_mesh_animated = function (_vertexBuffer, _matrix, _material, _boneTransform) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.DrawMeshAnimated,
			_material,
			_matrix,
			_boneTransform,
			_vertexBuffer);
		return self;
	};

	/// @func draw_mesh_batched(_vertexBuffer, _matrix, _material, _batchData)
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMeshBatched} command into the queue.
	/// @param {Id.VertexBuffer} _vertexBuffer The vertex buffer to draw.
	/// @param {Array.Real} _matrix The world matrix.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array.Real} _batchData An array with batch data.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static draw_mesh_batched = function (_vertexBuffer, _matrix, _material, _batchData) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.DrawMeshBatched,
			_material,
			_matrix,
			_batchData,
			_vertexBuffer);
		return self;
	};

	/// @func is_empty()
	/// @desc Checks whether the render queue is empty.
	/// @return {Bool} Returns `true` if there are no commands in the render queue.
	static is_empty = function () {
		gml_pragma("forceinline");
		return ds_list_empty(RenderCommands);
	};

	/// @func submit()
	/// @desc Submits all commands.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	/// @see BBMOD_RenderQueue.clear
	static submit = function () {
		var i = 0;
		var _renderCommands = RenderCommands;
		var _renderCommandsCount = ds_list_size(_renderCommands);
		while (i < _renderCommandsCount)
		{
			switch (_renderCommands[| i++])
			{
			case BBMOD_ERenderCommand.DrawMesh:
				var _material = _renderCommands[| i++];
				if (!_material.apply())
				{
					i += 2;
					continue;
				}
				matrix_set(matrix_world, _renderCommands[| i++]);
				vertex_submit(_renderCommands[| i++], pr_trianglelist, _material.BaseOpacity);
				break;

			case BBMOD_ERenderCommand.DrawMeshAnimated:
				var _material = _renderCommands[| i++];
				if (!_material.apply())
				{
					i += 3;
					continue;
				}
				matrix_set(matrix_world, _renderCommands[| i++]);
				BBMOD_SHADER_CURRENT.set_bones(_renderCommands[| i++]);
				vertex_submit(_renderCommands[| i++], pr_trianglelist, _material.BaseOpacity);
				break;

			case BBMOD_ERenderCommand.DrawMeshBatched:
				var _material = _renderCommands[| i++];
				if (!_material.apply())
				{
					i += 3;
					continue;
				}
				matrix_set(matrix_world, _renderCommands[| i++]);
				BBMOD_SHADER_CURRENT.set_batch_data(_renderCommands[| i++]);
				vertex_submit(_renderCommands[| i++], pr_trianglelist, _material.BaseOpacity);
				break;
			}
		}
		return self;
	};

	/// @func clear()
	/// @desc Clears the render queue.
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static clear = function () {
		gml_pragma("forceinline");
		ds_list_clear(RenderCommands);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		__bbmod_remove_render_queue(self);
	};

	__bbmod_add_render_queue(self);
}

function __bbmod_add_render_queue(_renderQueue)
{
	gml_pragma("forceinline");
	array_push(global.bbmod_render_queues, _renderQueue);
	__bbmod_reindex_render_queues();
}

function __bbmod_remove_render_queue(_renderQueue)
{
	gml_pragma("forceinline");
	for (var i = 0; i < array_length(global.bbmod_render_queues); ++i)
	{
		if (global.bbmod_render_queues[i] == _renderQueue)
		{
			array_delete(global.bbmod_render_queues, i, 1);
			break;
		}
	}
	__bbmod_reindex_render_queues();
}

function __bbmod_reindex_render_queues()
{
	gml_pragma("forceinline");
	static _sortFn = function (_a, _b) {
		if (_b.Priority > _a.Priority) return -1;
		if (_b.Priority < _a.Priority) return +1;
		return 0;
	};
	array_sort(global.bbmod_render_queues, _sortFn);
}

function bbmod_get_default_render_queue()
{
	static _renderQueue = new BBMOD_RenderQueue("Default");
	return _renderQueue;
}
