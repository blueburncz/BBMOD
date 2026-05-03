/// @module Core

/// @func BBMOD_Mesh(_vertexFormat[, _model])
///
/// @implements {BBMOD_IDestructible}
///
/// @desc A mesh defined by vertex data, its format and the primitive type to
/// use when it's drawn.
///
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format of the
/// mesh or `undefined`.
/// @param {Struct.BBMOD_Model} [_model] The model to which the mesh belongs or
/// `undefined`.
function BBMOD_Mesh(_vertexFormat, _model = undefined) constructor
{
	/// @var {Struct.BBMOD_Model} The model to which the mesh belongs or
	/// `undefined` (default).
	/// @readonly
	Model = _model;

	/// @var {Real} An index of a material to use when drawing the mesh (if
	/// {@link BBMOD_Mesh.Model} is not `undefined`). Default value is 0.
	/// @see BBMOD_Model.Materials
	/// @readonly
	MaterialIndex = 0;

	/// @var {Struct.BBMOD_Vec3} The minimum coordinate of the mesh's bounding
	/// box. Available since model version 3.1. Can be `undefined` (default).
	/// @see BBMOD_Mesh.update_bbox
	BboxMin = undefined;

	/// @var {Struct.BBMOD_Vec3} The maximum coordinate of the mesh's bounding
	/// box. Available since model version 3.1. Can be `undefined` (default).
	/// @see BBMOD_Mesh.update_bbox
	BboxMax = undefined;

	/// @var {Struct.BBMOD_Vec3} The center of the mesh's bounding sphere in
	/// local space. Computed from BboxMin and BboxMax. Can be `undefined` (default).
	/// @readonly
	/// @see BBMOD_Mesh.update_bbox
	/// @see BBMOD_Mesh.BoundingSphereRadius
	BoundingSphereCenter = undefined;

	/// @var {Real} The radius of the mesh's bounding sphere in local space.
	/// Computed from BboxMin and BboxMax. Can be `undefined` (default).
	/// @readonly
	/// @see BBMOD_Mesh.update_bbox
	/// @see BBMOD_Mesh.BoundingSphereCenter
	BoundingSphereRadius = undefined;

	/// @var {Id.VertexBuffer} A vertex buffer containing the raw mesh data or
	/// `undefined` (default).
	/// @readonly
	VertexBuffer = undefined;

	/// @var {Struct.BBMOD_VertexFormat} The vertex format of the mesh.
	/// @readonly
	VertexFormat = _vertexFormat;

	/// @var {Constant.PrimitiveType} The primitive type of the mesh. Default is
	/// `pr_trianglelist`.
	/// @readonly
	PrimitiveType = pr_trianglelist;

	/// @var {Bool} If `true` then the mesh is "frozen", which means it resides
	/// in the GPU memory, making it faster to draw, but also unmodifiable.
	/// @readonly
	/// @see BBMOD_Mesh.freeze
	Frozen = false;

	/// @func __compute_bounding_sphere()
	///
	/// @desc Computes the bounding sphere center and radius from BboxMin and BboxMax.
	/// Called internally when the bounding box is updated.
	///
	/// @private
	static __compute_bounding_sphere = function ()
	{
		if (BboxMin != undefined && BboxMax != undefined)
		{
			// Compute center
			BoundingSphereCenter = new BBMOD_Vec3(
				(BboxMin.X + BboxMax.X) * 0.5,
				(BboxMin.Y + BboxMax.Y) * 0.5,
				(BboxMin.Z + BboxMax.Z) * 0.5
			);

			// Compute radius (distance from center to corner)
			var _halfSizeX = (BboxMax.X - BboxMin.X) * 0.5;
			var _halfSizeY = (BboxMax.Y - BboxMin.Y) * 0.5;
			var _halfSizeZ = (BboxMax.Z - BboxMin.Z) * 0.5;
			BoundingSphereRadius = sqrt(_halfSizeX * _halfSizeX + _halfSizeY * _halfSizeY + _halfSizeZ
				* _halfSizeZ);
		}
		else
		{
			BoundingSphereCenter = undefined;
			BoundingSphereRadius = undefined;
		}
	};

	/// @func copy(_dest)
	///
	/// @desc Copies mesh data into another mesh.
	///
	/// @param {Struct.BBMOD_Mesh} _dest The mesh to copy data to.
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	static copy = function (_dest)
	{
		_dest.Model = Model;
		_dest.MaterialIndex = MaterialIndex;
		_dest.BboxMin = (BboxMin != undefined) ? BboxMin.Clone() : undefined;
		_dest.BboxMax = (BboxMax != undefined) ? BboxMax.Clone() : undefined;
		_dest.BoundingSphereCenter = (BoundingSphereCenter != undefined) ? BoundingSphereCenter.Clone() : undefined;
		_dest.BoundingSphereRadius = BoundingSphereRadius;

		if (_dest.VertexBuffer != undefined)
		{
			vertex_delete_buffer(_dest.VertexBuffer);
		}

		if (VertexBuffer)
		{
			var _buffer = buffer_create_from_vertex_buffer(VertexBuffer, buffer_fixed, 1);
			_dest.VertexBuffer = vertex_create_buffer_from_buffer_ext(_buffer,
				(VertexFormat != undefined) ? VertexFormat.Raw : Model.VertexFormat.Raw,
				0, vertex_get_number(VertexBuffer));
			buffer_delete(_buffer);
		}
		else
		{
			_dest.VertexBuffer = undefined;
		}

		_dest.VertexFormat = VertexFormat;
		_dest.PrimitiveType = PrimitiveType;

		return self;
	};

	/// @func clone()
	///
	/// @desc Creates a clone of the mesh.
	///
	/// @return {Struct.BBMOD_Mesh} The created clone.
	static clone = function ()
	{
		var _clone = new BBMOD_Mesh(VertexFormat, Model);
		copy(_clone);
		return _clone;
	};

	/// @func from_buffer(_buffer)
	///
	/// @desc Loads mesh data from a buffer following the BBMOD file format.
	///
	/// @param {Id.Buffer} _buffer The buffer to load the data from. Its seek
	/// position must point to a beginning of a BBMOD mesh.
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If {@link BBMOD_Mesh.Model} is `undefined`.
	static from_buffer = function (_buffer)
	{
		if (Model == undefined)
		{
			throw new BBMOD_Exception("Cannot load a mesh from a buffer if Model is undefined!");
		}

		MaterialIndex = buffer_read(_buffer, buffer_u32);

		if (Model.VersionMinor >= 1)
		{
			BboxMin = new BBMOD_Vec3().FromBuffer(_buffer, buffer_f32);
			BboxMax = new BBMOD_Vec3().FromBuffer(_buffer, buffer_f32);
			__compute_bounding_sphere();
		}

		if (Model.VersionMinor >= 2)
		{
			VertexFormat = __bbmod_vertex_format_load(_buffer, Model.VersionMinor);
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
	/// @desc Writes mesh data to a buffer following the current version of the
	/// BBMOD file format.
	///
	/// @param {Id.Buffer} _buffer The buffer to write the data to.
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If {@link BBMOD_Mesh.Model} is `undefined`.
	///
	/// @see BBMOD_VERSION_MAJOR
	/// @see BBMOD_VERSION_MINOR
	static to_buffer = function (_buffer)
	{
		if (Model == undefined)
		{
			throw new BBMOD_Exception("Cannot write a mesh to a buffer if Model is undefined!");
		}

		buffer_write(_buffer, buffer_u32, MaterialIndex);

		var _versionMinor = Model.VersionMinor;

		if (_versionMinor >= 1)
		{
			BboxMin.ToBuffer(_buffer, buffer_f32);
			BboxMax.ToBuffer(_buffer, buffer_f32);
		}

		if (_versionMinor >= 2)
		{
			__bbmod_vertex_format_save(VertexFormat, _buffer, _versionMinor);
			buffer_write(_buffer, buffer_u32, PrimitiveType);
		}

		var _bufferVertices = buffer_create_from_vertex_buffer(VertexBuffer, buffer_fixed, 1);
		var _bufferVerticesSize = buffer_get_size(_bufferVertices);
		var _vertexCount = _bufferVerticesSize / VertexFormat.get_byte_size();

		buffer_write(_buffer, buffer_u32, _vertexCount);
		buffer_copy(_bufferVertices, 0, _bufferVerticesSize, _buffer, buffer_tell(_buffer));
		buffer_seek(_buffer, buffer_seek_relative, _bufferVerticesSize);
		buffer_delete(_bufferVertices);

		return self;
	};

	/// @func update_bbox()
	///
	/// @desc Updates the mesh's bounding box using data from its vertex buffer,
	/// which must not be frozen!
	///
	/// @throws {BBMOD_Exception} If {@link BBMOD_Mesh.VertexBuffer} is `undefined`
	/// or frozen!
	///
	/// @see BBMOD_Mesh.BboxMin
	/// @see BBMOD_Mesh.BboxMax
	/// @see BBMOD_Mesh.Frozen
	static update_bbox = function ()
	{
		if (VertexBuffer == undefined)
		{
			throw new BBMOD_Exception("Cannot update bounding box of a mesh whose vertex buffer is undefined!");
		}

		if (Frozen)
		{
			throw new BBMOD_Exception("Cannot update bounding box of a mesh when it's frozen!");
		}

		var _buffer = buffer_create_from_vertex_buffer(VertexBuffer, buffer_fixed, 1);
		var _stride = VertexFormat.get_byte_size();
		var _offset = 0;
		BboxMin = new BBMOD_Vec3(infinity);
		BboxMax = new BBMOD_Vec3(-infinity);

		buffer_seek(_buffer, buffer_seek_start, 0);
		repeat(vertex_get_number(VertexBuffer))
		{
			var _x = buffer_peek(_buffer, _offset, buffer_f32);
			var _y = buffer_peek(_buffer, _offset + 4, buffer_f32);
			var _z = buffer_peek(_buffer, _offset + 8, buffer_f32);

			BboxMin.X = min(BboxMin.X, _x);
			BboxMin.Y = min(BboxMin.Y, _y);
			BboxMin.Z = min(BboxMin.Z, _z);

			BboxMax.X = max(BboxMax.X, _x);
			BboxMax.Y = max(BboxMax.Y, _y);
			BboxMax.Z = max(BboxMax.Z, _z);

			_offset += _stride;
		}
		buffer_delete(_buffer);

		__compute_bounding_sphere();

		return self;
	};

	/// @func freeze()
	///
	/// @desc "Freezes" the mesh. This uploads its data to the GPU memory, which
	/// makes it draw faster but also makes it unmodifiable.
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	///
	/// @see BBMOD_Mesh.Frozen
	static freeze = function ()
	{
		gml_pragma("forceinline");
		if (!Frozen)
		{
			vertex_freeze(VertexBuffer);
			Frozen = true;
		}
		return self;
	};

	/// @func submit(_material, _transform, _batchData)
	///
	/// @desc Immediately submits the mesh for rendering.
	///
	/// @param {Struct.BBMOD_IMaterial, Pointer.Texture} _material A material struct
	/// to apply or just the base texture if you don't use BBMOD's material system.
	/// @param {Array<Real>} _transform An array of bone transform or `undefined`.
	/// @param {Array<Real>, Array<Array<Real>>} _batchData Data for dynamic
	/// batching or `undefined`.
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	static submit = function (_material, _transform, _batchData)
	{
		var _materialIsStruct = is_struct(_material);
		var _isBatched = (_batchData != undefined);
		var _isAnimated = (_transform != undefined);
		var _ditherEnableSnapshot = bbmod_dither_get_enabled();
		var _ditherValueSnapshot = bbmod_dither_get_value();
		var _batchedInstancesExecuted = 1;

		if (_isBatched && !_isAnimated)
		{
			var _batchContext = global.__bbmodDynamicBatchContext;
			if (_batchContext != undefined)
			{
				var _batchVisibleHint = variable_global_exists("__bbmodBatchVisibleInstances")
					? global.__bbmodBatchVisibleInstances
					: undefined;
				var _filterResult = _batchContext.DataFilter(
					self,
					matrix_get(matrix_world),
					_batchData,
					global.__bbmodInstanceIDBatch,
					undefined,
					_batchVisibleHint,
					_ditherEnableSnapshot,
					_ditherValueSnapshot);

				_batchData = _filterResult.BatchData;
				_batchedInstancesExecuted = _filterResult.VisibleInstances;

				if (_filterResult.FrustumCulledInstances > 0)
				{
					__bbmod_render_statistics_count(
						__BBMOD_ERenderStatisticsCounter.BatchedMeshDrawCallsFrustumCulled,
						_filterResult.FrustumCulledInstances);
				}

				if (_filterResult.DistanceCulledInstances > 0)
				{
					__bbmod_render_statistics_count(
						__BBMOD_ERenderStatisticsCounter.BatchedMeshDrawCallsDistanceCulled,
						_filterResult.DistanceCulledInstances);
				}

				if (_filterResult.SkipDraw || _batchedInstancesExecuted <= 0)
				{
					return self;
				}
			}
			else
			{
				var _batchInstanceIds = global.__bbmodInstanceIDBatch;
				if (is_array(_batchInstanceIds))
				{
					if (is_array(_batchInstanceIds[0]))
					{
						_batchedInstancesExecuted = 0;
						var _idArrayIndex = 0;
						repeat(array_length(_batchInstanceIds))
						{
							var _idsCurrent = _batchInstanceIds[_idArrayIndex++];
							var _idIndex = 0;
							repeat(array_length(_idsCurrent))
							{
								if (_idsCurrent[_idIndex++] != 0)
								{
									++_batchedInstancesExecuted;
								}
							}
						}
					}
					else
					{
						_batchedInstancesExecuted = 0;
						var _idIndex = 0;
						repeat(array_length(_batchInstanceIds))
						{
							if (_batchInstanceIds[_idIndex++] != 0)
							{
								++_batchedInstancesExecuted;
							}
						}
					}
				}
				else if (is_array(_batchData[0]))
				{
					// No IDs available, so use chunk count as a conservative fallback.
					_batchedInstancesExecuted = array_length(_batchData);
				}
			}
		}

		if (_materialIsStruct && !_material.apply(VertexFormat))
		{
			return self;
		}

		var _ditherEnable = _ditherEnableSnapshot ? 1.0 : 0.0;
		var _instanceId = variable_global_exists("__bbmodInstanceID")
			? variable_global_get("__bbmodInstanceID")
			: 0.0;
		var _ditherFade = _ditherValueSnapshot;

		// Frustum culling (skip for dynamic batches as it would be expensive)
		if (global.__bbmodFrustumCulling && BoundingSphereCenter != undefined && !(_batchData != undefined
				&& is_array(_batchData[0])))
		{
			var _matrix = matrix_get(matrix_world);
			var _center = BoundingSphereCenter;
			var _centerX = _center.X;
			var _centerY = _center.Y;
			var _centerZ = _center.Z;

			// Transform center to world space
			var _worldX = _matrix[12] + _centerX * _matrix[0] + _centerY * _matrix[4] + _centerZ * _matrix[8];
			var _worldY = _matrix[13] + _centerX * _matrix[1] + _centerY * _matrix[5] + _centerZ * _matrix[9];
			var _worldZ = _matrix[14] + _centerX * _matrix[2] + _centerY * _matrix[6] + _centerZ * _matrix[10];

			// Get maximum scale from matrix
			var _scaleX = sqrt(_matrix[0] * _matrix[0] + _matrix[1] * _matrix[1] + _matrix[2] * _matrix[2]);
			var _scaleY = sqrt(_matrix[4] * _matrix[4] + _matrix[5] * _matrix[5] + _matrix[6] * _matrix[6]);
			var _scaleZ = sqrt(_matrix[8] * _matrix[8] + _matrix[9] * _matrix[9] + _matrix[10] * _matrix[10]);
			var _maxScale = max(_scaleX, _scaleY, _scaleZ);
			var _worldRadius = BoundingSphereRadius * _maxScale;

			// Test visibility
			if (!sphere_is_visible(_worldX, _worldY, _worldZ, _worldRadius))
			{
				if (_isAnimated)
				{
					__bbmod_render_statistics_count(
						__BBMOD_ERenderStatisticsCounter.AnimatedMeshDrawCallsFrustumCulled);
				}
				else if (_isBatched)
				{
					__bbmod_render_statistics_count(
						__BBMOD_ERenderStatisticsCounter.BatchedMeshDrawCallsFrustumCulled);
				}
				else
				{
					__bbmod_render_statistics_count(
						__BBMOD_ERenderStatisticsCounter.MeshDrawCallsFrustumCulled);
				}

				return self;
			}
		}

		if (_ditherEnable > 0.0 && _ditherFade <= 0.0 && !_isBatched)
		{
			if (_isAnimated)
			{
				__bbmod_render_statistics_count(
					__BBMOD_ERenderStatisticsCounter.AnimatedMeshDrawCallsDistanceCulled);
			}
			else
			{
				__bbmod_render_statistics_count(
					__BBMOD_ERenderStatisticsCounter.MeshDrawCallsDistanceCulled);
			}

			return self;
		}

		var _vertexBuffer = VertexBuffer;
		var _primitiveType = PrimitiveType;
		var _baseOpacity = _materialIsStruct ? _material.BaseOpacity : _material;
		var _shader = shader_current();
		var _ditherSeed = 0.0;

		if (_shader != -1)
		{
			if (_instanceId != 0)
			{
				_ditherSeed = _instanceId;
				shader_set_uniform_f(
					shader_get_uniform(_shader, "bbmod_InstanceID"),
					((_instanceId & $000000FF) >> 0) / 255,
					((_instanceId & $0000FF00) >> 8) / 255,
					((_instanceId & $00FF0000) >> 16) / 255,
					((_instanceId & $FF000000) >> 24) / 255);
			}

			shader_set_uniform_f(shader_get_uniform(_shader, "bbmod_MaterialIndex"), MaterialIndex);
			shader_set_uniform_f(shader_get_uniform(_shader, BBMOD_U_DITHER_ENABLE), _ditherEnable);
			shader_set_uniform_f(shader_get_uniform(_shader, BBMOD_U_DITHER_SEED), _ditherSeed);
			shader_set_uniform_f(shader_get_uniform(_shader, BBMOD_U_DITHER_FADE), _ditherFade);

			if (_transform != undefined)
			{
				shader_set_uniform_f_array(shader_get_uniform(_shader, "bbmod_Bones"), _transform);
			}
		}

		if (_batchData != undefined)
		{
			if (is_array(_batchData[0]))
			{
				var _dataIndex = 0;
				var _uBatchData = undefined;
				repeat(array_length(_batchData))
				{
					if (_shader != -1)
					{
						_uBatchData ??= shader_get_uniform(_shader, "bbmod_BatchData");
						shader_set_uniform_f_array(_uBatchData, _batchData[_dataIndex++]);
					}
					if (_isAnimated)
					{
						__bbmod_render_statistics_count(
							__BBMOD_ERenderStatisticsCounter.AnimatedMeshDrawCallsDrawn);
					}
					vertex_submit(_vertexBuffer, _primitiveType, _baseOpacity);
				}
			}
			else
			{
				if (_shader != -1)
				{
					shader_set_uniform_f_array(
						shader_get_uniform(_shader, "bbmod_BatchData"), _batchData);
				}
				if (_isAnimated)
				{
					__bbmod_render_statistics_count(
						__BBMOD_ERenderStatisticsCounter.AnimatedMeshDrawCallsDrawn);
				}
				vertex_submit(_vertexBuffer, _primitiveType, _baseOpacity);
			}

			if (!_isAnimated)
			{
				__bbmod_render_statistics_count(
					__BBMOD_ERenderStatisticsCounter.BatchedMeshDrawCallsDrawn,
					_batchedInstancesExecuted);
			}
		}
		else
		{
			if (_isAnimated)
			{
				__bbmod_render_statistics_count(
					__BBMOD_ERenderStatisticsCounter.AnimatedMeshDrawCallsDrawn);
			}
			else
			{
				__bbmod_render_statistics_count(
					__BBMOD_ERenderStatisticsCounter.MeshDrawCallsDrawn);
			}
			vertex_submit(_vertexBuffer, _primitiveType, _baseOpacity);
		}

		return self;
	};

	/// @func render(_material, _transform, _batchData, _matrix)
	///
	/// @desc Enqueues the mesh for rendering.
	///
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array<Real>} _transform An array of bone transforms or `undefined`.
	/// @param {Array<Real>, Array<Array<Real>>} _batchData Data for dynamic
	/// batching or `undefined`.
	/// @param {Array<Real>} _matrix The current world matrix.
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	static render = function (_material, _transform, _batchData, _matrix)
	{
		gml_pragma("forceinline");
		var _renderQueue = bbmod_render_queue_get(_material.RenderQueue);
		if (_batchData != undefined)
		{
			_renderQueue.DrawMeshBatched(self, _material, _matrix, _batchData);
		}
		else if (_transform != undefined)
		{
			_renderQueue.DrawMeshAnimated(self, _material, _matrix, _transform);
		}
		else
		{
			_renderQueue.DrawMesh(self, _material, _matrix);
		}
		return self;
	};

	/// @func __to_dynamic_batch(_dynamicBatch)
	///
	/// @param {Struct.BBMOD_DynamicBatch} _dynamicBatch
	///
	/// @return {Struct.BBMOD_Mesh} Returns `self`.
	///
	/// @throws {BBMOD_Exception} When adding the mesh into a batch with a
	/// different primitive type.
	///
	/// @private
	static __to_dynamic_batch = function (_dynamicBatch)
	{
		if (_dynamicBatch.PrimitiveType != undefined
			&& _dynamicBatch.PrimitiveType != PrimitiveType)
		{
			throw new BBMOD_Exception(
				"Cannot add a mesh to a dynamic batch with a different primitive type!");
		}
		_dynamicBatch.PrimitiveType = PrimitiveType;
		var _vertexBuffer = _dynamicBatch.VertexBuffer;
		var _vertexFormat = VertexFormat;
		var _hasVertices = _vertexFormat.Vertices;
		var _hasNormals = _vertexFormat.Normals;
		var _hasUvs = _vertexFormat.TextureCoords;
		var _hasUvs2 = _vertexFormat.TextureCoords2;
		var _hasColors = _vertexFormat.Colors;
		var _hasTangentW = _vertexFormat.TangentW;
		var _hasBones = _vertexFormat.Bones;
		var _hasIds = _vertexFormat.Ids;
		var _meshVertexBuffer = VertexBuffer;
		var _vertexCount = vertex_get_number(_meshVertexBuffer);
		var _buffer = buffer_create_from_vertex_buffer(
			_meshVertexBuffer, buffer_fixed, 1);
		var _id = 0;

		repeat(_dynamicBatch.Size)
		{
			buffer_seek(_buffer, buffer_seek_start, 0);

			repeat(_vertexCount)
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

					if (_hasUvs2)
					{
						buffer_read(_buffer, buffer_f32);
						buffer_read(_buffer, buffer_f32);
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
						repeat(8)
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

	/// @func __to_static_batch(_model, _staticBatch, _transform)
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
	static __to_static_batch = function (_model, _staticBatch, _transform)
	{
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
		var _hasUvs2 = _vertexFormat.TextureCoords2;
		var _hasColors = _vertexFormat.Colors;
		var _hasTangentW = _vertexFormat.TangentW;
		var _hasBones = _vertexFormat.Bones;
		var _hasIds = _vertexFormat.Ids;
		var _meshVertexBuffer = VertexBuffer;
		var _buffer = buffer_create_from_vertex_buffer(
			_meshVertexBuffer, buffer_fixed, 1);

		buffer_seek(_buffer, buffer_seek_start, 0);

		repeat(vertex_get_number(_meshVertexBuffer))
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

			if (_hasUvs2)
			{
				buffer_read(_buffer, buffer_f32);
				buffer_read(_buffer, buffer_f32);
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
				repeat(8)
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

	static destroy = function ()
	{
		vertex_delete_buffer(VertexBuffer);
		return undefined;
	};
}
