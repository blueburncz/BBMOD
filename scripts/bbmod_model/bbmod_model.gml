/// @enum An enumeration of members of a Model structure.
enum BBMOD_EModel
{
	/// @member The version of the model file.
	Version,
	/// @member True if the model has vertices (always true).
	HasVertices,
	/// @member True if the model has normal vectors.
	HasNormals,
	/// @member True if the model has texture coordinates.
	HasTextureCoords,
	/// @member True if the model has vertex colors.
	HasColors,
	/// @member True if the model has tangent vectors and bitangent sign.
	HasTangentW,
	/// @member True if the model has vertex weights and bone indices.
	HasBones,
	/// @member The global inverse transform matrix.
	InverseTransformMatrix,
	/// @member The root Node structure.
	RootNode,
	/// @member Number of bones.
	BoneCount,
	/// @member The root Bone structure.
	Skeleton,
	/// @member Number of materials that the model uses.
	MaterialCount,
	/// @member Array of material names.
	MaterialNames,
	/// @member The size of the Model structure.
	SIZE
};

/// @func bbmod_model_load(_buffer, _version)
/// @desc Loads a Model structure from a buffer.
/// @param {real} _buffer The buffer to load the structure from.
/// @param {real} _version The version of the model file.
/// @return {array} The loaded Model structure.
function bbmod_model_load(_buffer, _version)
{
	var _vformat = undefined;
	var _bbmod = array_create(BBMOD_EModel.SIZE);

	// Header
	_bbmod[@ BBMOD_EModel.Version] = _version;

	var _has_vertices = buffer_read(_buffer, buffer_bool);
	_bbmod[@ BBMOD_EModel.HasVertices] = _has_vertices;

	var _has_normals = buffer_read(_buffer, buffer_bool);
	_bbmod[@ BBMOD_EModel.HasNormals] = _has_normals;

	var _has_uvs = buffer_read(_buffer, buffer_bool);
	_bbmod[@ BBMOD_EModel.HasTextureCoords] = _has_uvs;

	var _has_colors = buffer_read(_buffer, buffer_bool);
	_bbmod[@ BBMOD_EModel.HasColors] = _has_colors;

	var _has_tangentw = buffer_read(_buffer, buffer_bool);
	_bbmod[@ BBMOD_EModel.HasTangentW] = _has_tangentw;

	var _has_bones = buffer_read(_buffer, buffer_bool);
	_bbmod[@ BBMOD_EModel.HasBones] = _has_bones;

	// Global inverse transform matrix
	_bbmod[@ BBMOD_EModel.InverseTransformMatrix] = bbmod_load_matrix(_buffer);

	// Vertex format
	var _mask = (0
		| (_has_vertices << BBMOD_VFORMAT_VERTEX)
		| (_has_normals << BBMOD_VFORMAT_NORMAL)
		| (_has_uvs << BBMOD_VFORMAT_TEXCOORD)
		| (_has_colors << BBMOD_VFORMAT_COLOR)
		| (_has_tangentw << BBMOD_VFORMAT_TANGENTW)
		| (_has_bones << BBMOD_VFORMAT_BONES));

	if (is_undefined(_vformat))
	{
		_vformat = bbmod_get_vertex_format(
			_has_vertices,
			_has_normals,
			_has_uvs,
			_has_colors,
			_has_tangentw,
			_has_bones);
	}

	// Root node
	_bbmod[@ BBMOD_EModel.RootNode] = bbmod_node_load(_buffer, _vformat, _mask);

	// Skeleton
	var _bone_count = buffer_read(_buffer, buffer_u32);
	_bbmod[@ BBMOD_EModel.BoneCount] = _bone_count;

	if (_bone_count > 0)
	{
		_bbmod[@ BBMOD_EModel.Skeleton] = bbmod_bone_load(_buffer);
	}

	// Materials
	var _material_count = buffer_read(_buffer, buffer_u32);
	_bbmod[@ BBMOD_EModel.MaterialCount] = _material_count;

	if (_material_count > 0)
	{
		var _material_names = array_create(_material_count, 0);

		var i  = 0;
		repeat (_material_count)
		{
			_material_names[@ i++] = buffer_read(_buffer, buffer_string);
		}

		_bbmod[@ BBMOD_EModel.MaterialNames] = _material_names;
	}
	else
	{
		_bbmod[@ BBMOD_EModel.MaterialNames] = undefined;
	}

	return _bbmod;
}

/// @func bbmod_model_freeze(_model)
/// @desc Freezes all vertex buffers used by a model. This should make its
/// rendering faster, but it disables creating new batches of the model.
/// @param {array} _model The model to freeze.
function bbmod_model_freeze(_model)
{
	gml_pragma("forceinline");
	_bbmod_node_freeze(_model[BBMOD_EModel.RootNode]);
}

/// @func bbmod_model_find_bone_id(_model, _bone_name[, _bone])
/// @desc Seaches for a bone id assigned to given bone name.
/// @param {array} _model The Model structure.
/// @param {string} _bone_name The name of the Bone structure.
/// @param {array/undefined} [_bone] The Bone structure to start searching from.
/// Use `undefined` to use the model's root bone. Defaults to `undefined`.
/// @return {real/BBMOD_NONE} The id of the bone on success or `BBMOD_NONE` on fail.
/// @note It is not recommened to use this script in release builds, because having
/// many of these lookups can slow down your game! You should instead use the
/// ids available from the `_log.txt` files, which are created during model
/// conversion.
function bbmod_model_find_bone_id()
{
	var _model = argument[0];
	var _bone_name = argument[1];
	var _bone = (argument_count > 2) ? argument[2] : _model[BBMOD_EModel.Skeleton];

	if (_bone[BBMOD_EBone.Name] == _bone_name)
	{
		return _bone[BBMOD_EBone.Index];
	}

	var _children = _bone[BBMOD_EBone.Children];
	var i = 0;

	repeat (array_length(_children))
	{
		var _found = bbmod_model_find_bone_id(_model, _bone_name, _children[i++]);
		if (_found != BBMOD_NONE)
		{
			return _found;
		}
	}

	return BBMOD_NONE;
}

