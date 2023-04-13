/// @func BBMOD_MaterialPropertyBlock()
///
/// @extends BBMOD_Class
///
/// @desc
///
/// @see BBMOD_Material
function BBMOD_MaterialPropertyBlock()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {Struct}
	/// @private
	__props = {};

	static add_property = function () {
		
	};

	static destroy = function () {
		Class_destroy();
		return undefined;
	};
}
