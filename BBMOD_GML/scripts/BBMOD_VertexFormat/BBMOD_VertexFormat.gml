/// @module Core

/// @macro {Struct.BBMOD_VertexFormat} The default vertex format for static
/// models. Consists of vertex 3D positions, normals, texture coordinates,
/// tangents and bitangent signs.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_DEFAULT __bbmod_vformat_default()

/// @macro {Struct.BBMOD_VertexFormat} The default vertex format for animated
/// models. Consists of vertex 3D positions, normals, texture coordinates,
/// tangents and bitangent signs, bone indices and weights.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_DEFAULT_ANIMATED __bbmod_vformat_default_animated()

/// @macro {Struct.BBMOD_VertexFormat} The default vertex format for dynamically
/// batched models. Consists of vertex 3D positions, normals, texture coordinates,
/// tangents and bitangent signs, instance IDs.
/// @see BBMOD_VertexFormat
/// @see BBMOD_DynamicBatch
#macro BBMOD_VFORMAT_DEFAULT_BATCHED __bbmod_vformat_default_batched()

/// @macro {Struct.BBMOD_VertexFormat} The default vertex format for static
/// models with vertex colors. Consists of vertex 3D positions, normals,
/// texture coordinates, vertex colors, tangents and bitangent signs.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_DEFAULT_COLOR __bbmod_vformat_default_color()

/// @macro {Struct.BBMOD_VertexFormat} The default vertex format for animated
/// models with vertex colors. Consists of vertex 3D positions, normals, texture
/// coordinates, vertex colors, tangents and bitangent signs, bone indices and
/// weights.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_DEFAULT_COLOR_ANIMATED __bbmod_vformat_default_color_animated()

/// @macro {Struct.BBMOD_VertexFormat} The default vertex format for dynamically
/// batched models with vertex colors. Consists of vertex 3D positions, normals,
/// texture coordinates, vertex colors, tangents and bitangent signs, instance IDs.
/// @see BBMOD_VertexFormat
/// @see BBMOD_DynamicBatch
#macro BBMOD_VFORMAT_DEFAULT_COLOR_BATCHED __bbmod_vformat_default_color_batched()

