/// @func bbmod_render(model[, materials[, transform]])
/// @desc Submits a Model for rendering.
/// @param {array} model A Model structure.
/// @param {array} [materials] An array of Material structures, one for each
/// material slot of the Model. If not specified, then the default material
/// is used for each slot.
/// @param {array/undefined} [transform] An array of transformation matrices
/// (for animated models) or `undefined`.
gml_pragma("forceinline");

var _model = argument[0];
var _materials = (argument_count > 1)
	? argument[1]
	: array_create(_model[BBMOD_EModel.MaterialCount], BBMOD_MATERIAL_DEFAULT);
var _transform = (argument_count > 2) ? argument[2] : undefined;
var _render_pass = global.bbmod_render_pass;

var i = 0;
repeat (array_length_1d(_materials))
{
	var _material = _materials[i++];
	if ((_material[BBMOD_EMaterial.RenderPath] & _render_pass) == 0)
	{
		// Do not render the model if it doesn't use any material that can be
		// used in the current render pass.
		return;
	}
}

bbmod_node_render(
	_model,
	array_get(_model, BBMOD_EModel.RootNode),
	_materials,
	_transform);