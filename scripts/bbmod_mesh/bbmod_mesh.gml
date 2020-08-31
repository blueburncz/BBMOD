/// @enum An enumeration of members of a BBMOD_EMesh legacy struct.
enum BBMOD_EMesh
{
	/// @member An index of a material that the mesh uses.
	MaterialIndex,
	/// @member A vertex buffer.
	VertexBuffer,
	/// @member The size of the BBMOD_EMesh legacy struct.
	SIZE
};

/// @func bbmod_mesh_load(_buffer, _format, _format_mask)
/// @desc Loads a mesh from a bufffer.
/// @param {real} _buffer The buffer to load the struct from.
/// @param {real} _format A vertex format that the mesh uses.
/// @param {real} _format_mask A vertex format mask.
/// @return {BBMOD_EMesh} The loaded mesh.
function bbmod_mesh_load(_buffer, _format, _format_mask)
{
	var _has_vertices = (_format_mask >> BBMOD_VFORMAT_VERTEX) & 1;
	var _has_normals = (_format_mask >> BBMOD_VFORMAT_NORMAL) & 1;
	var _has_uvs = (_format_mask >> BBMOD_VFORMAT_TEXCOORD) & 1;
	var _has_colors = (_format_mask >> BBMOD_VFORMAT_COLOR) & 1;
	var _has_tangentw = (_format_mask >> BBMOD_VFORMAT_TANGENTW) & 1;
	var _has_bones = (_format_mask >> BBMOD_VFORMAT_BONES) & 1;

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
}

/// @func bbmod_mesh_destroy(_mesh)
/// @desc Destroys a mesh.
/// @param {BBMOD_EMesh} _mesh The mesh to destroy,
function bbmod_mesh_destroy(_mesh)
{
	vertex_delete_buffer(_mesh[BBMOD_EMesh.VertexBuffer]);
}

/// @func _bbmod_mesh_freeze(_mesh)
/// @param {BBMOD_EMesh} _mesh
function _bbmod_mesh_freeze(_mesh)
{
	gml_pragma("forceinline");
	vertex_freeze(_mesh[BBMOD_EMesh.VertexBuffer]);
}

/// @func _bbmod_mesh_to_dynamic_batch(_mesh, _dynamic_batch)
/// @param {BBMOD_EMesh} _mesh
/// @param {BBMOD_EDynamicBatch} _dynamic_batch
function _bbmod_mesh_to_dynamic_batch(_mesh, _dynamic_batch)
{
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

	var _id = 0;

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
}

/// @func _bbmod_mesh_to_static_batch(_model, _mesh, _static_batch, _transform)
/// @param {BBMOD_EModel} _model
/// @param {BBMOD_EMesh} _mesh
/// @param {BBMOD_EDynamicBatch} _static_batch
/// @param {array} _transform
function _bbmod_mesh_to_static_batch(_model, _mesh, _static_batch, _transform)
{
	var _vertex_buffer = _static_batch[BBMOD_EStaticBatch.VertexBuffer];

	var _has_vertices = _model[BBMOD_EModel.HasVertices];
	var _has_normals = _model[BBMOD_EModel.HasNormals];
	var _has_uvs = _model[BBMOD_EModel.HasTextureCoords];
	var _has_colors = _model[BBMOD_EModel.HasColors];
	var _has_tangentw = _model[BBMOD_EModel.HasTangentW];
	var _has_bones = _model[BBMOD_EModel.HasBones];

	var _mesh_vertex_buffer = _mesh[BBMOD_EMesh.VertexBuffer];

	var _buffer = buffer_create_from_vertex_buffer(_mesh_vertex_buffer, buffer_fixed, 1);
	buffer_seek(_buffer, buffer_seek_start, 0);

	repeat (vertex_get_number(_mesh_vertex_buffer))
	{
		if (_has_vertices)
		{
			var _x = buffer_read(_buffer, buffer_f32);
			var _y = buffer_read(_buffer, buffer_f32);
			var _z = buffer_read(_buffer, buffer_f32);

			var _vec = [_x, _y, _z];
			ce_vec3_transform(_vec, _transform);

			vertex_position_3d(_vertex_buffer, _vec[0], _vec[1], _vec[2]);
		}

		if (_has_normals)
		{
			var _x = buffer_read(_buffer, buffer_f32);
			var _y = buffer_read(_buffer, buffer_f32);
			var _z = buffer_read(_buffer, buffer_f32);

			var _vec = [_x, _y, _z, 0];
			ce_vec4_transform(_vec, _transform);

			vertex_normal(_vertex_buffer, _vec[0], _vec[1], _vec[2]);
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
	}

	buffer_delete(_buffer);
}