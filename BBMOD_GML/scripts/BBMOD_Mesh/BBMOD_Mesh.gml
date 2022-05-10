/// @func BBMOD_Mesh(_vertexFormat)
/// @extends BBMOD_Class
/// @desc A mesh struct.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format of the mesh.
/// @see BBMOD_Node
function BBMOD_Mesh(_vertexFormat)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Real} An index of a material that the mesh uses.
	/// @see BBMOD_Model.MaterialCount
	/// @see BBMOD_Model.MaterialNames
	/// @readonly
	MaterialIndex = 0;

	/// @var {Id.VertexBuffer} A vertex buffer.
	/// @readonly
	VertexBuffer = undefined;

	/// @var {Struct.BBMOD_VertexFormat} The vertex format of the mesh.
	/// @readonly
	VertexFormat = _vertexFormat;

	/// @func from_buffer(_buffer)
	/// @desc Loads mesh data from a bufffer.
	/// @param {Id.Buffer} _buffer The buffer to load the data from.
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	/// @private
	static from_buffer = function (_buffer) {
		MaterialIndex = buffer_read(_buffer, buffer_u32);

		var _vertexCount = buffer_read(_buffer, buffer_u32);
		if (_vertexCount > 0)
		{
			var _size = _vertexCount * VertexFormat.get_byte_size();
			if (_size > 0)
			{
				VertexBuffer = vertex_create_buffer_from_buffer_ext(
					_buffer, VertexFormat.Raw, buffer_tell(_buffer), _vertexCount);
				buffer_seek(_buffer, buffer_seek_relative, _size);
			}
		}

		return self;
	};

	/// @func freeze()
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	/// @private
	static freeze = function (_material, _transform) {
		gml_pragma("forceinline");
		vertex_freeze(VertexBuffer);
		return self;
	};

	/// @func submit(_material[, _transform])
	/// @func {Struct.BBMOD_BaseMaterial} _material
	/// @func {Array<Real>/Undefined} [_transform]
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	/// @private
	static submit = function (_material, _transform=undefined) {
		if (!_material.apply())
		{
			return self;
		}
		if (_transform != undefined)
		{
			BBMOD_SHADER_CURRENT.set_bones(_transform);
		}
		BBMOD_SHADER_CURRENT.set_instance_id();
		vertex_submit(VertexBuffer, pr_trianglelist, _material.BaseOpacity);
		return self;
	};

	/// @func render(_material, _transform, _matrix)
	/// @func {Struct.BBMOD_BaseMaterial} _material
	/// @func {Array<Real>/undefined} _transform
	/// @func {Array<Real>} _matrix
	/// @return {BBMOD_Mesh} Returns `self`.
	/// @private
	static render = function (_material, _transform, _matrix) {
		gml_pragma("forceinline");
		if (_transform != undefined)
		{
			_material.RenderQueue.draw_mesh_animated(VertexBuffer, _matrix, _material, _transform);
		}
		else
		{
			_material.RenderQueue.draw_mesh(VertexBuffer, _matrix, _material);
		}
		return self;
	};

	/// @func to_dynamic_batch(_dynamicBatch)
	/// @param {Struct.BBMOD_DynamicBatch} _dynamicBatch
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	/// @private
	static to_dynamic_batch = function (_dynamicBatch) {
		var _vertexBuffer = _dynamicBatch.VertexBuffer;
		var _model = _dynamicBatch.Model;
		var _vertexFormat = _model.VertexFormat;
		var _hasVertices = _vertexFormat.Vertices;
		var _hasNormals = _vertexFormat.Normals;
		var _hasUvs = _vertexFormat.TextureCoords;
		var _hasColors = _vertexFormat.Colors;
		var _hasTangentW = _vertexFormat.TangentW;
		var _hasBones = _vertexFormat.Bones;
		var _hasIds = _vertexFormat.Ids;
		var _meshVertexBuffer = VertexBuffer;
		var _vertexCount = vertex_get_number(_meshVertexBuffer);
		var _buffer = buffer_create_from_vertex_buffer(_meshVertexBuffer, buffer_fixed, 1);
		var _id = 0;

		repeat (_dynamicBatch.Size)
		{
			buffer_seek(_buffer, buffer_seek_start, 0);

			repeat (_vertexCount)
			{
				if (_hasVertices)
				{
					var _x = buffer_read(_buffer, buffer_f32);
					var _y = buffer_read(_buffer, buffer_f32);
					var _z = buffer_read(_buffer, buffer_f32);

					vertex_position_3d(_vertexBuffer, _x, _y, _z);
				}

				if (_hasNormals)
				{
					var _x = buffer_read(_buffer, buffer_f32);
					var _y = buffer_read(_buffer, buffer_f32);
					var _z = buffer_read(_buffer, buffer_f32);

					vertex_normal(_vertexBuffer, _x, _y, _z);
				}

				if (_hasUvs)
				{
					var _u = buffer_read(_buffer, buffer_f32);
					var _v = buffer_read(_buffer, buffer_f32);

					vertex_texcoord(_vertexBuffer, _u, _v);
				}

				if (_hasColors)
				{
					var _a = buffer_read(_buffer, buffer_u8);
					var _b = buffer_read(_buffer, buffer_u8);
					var _g = buffer_read(_buffer, buffer_u8);
					var _r = buffer_read(_buffer, buffer_u8);

					vertex_color(_vertexBuffer, make_color_rgb(_r, _g, _b), _a);
				}

				if (_hasTangentW)
				{
					var _x = buffer_read(_buffer, buffer_f32);
					var _y = buffer_read(_buffer, buffer_f32);
					var _z = buffer_read(_buffer, buffer_f32);
					var _w = buffer_read(_buffer, buffer_f32);

					vertex_float4(_vertexBuffer, _x, _y, _z, _w);
				}

				if (_hasBones)
				{
					repeat (8)
					{
						buffer_read(_buffer, buffer_f32);
					}
				}

				if (_hasIds)
				{
					buffer_read(_buffer, buffer_f32);
				}

				vertex_float1(_vertexBuffer, _id);
			}

			++_id;
		}

		buffer_delete(_buffer);

		return self;
	};

	/// @func to_static_batch(_model, _staticBatch, _transform)
	/// @param {Struct.BBMOD_Model} _model
	/// @param {Struct.BBMOD_StaticBatch} _staticBatch
	/// @param {Array<Real>} _transform
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	/// @private
	static to_static_batch = function (_model, _staticBatch, _transform) {
		var _vertexBuffer = _staticBatch.VertexBuffer;
		var _vertexFormat = _model.VertexFormat;
		var _hasVertices = _vertexFormat.Vertices;
		var _hasNormals = _vertexFormat.Normals;
		var _hasUvs = _vertexFormat.TextureCoords;
		var _hasColors = _vertexFormat.Colors;
		var _hasTangentW = _vertexFormat.TangentW;
		var _hasBones = _vertexFormat.Bones;
		var _hasIds = _vertexFormat.Ids;
		var _meshVertexBuffer = VertexBuffer;
		var _buffer = buffer_create_from_vertex_buffer(_meshVertexBuffer, buffer_fixed, 1);

		buffer_seek(_buffer, buffer_seek_start, 0);

		repeat (vertex_get_number(_meshVertexBuffer))
		{
			if (_hasVertices)
			{
				var _x = buffer_read(_buffer, buffer_f32);
				var _y = buffer_read(_buffer, buffer_f32);
				var _z = buffer_read(_buffer, buffer_f32);
				var _vec = new BBMOD_Vec3(_x, _y, _z).Transform(_transform);

				vertex_position_3d(_vertexBuffer, _vec.X, _vec.Y, _vec.Z);
			}

			if (_hasNormals)
			{
				var _x = buffer_read(_buffer, buffer_f32);
				var _y = buffer_read(_buffer, buffer_f32);
				var _z = buffer_read(_buffer, buffer_f32);
				var _vec = new BBMOD_Vec4(_x, _y, _z, 0.0).Transform(_transform);

				vertex_normal(_vertexBuffer, _vec.X, _vec.Y, _vec.Z);
			}

			if (_hasUvs)
			{
				var _u = buffer_read(_buffer, buffer_f32);
				var _v = buffer_read(_buffer, buffer_f32);

				vertex_texcoord(_vertexBuffer, _u, _v);
			}

			if (_hasColors)
			{
				var _a = buffer_read(_buffer, buffer_u8);
				var _b = buffer_read(_buffer, buffer_u8);
				var _g = buffer_read(_buffer, buffer_u8);
				var _r = buffer_read(_buffer, buffer_u8);

				vertex_color(_vertexBuffer, make_color_rgb(_r, _g, _b), _a);
			}

			if (_hasTangentW)
			{
				var _x = buffer_read(_buffer, buffer_f32);
				var _y = buffer_read(_buffer, buffer_f32);
				var _z = buffer_read(_buffer, buffer_f32);
				var _w = buffer_read(_buffer, buffer_f32);

				vertex_float4(_vertexBuffer, _x, _y, _z, _w);
			}

			if (_hasBones)
			{
				repeat (8)
				{
					buffer_read(_buffer, buffer_f32);
				}
			}

			if (_hasIds)
			{
				buffer_read(_buffer, buffer_f32);
			}
		}

		buffer_delete(_buffer);

		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		vertex_delete_buffer(VertexBuffer);
		return undefined;
	};
}