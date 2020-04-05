/// @func bbmod_material_create([diffuse[, normal]])
/// @desc Creates a new Material structure.
/// @param {ptr} [diffuse] A diffuse texture.
/// @param {ptr} [normal] A normal texture.
/// @return {array} The created Material structure.
var _mat = array_create(BBMOD_EMaterial.SIZE, -1);

_mat[@ BBMOD_EMaterial.RenderPath] = BBMOD_RENDER_FORWARD;
_mat[@ BBMOD_EMaterial.Shader] = BBMOD_ShDefault;
_mat[@ BBMOD_EMaterial.OnApply] = bbmod_material_on_apply_default;
_mat[@ BBMOD_EMaterial.BlendMode] = bm_normal;
_mat[@ BBMOD_EMaterial.Culling] = cull_counterclockwise;

_mat[@ BBMOD_EMaterial.Diffuse] = (argument_count > 0) ? argument[0]
	: sprite_get_texture(BBMOD_SprDefaultMaterial, 0);

_mat[@ BBMOD_EMaterial.Normal] = (argument_count > 1) ? argument[1]
	: sprite_get_texture(BBMOD_SprDefaultMaterial, 1);

return _mat;