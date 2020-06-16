/// @func _bbmod_node_to_static_batch(model, node, static_batch, transform)
/// @param {array} model
/// @param {array} node
/// @param {array} static_batch
/// @param {array} transform
var _model = argument0;
var _node = argument1;
var _static_batch = argument2;
var _transform = argument3;

var _meshes = _node[BBMOD_ENode.Meshes];
var _children = _node[BBMOD_ENode.Children];
var i/*:int*/= 0;

repeat (array_length_1d(_meshes))
{
	_bbmod_mesh_to_static_batch(_model, _meshes[i++], _static_batch, _transform);
}

i = 0;
repeat (array_length_1d(_children))
{
	_bbmod_node_to_static_batch(_model, _children[i++], _static_batch, _transform);
}