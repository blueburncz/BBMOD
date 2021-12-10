/// @func BBMOD_Light()
/// @extends BBMOD_Class
/// @desc Base class for lights.
function BBMOD_Light()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {BBMOD_Vec3} The position of the light.
	Position = new BBMOD_Vec3();

	/// @var {bool} If `true` then the light should casts shadows.
	/// Defaults to `false`.
	CastShadows = false;
}