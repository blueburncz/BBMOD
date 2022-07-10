/// @func BBMOD_PBRMaterial([_shader])
///
/// @extends BBMOD_DefaultMaterial
///
/// @desc A PBR material using the metallic-rougness workflow.
///
/// @param {Struct.BBMOD_Shader} [_shader] A shader that the material uses in
/// the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you would
/// like to use {@link BBMOD_BaseMaterial.set_shader} to specify shaders used in
/// specific render passes.
///
/// @obsolete Please use {@link BBMOD_DefaultMaterial} instead.
function BBMOD_PBRMaterial(_shader=undefined)
	: BBMOD_DefaultMaterial(_shader) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static clone = function () {
		var _clone = new BBMOD_PBRMaterial();
		copy(_clone);
		return _clone;
	};
}
