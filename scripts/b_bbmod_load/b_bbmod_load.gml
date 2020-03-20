/// @func b_bbmod_load(file[, format[, sha1]])
/// @desc Loads a model from a BBMOD file into a vertex buffer.
/// @param {string} file Path to the BBMOD file.
/// @param {real} [format] An id of a vertex format of the model. If not
/// specified, a new vertex format will be built based on the information in the
/// header of the BBMOD.
/// @param {string} [sha1] Expected SHA1 of the BBMOD file. If the actual one
/// does not match with this, then the model will not be loaded.
/// @return {real} The id of the created vertex buffer or -1 on fail.
var _file = argument[0];
var _vformat = (argument_count > 1) ? argument[1] : undefined;
var _sha1 = (argument_count > 2) ? argument[2] : undefined;

if (!is_undefined(_sha1))
{
	if (sha1_file(_file) != _sha1)
	{
		return -1;
	}
}

var _buffer = buffer_load(_file);
buffer_seek(_buffer, buffer_seek_start, 0);

var _vbuffer = -1;
var _version = buffer_read(_buffer, buffer_u8);

if (_version == 0)
{
	var _has_vertices = buffer_read(_buffer, buffer_bool);
	var _has_normals = buffer_read(_buffer, buffer_bool);
	var _has_uvs = buffer_read(_buffer, buffer_bool);
	var _has_colors = buffer_read(_buffer, buffer_bool);
	var _has_tangentw = buffer_read(_buffer, buffer_bool);
	var _vertex_count = buffer_read(_buffer, buffer_u32);

	if (is_undefined(_vformat))
	{
		if (!variable_global_exists("__b_vertex_formats"))
		{
			global.__b_vertex_formats = ds_map_create();
		}

		var _mask = (_has_vertices
			| _has_normals << 1
			| _has_uvs << 2
			| _has_colors << 3
			| _has_tangentw << 4);
 
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

			_vformat = vertex_format_end();
			global.__b_vertex_formats[? _mask] = _vformat;
		}
	}

	_vbuffer = vertex_create_buffer_from_buffer_ext(
		_buffer, _vformat, buffer_tell(_buffer), _vertex_count);
	vertex_freeze(_vbuffer);
}

buffer_delete(_buffer);
return _vbuffer;