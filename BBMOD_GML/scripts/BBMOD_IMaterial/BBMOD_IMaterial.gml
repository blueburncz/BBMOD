/// @func BBMOD_IMaterial()
///
/// @interface
///
/// @desc Interface for the most basic BBMOD materials that can be used with the
/// {@link BBMOD_Model.submit} method.
function BBMOD_IMaterial()
{
	/// @var {Pointer.Texture} A texture with a base color in the RGB channels
	/// and opacity in the alpha channel.
	BaseOpacity = pointer_null;

	/// @func apply(_vertexFormat)
	///
	/// @desc Tries to apply the material and make it the current one.
	///
	/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format of
	/// meshes that we are going to use the material for.
	///
	/// @return {Bool} Returns `true` if the material was applied. If `false`
	/// is returned instead, then meshes that were going to use it are not
	/// rendered.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static apply = __bbmod_throw_not_implemented_exception;
}
