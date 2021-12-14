/// @func BBMOD_Light()
/// @extends BBMOD_Class
/// @desc Base class for lights.
/// @see BBMOD_DirectionalLight
/// @see BBMOD_ImageBasedLight
/// @see BBMOD_PointLight
function BBMOD_Light()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {bool} Use `false` to disable the light. Defaults to `true` (the
	/// light is enabled).
	Enabled = true;

	/// @var {BBMOD_Vec3} The position of the light.
	Position = new BBMOD_Vec3();

	/// @var {bool} If `true` then the light should casts shadows.
	/// Defaults to `false`.
	CastShadows = false;
}