/// @enum An enumeration of members of a legacy model struct.
/// @deprecated This legacy struct is deprecated. Please use
/// {@link BBMOD_Model} instead.
enum BBMOD_EModel
{
	/// @member {real} The version of the model file.
	/// @readonly
	Version,
	/// @member {bool} If `true` then the model has vertices (always `true`).
	/// @readonly
	HasVertices,
	/// @member {bool} If `true` then the model has normal vectors.
	/// @readonly
	HasNormals,
	/// @member {bool} If `true` then the model has texture coordinates.
	/// @readonly
	HasTextureCoords,
	/// @member {bool} If `true` then the model has vertex colors.
	/// @readonly
	HasColors,
	/// @member {bool} If `true` then the model has tangent vectors and bitangent sign.
	/// @readonly
	HasTangentW,
	/// @member {bool} If `true` then the model has vertex weights and bone indices.
	/// @readonly
	HasBones,
	/// @member {real[]} The global inverse transform matrix.
	/// @readonly
	InverseTransformMatrix,
	/// @member {BBMOD_ENode} The root node.
	/// @see BBMOD_ENode
	/// @readonly
	RootNode,
	/// @member {real} Number of bones.
	/// @readonly
	BoneCount,
	/// @member {BBMOD_EBone} The root bone.
	/// @see BBMOD_EBone
	/// @readonly
	Skeleton,
	/// @member {real} Number of materials that the model uses.
	/// @see BBMOD_EMaterial
	/// @readonly
	MaterialCount,
	/// @member {string[]} Array of material names.
	/// @see BBMOD_EMaterial
	/// @readonly
	MaterialNames,
	/// @member The size of the struct.
	SIZE
};

/// @func bbmod_model_load(_buffer, _version)
/// @desc Loads a model from a buffer.
/// @param {buffer} _buffer The buffer to load the struct from.
/// @param {real} _version The version of the model file.
/// @return {BBMOD_EModel} The loaded model.
/// @private
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

/// @func bbmod_model_destroy(_model)
/// @desc Destroys a model.
/// @param {BBMOD_EModel} _model The model to destroy.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Model.destroy}
/// instead.
function bbmod_model_destroy(_model)
{
	bbmod_node_destroy(_model[BBMOD_EModel.RootNode]);
}

/// @func bbmod_model_freeze(_model)
/// @desc Freezes all vertex buffers used by a model. This should make its
/// rendering faster, but it disables creating new batches of the model.
/// @param {BBMOD_EModel} _model The model to freeze.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Model.freeze}
/// instead.
function bbmod_model_freeze(_model)
{
	gml_pragma("forceinline");
	_bbmod_node_freeze(_model[BBMOD_EModel.RootNode]);
}

