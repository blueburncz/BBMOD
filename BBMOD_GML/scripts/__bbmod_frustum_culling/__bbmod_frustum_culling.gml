/// @module Core

/// @var {Bool}
/// @private
global.__bbmodFrustumCulling = true;

/// @func bbmod_get_frustum_culling()
///
/// @desc Retrieves whether automatic frustum culling is enabled.
/// When enabled, meshes and terrain chunks are tested against the view
/// frustum using their bounding spheres and skipped if not visible.
///
/// @return {Bool} Returns `true` if frustum culling is enabled.
///
/// @see bbmod_set_frustum_culling
function bbmod_get_frustum_culling()
{
	gml_pragma("forceinline");
	return global.__bbmodFrustumCulling;
}

/// @func bbmod_set_frustum_culling(_enable)
///
/// @desc Enables or disables automatic frustum culling.
/// When enabled, meshes and terrain chunks outside the view frustum are
/// automatically skipped during rendering, improving performance. When
/// disabled, all objects are rendered regardless of visibility.
///
/// @param {Bool} _enable Set to `true` to enable frustum culling or `false`
/// to disable it.
///
/// @see bbmod_get_frustum_culling
function bbmod_set_frustum_culling(_enable)
{
	gml_pragma("forceinline");
	global.__bbmodFrustumCulling = _enable;
}
