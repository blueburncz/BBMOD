/// @func b_bbmod_material_create([diffuse[, normal]])
/// @param {ptr} [diffuse] The diffuse texture.
/// @param {ptr} [normal] The normal texture.
var _mat = array_create(B_EBBMODMaterial.SIZE, -1);

_mat[@ B_EBBMODMaterial.RenderPath] = B_BBMOD_RENDER_FORWARD;
// FIXME: Use default BBMOD shader here.
_mat[@ B_EBBMODMaterial.Shader] = ShDemo;
_mat[@ B_EBBMODMaterial.BlendMode] = bm_normal;
_mat[@ B_EBBMODMaterial.Culling] = cull_counterclockwise;

_mat[@ B_EBBMODMaterial.Diffuse] = (argument_count > 0) ? argument[0]
	: sprite_get_texture(B_SprBBMODDefaultMaterial, 0);

_mat[@ B_EBBMODMaterial.Normal] = (argument_count > 1) ? argument[1]
	: sprite_get_texture(B_SprBBMODDefaultMaterial, 1);

return _mat;