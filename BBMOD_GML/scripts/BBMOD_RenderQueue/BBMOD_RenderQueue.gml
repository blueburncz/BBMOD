/// @var {Array.Struct.BBMOD_RenderQueue} Array of all existing render queues.
/// @see BBMOD_RenderQueue
/// @readonly
global.bbmod_render_queues = [];

/// @func BBMOD_RenderQueue([_name])
function BBMOD_RenderQueue(_name=undefined)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	static IdNext = 0;

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

	/// @func add(_renderCommand)
	/// @desc Adds a command into the render queue.
	/// @param {Struct.BBMOD_RenderCommand} _renderCommand The render command to add.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	/// @see BBMOD_RenderCommand
	static add = function (_renderCommand) {
		gml_pragma("forceinline");
		ds_list_add(RenderCommands, _renderCommand);
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
		var _matWorld = matrix_get(matrix_world);
		var i = 0;
		var _renderCommands = RenderCommands;

		repeat (ds_list_size(_renderCommands))
		{
			var _command = _renderCommands[| i++];
			var _commandMaterial = _command.Material;

			if (!_commandMaterial.apply())
			{
				continue;
			}

			var _matrix = _command.Matrix;
			if (_matrix != undefined
				&& !array_equals(_matWorld, _matrix))
			{
				matrix_set(matrix_world, _matrix);
				_matWorld = _matrix;
			}

			var _transform = _command.BoneTransform;
			if (_transform != undefined)
			{
				BBMOD_SHADER_CURRENT.set_bones(_transform);
			}

			var _data = _command.BatchData;
			if (_data != undefined)
			{
				BBMOD_SHADER_CURRENT.set_batch_data(_data);
			}

			var _vbuffer = _command.VertexBuffer;
			if (_vbuffer != undefined)
			{
				vertex_submit(_vbuffer, pr_trianglelist,
					_commandMaterial ? _commandMaterial.BaseOpacity : pointer_null);
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