/// @func BBMOD_VertexFormat([_confOrVertices[, _normals[, _uvs[, _colors[, _tangentw[, _bones[, _ids]]]]]]])
///
/// @desc A wrapper of a raw GameMaker vertex format.
///
/// @param {Struct, Bool} [_confOrVertices] Either a struct with keys called
/// after properties of `BBMOD_VertexFormat` and values `true` or `false`,
/// depending on whether the vertex format should have the property, or `true`,
/// since every vertex format must have vertex positions.
/// @param {Bool} [_normals] If `true` then the vertex format must have normal
/// vectors. Defaults to `false`. Used only if the first argument is not a
/// struct.
/// @param {Bool} [_uvs] If `true` then the vertex format must have texture
/// coordinates. Defaults to `false`. Used only if the first argument is not a
/// struct.
/// @param {Bool} [_colors] If `true` then the vertex format must have vertex
/// colors. Defaults to `false`. Used only if the first argument is not a
/// struct.
/// @param {Bool} [_tangentw] If `true` then the vertex format must have tangent
/// vectors and bitangent signs. Defaults to `false`. Used only if the first
/// argument is not a struct.
/// @param {Bool} [_bones] If `true` then the vertex format must have vertex
/// weights and bone indices. Defaults to `false`. Used only if the first
/// argument is not a struct.
/// @param {Bool} [_ids] If `true` then the vertex format must have IDs for
/// dynamic batching. Defaults to `false`. Used only if the first argument
/// is not a struct.
///
/// @example
/// ```gml
/// vformat = new BBMOD_VertexFormat({
///     Vertices: true,
///     Normals: true,
///     TextureCoords: true,
///     TextureCoords2: false,
///     Colors: true,
///     TangentW: true,
///     Bones: false,
///     Ids: false,
/// });
/// ```
function BBMOD_VertexFormat(
	_confOrVertices = true,
	_normals = false,
	_uvs = false,
	_colors = false,
	_tangentw = false,
	_bones = false,
	_ids = false) constructor
{
	var _vertices = true;
	var _uvs2 = false;

	if (is_struct(_confOrVertices))
	{
		if (variable_struct_exists(_confOrVertices, "Vertices"))
		{
			_vertices = _confOrVertices.Vertices;
		}

		if (variable_struct_exists(_confOrVertices, "Normals"))
		{
			_normals = _confOrVertices.Normals;
		}

		if (variable_struct_exists(_confOrVertices, "TextureCoords"))
		{
			_uvs = _confOrVertices.TextureCoords;
		}

		if (variable_struct_exists(_confOrVertices, "TextureCoords2"))
		{
			_uvs2 = _confOrVertices.TextureCoords2;
		}

		if (variable_struct_exists(_confOrVertices, "Colors"))
		{
			_colors = _confOrVertices.Colors;
		}

		if (variable_struct_exists(_confOrVertices, "TangentW"))
		{
			_tangentw = _confOrVertices.TangentW;
		}

		if (variable_struct_exists(_confOrVertices, "Bones"))
		{
			_bones = _confOrVertices.Bones;
		}

		if (variable_struct_exists(_confOrVertices, "Ids"))
		{
			_ids = _confOrVertices.Ids;
		}
	}

	/// @var {Bool} If `true` then the vertex format has vertices. Should always
	/// be `true`!
	/// @readonly
	Vertices = _vertices;

	/// @var {Bool} If `true` then the vertex format has normal vectors.
	/// @readonly
	Normals = _normals;

	/// @var {Bool} If `true` then the vertex format has texture coordinates.
	/// @readonly
	TextureCoords = _uvs;

	/// @var {Bool} If `true` then the vertex format has a second texture
	/// coordinates layer.
	/// @readonly
	TextureCoords2 = _uvs2;

	/// @var {Bool} If `true` then the vertex format has vertex colors.
	/// @readonly
	Colors = _colors;

	/// @var {Bool} If `true` then the vertex format has tangent vectors and
	/// bitangent sign.
	/// @readonly
	TangentW = _tangentw;

	/// @var {Bool} If `true` then the vertex format has vertex weights and bone
	/// indices.
	Bones = _bones;

	/// @var {Bool} If `true` then the vertex format has IDs for dynamic
	/// batching.
	/// @readonly
	Ids = _ids;

	/// @var {Id.VertexFormat} The raw vertex format.
	/// @readonly
	Raw = undefined;

	/// @var {Ds.Map} A map of existing raw vertex formats (`Real`s to
	/// `Id.VertexFormat`s).
	/// @private
	static __formats = ds_map_create();

	/// @func get_hash()
	///
	/// @desc Makes a hash based on the vertex format properties. Vertex buffers
	/// with same propereties will have the same hash.
	///
	/// @return {Real} The hash.
	static get_hash = function ()
	{
		return (0
			| ((Vertices ? 1 : 0) << 0)
			| ((Normals ? 1 : 0) << 1)
			| ((TextureCoords ? 1 : 0) << 2)
			| ((TextureCoords2 ? 1 : 0) << 3)
			| ((Colors ? 1 : 0) << 4)
			| ((TangentW ? 1 : 0) << 5)
			| ((Bones ? 1 : 0) << 6)
			| ((Ids ? 1 : 0) << 7)
		);
	};

	/// @func get_byte_size()
	///
	/// @desc Retrieves the size of a single vertex using the vertex format in
	/// bytes.
	///
	/// @return {Real} The byte size of a single vertex using the vertex format.
	static get_byte_size = function ()
	{
		gml_pragma("forceinline");
		return (0
			+ (buffer_sizeof(buffer_f32) * 3 * (Vertices ? 1 : 0))
			+ (buffer_sizeof(buffer_f32) * 3 * (Normals ? 1 : 0))
			+ (buffer_sizeof(buffer_f32) * 2 * (TextureCoords ? 1 : 0))
			+ (buffer_sizeof(buffer_f32) * 2 * (TextureCoords2 ? 1 : 0))
			+ (buffer_sizeof(buffer_u32) * 1 * (Colors ? 1 : 0))
			+ (buffer_sizeof(buffer_f32) * 4 * (TangentW ? 1 : 0))
			+ (buffer_sizeof(buffer_f32) * 8 * (Bones ? 1 : 0))
			+ (buffer_sizeof(buffer_f32) * 1 * (Ids ? 1 : 0))
		);
	};

	var _key = string(get_hash());

	if (ds_map_exists(__formats, _key))
	{
		Raw = __formats[?  _key];
	}
	else
	{
		vertex_format_begin();

		if (Vertices)
		{
			vertex_format_add_position_3d();
		}

		if (Normals)
		{
			vertex_format_add_normal();
		}

		if (TextureCoords)
		{
			vertex_format_add_texcoord();
		}

		if (TextureCoords2)
		{
			vertex_format_add_texcoord();
		}

		if (Colors)
		{
			vertex_format_add_colour();
		}

		if (TangentW)
		{
			vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
		}

		if (Bones)
		{
			vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
			vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
		}

		if (Ids)
		{
			vertex_format_add_custom(vertex_type_float1, vertex_usage_texcoord);
		}

		Raw = vertex_format_end();
		__formats[?  _key] = Raw;
	}
}

