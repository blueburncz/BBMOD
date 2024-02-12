/// @module PostProcessing

/// @func BBMOD_LensDirtEffect([_texture[, _bias[, _scale]]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Lens dirt (post-processing effect).
///
/// @param {Pointer.Texture} [_texture]
/// @param {Real} [_bias]
/// @param {Real} [_scale]
function BBMOD_LensDirtEffect(_texture=undefined, _bias=1.0, _scale=1.0)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Pointer.Texture}
	Texture = _texture ?? sprite_get_texture(BBMOD_SprLensDirt, 0);

	/// @var {Real}
	Bias = _bias;

	/// @var {Real}
	Scale = _scale;

	static __uLensDirtTex = shader_get_sampler_index(BBMOD_ShLensDirt, "u_texLensDirt");
	static __uLensDirtUVs = shader_get_uniform(BBMOD_ShLensDirt, "u_vLensDirtUVs");
	static __uBias = shader_get_uniform(BBMOD_ShLensDirt, "u_fBias");
	static __uScale = shader_get_uniform(BBMOD_ShLensDirt, "u_fScale");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShLensDirt);
		texture_set_stage(__uLensDirtTex, Texture);
		var _uvs = texture_get_uvs(Texture)
		shader_set_uniform_f(__uLensDirtUVs, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
		shader_set_uniform_f(__uBias, Bias);
		shader_set_uniform_f(__uScale, Scale);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();

		return _surfaceDest;
	};
}
