/// @func bbmod_mesh_load(buffer, format, format_mask)
/// @desc Loads a Mesh structure from a bufffer.
/// @param {real} buffer The buffer to load the structure from.
/// @param {real} format A vertex format that the mesh uses.
/// @param {real} format_mask A vertex format mask.
/// @return {array} The loaded Mesh structure.
var _buffer = argument0;
var _format = argument1;
var _mask = argument2;

var _has_vertices = (_mask >> BBMOD_VFORMAT_VERTEX) & 1;
var _has_normals = (_mask >> BBMOD_VFORMAT_NORMAL) & 1;
var _has_uvs = (_mask >> BBMOD_VFORMAT_TEXCOORD) & 1;
var _has_colors = (_mask >> BBMOD_VFORMAT_COLOR) & 1;
var _has_tangentw = (_mask >> BBMOD_VFORMAT_TANGENTW) & 1;
var _has_bones = (_mask >> BBMOD_VFORMAT_BONES) & 1;

var _mesh = array_create(BBMOD_EMesh.SIZE, 0);
_mesh[@ BBMOD_EMesh.MaterialIndex] = buffer_read(_buffer, buffer_u32);

var _vertex_count = buffer_read(_buffer, buffer_u32);
if (_vertex_count > 0)
{
	var _size = _vertex_count * (0
		+ _has_vertices * 3 * buffer_sizeof(buffer_f32)
		+ _has_normals * 3 * buffer_sizeof(buffer_f32)
		+ _has_uvs * 2 * buffer_sizeof(buffer_f32)
		+ _has_colors * buffer_sizeof(buffer_u32)
		+ _has_tangentw * 4 * buffer_sizeof(buffer_f32)
		+ _has_bones * 8 * buffer_sizeof(buffer_f32));

	if (_size > 0)
	{
		var _vbuffer = vertex_create_buffer_from_buffer_ext(
			_buffer, _format, buffer_tell(_buffer), _vertex_count);
		_mesh[@ BBMOD_EMesh.VertexBuffer] = _vbuffer;
		buffer_seek(_buffer, buffer_seek_relative, _size);
	}
}

return _mesh;