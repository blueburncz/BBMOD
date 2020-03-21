/// @func b_bbmod_load_1(file[, format[, sha1]])
/// @param {string} file
/// @param {real} [format]
/// @param {string} [sha1]
/// @return {array/undefined}
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

var _bbmod = undefined;
var _version = buffer_read(_buffer, buffer_u8);

if (_version == 1)
{
	_bbmod = array_create(B_EBBMOD1.SIZE);

	// Header
	_bbmod[@ B_EBBMOD1.Version] = _version;

	var _has_vertices = buffer_read(_buffer, buffer_bool);
	var _has_normals = buffer_read(_buffer, buffer_bool);
	var _has_uvs = buffer_read(_buffer, buffer_bool);
	var _has_colors = buffer_read(_buffer, buffer_bool);
	var _has_tangentw = buffer_read(_buffer, buffer_bool);
	var _has_bones = buffer_read(_buffer, buffer_bool);

	// Global inverse transform matrix
	_bbmod[@ B_EBBMOD1.InverseTransformMatrix] = b_bbmod_load_matrix(_buffer);

	// Vertex format
	var _mask = (_has_vertices
		| _has_normals << 1
		| _has_uvs << 2
		| _has_colors << 3
		| _has_tangentw << 4
		| _has_bones << 5);

	if (is_undefined(_vformat))
	{
		_vformat = b_bbmod_get_vertex_format(
			_has_vertices,
			_has_normals,
			_has_uvs,
			_has_colors,
			_has_tangentw,
			_has_bones);
	}

	// Root node
	_bbmod[@ B_EBBMOD1.RootNode] = b_bbmod_node_load(_buffer, _vformat, _mask);

	// Skeleton
	var _bone_count = buffer_read(_buffer, buffer_u32);
	_bbmod[@ B_EBBMOD1.BoneCount] = _bone_count;

	if (_bone_count > 0)
	{
		_bbmod[@ B_EBBMOD1.Skeleton] = b_bbmod_bone_load(_buffer);
	}

	// Animations
	var _animations = ds_map_create();
	_bbmod[@ B_EBBMOD1.Animations] = _animations;

	var _anim_count = buffer_read(_buffer, buffer_u32);

	repeat (_anim_count)
	{
		var _anim_data = b_bbmod_animation_load(_buffer);
		var _anim_name = _anim_data[B_EBBMODAnimation.Name];
		_animations[? _anim_name] = _anim_data;
	}
}

buffer_delete(_buffer);
return _bbmod;