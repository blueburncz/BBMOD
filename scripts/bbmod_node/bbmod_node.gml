/// @enum An enumeration of members of a legacy node struct.
/// @see BBMOD_EModel.RootNode
enum BBMOD_ENode
{
	/// @member {string} The name of the node.
	/// @readonly
	Name,
	/// @member {int} The node index.
	/// @readonly
	Index,
	/// @member {bool} If `true` then the node is a bone.
	/// @readonly
	IsBone,
	/// @member {matrix} A transformation matrix of the node.
	/// @readonly
	TransformMatrix,
	/// @member {int[]} An array of meshes indices.
	/// @readonly
	Meshes,
	/// @member {BBMOD_ENode[]} An array of child nodes.
	/// @see BBMOD_ENode
	/// @readonly
	Children,
	/// @member The size of the struct.
	SIZE
};

/// @func bbmod_node_load(_buffer, _format)
/// @desc Loads a node from a buffer.
/// @param {buffer} _buffer The buffer to load the struct from.
/// @param {BBMOD_VertexFormat} _format A vertex format for node's meshes.
/// @return {BBMOD_ENode} The loaded node.
/// @private
function bbmod_node_load(_buffer, _format)
{
	var i;

	var _node = array_create(BBMOD_ENode.SIZE, undefined);
	_node[@ BBMOD_ENode.Name] = buffer_read(_buffer, buffer_string);
	_node[@ BBMOD_ENode.Index] = buffer_read(_buffer, buffer_f32);
	_node[@ BBMOD_ENode.IsBone] = buffer_read(_buffer, buffer_bool);
	_node[@ BBMOD_ENode.TransformMatrix] = bbmod_load_matrix(_buffer);

	// Meshes
	var _mesh_count = buffer_read(_buffer, buffer_u32);
	var _meshes = array_create(_mesh_count, undefined);

	_node[@ BBMOD_ENode.Meshes] = _meshes;

	i = 0;
	repeat (_mesh_count)
	{
		_meshes[@ i++] = buffer_read(_buffer, buffer_u32);
	}

	// Child nodes
	var _child_count = buffer_read(_buffer, buffer_u32);
	var _children = array_create(_child_count, undefined);
	_node[@ BBMOD_ENode.Children] = _children;

	i = 0;
	repeat (_child_count)
	{
		_children[@ i++] = bbmod_node_load(_buffer, _format);
	}

	return _node;
}

/// @func bbmod_node_render(_model, _node, _materials, _transform)
/// @desc Submits a node for rendering.
/// @param {BBMOD_Model} _model The model to which the node belongs.
/// @param {BBMOD_ENode} _node The node.
/// @param {BBMOD_Material[]} _materials An array of materials, one for each
/// material slot of the model.
/// @param {real[]/undefined} _transform An array of transformation matrices
/// (for animated models) or `undefined`.
/// @private
function bbmod_node_render(_model, _node, _materials, _transform)
{
	var _meshes = _model.Meshes;
	var _mesh_indices = _node[BBMOD_ENode.Meshes];
	var _children = _node[BBMOD_ENode.Children];
	var _render_pass = global.bbmod_render_pass;
	var i = 0;

	repeat (array_length(_mesh_indices))
	{
		var _mesh = _meshes[_mesh_indices[i++]];
		var _material_index = _mesh[BBMOD_EMesh.MaterialIndex];
		var _material = _materials[_material_index];

		if ((_material.RenderPath & _render_pass) == 0)
		{
			// Do not render the mesh if it doesn't use a material that can be used
			// in the current render path.
			continue;
		}

		if (_material.apply() && !is_undefined(_transform))
		{
			shader_set_uniform_f_array(shader_get_uniform(shader_current(), "u_mBones"), _transform);
		}

		var _tex_base = _material.BaseOpacity;
		vertex_submit(_mesh[BBMOD_EMesh.VertexBuffer], pr_trianglelist, _tex_base);
	}

	i = 0;
	repeat (array_length(_children))
	{
		bbmod_node_render(_model, _children[i++], _materials, _transform);
	}
}