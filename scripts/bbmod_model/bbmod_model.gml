/// @enum An enumeration of members of a legacy model struct.
/// @obsolete This legacy struct is obsolete. Please use
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

/// @func bbmod_model_destroy(_model)
/// @desc Destroys a model.
/// @param {BBMOD_Model} _model The model to destroy.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Model.destroy}
/// instead.
function bbmod_model_destroy(_model)
{
	_model.destroy();
}

/// @func bbmod_model_freeze(_model)
/// @desc Freezes all vertex buffers used by a model. This should make its
/// rendering faster, but it disables creating new batches of the model.
/// @param {BBMOD_Model} _model The model to freeze.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Model.freeze}
/// instead.
function bbmod_model_freeze(_model)
{
	_model.freeze();
}

/// @func bbmod_model_find_bone_id(_model, _bone_name[, _bone])
/// @desc Seaches for a bone id assigned to given bone name.
/// @param {BBMOD_Model} _model The model.
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
	return _model.find_bone_id(_bone_name);
}

/// @func bbmod_model_get_bindpose_transform(_model)
/// @desc Creates a transformation array with model's bindpose.
/// @param {BBMOD_Model} _model A model.
/// @return {real[]} The created array.
/// @deprected This function is deprecated. Please use
/// {@link BBMOD_Model.get_bindpose_transform} instead.
function bbmod_model_get_bindpose_transform(_model)
{
	return _model.get_bindpose_transform();
}

/// @func bbmod_model_get_vertex_format(_model[, _bones[, _ids]])
/// @desc Retrieves a vertex format of a model.
/// @param {BBMOD_Model} _model The model.
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
	return _model.get_vertex_format(_bones, _ids);
}

