/// @func BBMOD_Mesh(_vertexFormat[, _model])
///
/// @extends BBMOD_Class
///
/// @desc A mesh struct.
///
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format of the
/// or `undefined`.
/// @param {Struct.BBMOD_Model} [_model] The model to which the mesh belongs or
/// `undefined`.
///
/// @see BBMOD_Model
/// @see BBMOD_VertexFormat
function BBMOD_Mesh(_vertexFormat, _model=undefined)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Struct.BBMOD_Model} The model to which the mesh belongs or
	/// `undefined`.
	/// @readonly
	Model = _model;

	/// @var {Real} An index of a material that the mesh uses.
	/// @see BBMOD_Model.MaterialCount
	/// @see BBMOD_Model.MaterialNames
	/// @readonly
	MaterialIndex = 0;

	/// @var {Struct.BBMOD_Vec3} The minimum coordinate of the mesh's bounding
	/// box. Available since model version 3.1. Can be `undefined`.
	BboxMin = undefined;

	/// @var {Struct.BBMOD_Vec3} The maximum coordinate of the mesh's bounding
	/// box. Available since model version 3.1. Can be `undefined`.
	BboxMax = undefined;

	/// @var {Id.VertexBuffer} A vertex buffer.
	/// @readonly
	VertexBuffer = undefined;

	/// @var {Struct.BBMOD_VertexFormat} The vertex format of the mesh.
	/// @readonly
	VertexFormat = _vertexFormat;

	/// @var {Constant.PrimitiveType} The primitive type of the mesh.
	/// @readonly
	PrimitiveType = pr_trianglelist;

	/// @func from_buffer(_buffer)
	///
	/// @desc Loads mesh data from a bufffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to load the data from.
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	///
	/// @private
	static from_buffer = function (_buffer) {
		MaterialIndex = buffer_read(_buffer, buffer_u32);

		if (Model.VersionMinor >= 1)
		{
			BboxMin = new BBMOD_Vec3().FromBuffer(_buffer, buffer_f32);
			BboxMax = new BBMOD_Vec3().FromBuffer(_buffer, buffer_f32);
		}

		if (Model.VersionMinor >= 2)
		{
			VertexFormat = bbmod_vertex_format_load(_buffer, Model.VersionMinor);
			PrimitiveType = buffer_read(_buffer, buffer_u32);
		}

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

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes mesh data to a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write the data to.
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	///
	/// @private
	static to_buffer = function (_buffer) {
		buffer_write(_buffer, MaterialIndex, buffer_u32);

		var _versionMinor = Model.VersionMinor;

		if (_versionMinor >= 1)
		{
			BboxMin.ToBuffer(_buffer, buffer_f32);
			BboxMax.ToBuffer(_buffer, buffer_f32);
		}

		if (_versionMinor >= 2)
		{
			bbmod_vertex_format_save(VertexFormat, _buffer, _versionMinor);
			buffer_write(_buffer, buffer_u32, PrimitiveType);
		}

		var _bufferVertices = buffer_create_from_vertex_buffer(VertexBuffer, buffer_fixed, 1);
		var _bufferVerticesSize = buffer_get_size(_bufferVertices);
		var _vertexCount = _bufferVerticesSize / VertexFormat.get_byte_size();

		buffer_write(_buffer, _vertexCount, buffer_u32);
		buffer_copy(_bufferVertices, 0, _bufferVerticesSize, _buffer, buffer_tell(_buffer));
		buffer_seek(_buffer, buffer_seek_relative, _bufferVerticesSize);
		buffer_delete(_bufferVertices);

		return self;
	};

	/// @func freeze()
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	///
	/// @private
	static freeze = function () {
		gml_pragma("forceinline");
		vertex_freeze(VertexBuffer);
		return self;
	};

	/// @func submit(_material[, _transform])
	///
	/// @param {Struct.BBMOD_BaseMaterial} _material
	///
	/// @param {Array<Real>} [_transform]
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	///
	/// @private
	static submit = function (_material, _transform=undefined) {
		if (!_material.apply())
		{
			return self;
		}
		with (BBMOD_SHADER_CURRENT)
		{
			if (_transform != undefined)
			{
				set_bones(_transform);
			}
			set_instance_id();
			set_material_index(other.MaterialIndex);
		}
		vertex_submit(VertexBuffer, PrimitiveType, _material.BaseOpacity);
		return self;
	};

	/// @func render(_material, _transform, _matrix)
	///
	/// @param {Struct.BBMOD_BaseMaterial} _material
	///
	/// @param {Array<Real>} _transform
	///
	/// @param {Array<Real>} _matrix
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	///
	/// @private
	static render = function (_material, _transform, _matrix) {
		gml_pragma("forceinline");
		if (_transform != undefined)
		{
			_material.RenderQueue.draw_mesh_animated(
				VertexBuffer, _matrix, _material, _transform, PrimitiveType, MaterialIndex);
		}
		else
		{
			_material.RenderQueue.draw_mesh(
				VertexBuffer, _matrix, _material, PrimitiveType, MaterialIndex);
		}
		return self;
	};

	/// @func to_dynamic_batch(_dynamicBatch)
	///
	/// @param {Struct.BBMOD_DynamicBatch} _dynamicBatch
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	///
	/// @throws {BBMOD_Exception} When adding the mesh into a batch with a
	/// different primitive type.
	///
	/// @private
	static to_dynamic_batch = function (_dynamicBatch) {
		if (_dynamicBatch.PrimitiveType != undefined
			&& _dynamicBatch.PrimitiveType != PrimitiveType)
		{
			throw new BBMOD_Exception(
				"Cannot add a mesh to a dynamic batch with a different primitive type!");
		}
		_dynamicBatch.PrimitiveType = PrimitiveType;
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
		var _buffer = buffer_create_from_vertex_buffer(
			_meshVertexBuffer, buffer_fixed, 1);
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
	///
	/// @param {Struct.BBMOD_Model} _model
	/// @param {Struct.BBMOD_StaticBatch} _staticBatch
	/// @param {Array<Real>} _transform
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	///
	/// @throws {BBMOD_Exception} When adding the mesh into a batch with a
	/// different primitive type.
	///
	/// @private
	static to_static_batch = function (_model, _staticBatch, _transform) {
		if (_staticBatch.PrimitiveType != undefined
			&& _staticBatch.PrimitiveType != PrimitiveType)
		{
			throw new BBMOD_Exception(
				"Cannot add a mesh to a static batch with a different primitive type!");
		}
		_staticBatch.PrimitiveType = PrimitiveType;
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
		var _buffer = buffer_create_from_vertex_buffer(
			_meshVertexBuffer, buffer_fixed, 1);

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
