/// @module PostProcessing

/// @func BBMOD_LensFlaresEffect()
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Draws lens flares added with {@link bbmod_lens_flare_add}.
///
/// @see BBMOD_LensFlare
function BBMOD_LensFlaresEffect()
	: BBMOD_PostProcessEffect() constructor
{
	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		if (_depth == undefined)
		{
			return _surfaceSrc;
		}
		surface_set_target(_surfaceDest);
		draw_surface(_surfaceSrc, 0, 0);
		gpu_push_state();
		gpu_set_blendenable(true);
		var _lensFlares = global.__bbmodLensFlares;
		for (var i = array_length(_lensFlares) - 1; i >= 0; --i)
		{
			_lensFlares[i].draw(PostProcessor, _depth);
		}
		gpu_pop_state();
		surface_reset_target();
		return _surfaceDest;
	};
}