/// @func bbmod_render(_model[, _materials[, _transform]])
/// @desc Submits a model for rendering.
/// @param {BBMOD_Model} _model A model.
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
	_model.render(_materials, _transform);
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

	/// @var {real} The version of the model file.
	/// @readonly
	Version = 0;

	/// @var {BBMOD_VertexFormat} The vertex format of the model.
	/// @see BBMOD_VertexFormat
	/// @readonly
	VertexFormat = undefined;

	/// @var {real[]} The global inverse transform matrix.
	/// @readonly
	InverseTransformMatrix = undefined;

	/// @var {BBMOD_ENode} The root node.
	/// @see BBMOD_ENode
	/// @readonly
	RootNode = undefined;

	/// @var {real} Number of bones.
	/// @readonly
	BoneCount = 0;

	/// @var {BBMOD_EBone} The root bone.
	/// @see BBMOD_EBone
	/// @readonly
	Skeleton = undefined;

	/// @var {real} Number of materials that the model uses.
	/// @see BBMOD_EMaterial
	/// @readonly
	MaterialCount = 0;

	/// @var {string[]} Array of material names.
	/// @see BBMOD_EMaterial
	/// @readonly
	MaterialNames = [];

	/// @func from_buffer(_buffer)
	/// @desc Loads model data from a buffer.
	/// @param {buffer} _buffer The buffer to load the data from.
	/// @return {BBMOD_Model} Returns `self` to allow method chaining.
	/// @private
	static from_buffer = function (_buffer) {
		// Vertex format
		var _vertices = buffer_read(_buffer, buffer_bool);
		var _normals = buffer_read(_buffer, buffer_bool);
		var _textureCoords = buffer_read(_buffer, buffer_bool);
		var _colors = buffer_read(_buffer, buffer_bool);
		var _tangentW = buffer_read(_buffer, buffer_bool);
		var _bones = buffer_read(_buffer, buffer_bool);

		VertexFormat = new BBMOD_VertexFormat(
			_vertices,
			_normals,
			_textureCoords,
			_colors,
			_tangentW,
			_bones,
			false);

		// Global inverse transform matrix
		InverseTransformMatrix = bbmod_load_matrix(_buffer);

		// Root node
		RootNode = bbmod_node_load(_buffer, VertexFormat);

		// Skeleton
		BoneCount = buffer_read(_buffer, buffer_u32);

		if (BoneCount > 0)
		{
			Skeleton = bbmod_bone_load(_buffer);
		}

		// Materials
		MaterialCount = buffer_read(_buffer, buffer_u32);

		if (MaterialCount > 0)
		{
			var _material_names = array_create(MaterialCount, 0);

			var i  = 0;
			repeat (MaterialCount)
			{
				_material_names[@ i++] = buffer_read(_buffer, buffer_string);
			}

			MaterialNames = _material_names;
		}

		return self;
	};

	/// @func from_file(_file[, _sha1])
	/// @desc Loads model data from a file.
	/// @param {string} _file The path to the file.
	/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one
	/// does not match with this, then the model will not be loaded.
	/// @return {BBMOD_Model} Returns `self` to allow method chaining.
	/// @throws {BBMOD_Error} If loading fails.
	/// @private
	static from_file = function (_file) {
		var _sha1 = (argument_count > 1) ? argument[1] : undefined;

		if (!file_exists(_file))
		{
			throw new BBMOD_Error("File " + _file + " does not exist!");
		}

		if (!is_undefined(_sha1))
		{
			if (sha1_file(_file) != _sha1)
			{
				throw new BBMOD_Error("SHA1 does not match!");
			}
		}

		var _buffer = buffer_load(_file);
		buffer_seek(_buffer, buffer_seek_start, 0);

		var _type = buffer_read(_buffer, buffer_string);
		if (_type != "bbmod")
		{
			buffer_delete(_buffer);
			throw new BBMOD_Error("Not a BBMOD file!");
		}

		Version = buffer_read(_buffer, buffer_u8);
		if (Version != 1)
		{
			buffer_delete(_buffer);
			throw new BBMOD_Error("Invalid version " + string(Version) + "!");
		}

		from_buffer(_buffer);
		buffer_delete(_buffer);
		return self;
	};

	/// @func freeze()
	/// @desc Freezes all vertex buffers used by the model. This should make its
	/// rendering faster, but it disables creating new batches of the model.
	static freeze = function () {
		gml_pragma("forceinline");
		_bbmod_node_freeze(RootNode);
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
		var _bone = (argument_count > 1) ? argument[1] : Skeleton;

		if (_bone[BBMOD_EBone.Name] == _bone_name)
		{
			return _bone[BBMOD_EBone.Index];
		}

		var _children = _bone[BBMOD_EBone.Children];
		var i = 0;

		repeat (array_length(_children))
		{
			var _found = find_bone_id(_bone_name, _children[i++]);
			if (_found != BBMOD_NONE)
			{
				return _found;
			}
		}

		return BBMOD_NONE;
	};

	/// @func get_bindpose_transform()
	/// @desc Retrieves bindpose transform of the model.
	/// @return {real[]} The bindpose transform.
	static get_bindpose_transform = function () {
		var _transform = array_create(BoneCount * 16, 0);
		var _matrix = matrix_build_identity();
		var i = 0;
		repeat (BoneCount)
		{
			array_copy(_transform, (i++) * 16, _matrix, 0, 16);
		}
		return _transform;
	};

	/// @func get_vertex_format([_bones[, _ids]])
	/// @desc Retrieves or creates a vertex format compatible with the model.
	/// This can be used when creating a {@link BBMOD_StaticBatch}.
	/// @param {bool} [_bones] `true` to include bone data in the vertex format.
	/// Defaults to `true`.
	/// @param {bool} [_ids] `true` to include model instance ids in the vertex
	/// format.
	/// Defaults to `false`.
	/// @return {BBMOD_VertexFormat} The vertex format.
	/// @example
	/// ```gml
	/// static_batch = new BBMOD_StaticBatch(mod_tree.get_vertex_format());
	/// ```
	static get_vertex_format = function () {
		gml_pragma("forceinline");
		var _bones = (argument_count > 0) ? argument[0] : true;
		var _ids = (argument_count > 1) ? argument[1] : false;
		return new BBMOD_VertexFormat(
			VertexFormat.Vertices,
			VertexFormat.Normals,
			VertexFormat.TextureCoords,
			VertexFormat.Colors,
			VertexFormat.TangentW,
			_bones ? VertexFormat.Bones : false,
			_ids);
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

		if (is_undefined(_materials))
		{
			_materials = array_create(
				MaterialCount,
				is_undefined(_transform)
					? BBMOD_MATERIAL_DEFAULT
					: BBMOD_MATERIAL_DEFAULT_ANIMATED);
		}

		var _render_pass = global.bbmod_render_pass;

		var i = 0;
		repeat (array_length(_materials))
		{
			var _material = _materials[i++];
			if ((_material.RenderPath & _render_pass) == 0)
			{
				// Do not render the model if it doesn't use any material that
				// can be used in the current render pass.
				return;
			}
		}

		bbmod_node_render(self, RootNode, _materials, _transform);
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
		gml_pragma("forceinline");
		bbmod_node_destroy(RootNode);
	};

	/// @func to_dynamic_batch(_model, _dynamic_batch)
	/// @param {BBMOD_Model} _model
	/// @param {BBMOD_DynamicBatch} _dynamic_batch
	/// @private
	function to_dynamic_batch(_dynamic_batch)
	{
		gml_pragma("forceinline");
		_bbmod_node_to_dynamic_batch(RootNode, _dynamic_batch);
	}

	/// @func to_static_batch(_model, _static_batch, _transform)
	/// @param {BBMOD_Model} _model
	/// @param {BBMOD_StaticBatch} _static_batch
	/// @param {matrix} _transform
	/// @private
	function to_static_batch(_static_batch, _transform)
	{
		gml_pragma("forceinline");
		_bbmod_node_to_static_batch(self, RootNode, _static_batch, _transform);
	}

	if (_file != undefined)
	{
		from_file(_file, _sha1);
	}
}