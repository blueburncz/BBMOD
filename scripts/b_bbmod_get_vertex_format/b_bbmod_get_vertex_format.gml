/// @func b_bbmod_get_vertex_format(vertices, normals, uvs, colors, tangetW, bones)
/// @param {bool} vertices
/// @param {bool} normals
/// @param {bool} uvs
/// @param {bool} colors
/// @param {bool} tangentW
/// @param {bool} bones
/// @return {real}
var _has_vertices = argument0;
var _has_normals = argument1;
var _has_uvs = argument2;
var _has_colors = argument3;
var _has_tangentw = argument4;
var _has_bones = argument5;

var _mask = (0
	| (_has_vertices << B_BBMOD_VFORMAT_VERTEX)
	| (_has_normals << B_BBMOD_VFORMAT_NORMAL)
	| (_has_uvs << B_BBMOD_VFORMAT_TEXCOORD)
	| (_has_colors << B_BBMOD_VFORMAT_COLOR)
	| (_has_tangentw << B_BBMOD_VFORMAT_TANGENTW)
	| (_has_bones << B_BBMOD_VFORMAT_BONES));

var _vformat;

if (ds_map_exists(global.__b_vertex_formats, _mask))
{
	_vformat = global.__b_vertex_formats[? _mask];
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

	_vformat = vertex_format_end();
	global.__b_vertex_formats[? _mask] = _vformat;
}

return _vformat;