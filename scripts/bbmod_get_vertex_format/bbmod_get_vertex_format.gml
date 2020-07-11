/// @func bbmod_get_vertex_format(vertices, normals, uvs, colors, tangetw, bones[, ids])
/// @desc Creates a new vertex format or retrieves an existing one with specified
/// properties.
/// @param {bool} vertices True if the vertex format must have vertices.
/// @param {bool} normals True if the vertex format must have normal vectors.
/// @param {bool} uvs True if the vertex format must have texture coordinates.
/// @param {bool} colors True if the vertex format must have vertex colors.
/// @param {bool} tangentw True if the vertex format must have tangent vectors and
/// bitangent signs.
/// @param {bool} bones True if the vertex format must have vertex weights and bone
/// indices.
/// @param {bool} [ids] True if the vertex format must have ids for dynamic batching.
/// @return {real} The vertex format.
var _has_vertices = argument[0];
var _has_normals = argument[1];
var _has_uvs = argument[2];
var _has_colors = argument[3];
var _has_tangentw = argument[4];
var _has_bones = argument[5];
var _has_ids = (argument_count > 6) ? argument[6] : false;

var _mask = (0
	| (_has_vertices << BBMOD_VFORMAT_VERTEX)
	| (_has_normals << BBMOD_VFORMAT_NORMAL)
	| (_has_uvs << BBMOD_VFORMAT_TEXCOORD)
	| (_has_colors << BBMOD_VFORMAT_COLOR)
	| (_has_tangentw << BBMOD_VFORMAT_TANGENTW)
	| (_has_bones << BBMOD_VFORMAT_BONES)
	| (_has_ids << BBMOD_VFORMAT_IDS));

var _vformat;

if (ds_map_exists(global.__bbmod_vertex_formats, _mask))
{
	_vformat = global.__bbmod_vertex_formats[? _mask];
}
else
{
	vertex_format_begin();

	if (_has_vertices)
	{
		vertex_format_add_position_3d();
	}

	if (_has_normals)
	{
		vertex_format_add_normal();
	}

	if (_has_uvs)
	{
		vertex_format_add_texcoord();
	}

	if (_has_colors)
	{
		vertex_format_add_colour();
	}

	if (_has_tangentw)
	{
		vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
	}

	if (_has_bones)
	{
		vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
		vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
	}

	if (_has_ids)
	{
		vertex_format_add_custom(vertex_type_float1, vertex_usage_texcoord);
	}

	_vformat = vertex_format_end();
	global.__bbmod_vertex_formats[? _mask] = _vformat;
}

return _vformat;