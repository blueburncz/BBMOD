/// @func _bbmod_mesh_to_dynamic_batch(mesh, dynamic_batch)
/// @param {array} mesh
/// @param {array} dynamic_batch
var _mesh = argument0;
var _dynamic_batch = argument1;

var _vertex_buffer = _dynamic_batch[BBMOD_EStaticBatch.VertexBuffer];
var _model = _dynamic_batch[BBMOD_EDynamicBatch.Model];

var _has_vertices = _model[BBMOD_EModel.HasVertices];
var _has_normals = _model[BBMOD_EModel.HasNormals];
var _has_uvs = _model[BBMOD_EModel.HasTextureCoords];
var _has_colors = _model[BBMOD_EModel.HasColors];
var _has_tangentw = _model[BBMOD_EModel.HasTangentW];
var _has_bones = _model[BBMOD_EModel.HasBones];

var _mesh_vertex_buffer = _mesh[BBMOD_EMesh.VertexBuffer];
var _vertex_count = vertex_get_number(_mesh_vertex_buffer);
var _buffer = buffer_create_from_vertex_buffer(_mesh_vertex_buffer, buffer_fixed, 1);

var _id/*:int*/= 0;

repeat (_dynamic_batch[BBMOD_EDynamicBatch.Size])
{
	buffer_seek(_buffer, buffer_seek_start, 0);

	repeat (_vertex_count)
	{
		if (_has_vertices)
		{
			var _x = buffer_read(_buffer, buffer_f32);
			var _y = buffer_read(_buffer, buffer_f32);
			var _z = buffer_read(_buffer, buffer_f32);

			vertex_position_3d(_vertex_buffer, _x, _y, _z);
		}

		if (_has_normals)
		{
			var _x = buffer_read(_buffer, buffer_f32);
			var _y = buffer_read(_buffer, buffer_f32);
			var _z = buffer_read(_buffer, buffer_f32);

			vertex_normal(_vertex_buffer, _x, _y, _z);
		}

		if (_has_uvs)
		{
			var _u = buffer_read(_buffer, buffer_f32);
			var _v = buffer_read(_buffer, buffer_f32);

			vertex_texcoord(_vertex_buffer, _u, _v);
		}

		if (_has_colors)
		{
			var _a = buffer_read(_buffer, buffer_u8);
			var _b = buffer_read(_buffer, buffer_u8);
			var _g = buffer_read(_buffer, buffer_u8);
			var _r = buffer_read(_buffer, buffer_u8);

			vertex_float4(_vertex_buffer, _a, _b, _g, _r);
		}

		if (_has_tangentw)
		{
			var _x = buffer_read(_buffer, buffer_f32);
			var _y = buffer_read(_buffer, buffer_f32);
			var _z = buffer_read(_buffer, buffer_f32);
			var _w = buffer_read(_buffer, buffer_f32);

			vertex_float4(_vertex_buffer, _x, _y, _z, _w);
		}

		if (_has_bones)
		{
			repeat (8)
			{
				buffer_read(_buffer, buffer_f32);
			}
		}

		vertex_float1(_vertex_buffer, _id);
	}

	++_id;
}

buffer_delete(_buffer);