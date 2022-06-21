/// @func bbmod_model_to_colmesh(_model, _colmesh[, _transform])
///
/// @desc Adds a {@link BBMOD_Model} into a colmesh.
///
/// @param {Struct.BBMOD_Model} _model The model to add.
/// @param {Struct.colmesh} _colmesh The colmesh to add the model to.
/// @param {Array<Real>} [_transform] A matrix to transform the model with
/// before it is added to the colmesh. Leave `undefined` if you do not wish to
/// transform the model.
///
/// @see https://marketplace.yoyogames.com/assets/8130/colmesh
function bbmod_model_to_colmesh(_model, _colmesh, _transform=undefined)
{
	static _stack = ds_stack_create();

	var _meshes = _model.Meshes;

	ds_stack_push(_stack, _model.RootNode);

	while (!ds_stack_empty(_stack))
	{
		var _node = ds_stack_pop(_stack);

		if (!_node.IsRenderable || !_node.Visible)
		{
			continue;
		}

		var _meshIndices = _node.Meshes;
		var _children = _node.Children;
		var i = 0;

		repeat (array_length(_meshIndices))
		{
			var _mesh = _meshes[_meshIndices[i++]];
			bbmod_mesh_to_colmesh(_mesh, _colmesh, _transform);
		}

		i = 0;
		repeat (array_length(_children))
		{
			ds_stack_push(_stack, _children[i++]);
		}
	}
}
