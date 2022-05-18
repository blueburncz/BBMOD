/// @func BBMOD_BaseMaterial([_shader])
/// @extends BBMOD_Material
/// @desc A material that can be used when rendering models.
/// @param {Struct.BBMOD_Shader/Undefined} [_shader] A shader that the material uses in
/// the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you would
/// like to use {@link BBMOD_Material.set_shader} to specify shaders used in
/// specific render passes.
/// @see BBMOD_Shader
function BBMOD_BaseMaterial(_shader=undefined)
	: BBMOD_Material(_shader) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Material = {
		copy: copy,
	};

	/// @var {Struct.BBMOD_Color} Multiplier for {@link BBMOD_Material.BaseOpacity}.
	/// Default value is {@link BBMOD_C_WHITE}.
	BaseOpacityMultiplier = BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Vec2} An offset of texture UV coordinates. Defaults to `(0, 0)`.
	/// Using this you can control texture's position within texture page.
	TextureOffset = new BBMOD_Vec2(0.0);

	/// @var {Struct.BBMOD_Vec2} A scale of texture UV coordinates. Defaults to `(1, 1)`.
	/// Using this you can control texture's size within texture page.
	TextureScale = new BBMOD_Vec2(1.0);

	/// @func copy(_dest)
	/// @desc Copies properties of this material into another material.
	/// @param {Struct.BBMOD_BaseMaterial} _dest The destination material.
	/// @return {Struct.BBMOD_BaseMaterial} Returns `self`.
	static copy = function (_dest) {
		method(self, Super_Material.copy)(_dest);
		BaseOpacityMultiplier.Copy(_dest.BaseOpacityMultiplier);
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
}