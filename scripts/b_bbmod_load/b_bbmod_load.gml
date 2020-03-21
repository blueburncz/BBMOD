/// @func b_bbmod_load(file[, format[, sha1]])
/// @desc Loads a model from a BBMOD version 1 file.
/// @param {string} file The path to the BBMOD file.
/// @param {real} [format] An id of a vertex format of the model. If not
/// specified, a new vertex format will be built based on the information in the
/// header of the BBMOD. Default is `undefined`.
/// @param {string} [sha1] Expected SHA1 of the BBMOD file. If the actual one
/// does not match with this, then the model will not be loaded. Default is
/// `undefined`.
/// @return {array/B_BBMOD_NONE} The loaded model on success or `B_BBMOD_NONE` on fail.
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

var _bbmod = B_BBMOD_NONE;
var _version = buffer_read(_buffer, buffer_u8);

if (_version == 1)
{
	_bbmod = array_create(B_EBBMOD.SIZE);

	// Header
	_bbmod[@ B_EBBMOD.Version] = _version;

	var _has_vertices = buffer_read(_buffer, buffer_bool);
	_bbmod[@ B_EBBMOD.HasVertices] = _has_vertices;

	var _has_normals = buffer_read(_buffer, buffer_bool);
	_bbmod[@ B_EBBMOD.HasNormals] = _has_normals;

	var _has_uvs = buffer_read(_buffer, buffer_bool);
	_bbmod[@ B_EBBMOD.HasTextureCoords] = _has_uvs;

	var _has_colors = buffer_read(_buffer, buffer_bool);
	_bbmod[@ B_EBBMOD.HasColors] = _has_colors;

	var _has_tangentw = buffer_read(_buffer, buffer_bool);
	_bbmod[@ B_EBBMOD.HasTangentW] = _has_tangentw;

	var _has_bones = buffer_read(_buffer, buffer_bool);
	_bbmod[@ B_EBBMOD.HasBones] = _has_bones;

	// Global inverse transform matrix
	_bbmod[@ B_EBBMOD.InverseTransformMatrix] = b_bbmod_load_matrix(_buffer);

	// Vertex format
	var _mask = (0
		| (_has_vertices << B_BBMOD_VFORMAT_VERTEX)
		| (_has_normals << B_BBMOD_VFORMAT_NORMAL)
		| (_has_uvs << B_BBMOD_VFORMAT_TEXCOORD)
		| (_has_colors << B_BBMOD_VFORMAT_COLOR)
		| (_has_tangentw << B_BBMOD_VFORMAT_TANGENTW)
		| (_has_bones << B_BBMOD_VFORMAT_BONES));

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
	_bbmod[@ B_EBBMOD.RootNode] = b_bbmod_node_load(_buffer, _vformat, _mask);

	// Skeleton
	var _bone_count = buffer_read(_buffer, buffer_u32);
	_bbmod[@ B_EBBMOD.BoneCount] = _bone_count;

	if (_bone_count > 0)
	{
		_bbmod[@ B_EBBMOD.Skeleton] = b_bbmod_bone_load(_buffer);
	}

	// Animations
	var _animations = ds_map_create();
	_bbmod[@ B_EBBMOD.Animations] = _animations;

	var _anim_count = buffer_read(_buffer, buffer_u32);

	repeat (_anim_count)
	{
		var _anim_data = b_bbmod_animation_load(_buffer);
		var _anim_name = _anim_data[B_EBBMODAnimation.Name];
		_animations[? _anim_name] = _anim_data;
	}

	// Materials
	var _material_count = buffer_read(_buffer, buffer_u32);
	_bbmod[@ B_EBBMOD.Materials] = array_create(_material_count, global.__b_material_default);
}

buffer_delete(_buffer);
return _bbmod;