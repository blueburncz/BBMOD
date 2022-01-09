/// @func BBMOD_Model([_file[, _sha1]])
/// @extends BBMOD_Class
/// @implements {BBMOD_IRenderable}
/// @desc A model.
/// @param {string} [_file] The "*.bbmod" model file to load.
/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one does
/// not match with this, then the model will not be loaded.
/// @example
/// ```gml
/// try
/// {
///     modCharacter = new BBMOD_Model("Character.bbmod");
/// }
/// catch (_error)
/// {
///     // The model failed to load!
/// }
/// ```
/// @throws {BBMOD_Exception} When the model fails to load.
function BBMOD_Model(_file=undefined, _sha1=undefined)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	implement(BBMOD_IRenderable);

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {bool} If `false` then the model has not been loaded yet.
	/// @readonly
	IsLoaded = false;

	/// @var {real} The version of the model file.
	/// @readonly
	Version = BBMOD_VERSION;

	/// @var {BBMOD_VertexFormat} The vertex format of the model.
	/// @see BBMOD_VertexFormat
	/// @readonly
	VertexFormat = undefined;

	/// @var {BBMOD_Mesh[]} Array of meshes.
	/// @readonly
	Meshes = [];

	/// @var {int} Number of nodes.
	/// @readonly
	NodeCount = 0;

	/// @var {BBMOD_Node} The root node.
	/// @see BBMOD_Node
	/// @readonly
	RootNode = undefined;

	/// @var {real} Number of bones.
	/// @readonly
	BoneCount = 0;

	/// @var {real[]} An array of bone offset dual quaternions.
	/// @private
	OffsetArray = [];

	/// @var {real} Number of materials that the model uses.
	/// @see BBMOD_BaseMaterial
	/// @readonly
	MaterialCount = 0;

	/// @var {string[]} An array of material names.
	/// @see BBMOD_Model.Materials
	/// @see BBMOD_Model.get_material
	/// @see BBMOD_Model.set_material
	/// @readonly
	MaterialNames = [];

	/// @var {BBMOD_BaseMaterial[]} An array of materials. Each entry defaults to
	/// {@link BBMOD_MATERIAL_DEFAULT} or {@link BBMOD_MATERIAL_DEFAULT_ANIMATED}
	/// for animated models.
	/// @see BBMOD_Model.MaterialNames
	/// @see BBMOD_Model.get_material
	/// @see BBMOD_Model.set_material
	/// @see BBMOD_BaseMaterial
	Materials = [];

	/// @func from_buffer(_buffer)
	/// @desc Loads model data from a buffer.
	/// @param {buffer} _buffer The buffer to load the data from.
	/// @return {BBMOD_Model} Returns `self`.
	/// @throws {BBMOD_Exception} If loading fails.
	static from_buffer = function (_buffer) {
		var _type = buffer_read(_buffer, buffer_string);
		if (_type != "bbmod")
		{
			throw new BBMOD_Exception("Buffer does not contain a BBMOD!");
		}

		Version = buffer_read(_buffer, buffer_u8);
		if (Version != BBMOD_VERSION)
		{
			throw new BBMOD_Exception(
				"Invalid BBMOD version " + string(Version) + "!");
		}

		// Vertex format
		VertexFormat = bbmod_vertex_format_load(_buffer);

		// Meshes
		var _meshCount = buffer_read(_buffer, buffer_u32);
		Meshes = array_create(_meshCount, undefined);

		var i = 0;
		repeat (_meshCount)
		{
			Meshes[@ i++] = new BBMOD_Mesh(VertexFormat).from_buffer(_buffer);
		}

		// Node count and root node
		NodeCount = buffer_read(_buffer, buffer_u32);
		RootNode = new BBMOD_Node(self).from_buffer(_buffer);

		// Bone offsets
		BoneCount = buffer_read(_buffer, buffer_u32);

		if (BoneCount > 0)
		{
			OffsetArray = array_create(BoneCount * 8, 0);

			repeat (BoneCount)
			{
				var _index = buffer_read(_buffer, buffer_f32) * 8; // Bone index
				OffsetArray[@ _index + 0] = buffer_read(_buffer, buffer_f32);
				OffsetArray[@ _index + 1] = buffer_read(_buffer, buffer_f32);
				OffsetArray[@ _index + 2] = buffer_read(_buffer, buffer_f32);
				OffsetArray[@ _index + 3] = buffer_read(_buffer, buffer_f32);
				OffsetArray[@ _index + 4] = buffer_read(_buffer, buffer_f32);
				OffsetArray[@ _index + 5] = buffer_read(_buffer, buffer_f32);
				OffsetArray[@ _index + 6] = buffer_read(_buffer, buffer_f32);
				OffsetArray[@ _index + 7] = buffer_read(_buffer, buffer_f32);
			}
		}

		// Materials
		MaterialCount = buffer_read(_buffer, buffer_u32);

		if (MaterialCount > 0)
		{
			var _materialDefault = (BoneCount > 0)
				? BBMOD_MATERIAL_DEFAULT_ANIMATED
				: BBMOD_MATERIAL_DEFAULT;
			Materials = array_create(MaterialCount, _materialDefault);
			var _materialNames = array_create(MaterialCount, undefined);

			i = 0;
			repeat (MaterialCount)
			{
				_materialNames[@ i++] = buffer_read(_buffer, buffer_string);
			}

			MaterialNames = _materialNames;
		}

		IsLoaded = true;

		return self;
	};

	/// @func from_file(_file[, _sha1])
	/// @desc Loads model data from a file.
	/// @param {string} _file The path to the file.
	/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one
	/// does not match with this, then the model will not be loaded.
	/// @return {BBMOD_Model} Returns `self`.
	/// @throws {BBMOD_Exception} If loading fails.
	static from_file = function (_file, _sha1) {
		if (!file_exists(_file))
		{
			throw new BBMOD_Exception("File " + _file + " does not exist!");
		}

		if (_sha1 != undefined)
		{
			if (sha1_file(_file) != _sha1)
			{
				throw new BBMOD_Exception("SHA1 does not match!");
			}
		}

		var _buffer = buffer_load(_file);
		buffer_seek(_buffer, buffer_seek_start, 0);

		try
		{
			from_buffer(_buffer);
			buffer_delete(_buffer);
		}
		catch (_e)
		{
			buffer_delete(_buffer);
			throw _e;
		}

		return self;
	};

	/// @func from_file_async(_file[, _sha1[, _callback]])
	/// @desc Asynchronnously loads the model from a file.
	/// @param {string} _file The path to the file.
	/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one
	/// does not match with this, then the model will not be loaded.
	/// @param {function} [_callback] The function to execute when the model is
	/// loaded or if an error occurs. It must take the error as the first argument
	/// and the model as the second argument. If no error occurs, then `undefined`
	/// is passed.
	/// @return {BBMOD_Model} Returns `self`.
	static from_file_async = function (_file, _sha1=undefined, _callback=undefined) {
		if (_sha1 != undefined)
		{
			if (sha1_file(_file) != _sha1)
			{
				_callback(new BBMOD_Exception("SHA1 does not match!"));
				return self;
			}
		}

		var _model = self;
		var _struct = {
			Model: _model,
			Callback: _callback,
		};

		bbmod_buffer_load_async(_file, method(_struct, function (_err, _buffer) {
			var _callback = Callback;
			if (_err)
			{
				if (_callback != undefined)
				{
					_callback(_err, Model);
				}
				return;
			}

			try
			{
				Model.from_buffer(_buffer);
			}
			catch (_err2)
			{
				if (_callback != undefined)
				{
					_callback(_err2, Model);
				}
				return;
			}

			if (_callback != undefined)
			{
				_callback(undefined, Model);
			}
		}));

		return self;
	};

	/// @func freeze()
	/// @desc Freezes all vertex buffers used by the model. This should make its
	/// rendering faster, but it disables creating new batches of the model.
	/// @return {BBMOD_Model} Returns `self`.
	static freeze = function () {
		gml_pragma("forceinline");
		var i = 0;
		repeat (array_length(Meshes))
		{
			Meshes[i++].freeze();
		}
		return self;
	};

	/// @func find_node(_idOrName)
	/// @desc Finds a legacy node struct by its name or id.
	/// @param {real/string} _idOrName The id or the name of the node.
	/// @return {BBMOD_Node/BBMOD_NONE} Returns the found legacy node struct or
	/// `BBMOD_NONE`.
	static find_node = function (_idOrName) {
		var _isName = is_string(_idOrName);
		var _node = (argument_count > 1) ? argument[1] : RootNode;
		if (_isName && _node.Name == _idOrName)
		{
			return _node;
		}
		if (!_isName && _node.Index == _idOrName)
		{
			return _node;
		}
		var _children = _node.Children;
		var i = 0;
		repeat (array_length(_children))
		{
			var _found = find_node(_idOrName, _children[i++]);
			if (_found != BBMOD_NONE)
			{
				return _found;
			}
		}
		return BBMOD_NONE;
	};

	/// @func find_node_id(_nodeName)
	/// @desc Finds id of the model's node by its name.
	/// @param {string} _nodeName The name of the node.
	/// @return {uint/BBMOD_NONE} The id of the node or {@link BBMOD_NONE} when
	/// it is not found.
	/// @note It is not recommended to use this method in release builds, because
	/// having many of these lookups can slow down your game! You should instead
	/// use the ids available from the `_log.txt` files, which are created during
	/// model conversion.
	static find_node_id = function (_nodeName) {
		gml_pragma("forceinline");
		var _node = find_node(_nodeName);
		if (_node != BBMOD_NONE)
		{
			return _node.Index;
		}
		return BBMOD_NONE;
	};

	/// @func get_material(_name)
	/// @desc Retrieves a material by its name.
	/// @param {string} _name The name of the material.
	/// @return {BBMOD_BaseMaterial} The material.
	/// @throws {BBMOD_Exception} If the model does not have a material with
	/// given name.
	/// @see BBMOD_Model.Materials
	/// @see BBMOD_Model.MaterialNames
	/// @see BBMOD_Model.set_material
	/// @see BBMOD_BaseMaterial
	static get_material = function (_name) {
		var i = 0;
		repeat (MaterialCount)
		{
			if (MaterialNames[i] == _name)
			{
				return Materials[i];
			}
			++i;
		}
		throw new BBMOD_Exception("No such material found!");
	};

	/// @func set_material(_name, _material)
	/// @desc Sets a material.
	/// @param {string} _name The name of the material slot.
	/// @param {BBMOD_BaseMaterial} _material The material.
	/// @return {BBMOD_Model} Returns `self`.
	/// @throws {BBMOD_Exception} If the model does not have a material with
	/// given name.
	/// @see BBMOD_Model.Materials
	/// @see BBMOD_Model.MaterialNames
	/// @see BBMOD_Model.get_material
	/// @see BBMOD_BaseMaterial
	static set_material = function (_name, _material) {
		var i = 0;
		repeat (MaterialCount)
		{
			if (MaterialNames[i] == _name)
			{
				Materials[@ i] = _material;
				return self;
			}
			++i;
		}
		throw new BBMOD_Exception("No such material found!");
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
	/// staticBatch = new BBMOD_StaticBatch(mod_tree.get_vertex_format());
	/// ```
	static get_vertex_format = function (_bones, _ids) {
		gml_pragma("forceinline");
		_bones = (_bones != undefined) ? _bones : true;
		_ids = (_ids != undefined) ? _ids : false;
		return new BBMOD_VertexFormat(
			VertexFormat.Vertices,
			VertexFormat.Normals,
			VertexFormat.TextureCoords,
			VertexFormat.Colors,
			VertexFormat.TangentW,
			_bones ? VertexFormat.Bones : false,
			_ids);
	};

	/// @func submit([_materials[, _transform]])
	///
	/// @desc Immediately submits the model for rendering.
	///
	/// @param {BBMOD_BaseMaterial[]/undefined} [_materials] An array of materials,
	/// one for each material slot of the model. If not specified, then
	/// {@link BBMOD_Model.Materials} is used. Defaults to `undefined`.
	/// @param {real[]/undefined} [_transform] An array of transformation matrices
	/// (for animated models) or `undefined`.
	///
	/// @return {BBMOD_Model} Returns `self`.
	///
	/// @example
	/// ```gml
	/// bbmod_material_reset();
	/// // Render a terrain model (does not have animation data)
	/// modTerrain.submit([mat_grass]);
	/// // Render a character model (animated by animationPlayer)
	/// modCharacter.submit([mat_head, mat_body], animationPlayer.get_transform());
	/// bbmod_material_reset();
	/// ```
	///
	/// @note Only parts of the model that use materials compatible with the
	/// current render pass are submitted!
	///
	/// @see BBMOD_BaseMaterial
	/// @see BBMOD_AnimationPlayer.get_transform
	/// @see bbmod_material_reset
	/// @see BBMOD_ERenderPass
	static submit = function (_materials, _transform) {
		gml_pragma("forceinline");
		if (RootNode != undefined)
		{
			_materials ??= Materials;
			RootNode.submit(_materials, _transform);
		}
		return self;
	};

	/// @func render([_materials[, _transform]])
	/// @desc Enqueues the model for rendering.
	/// @param {BBMOD_BaseMaterial[]/undefined} [_materials] An array of materials,
	/// one for each material slot of the model. If not specified, then
	/// {@link BBMOD_Model.Materials} is used. Defaults to `undefined`.
	/// @param {real[]/undefined} [_transform] An array of transformation matrices
	/// (for animated models) or `undefined`.
	/// @return {BBMOD_Model} Returns `self`.
	/// @see BBMOD_BaseMaterial
	/// @see BBMOD_AnimationPlayer.get_transform
	/// @see bbmod_material_reset
	static render = function (_materials, _transform) {
		gml_pragma("forceinline");
		if (RootNode != undefined)
		{
			_materials ??= Materials;
			RootNode.render(_materials, _transform, matrix_get(matrix_world));
		}
		return self;
	};

	/// @func to_dynamic_batch(_dynamicBatch)
	/// @param {BBMOD_DynamicBatch} _dynamicBatch
	/// @return {BBMOD_DynamicBatch} Returns `self`.
	/// @private
	static to_dynamic_batch = function (_dynamicBatch) {
		gml_pragma("forceinline");
		var i = 0;
		repeat (array_length(Meshes))
		{
			Meshes[i++].to_dynamic_batch(_dynamicBatch);
		}
		return self;
	};

	/// @func to_static_batch(_model, _staticBatch, _transform)
	/// @param {BBMOD_Model} _model
	/// @param {BBMOD_StaticBatch} _staticBatch
	/// @param {matrix} _transform
	/// @return {BBMOD_DynamicBatch} Returns `self`.
	/// @private
	static to_static_batch = function (_staticBatch, _transform) {
		gml_pragma("forceinline");
		var i = 0;
		repeat (array_length(Meshes))
		{
			Meshes[i++].to_static_batch(self, _staticBatch, _transform);
		}
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		var i = 0;
		repeat (array_length(Meshes))
		{
			Meshes[i++].destroy();
		}
	};

	if (_file != undefined)
	{
		from_file(_file, _sha1);
	}
}