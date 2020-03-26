/// @func bbmod_model_load(buffer, version)
/// @param {real} buffer
/// @param {real} version
/// @return {array}
var _buffer = argument0;
var _version = argument1;
var _vformat = undefined;

var _bbmod = array_create(BBMOD_EModel.SIZE);

// Header
_bbmod[@ BBMOD_EModel.Version] = _version;

var _has_vertices = buffer_read(_buffer, buffer_bool);
_bbmod[@ BBMOD_EModel.HasVertices] = _has_vertices;

var _has_normals = buffer_read(_buffer, buffer_bool);
_bbmod[@ BBMOD_EModel.HasNormals] = _has_normals;

var _has_uvs = buffer_read(_buffer, buffer_bool);
_bbmod[@ BBMOD_EModel.HasTextureCoords] = _has_uvs;

var _has_colors = buffer_read(_buffer, buffer_bool);
_bbmod[@ BBMOD_EModel.HasColors] = _has_colors;

var _has_tangentw = buffer_read(_buffer, buffer_bool);
_bbmod[@ BBMOD_EModel.HasTangentW] = _has_tangentw;

var _has_bones = buffer_read(_buffer, buffer_bool);
_bbmod[@ BBMOD_EModel.HasBones] = _has_bones;

// Global inverse transform matrix
_bbmod[@ BBMOD_EModel.InverseTransformMatrix] = bbmod_load_matrix(_buffer);

// Vertex format
var _mask = (0
	| (_has_vertices << BBMOD_VFORMAT_VERTEX)
	| (_has_normals << BBMOD_VFORMAT_NORMAL)
	| (_has_uvs << BBMOD_VFORMAT_TEXCOORD)
	| (_has_colors << BBMOD_VFORMAT_COLOR)
	| (_has_tangentw << BBMOD_VFORMAT_TANGENTW)
	| (_has_bones << BBMOD_VFORMAT_BONES));

if (is_undefined(_vformat))
{
	_vformat = bbmod_get_vertex_format(
		_has_vertices,
		_has_normals,
		_has_uvs,
		_has_colors,
		_has_tangentw,
		_has_bones);
}

// Root node
_bbmod[@ BBMOD_EModel.RootNode] = bbmod_node_load(_buffer, _vformat, _mask);

// Skeleton
var _bone_count = buffer_read(_buffer, buffer_u32);
_bbmod[@ BBMOD_EModel.BoneCount] = _bone_count;

if (_bone_count > 0)
{
	_bbmod[@ BBMOD_EModel.Skeleton] = bbmod_bone_load(_buffer);
}

// Materials
_bbmod[@ BBMOD_EModel.MaterialCount] = buffer_read(_buffer, buffer_u32);

return _bbmod;