/// @func bbmod_model_get_bindpose_transform(_model)
/// @desc Creates a transformation array with model's bindpose.
/// @param {array} _model A Model structure.
/// @return {array} The created array.
function bbmod_model_get_bindpose_transform(_model)
{
	var _bone_count = _model[BBMOD_EModel.BoneCount];
	var _transform = array_create(_bone_count * 16, 0);
	var _matrix = matrix_build_identity();
	var i = 0;
	repeat (_bone_count)
	{
		array_copy(_transform, (i++) * 16, _matrix, 0, 16);
	}
	return _transform;
}

/// @func bbmod_model_get_vertex_format(_model[, _bones[, _ids]])
/// @desc Retrieves a vertex format of a model.
/// @param {array} _model The mode.
/// @param {bool} [_bones] Use `false` to disable bones. Defaults to `true`.
/// @param {bool} [_ids] Use `true` to force ids for dynamic batching. Defaults
/// to `false`.
/// @return {real} The vertex format.
function bbmod_model_get_vertex_format()
{
	gml_pragma("forceinline");
	var _model = argument[0];
	var _bones = (argument_count > 1) ? argument[1] : true;
	var _ids = (argument_count > 2) ? argument[2] : false;
	return bbmod_get_vertex_format(
		_model[BBMOD_EModel.HasVertices],
		_model[BBMOD_EModel.HasNormals],
		_model[BBMOD_EModel.HasTextureCoords],
		_model[BBMOD_EModel.HasColors],
		_model[BBMOD_EModel.HasTangentW],
		_bones ? _model[BBMOD_EModel.HasBones] : false,
		_ids);
}

/// @func _bbmod_model_to_dynamic_batch(_model, _dynamic_batch)
/// @param {array} _model
/// @param {array} _dynamic_batch
function _bbmod_model_to_dynamic_batch(_model, _dynamic_batch)
{
	gml_pragma("forceinline");
	_bbmod_node_to_dynamic_batch(_model[BBMOD_EModel.RootNode], _dynamic_batch);
}

/// @func _bbmod_model_to_static_batch(_model, _static_batch, _transform)
/// @param {array} _model
/// @param {array} _static_batch
/// @param {array} _transform
function _bbmod_model_to_static_batch(_model, _static_batch, _transform)
{
	gml_pragma("forceinline");
	_bbmod_node_to_static_batch(_model, _model[BBMOD_EModel.RootNode], _static_batch, _transform);
}

/// @func bbmod_render(_model[, _materials[, _transform]])
/// @desc Submits a Model for rendering.
/// @param {array} _model A Model structure.
/// @param {array/undefined} [_materials] An array of Material structures, one
/// for each material slot of the Model. If not specified, then the default
/// material is used for each slot. Default is `undefined`.
/// @param {array/undefined} [_transform] An array of transformation matrices
/// (for animated models) or `undefined`.
function bbmod_render()
{
	gml_pragma("forceinline");

	var _model = argument[0];
	var _materials = (argument_count > 1) ? argument[1] : undefined;
	var _transform = (argument_count > 2) ? argument[2] : undefined;
	var _render_pass = global.bbmod_render_pass;

	if (is_undefined(_materials))
	{
		_materials = array_create(
			_model[BBMOD_EModel.MaterialCount],
			is_undefined(_transform)
				? BBMOD_MATERIAL_DEFAULT
				: BBMOD_MATERIAL_DEFAULT_ANIMATED);
	}

	var i = 0;
	repeat (array_length(_materials))
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
}

/// @func BBMOD_Model(_file[, _sha1])
/// @desc An OOP wrapper around BBMOD_EModel.
/// @param {string} _file
/// @param {string} [_sha1]
function BBMOD_Model(_file) constructor
{
	var _sha1 = (argument_count > 1) ? argument[1] : undefined;

	/// @var {array} A BBMOD_EModel that this struct wraps.
	model = bbmod_load(_file, _sha1);
	if (model == BBMOD_NONE)
	{
		throw new BBMOD_Error("Could not load file " + _file);
	}

	static freeze = function () {
		bbmod_model_freeze(model);
	};

	/// @param {string} _bone_name
	/// @return {real} The id of the bone.
	static find_bone_id = function (_bone_name) {
		return bbmod_model_find_bone_id(model, _bone_name);
	};

	/// @return {array}
	static get_bindpose_transform = function () {
		return bbmod_model_get_bindpose_transform(model);
	};

	/// @param {bool} [_bones]
	/// @param {bool} [_ids]
	/// @return {real} The vertex format.
	static get_vertex_format = function () {
		var _bones = (argument_count > 0) ? argument[0] : true;
		var _ids = (argument_count > 1) ? argument[1] : false;
		return bbmod_model_get_vertex_format(model, _bones, _ids);
	};

	/// @param {BBMOD_Material[]} [_materials]
	/// @param {array} [_transform]
	static render = function () {
		var _materials = (argument_count > 0) ? argument[0] : undefined;
		var _transform = (argument_count > 1) ? argument[1] : undefined;

		_materials = ce_array_map(_materials, method(undefined, function (_m) {
			return _m.material;
		}));

		bbmod_render(model, _materials, _transform);
	};
}