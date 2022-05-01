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

	/// @var {Id.DsList.Struct.BBMOD_RenderCommand} A list of render commands using this
	/// material.
	/// @readonly

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

	/// @func submit_queue()
	/// @desc Submits all render commands without clearing the render queue.
	/// @return {BBMOD_BaseMaterial} Returns `self`.
	/// @see BBMOD_BaseMaterial.clear_queue
	/// @see BBMOD_BaseMaterial.RenderCommands
	/// @see BBMOD_RenderCommand

	/// @func clear_queue()
	/// @desc Clears the queue of render commands.
	/// @return {BBMOD_BaseMaterial} Returns `self`.

	static destroy = function () {
		method(self, Super_Material.destroy)();
		ds_list_destroy(RenderCommands);
	};
}