/// @func bbmod_model_find_bone_id(_model, _bone_name[, _bone])
/// @desc Seaches for a bone id assigned to given bone name.
/// @param {BBMOD_EModel} _model The model.
/// @param {string} _bone_name The name of the bone.
/// @param {BBMOD_EBone/undefined} [_bone] The bone to start searching
/// from. Use `undefined` to use the model's root bone. Defaults to `undefined`.
/// @return {real/BBMOD_NONE} The id of the bone on success or {@link BBMOD_NONE}
/// on fail.
/// @note It is not recommened to use this script in release builds, because having
/// many of these lookups can slow down your game! You should instead use the
/// ids available from the `_log.txt` files, which are created during model
/// conversion.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Model.find_bone_id}
/// instead.
function bbmod_model_find_bone_id(_model, _bone_name)
{
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
/// @param {BBMOD_EModel} _model A model.
/// @return {real[]} The created array.
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
/// @param {BBMOD_EModel} _model The model.
/// @param {bool} [_bones] Use `false` to disable bones. Defaults to `true`.
/// @param {bool} [_ids] Use `true` to force ids for dynamic batching. Defaults
/// to `false`.
/// @return {real} The vertex format.
/// @deprecated This function is deprecated. Please use
/// {@link BBMOD_Model.get_vertex_format} instead.
function bbmod_model_get_vertex_format(_model)
{
	gml_pragma("forceinline");
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
/// @param {BBMOD_EModel} _model
/// @param {BBMOD_DynamicBatch} _dynamic_batch
/// @private
function _bbmod_model_to_dynamic_batch(_model, _dynamic_batch)
{
	gml_pragma("forceinline");
	_bbmod_node_to_dynamic_batch(_model[BBMOD_EModel.RootNode], _dynamic_batch);
}

/// @func _bbmod_model_to_static_batch(_model, _static_batch, _transform)
/// @param {BBMOD_EModel} _model
/// @param {BBMOD_EStaticBatch} _static_batch
/// @param {real[]} _transform
/// @private
function _bbmod_model_to_static_batch(_model, _static_batch, _transform)
{
	gml_pragma("forceinline");
	_bbmod_node_to_static_batch(_model, _model[BBMOD_EModel.RootNode], _static_batch, _transform);
}

/// @func bbmod_render(_model[, _materials[, _transform]])
/// @desc Submits a model for rendering.
/// @param {BBMOD_EModel} _model A model.
/// @param {BBMOD_EMaterial[]/undefined} [_materials] An array of materials,
/// one for each material slot of the model. If not specified, then
/// the default material is used for each slot. Default is `undefined`.
/// @param {real[]/undefined} [_transform] An array of transformation matrices
/// (for animated models) or `undefined`.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Model.render}
/// instead.
function bbmod_render(_model)
{
	gml_pragma("forceinline");
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
/// @desc A model.
/// @param {string} _file The "*.bbmod" model file to load.
/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one does
/// not match with this, then the model will not be loaded.
/// @example
/// ```gml
/// try
/// {
///     mod_character = new BBMOD_Model("character.bbmod");
/// }
/// catch (e)
/// {
///     // The model failed to load!
/// }
/// ```
/// @throws {BBMOD_Error} When the model fails to load.
function BBMOD_Model(_file) constructor
{
	var _sha1 = (argument_count > 1) ? argument[1] : undefined;

	/// @var {BBMOD_EModel} The model that this struct wraps.
	/// @private
	model = bbmod_load(_file, _sha1);

	if (model == BBMOD_NONE)
	{
		throw new BBMOD_Error("Could not load file " + _file);
	}

	/// @func freeze()
	/// @desc Freezes all vertex buffers used by the model. This should make its
	/// rendering faster, but it disables creating new batches of the model.
	static freeze = function () {
		bbmod_model_freeze(model);
	};

	/// @func find_bone_id(_bone_name)
	/// @desc Finds model's bone by its name.
	/// @param {string} _bone_name The name of the bone.
	/// @return {real} The id of the bone or {@link BBMOD_NONE} when it's not found.
	/// @note It is not recommened to use this script in release builds, because
	/// having many of these lookups can slow down your game! You should instead
	/// use the ids available from the `_log.txt` files, which are created during
	/// model conversion.
	static find_bone_id = function (_bone_name) {
		return bbmod_model_find_bone_id(model, _bone_name);
	};

	/// @func get_bindpose_transform()
	/// @desc Retrieves bindpose transform of the model.
	/// @return {real[]} The bindpose transform.
	static get_bindpose_transform = function () {
		return bbmod_model_get_bindpose_transform(model);
	};

	/// @func get_vertex_format([_bones[, _ids]])
	/// @desc Retrieves or creates a vertex format compatible with the model.
	/// This can be used when creating a {@link BBMOD_StaticBatch}.
	/// @param {bool} [_bones] `true` to include bone data in the vertex format.
	/// Defaults to `true`.
	/// @param {bool} [_ids] `true` to include model instance ids in the vertex
	/// format.
	/// Defaults to `false`.
	/// @return {real} The vertex format.
	/// @example
	/// ```gml
	/// static_batch = new BBMOD_StaticBatch(mod_tree.get_vertex_format());
	/// ```
	static get_vertex_format = function () {
		var _bones = (argument_count > 0) ? argument[0] : true;
		var _ids = (argument_count > 1) ? argument[1] : false;
		return bbmod_model_get_vertex_format(model, _bones, _ids);
	};

	/// @func render([_materials[, _transform]])
	/// @desc Submits the model for rendering.
	/// @param {BBMOD_Material[]/undefined} [_materials] An array of materials,
	/// one for each material slot of the model. If not specified, then
	/// the default material is used for each slot. Defaults to `undefined`.
	/// @param {real[]/undefined} [_transform] An array of transformation matrices
	/// (for animated models) or `undefined`.
	/// @example
	/// ```gml
	/// bbmod_material_reset();
	/// // Render a terrain model (doesn't have animation data)
	/// mod_terrain.render([mat_grass]);
	/// // Render a character model (animated by animation_player)
	/// mod_character.render([mat_head, mat_body], animation_player.get_transform());
	/// bbmod_material_reset();
	/// ```
	/// @see BBMOD_Material
	/// @see BBMOD_AnimationPlayer.get_transform
	/// @see bbmod_material_reset
	static render = function () {
		var _materials = (argument_count > 0) ? argument[0] : undefined;
		var _transform = (argument_count > 1) ? argument[1] : undefined;

		_materials = ce_array_map(_materials, method(undefined, function (_m) {
			return _m.material;
		}));

		bbmod_render(model, _materials, _transform);
	};

	/// @func destroy()
	/// @desc Frees memory used by the model. Use this in combination with
	/// `delete` to destroy a model struct.
	/// @example
	/// ```gml
	/// model.destroy();
	/// delete model;
	/// ```
	static destroy = function () {
		bbmod_model_destroy(model);
	};
}