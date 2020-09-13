/// @enum An enumeration of members of a legacy mesh struct.
/// @see BBMOD_ENode
enum BBMOD_EMesh
{
	/// @member {real} An index of a material that the mesh uses.
	/// @see BBMOD_EModel.MaterialCount
	/// @see BBMOD_EModel.MaterialNames
	/// @readonly
	MaterialIndex,
	/// @member {vertex_buffer} A vertex buffer.
	/// @readonly
	VertexBuffer,
	/// @member The size of the struct.
	SIZE
};

/// @func bbmod_mesh_load(_buffer, _format)
/// @desc Loads a mesh from a bufffer.
/// @param {buffer} _buffer The buffer to load the struct from.
/// @param {BBMOD_VertexFormat} _format A vertex format that the mesh uses.
/// @return {BBMOD_EMesh} The loaded mesh.
/// @private
function bbmod_mesh_load(_buffer, _format)
{
	var _has_vertices = _format.Vertices;
	var _has_normals = _format.Normals;
	var _has_uvs = _format.TextureCoords;
	var _has_colors = _format.Colors;
	var _has_tangentw = _format.TangentW;
	var _has_bones = _format.Bones;
	var _has_ids = _format.Ids;

	var _mesh = array_create(BBMOD_EMesh.SIZE, undefined);
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
			+ _has_bones * 8 * buffer_sizeof(buffer_f32)
			+ _has_ids * buffer_sizeof(buffer_f32));

		if (_size > 0)
		{
			var _vbuffer = vertex_create_buffer_from_buffer_ext(
				_buffer, _format.Raw, buffer_tell(_buffer), _vertex_count);
			_mesh[@ BBMOD_EMesh.VertexBuffer] = _vbuffer;
			buffer_seek(_buffer, buffer_seek_relative, _size);
		}
	}

	return _mesh;
}

/// @func bbmod_mesh_destroy(_mesh)
/// @desc Destroys a mesh.
/// @param {BBMOD_EMesh} _mesh The mesh to destroy,
/// @private
function bbmod_mesh_destroy(_mesh)
{
	vertex_delete_buffer(_mesh[BBMOD_EMesh.VertexBuffer]);
}

/// @func _bbmod_mesh_freeze(_mesh)
/// @param {BBMOD_EMesh} _mesh
/// @private
function _bbmod_mesh_freeze(_mesh)
{
	gml_pragma("forceinline");
	vertex_freeze(_mesh[BBMOD_EMesh.VertexBuffer]);
}

/// @func _bbmod_mesh_to_dynamic_batch(_mesh, _dynamic_batch)
/// @param {BBMOD_EMesh} _mesh
/// @param {BBMOD_DynamicBatch} _dynamic_batch
/// @private
function _bbmod_mesh_to_dynamic_batch(_mesh, _dynamic_batch)
{
	var _vertex_buffer = _dynamic_batch.VertexBuffer;
	var _model = _dynamic_batch.Model;
	var _vertex_format = _model.VertexFormat;
	var _has_vertices = _vertex_format.Vertices;
	var _has_normals = _vertex_format.Normals;
	var _has_uvs = _vertex_format.TextureCoords;
	var _has_colors = _vertex_format.Colors;
	var _has_tangentw = _vertex_format.TangentW;
	var _has_bones = _vertex_format.Bones;
	var _has_ids = _vertex_format.Ids;
	var _mesh_vertex_buffer = _mesh[BBMOD_EMesh.VertexBuffer];
	var _vertex_count = vertex_get_number(_mesh_vertex_buffer);
	var _buffer = buffer_create_from_vertex_buffer(_mesh_vertex_buffer, buffer_fixed, 1);
	var _id = 0;

	repeat (_dynamic_batch.Size)
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

			if (_has_ids)
			{
				buffer_read(_buffer, buffer_f32);
			}

			vertex_float1(_vertex_buffer, _id);
		}

		++_id;
	}

	buffer_delete(_buffer);
}

/// @func _bbmod_mesh_to_static_batch(_model, _mesh, _static_batch, _transform)
/// @param {BBMOD_Model} _model
/// @param {BBMOD_EMesh} _mesh
/// @param {BBMOD_StaticBatch} _static_batch
/// @param {matrix} _transform
/// @private
function _bbmod_mesh_to_static_batch(_model, _mesh, _static_batch, _transform)
{
	var _vertex_buffer = _static_batch.VertexBuffer;
	var _vertex_format = _model.VertexFormat;
	var _has_vertices = _vertex_format.Vertices;
	var _has_normals = _vertex_format.Normals;
	var _has_uvs = _vertex_format.TextureCoords;
	var _has_colors = _vertex_format.Colors;
	var _has_tangentw = _vertex_format.TangentW;
	var _has_bones = _vertex_format.Bones;
	var _has_ids = _vertex_format.Ids;
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

		if (_has_ids)
		{
			buffer_read(_buffer, buffer_f32);
		}
	}

	buffer_delete(_buffer);
}