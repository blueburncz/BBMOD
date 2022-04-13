/// @func BBMOD_BaseMaterial([_shader])
/// @extends BBMOD_Material
/// @desc A material that can be used when rendering models.
/// @param {Struct.BBMOD_Shader/Undefined} [_shader] A shader that the material uses in
/// the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you would
/// like to use {@link BBMOD_BaseMaterial.set_shader} to specify shaders used in
/// specific render passes.
/// @see BBMOD_Shader
function BBMOD_BaseMaterial(_shader=undefined)
	: BBMOD_Material(_shader) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Material = {
		copy: copy,
		destroy: destroy,
	};

	/// @var {Struct.BBMOD_Vec2} An offset of texture UV coordinates. Defaults to `[0, 0]`.
	/// Using this you can control texture's position within texture page.
	TextureOffset = new BBMOD_Vec2(0.0);

	/// @var {Struct.BBMOD_Vec2} A scale of texture UV coordinates. Defaults to `[1, 1]`.
	/// Using this you can control texture's size within texture page.
	TextureScale = new BBMOD_Vec2(1.0);

	/// @var {Id.DsList<Struct.BBMOD_RenderCommand>} A list of render commands using this
	/// material.
	/// @readonly
	/// @obsolete This has been replaced with {@link BBMOD_Material.RenderQueue}.
	RenderCommands = ds_list_create();

	/// @func copy(_dest)
	/// @desc Copies properties of this material into another material.
	/// @param {Struct.BBMOD_BaseMaterial} _dest The destination material.
	/// @return {Struct.BBMOD_BaseMaterial} Returns `self`.
	static copy = function (_dest) {
		method(self, Super_Material.copy)(_dest);
		_dest.TextureOffset = TextureOffset.Clone();
		_dest.TextureScale = TextureScale.Clone();
		return self;
	};

	/// @func clone()
	/// @desc Creates a clone of the material.
	/// @return {Struct.BBMOD_BaseMaterial} The created clone.
	static clone = function () {
		var _clone = new BBMOD_BaseMaterial();
		copy(_clone);
		return _clone;
	};

	/// @func has_commands()
	/// @desc Checks whether the material has any render commands waiting for
	/// submission.
	/// @return {Bool} Returns true if the material's render queue is not empty.
	/// @obsolete Render commands are now stored in {@link BBMOD_Material.RenderQueue}.
	/// Please use {@link BBMOD_RenderQueue.is_empty} instead.
	static has_commands = function () {
		gml_pragma("forceinline");
		return !ds_list_empty(RenderCommands);
	};

	/// @func submit_queue()
	/// @desc Submits all render commands without clearing the render queue.
	/// @return {BBMOD_BaseMaterial} Returns `self`.
	/// @see BBMOD_BaseMaterial.clear_queue
	/// @see BBMOD_BaseMaterial.RenderCommands
	/// @see BBMOD_RenderCommand
	/// @obsolete Render commands are now stored in {@link BBMOD_Material.RenderQueue}.
	/// Please use {@link BBMOD_RenderQueue.submit} instead.
	static submit_queue = function () {
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

	/// @func clear_queue()
	/// @desc Clears the queue of render commands.
	/// @return {BBMOD_BaseMaterial} Returns `self`.
	/// @obsolete Render commands are now stored in {@link BBMOD_Material.RenderQueue}.
	/// Please use {@link BBMOD_RenderQueue.clear} instead.
	static clear_queue = function () {
		gml_pragma("forceinline");
		ds_list_clear(RenderCommands);
		return self;
	};

	static destroy = function () {
		method(self, Super_Material.destroy)();
		ds_list_destroy(RenderCommands);
	};
}