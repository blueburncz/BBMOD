/// @func BBMOD_ChromaticAberrationEffect([_strength[, _offset]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Chromatic aberration (post-processing effect).
///
/// @param {Real} _strength The strength of the effect. Defaults to 1 if
/// `undefined`.
/// @param {Struct.BBMOD_Vec3} _offset Offsets for RGB channels. Defaults to
/// `(-1, 0, 1)` if `undefined`.
function BBMOD_ChromaticAberrationEffect(_strength=1.0, _offset=undefined)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Real} The strength of the effect. Default value is 1.
	Strength = _strength;

	/// @var {Struct.BBMOD_Vec3} Offsets for RGB channels. Default value is
	/// `(-1, 0, 1)`.
	Offset = _offset ?? new BBMOD_Vec3(-1.0, 0.0, 1.0);

	__uTexel = shader_get_uniform(BBMOD_ShChromaticAberration, "u_vTexel");
	__uOffset = shader_get_uniform(BBMOD_ShChromaticAberration, "u_vOffset");
	__uDistortion = shader_get_uniform(BBMOD_ShChromaticAberration, "u_fDistortion");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShChromaticAberration);
		shader_set_uniform_f(
			__uTexel,
			1.0 / surface_get_width(_surfaceSrc),
			1.0 / surface_get_height(_surfaceSrc));
		shader_set_uniform_f(
			__uOffset,
			Offset.X,
			Offset.Y,
			Offset.Z);
		shader_set_uniform_f(__uDistortion, Strength);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();

		return self;
	};
}
