/// @func BBMOD_RenderQueue()
/// @extends BBMOD_Class
function BBMOD_RenderQueue()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Id.DsList.BBMOD_RenderCommand} Commands to submit.
	/// @readonly
	RenderCommands = ds_list_create();

	/// @func add(_renderCommand)
	/// @desc Adds a render command to the queue.
	/// @param {Struct.BBMOD_RenderCommand} _renderCommand The render command to add.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	/// @see BBMOD_RenderCommand
	static add = function (_renderCommand) {
		gml_pragma("forceinline");
		ds_list_add(RenderCommands, _renderCommand);
		return self;
	};

	/// @func is_empty()
	/// @desc Checks whether there are any commands in the queue.
	/// @return {Bool} Returns `true` if there are no commands in the queue.
	static is_empty = function () {
		gml_pragma("forceinline");
		return ds_list_empty(RenderCommands);
	};

	/// @func submit()
	/// @desc Submits all commands without clearing the queue.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	/// @see BBMOD_RenderQueue.clear
	static submit = function () {
		var _matWorld = matrix_get(matrix_world);
		var i = 0;

		var _shaderCurrent = BBMOD_SHADER_CURRENT;
		var _setBones = method(_shaderCurrent, _shaderCurrent.set_bones);
		var _setData = method(_shaderCurrent, _shaderCurrent.set_batch_data);
		var _renderCommands = RenderCommands;

		repeat (ds_list_size(_renderCommands))
		{
			var _command = _renderCommands[| i++];

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
				_setBones(_transform);
			}

			var _data = _command.BatchData;
			if (_data != undefined)
			{
				_setData(_data);
			}

			var _vbuffer = _command.VertexBuffer;
			if (_vbuffer != undefined)
			{
				vertex_submit(_vbuffer, pr_trianglelist, _command.Texture);
			}
		}

		return self;
	};

	/// @func clear()
	/// @desc Clears the queue.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static clear = function () {
		gml_pragma("forceinline");
		ds_list_clear(RenderCommands);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		ds_list_destroy(RenderCommands);
	};
}