/// @func __bbmod_vertex_format_save(_vertexFormat, _buffer[, _versionMinor])
///
/// @desc Saves a vertex format to a buffer following the BBMOD file format.
///
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format to save.
/// @param {Id.Buffer} _buffer The buffer to save the vertex format to.
/// @param {Real} [_versionMinor] The minor version of the BBMOD file format.
/// Defaults to {@link BBMOD_VERSION_MINOR}.
///
/// @private
function __bbmod_vertex_format_save(_vertexFormat, _buffer, _versionMinor = BBMOD_VERSION_MINOR)
{
	with(_vertexFormat)
	{
		buffer_write(_buffer, buffer_bool, Vertices);
		buffer_write(_buffer, buffer_bool, Normals);
		buffer_write(_buffer, buffer_bool, TextureCoords);
		if (_versionMinor >= 3)
		{
			buffer_write(_buffer, buffer_bool, TextureCoords2);
		}
		buffer_write(_buffer, buffer_bool, Colors);
		buffer_write(_buffer, buffer_bool, TangentW);
		buffer_write(_buffer, buffer_bool, Bones);
		buffer_write(_buffer, buffer_bool, Ids);
	}
}

/// @func __bbmod_vertex_format_load(_buffer[, _versionMinor])
///
/// @desc Loads a vertex format from a buffer following the BBMOD file format.
///
/// @param {Id.Buffer} _buffer The buffer to load the vertex format from. Its
/// seek position must point to a beginning of a BBMOD vertex format!
/// @param {Real} _versionMinor The minor version of the BBMOD file format.
/// Defaults to {@link BBMOD_VERSION_MINOR}.
///
/// @return {Struct.BBMOD_VertexFormat} The loaded vetex format.
///
/// @private
function __bbmod_vertex_format_load(_buffer, _versionMinor = BBMOD_VERSION_MINOR)
{
	var _vertices = buffer_read(_buffer, buffer_bool);
	var _normals = buffer_read(_buffer, buffer_bool);
	var _textureCoords = buffer_read(_buffer, buffer_bool);
	var _textureCoords2 = (_versionMinor >= 3)
		? buffer_read(_buffer, buffer_bool)
		: false;
	var _colors = buffer_read(_buffer, buffer_bool);
	var _tangentW = buffer_read(_buffer, buffer_bool);
	var _bones = buffer_read(_buffer, buffer_bool);
	var _ids = buffer_read(_buffer, buffer_bool);

	return new BBMOD_VertexFormat(
	{
		"Vertices": _vertices,
		"Normals": _normals,
		"TextureCoords": _textureCoords,
		"TextureCoords2": _textureCoords2,
		"Colors": _colors,
		"TangentW": _tangentW,
		"Bones": _bones,
		"Ids": _ids,
	});
}

function __bbmod_vformat_default()
{
	static _vformat = new BBMOD_VertexFormat(
		true, true, true, false, true, false, false);
	return _vformat;
}

function __bbmod_vformat_default_animated()
{
	static _vformat = new BBMOD_VertexFormat(
		true, true, true, false, true, true, false);
	return _vformat;
}

function __bbmod_vformat_default_batched()
{
	static _vformat = new BBMOD_VertexFormat(
		true, true, true, false, true, false, true);
	return _vformat;
}

function __bbmod_vformat_default_color()
{
	static _vformat = new BBMOD_VertexFormat(
		true, true, true, true, true, false, false);
	return _vformat;
}

function __bbmod_vformat_default_color_animated()
{
	static _vformat = new BBMOD_VertexFormat(
		true, true, true, true, true, true, false);
	return _vformat;
}

function __bbmod_vformat_default_color_batched()
{
	static _vformat = new BBMOD_VertexFormat(
		true, true, true, true, true, false, true);
	return _vformat;
}
