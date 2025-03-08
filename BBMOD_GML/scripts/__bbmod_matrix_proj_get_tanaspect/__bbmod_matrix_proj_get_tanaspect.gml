/// @func __bbmod_matrix_proj_get_tanaspect(_matProj)
///
/// @desc
///
/// @param {Array<Real>} _matProj
///
/// @return {Array<Real>}
///
/// @private
function __bbmod_matrix_proj_get_tanaspect(_matProj)
{
	gml_pragma("forceinline");
	return (_matProj[11] == 0.0) ? [1.0, -1.0] // Ortho
		: [1.0 / _matProj[0], -1.0 / _matProj[5]]; // Perspective
}
