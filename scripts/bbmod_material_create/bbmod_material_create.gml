/// @func bbmod_material_create(shader, [base_opacity[, normal_roughness[, metallic_ao[, subsurface[, emissive]]]]])
/// @desc Creates a new Material structure.
/// @param {ptr} shader A shader that the material uses.
/// @param {ptr} [base_opacity] A texture with base color in RGB and opacity in alpha.
/// @param {ptr} [normal_roughness] A texture with normals in RGB and roughness in alpha.
/// @param {ptr} [metallic_ao] A texture with metallic in R and ambient occlusion in G.
/// @param {ptr} [subsurface] A texture with subsurface color in RGB and intensity in alpha.
/// @param {ptr} [emissive] A texture with RGBM encoded emissive color.
/// @return {array} The created Material structure.
var _mat = array_create(BBMOD_EMaterial.SIZE, -1);

_mat[@ BBMOD_EMaterial.RenderPath] = BBMOD_RENDER_FORWARD;
_mat[@ BBMOD_EMaterial.Shader] = argument[0];
_mat[@ BBMOD_EMaterial.OnApply] = bbmod_material_on_apply_default;
_mat[@ BBMOD_EMaterial.BlendMode] = bm_normal;
_mat[@ BBMOD_EMaterial.Culling] = cull_counterclockwise;
_mat[@ BBMOD_EMaterial.ZWrite] = true;
_mat[@ BBMOD_EMaterial.ZTest] = true;
_mat[@ BBMOD_EMaterial.ZFunc] = cmpfunc_lessequal;

_mat[@ BBMOD_EMaterial.BaseOpacity] = (argument_count > 1) ? argument[1]
	: sprite_get_texture(BBMOD_SprDefaultMaterial, 0);

_mat[@ BBMOD_EMaterial.NormalRoughness] = (argument_count > 2) ? argument[2]
	: sprite_get_texture(BBMOD_SprDefaultMaterial, 1);

_mat[@ BBMOD_EMaterial.MetallicAO] = (argument_count > 3) ? argument[3]
	: sprite_get_texture(BBMOD_SprDefaultMaterial, 2);

_mat[@ BBMOD_EMaterial.Subsurface] = (argument_count > 4) ? argument[4]
	: sprite_get_texture(BBMOD_SprDefaultMaterial, 3);

_mat[@ BBMOD_EMaterial.Emissive] = (argument_count > 5) ? argument[5]
	: sprite_get_texture(BBMOD_SprDefaultMaterial, 4);

return _mat;