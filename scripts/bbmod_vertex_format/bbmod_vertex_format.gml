/// @func bbmod_get_vertex_format(_vertices, _normals, _uvs, _colors, _tangentw, _bones[, _ids])
/// @desc Creates a new vertex format or retrieves an existing one with specified
/// properties.
/// @param {bool} _vertices `true` if the vertex format must have vertices.
/// @param {bool} _normals `true` if the vertex format must have normal vectors.
/// @param {bool} _uvs `true` if the vertex format must have texture coordinates.
/// @param {bool} _colors `true` if the vertex format must have vertex colors.
/// @param {bool} _tangentw `true` if the vertex format must have tangent vectors and
/// bitangent signs.
/// @param {bool} _bones `true` if the vertex format must have vertex weights and bone
/// indices.
/// @param {bool} [_ids] `true` if the vertex format must have ids for dynamic batching.
/// @return {vertex_format} The vertex format.
/// @deprecated This function is deprecated. Please use {@link BBMOD_VertexFomat} instead.
function bbmod_get_vertex_format(_vertices, _normals, _uvs, _colors, _tangentw, _bones)
{
	gml_pragma("forceinline");
	var _ids = (argument_count > 6) ? argument[6] : false;
	return new BBMOD_VertexFormat(_vertices, _normals, _uvs, _colors, _tangentw, _bones, _ids);
}

/// @func BBMOD_VertexFormat(_vertices, _normals, _uvs, _colors, _tangentw, _bones, _ids)
/// @param {bool} _vertices If `true` then the vertex format must have vertices.
/// @param {bool} _normals If `true` then the vertex format must have normal vectors.
/// @param {bool} _uvs If `true` then the vertex format must have texture coordinates.
/// @param {bool} _colors If `true` then the vertex format must have vertex colors.
/// @param {bool} _tangentw If `true` then the vertex format must have tangent vectors and
/// bitangent signs.
/// @param {bool} _bones If `true` then the vertex format must have vertex weights and bone
/// indices.
/// @param {bool} _ids If `true` then the vertex format must have ids for dynamic batching.
function BBMOD_VertexFormat(_vertices, _normals, _uvs, _colors, _tangentw, _bones, _ids) constructor
{
	/// @var {bool} If `true` then the vertex foramt has vertices.
	/// @readonly
	Vertices = _vertices;

	/// @var {bool} If `true` then the vertex foramt has normal vectors.
	/// @readonly
	Normals = _normals;

	/// @var {bool} If `true` then the vertex foramt has texture coordinates.
	/// @readonly
	TextureCoords = _uvs;

	/// @var {bool} If `true` then the vertex foramt has vertex colors.
	/// @readonly
	Colors = _colors;

	/// @var {bool} If `true` then the vertex foramt has tangent vectors and
	/// bitangent sign.
	/// @readonly
	TangentW = _tangentw;

	/// @var {bool} If `true` then the vertex foramt has vertex weights and bone
	/// indices.
	Bones = _bones;

	/// @var {bool} If `true` then the vertex foramt has ids for dynamic batching.
	/// @readonly
	Ids = _ids;

	/// @var {vertex_format} The raw vertex format.
	/// @readonly
	Raw = undefined;

	/// @var {ds_map<int, vertex_format> A map of existing raw vertex formats.
	/// @private
	static Formats = ds_map_create();

	/// @func get_hash()
	/// @desc Makes a hash based on the vertex format properties. Vertex buffers
	/// with same propereties will have the same hash.
	/// @return {int} The hash.
	static get_hash = function () {
		return ((Vertices << 0)
			| (Normals << 1)
			| (TextureCoords << 2)
			| (Colors << 3)
			| (TangentW << 4)
			| (Bones << 5)
			| (Ids << 6));
	};

	var _hash = get_hash();

	if (ds_map_exists(Formats, _hash))
	{
		Raw = Formats[? _hash];
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
		Formats[? _hash] = Raw;
	}
}