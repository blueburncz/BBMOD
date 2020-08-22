/// @func bbmod_get_vertex_format(_vertices, _normals, _uvs, _colors, _tangetw, _bones[, _ids])
/// @desc Creates a new vertex format or retrieves an existing one with specified
/// properties.
/// @param {bool} _vertices True if the vertex format must have vertices.
/// @param {bool} _normals True if the vertex format must have normal vectors.
/// @param {bool} _uvs True if the vertex format must have texture coordinates.
/// @param {bool} _colors True if the vertex format must have vertex colors.
/// @param {bool} _tangentw True if the vertex format must have tangent vectors and
/// bitangent signs.
/// @param {bool} _bones True if the vertex format must have vertex weights and bone
/// indices.
/// @param {bool} [_ids] True if the vertex format must have ids for dynamic batching.
/// @return {real} The vertex format.
function bbmod_get_vertex_format()
{
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
}

/// @func bbmod_load_matrix(_buffer)
/// @desc Loads a 4x4 row-major matrix from a buffer.
/// @param {real} _buffer The buffer to load the matrix from.
/// @return {array} The loaded matrix.
function bbmod_load_matrix(_buffer)
{
	var _matrix = array_create(16, 0);
	for (var i/*:int*/= 0; i < 16; ++i)
	{
		_matrix[@ i] = buffer_read(_buffer, buffer_f32);
	}
	ce_matrix_transpose(_matrix);
	return _matrix;
}

/// @func bbmod_load_quaternion(_buffer)
/// @desc Loads a quaternion from a buffer.
/// @param {real} _buffer The buffer to load a quaternion from.
/// @return {array} The loaded quaternion.
function bbmod_load_quaternion(_buffer)
{
	var _quaternion = array_create(4, 0);
	_quaternion[@ 0] = buffer_read(_buffer, buffer_f32);
	_quaternion[@ 1] = buffer_read(_buffer, buffer_f32);
	_quaternion[@ 2] = buffer_read(_buffer, buffer_f32);
	_quaternion[@ 3] = buffer_read(_buffer, buffer_f32);
	return _quaternion;
}

/// @func bbmod_load_vec3(_buffer)
/// @desc Loads a 3D vector from a buffer.
/// @param {real} _buffer The buffer to load the vector from.
/// @return {array} The loaded vector.
function bbmod_load_vec3(_buffer)
{
	var _vec3 = array_create(3, 0);
	_vec3[@ 0] = buffer_read(_buffer, buffer_f32);
	_vec3[@ 1] = buffer_read(_buffer, buffer_f32);
	_vec3[@ 2] = buffer_read(_buffer, buffer_f32);
	return _vec3;
}