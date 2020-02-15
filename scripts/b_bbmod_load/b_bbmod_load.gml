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
var _vFormat = (argument_count > 1) ? argument[1] : undefined;
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

var _vBuffer = -1;
var _version = buffer_read(_buffer, buffer_u8);

if (_version == 0)
{
	var _hasVertices = buffer_read(_buffer, buffer_bool);
	var _hasNormals = buffer_read(_buffer, buffer_bool);
	var _hasUVs = buffer_read(_buffer, buffer_bool);
	var _hasColours = buffer_read(_buffer, buffer_bool);
	var _hasTangentW = buffer_read(_buffer, buffer_bool);
	var _vertexCount = buffer_read(_buffer, buffer_u32);

	if (is_undefined(_vFormat))
	{
		if (!variable_global_exists("__bVertexFormats"))
		{
			global.__bVertexFormats = ds_map_create();
		}

		var _mask = (_hasVertices
			| _hasNormals << 1
			| _hasUVs << 2
			| _hasColours << 3
			| _hasTangentW << 4);
 
		if (ds_map_exists(global.__bVertexFormats, _mask))
		{
			_vFormat = global.__bVertexFormats[? _mask];
		}
		else
		{
			vertex_format_begin();
	 
			if (_hasVertices)
			{
				vertex_format_add_position_3d();
			}

			if (_hasNormals)
			{
				vertex_format_add_normal();
			}

			if (_hasUVs)
			{
				vertex_format_add_texcoord();
			}

			if (_hasColours)
			{
				vertex_format_add_colour();
			}

			if (_hasTangentW)
			{
				vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
			}

			_vFormat = vertex_format_end();
			global.__bVertexFormats[? _mask] = _vFormat;
		}
	}

	_vBuffer = vertex_create_buffer_from_buffer_ext(
		_buffer, _vFormat, buffer_tell(_buffer), _vertexCount);
	vertex_freeze(_vBuffer);
}

buffer_delete(_buffer);
return _vBuffer;