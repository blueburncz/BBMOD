/// @func BBMOD_NormalDistortionEffect(_texture[, _strength])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Distort screen using a normal map texture (post-processing effect).
///
/// @param {Pointer.Texture} _texture A normal map texture.
/// @param {Real} _strength The strength of the effect. Both positive and
/// negative values can be used. Use 0 to disable the effect. Default value is 1.
function BBMOD_NormalDistortionEffect(_texture, _strength=1.0)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Pointer.Texture} A normal map texture.
	Texture = _texture;

	/// @var {Real} The strength of the effect. Both positive and negative values
	/// can be used. Use 0 to disable the effect. Default value is 1.
	Strength = _strength;

	static __uNormal    = shader_get_sampler_index(BBMOD_ShNormalDistortion, "u_texNormal");
	static __uNormalUVs = shader_get_uniform(BBMOD_ShNormalDistortion, "u_vNormalUVs");
	static __uStrength  = shader_get_uniform(BBMOD_ShNormalDistortion, "u_fStrength");
	static __uTexel     = shader_get_uniform(BBMOD_ShNormalDistortion, "u_vTexel");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShNormalDistortion);
		texture_set_stage(__uNormal, Texture);
		var _uvs = texture_get_uvs(Texture);
		shader_set_uniform_f(__uNormalUVs, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
		shader_set_uniform_f(__uStrength, Strength);
		shader_set_uniform_f(__uTexel, 1.0 / surface_get_width(_surfaceDest), 1.0 / surface_get_height(_surfaceDest));
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};
}
