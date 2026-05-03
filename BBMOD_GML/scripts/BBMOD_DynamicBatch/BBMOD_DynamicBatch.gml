/// @module Core

/// @macro {Real} Maximum number of vec4 uniforms for dynamic batch data
/// available in the default shaders. Equals to 192.
#macro BBMOD_MAX_BATCH_VEC4S 192

/// @func BBMOD_DynamicBatch([_model[, _size[, _slotsPerInstance]]])
///
/// @implements {BBMOD_IDestructible}
///
/// @desc A dynamic batch is a structure that allows you to render multiple
/// instances of a single model at once, each with its own position, scale and
/// rotation. Compared to {@link BBMOD_Model.submit}, this drastically reduces
/// draw calls and increases performance, but requires more memory. Number of
/// model instances per batch is also affected by maximum number of uniforms
/// that a vertex shader can accept.
///
/// @param {Struct.BBMOD_Model} [_model] The model to create a dynamic batch of.
/// @param {Real} [_size] Number of model instances in the batch. Default value
/// is 32.
/// @param {Real} [_slotsPerInstance] Number of slots that each instance takes
/// in the data array. Default value is 16.
///
/// @example
/// Following code renders all instances of a car object in batches of 64.
/// ```gml
/// /// @desc Create event
/// modCar = new BBMOD_Model("Car.bbmod");
/// matCar = new BBMOD_DefaultMaterial(BBMOD_ShDefaultBatched,
///     sprite_get_texture(SprCar, 0));
/// carBatch = new BBMOD_DynamicBatch(modCar, 64);
///
/// /// @desc Draw event
/// carBatch.render_object(OCar, matCar);
/// ```
///
/// @see BBMOD_StaticBatch
function BBMOD_DynamicBatch(_model = undefined, _size = 32, _slotsPerInstance = 16) constructor
{
	/// @var {Struct.BBMOD_Model} A model that is being batched.
	/// @readonly
	Model = _model;

	/// @var {Struct.BBMOD_Model} The batched model.
	/// @readonly
	Batch = undefined;

	/// @var {Real} Number of model instances in the batch.
	/// @readonly
	Size = _size;

	/// @var {Real} Number of instances currently added to the dynamic batch.
	/// @readonly
	/// @see BBMOD_DynamicBatch.add_instance
	InstanceCount = 0;

	/// @var {Real} Number of slots that each instance takes in the data array.
	/// @readonly
	SlotsPerInstance = _slotsPerInstance;

	/// @var {Real} Total length of batch data array for a single draw call.
	/// @readonly
	BatchLength = Size * SlotsPerInstance;

	/// @var {Function} A function that writes instance data into the batch data
	/// array. It must take the instance, array and starting index as arguments!
	/// Defaults to {@link BBMOD_DynamicBatch.default_fn}.
	DataWriter = default_fn;

	/// @var {Function} A function that filters dynamic batch payload right
	/// before queued draw submission.
	///
	/// It must accept arguments
	/// `(_mesh, _matrix, _batchData, _ids, _instances,
	/// _visibleInstancesHint, _ditherEnableSnapshot, _ditherValueSnapshot)`
	/// and return a struct
	/// with fields:
	/// `BatchData`, `VisibleInstances`, `FrustumCulledInstances`,
	/// `DistanceCulledInstances`, `FadeData`, `SkipDraw`.
	/// Defaults to {@link BBMOD_DynamicBatch.default_filter_fn}.
	DataFilter = default_filter_fn;

	/// @var {Array<Array<Real>>}
	/// @private
	__data = [];

	/// @var {Array<Array<Id.Instance>}}
	/// @private
	__ids = [];

	/// @var {Struct}
	/// @private
	__batchFilterResult = {
		BatchData: undefined,
		VisibleInstances: 0,
		FrustumCulledInstances: 0,
		DistanceCulledInstances: 0,
		FadeData: undefined,
		SkipDraw: false,
	};

	/// @var {Array<Real>}
	/// @private
	__filterScratchFlat = [];

	/// @var {Array<Array<Real>>}
	/// @private
	__filterScratchNested = [];

	/// @var {Array<Array<Real>>}
	/// @private
	__filterScratchOutput = [];

	/// @var {Array<Real>}
	/// @private
	__filterScratchFadeFlat = [];

	/// @var {Array<Array<Real>>}
	/// @private
	__filterScratchFadeNested = [];

	/// @var {Array<Array<Real>>}
	/// @private
	__filterScratchFadeOutput = [];

	/// @var {Array}
	/// @private
	__filterScratchEmpty = [];

	/// @var {Id.DsMap} Mapping from instances to indices at which they are
	/// stored in the data array.
	/// @private
	__instanceToIndex = ds_map_create();

	/// @var {Id.DsMap} Mapping from data array indices to instances that they
	/// hold.
	/// @private
	__indexToInstance = ds_map_create();

	// @func from_model(_model)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_Model} _model
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	static from_model = function (_model)
	{
		Model = _model;
		build_batch();
		return self;
	};

	/// @func __resize_data()
	///
	/// @desc Resizes `__data` and `__ids` arrays to required size.
	///
	/// @private
	static __resize_data = function ()
	{
		var _requiredArrayCount = ceil(InstanceCount / Size);
		var _currentArrayCount = array_length(__data);

		if (_currentArrayCount > _requiredArrayCount)
		{
			array_resize(__data, _requiredArrayCount);
			array_resize(__ids, _requiredArrayCount);
		}
		else if (_currentArrayCount < _requiredArrayCount)
		{
			repeat(_requiredArrayCount - _currentArrayCount)
			{
				array_push(__data, array_create(BatchLength, 0.0));
				array_push(__ids, array_create(Size, 0.0));
			}
		}
	};

	/// @func add_instance(_instance)
	///
	/// @desc Adds an instance to the dynamic batch.
	///
	/// @param {Id.Instance, Struct} _instance The instance to be added.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	static add_instance = function (_instance)
	{
		var _indexIds = InstanceCount;
		var _indexData = _indexIds * SlotsPerInstance;
		__instanceToIndex[?  _instance] = _indexData;
		__indexToInstance[?  _indexData] = _instance;
		++InstanceCount;
		__resize_data();
		var _batchContextPrev = global.__bbmodDynamicBatchContext;
		global.__bbmodDynamicBatchContext = self;
		method(_instance, DataWriter)(__data[_indexData div BatchLength], _indexData mod BatchLength);
		global.__bbmodDynamicBatchContext = _batchContextPrev;
		__ids[_indexIds div Size][@ _indexIds mod Size] = real(_instance[$ "id"] ?? 0.0);
		return self;
	};

	/// @func update_instance(_instance)
	///
	/// @desc Updates batch data for given instance.
	///
	/// @param {Id.Instance, Struct} _instance The instance to update.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	///
	/// @see BBMOD_DynamicBatch.DataWriter
	static update_instance = function (_instance)
	{
		gml_pragma("forceinline");
		var _index = __instanceToIndex[?  _instance];
		var _batchContextPrev = global.__bbmodDynamicBatchContext;
		global.__bbmodDynamicBatchContext = self;
		method(_instance, DataWriter)(__data[_index div BatchLength], _index mod BatchLength);
		global.__bbmodDynamicBatchContext = _batchContextPrev;
		return self;
	};

	/// @func remove_instance(_instance)
	///
	/// @desc Removes an instance from the dynamic batch.
	///
	/// @param {Id.Instance, Struct} _instance The instance to remove.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	static remove_instance = function (_instance)
	{
		var _indexDataDeleted = __instanceToIndex[?  _instance];
		if (_indexDataDeleted != undefined)
		{
			var _indexIdDeleted = _indexDataDeleted / SlotsPerInstance;
			var _indexLast = InstanceCount - 1;
			var _indexDataLast = _indexLast * SlotsPerInstance;
			var _instanceLast = __indexToInstance[?  _indexDataLast];

			--InstanceCount;
			if (InstanceCount > 0
				&& _indexDataDeleted != _indexDataLast)
			{
				////////////////////////////////////////////////////////////////
				// Data

				// Find the exact array that stores the data
				var _dataLast = __data[_indexDataLast div BatchLength];
				// Get starting index within that array
				var i = _indexDataLast mod BatchLength;

				// Copy data of the last instance over the data of the removed instance
				array_copy(
					__data[_indexDataDeleted div BatchLength], _indexDataDeleted mod BatchLength,
					_dataLast, i, SlotsPerInstance);

				// Clear slots
				repeat(SlotsPerInstance)
				{
					_dataLast[i++] = 0.0;
				}

				////////////////////////////////////////////////////////////////
				// Ids

				// Find the exact array that stores the ID
				var _idsLast = __ids[_indexLast div Size];
				// Get starting index within that array
				i = _indexLast mod Size;

				// Copy ID of the last instance over the ID of the removed instance
				__ids[_indexIdDeleted div Size][@ _indexIdDeleted mod Size] = _idsLast[i];

				// Clear slots
				_idsLast[i] = 0.0;

				////////////////////////////////////////////////////////////////

				// Last instance is now stored instead of the deleted one
				__instanceToIndex[?  _instanceLast] = _indexDataDeleted;
				__indexToInstance[?  _indexDataDeleted] = _instanceLast;
			}
			else
			{
				var _dataLast = __data[_indexDataLast div BatchLength];
				var i = _indexDataLast mod BatchLength;

				repeat(SlotsPerInstance)
				{
					_dataLast[i++] = 0.0;
				}

				var _idsLast = __ids[_indexLast div Size];
				_idsLast[@ _indexLast mod Size] = 0.0;
			}

			ds_map_delete(__instanceToIndex, _instance);
			ds_map_delete(__indexToInstance, _indexDataLast);
			__resize_data();
		}
		return self;
	};

	/// @func submit([_materials[, _batchData[, _ids[, _visibleInstances]]]])
	///
	/// @desc Immediately submits the dynamic batch for rendering.
	///
	/// @param {Array<Struct.BBMOD_Material>} [_materials] An array of materials.
	/// @param {Array<Real>, Array<Array<Real>>} [_batchData] Data for dynamic
	/// batching.
	/// @param {Array<Id.Instance>, Array<Array<Id.Instance>>} [_ids] IDs of
	/// instances in the `_batchData` array(s). Defaults to IDs of instances
	/// added with {@link BBMOD_DynamicBatch.add_instance}. When `_batchData` is
	/// provided, `_ids` must be provided and must match `_batchData` layout.
	/// @param {Real} [_visibleInstances] Optional number of visible instances in
	/// `_batchData`. When provided, render-queue filtering can reuse this value
	/// for no-ID payloads instead of scanning `_batchData`.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	///
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render
	/// @see BBMOD_DynamicBatch.render_object
	/// @see BBMOD_Material
	/// @see BBMOD_ERenderPass
	static submit = function (_materials = undefined, _batchData = undefined, _ids = undefined, _visibleInstances =
		undefined)
	{
		gml_pragma("forceinline");
		_batchData ??= __data;

		if (_batchData == __data)
		{
			_ids = __ids;
		}

		var _batchIdsPrev = global.__bbmodInstanceIDBatch;
		var _batchVisiblePrev = variable_global_exists("__bbmodBatchVisibleInstances")
			? global.__bbmodBatchVisibleInstances
			: undefined;
		var _batchContextPrev = global.__bbmodDynamicBatchContext;
		global.__bbmodInstanceIDBatch = _ids;
		global.__bbmodBatchVisibleInstances = _visibleInstances;
		global.__bbmodDynamicBatchContext = self;

		if (array_length(_batchData) > 0)
		{
			if (_materials != undefined
				&& !is_array(_materials))
			{
				_materials = [_materials];
			}
			matrix_set(matrix_world, matrix_build_identity());
			Batch.submit(_materials, undefined, _batchData);
		}

		global.__bbmodBatchVisibleInstances = _batchVisiblePrev;
		global.__bbmodDynamicBatchContext = _batchContextPrev;
		global.__bbmodInstanceIDBatch = _batchIdsPrev;
		return self;
	};

	/// @func render([_materials[, _batchData[, _ids[, _visibleInstances]]]])
	///
	/// @desc Enqueues the dynamic batch for rendering.
	///
	/// @param {Array<Struct.BBMOD_Material>} [_materials] An array of materials.
	/// @param {Array<Real>, Array<Array<Real>>} [_batchData] Data for dynamic
	/// batching. Defaults to data of instances added with
	/// {@link BBMOD_DynamicBatch.add_instance}.
	/// @param {Array<Id.Instance>, Array<Array<Id.Instance>>} [_ids] IDs of
	/// instances in the `_batchData` array(s). Defaults to IDs of instances
	/// added with {@link BBMOD_DynamicBatch.add_instance}. Applicable only when
	/// `_batchData` is `undefined`!
	/// @param {Real} [_visibleInstances] Optional number of visible instances in
	/// `_batchData`. When provided, render-queue filtering can reuse this value
	/// for no-ID payloads instead of scanning `_batchData`.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	///
	/// @see BBMOD_DynamicBatch.submit
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render_object
	/// @see BBMOD_Material
	static render = function (_materials = undefined, _batchData = undefined, _ids = undefined, _visibleInstances =
		undefined)
	{
		gml_pragma("forceinline");
		var _batchIdsPrev = global.__bbmodInstanceIDBatch;
		var _batchVisiblePrev = variable_global_exists("__bbmodBatchVisibleInstances")
			? global.__bbmodBatchVisibleInstances
			: undefined;
		var _batchContextPrev = global.__bbmodDynamicBatchContext;

		if (_batchData == undefined)
		{
			_batchData = __data;
			global.__bbmodInstanceIDBatch = __ids;
		}
		else
		{
			global.__bbmodInstanceIDBatch = _ids;
		}
		global.__bbmodBatchVisibleInstances = _visibleInstances;

		global.__bbmodDynamicBatchContext = self;

		if (array_length(_batchData) > 0)
		{
			if (_materials != undefined
				&& !is_array(_materials))
			{
				_materials = [_materials];
			}
			matrix_set(matrix_world, matrix_build_identity());
			Batch.render(_materials, undefined, _batchData);
		}

		global.__bbmodDynamicBatchContext = _batchContextPrev;
		global.__bbmodBatchVisibleInstances = _batchVisiblePrev;
		global.__bbmodInstanceIDBatch = _batchIdsPrev;

		return self;
	};

	/// @func default_fn(_data, _index)
	///
	/// @desc The default data writer function. Uses instance's variables
	/// `x`, `y`, `z` for position, `image_xscale` for uniform scale and
	/// `image_angle` for rotation around the `z` axis.
	///
	/// @param {Array<Real>} _data An array to which the function will write
	/// instance data. The data layout is compatible with shader `BBMOD_ShDefaultBatched`
	/// and hence with material {@link BBMOD_MATERIAL_DEFAULT_BATCHED}.
	/// @param {Real} _index An index at which the first variable will be written.
	///
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render_object
	static default_fn = function (_data, _index)
	{
		var _batchContext = variable_global_exists("__bbmodDynamicBatchContext")
			? global.__bbmodDynamicBatchContext
			: undefined;

		if (_batchContext != undefined)
		{
			bbmod_assert(_batchContext.SlotsPerInstance >= 16);
		}

		// Position
		_data[@ _index] = x;
		_data[@ _index + 1] = y;
		_data[@ _index + 2] = z;
		// Uniform scale
		_data[@ _index + 3] = image_xscale;
		// Rotation
		new BBMOD_Quaternion()
			.FromAxisAngle(BBMOD_VEC3_UP, image_angle)
			.ToArray(_data, _index + 4);
		// ID
		_data[@ _index + 8] = ((id & $000000FF) >> 0) / 255;
		_data[@ _index + 9] = ((id & $0000FF00) >> 8) / 255;
		_data[@ _index + 10] = ((id & $00FF0000) >> 16) / 255;
		_data[@ _index + 11] = ((id & $FF000000) >> 24) / 255;

		// Reserved/padding slot.
		_data[@ _index + 12] = 0.0;
		// Reserved/padding slot.
		_data[@ _index + 13] = 0.0;

		// Local per-instance dither multiplier used by queue-time snapshots.
		var _localMul = 1.0;
		if (is_struct(self))
		{
			if (variable_struct_exists(self, BBMOD_DITHER_VALUE))
			{
				_localMul = variable_struct_get(self, BBMOD_DITHER_VALUE);
			}
		}
		else if (variable_instance_exists(id, BBMOD_DITHER_VALUE))
		{
			_localMul = variable_instance_get(id, BBMOD_DITHER_VALUE);
		}

		_localMul = clamp(_localMul, 0.0, 1.0);
		_data[@ _index + 14] = _localMul;

		var _globalFade = bbmod_dither_get_enabled() ? bbmod_dither_get_value() : 1.0;
		_data[@ _index + 15] = clamp(_globalFade * _localMul, 0.0, 1.0);
	};

	/// @func default_filter_fn(_mesh, _matrix, _batchData, _ids, _instances[, _visibleInstancesHint[, _ditherEnableSnapshot[, _ditherValueSnapshot]]])
	///
	/// @desc Filters dynamic batch payload for queued rendering by optional
	/// instance-ID list and optional frustum visibility, then writes snapshot
	/// dither values into slot 15.
	///
	/// The default implementation assumes the same per-instance payload layout
	/// as {@link BBMOD_DynamicBatch.default_fn}.
	///
	/// @param {Struct.BBMOD_Mesh} _mesh The mesh being rendered.
	/// @param {Array<Real>} _matrix The world matrix for the mesh.
	/// @param {Array<Real>, Array<Array<Real>>} _batchData Batch payload.
	/// @param {Array<Id.Instance>, Array<Array<Id.Instance>>} _ids IDs matching
	/// instances in `_batchData`.
	/// @param {Id.DsList<Id.Instance>} _instances Optional instance filter.
	/// @param {Real} [_visibleInstancesHint] Visible instance hint for no-ID
	/// payloads.
	/// @param {Bool} [_ditherEnableSnapshot] Per-command dither enabled
	/// snapshot.
	/// @param {Real} [_ditherValueSnapshot] Per-command dither value snapshot.
	///
	/// @return {Struct} Filtering result with fields `BatchData`,
	/// `VisibleInstances`, `FrustumCulledInstances`,
	/// `DistanceCulledInstances`, `FadeData`, `SkipDraw`.
	static default_filter_fn = function (
		_mesh,
		_matrix,
		_batchData,
		_ids,
		_instances,
		_visibleInstancesHint = undefined,
		_ditherEnableSnapshot = bbmod_dither_get_enabled(),
		_ditherValueSnapshot = bbmod_dither_get_value())
	{
		gml_pragma("forceinline");

		var _result = __batchFilterResult;
		_result.BatchData = _batchData;
		_result.VisibleInstances = 0;
		_result.FrustumCulledInstances = 0;
		_result.DistanceCulledInstances = 0;
		_result.FadeData = undefined;
		_result.SkipDraw = false;

		var _ditherEnabled = _ditherEnableSnapshot;
		var _ditherValue = clamp(_ditherValueSnapshot, 0.0, 1.0);
		var _ditherCullAll = (_ditherEnabled && _ditherValue <= 0.0);

		if (!is_array(_ids))
		{
			// Some producers (for example particle emitters) submit
			// dynamic-batch payload without per-instance IDs; skip ID/frustum
			// filtering in that case.
			var _visibleFallback = 0;
			if (is_real(_visibleInstancesHint))
			{
				_visibleFallback = max(real(_visibleInstancesHint), 0.0);
			}
			else if (is_array(_batchData))
			{
				var _slotsPerInstanceFallback = max(SlotsPerInstance, 1);
				if (array_length(_batchData) > 0)
				{
					if (is_array(_batchData[0]))
					{
						var _batchIndexFallback = 0;
						repeat(array_length(_batchData))
						{
							_visibleFallback += ceil(array_length(_batchData[_batchIndexFallback++])
								/ _slotsPerInstanceFallback);
						}
					}
					else
					{
						_visibleFallback = ceil(array_length(_batchData) / _slotsPerInstanceFallback);
					}
				}
			}

			if (_ditherCullAll)
			{
				_result.VisibleInstances = 0;
				_result.DistanceCulledInstances = _visibleFallback;
				_result.SkipDraw = true;
				return _result;
			}

			_result.VisibleInstances = _visibleFallback;
			_result.SkipDraw = (_visibleFallback <= 0);
			return _result;
		}

		var _filterByInstances = (_instances != undefined);
		var _filterByFrustum = (global.__bbmodFrustumCulling && _mesh.BoundingSphereCenter != undefined);
		var _idsIsNested = is_array(_ids[0]);

		if (!_filterByInstances && !_filterByFrustum && !_ditherEnabled)
		{
			var _visibleNoFilter = 0;
			if (_idsIsNested)
			{
				var _idArrayIndex = 0;
				repeat(array_length(_ids))
				{
					var _idsCurrent = _ids[_idArrayIndex++];
					var _idIndex = 0;
					repeat(array_length(_idsCurrent))
					{
						if (_idsCurrent[_idIndex++] != 0)
						{
							++_visibleNoFilter;
						}
					}
				}
			}
			else
			{
				var _idIndex = 0;
				repeat(array_length(_ids))
				{
					if (_ids[_idIndex++] != 0)
					{
						++_visibleNoFilter;
					}
				}
			}

			_result.VisibleInstances = _visibleNoFilter;
			_result.SkipDraw = (_visibleNoFilter <= 0);
			return _result;
		}

		var _slotsPerInstance = SlotsPerInstance;
		if (_slotsPerInstance <= 0)
		{
			_result.SkipDraw = true;
			return _result;
		}

		bbmod_assert(_slotsPerInstance >= 16);

		var _centerX = 0.0;
		var _centerY = 0.0;
		var _centerZ = 0.0;
		var _radius = 0.0;
		var _m00 = 0.0;
		var _m01 = 0.0;
		var _m02 = 0.0;
		var _m10 = 0.0;
		var _m11 = 0.0;
		var _m12 = 0.0;
		var _m20 = 0.0;
		var _m21 = 0.0;
		var _m22 = 0.0;
		var _m30 = 0.0;
		var _m31 = 0.0;
		var _m32 = 0.0;
		var _matrixScale = 1.0;
		var _centerMatrixX = 0.0;
		var _centerMatrixY = 0.0;
		var _centerMatrixZ = 0.0;
		if (_filterByFrustum)
		{
			var _center = _mesh.BoundingSphereCenter;
			_centerX = _center.X;
			_centerY = _center.Y;
			_centerZ = _center.Z;
			_radius = _mesh.BoundingSphereRadius;

			_m00 = _matrix[0];
			_m01 = _matrix[1];
			_m02 = _matrix[2];
			_m10 = _matrix[4];
			_m11 = _matrix[5];
			_m12 = _matrix[6];
			_m20 = _matrix[8];
			_m21 = _matrix[9];
			_m22 = _matrix[10];
			_m30 = _matrix[12];
			_m31 = _matrix[13];
			_m32 = _matrix[14];

			var _scaleX = sqrt(_m00 * _m00 + _m01 * _m01 + _m02 * _m02);
			var _scaleY = sqrt(_m10 * _m10 + _m11 * _m11 + _m12 * _m12);
			var _scaleZ = sqrt(_m20 * _m20 + _m21 * _m21 + _m22 * _m22);
			_matrixScale = max(_scaleX, _scaleY, _scaleZ);

			// Keep culling math in sync with Transform.xsh batched path:
			// vertex = M * vertex; vertex = pos + (Q(vertex) * scale)
			_centerMatrixX = _m30 + _centerX * _m00 + _centerY * _m10 + _centerZ * _m20;
			_centerMatrixY = _m31 + _centerX * _m01 + _centerY * _m11 + _centerZ * _m21;
			_centerMatrixZ = _m32 + _centerX * _m02 + _centerY * _m12 + _centerZ * _m22;
		}

		var _visibleInstances = 0;
		var _frustumCulled = 0;
		var _distanceCulled = 0;
		var _filteredBatchData = __filterScratchEmpty;
		var _filteredFadeData = undefined;

		if (_idsIsNested)
		{
			var _scratchNested = __filterScratchNested;
			var _scratchOutput = __filterScratchOutput;
			var _batchCount = min(array_length(_ids), array_length(_batchData));
			var _filteredBatchCount = 0;

			var _batchIndex = 0;
			repeat(_batchCount)
			{
				var _idsCurrent = _ids[_batchIndex];
				var _idsCount = array_length(_idsCurrent);

				var _sourceDataCurrent = _batchData[_batchIndex];
				var _dataLength = array_length(_sourceDataCurrent);
				var _dataCurrent = undefined;
				if (_batchIndex < array_length(_scratchNested))
				{
					_dataCurrent = _scratchNested[_batchIndex];
				}

				if (_dataCurrent == undefined || array_length(_dataCurrent) != _dataLength)
				{
					_dataCurrent = array_create(_dataLength, 0.0);
					_scratchNested[@ _batchIndex] = _dataCurrent;
				}

				array_copy(_dataCurrent, 0, _sourceDataCurrent, 0, _dataLength);

				var _hasData = false;

				var _instanceIndex = 0;
				repeat(_idsCount)
				{
					var _keep = false;
					var _culledByFrustum = false;
					var _culledByDistance = false;
					var _idCurrent = _idsCurrent[_instanceIndex];
					var _index = _instanceIndex * _slotsPerInstance;

					if (_idCurrent != 0)
					{
						_keep = true;
					}

					if (_keep && _filterByInstances && ds_list_find_index(_instances, _idCurrent) == -1)
					{
						_keep = false;
					}

					if (_keep && _filterByFrustum)
					{
						var _worldX = 0.0;
						var _worldY = 0.0;
						var _worldZ = 0.0;
						var _worldRadius = 0.0;

						var _scale = _dataCurrent[@(_index + 3)];
						var _scaleAbs = abs(_scale);
						var _centerRotX = _centerMatrixX;
						var _centerRotY = _centerMatrixY;
						var _centerRotZ = _centerMatrixZ;

						if (_slotsPerInstance >= 8)
						{
							var _qx = _dataCurrent[@(_index + 4)];
							var _qy = _dataCurrent[@(_index + 5)];
							var _qz = _dataCurrent[@(_index + 6)];
							var _qw = _dataCurrent[@(_index + 7)];
							var _lenSqr = _qx * _qx + _qy * _qy + _qz * _qz + _qw * _qw;

							if (_lenSqr > 0.0)
							{
								if (abs(_lenSqr - 1.0) > math_get_epsilon())
								{
									var _invLen = 1.0 / sqrt(_lenSqr);
									_qx *= _invLen;
									_qy *= _invLen;
									_qz *= _invLen;
									_qw *= _invLen;
								}

								var _tx = 2.0 * (_qy * _centerRotZ - _qz * _centerRotY);
								var _ty = 2.0 * (_qz * _centerRotX - _qx * _centerRotZ);
								var _tz = 2.0 * (_qx * _centerRotY - _qy * _centerRotX);

								_centerRotX = _centerRotX + _qw * _tx + (_qy * _tz - _qz * _ty);
								_centerRotY = _centerRotY + _qw * _ty + (_qz * _tx - _qx * _tz);
								_centerRotZ = _centerRotZ + _qw * _tz + (_qx * _ty - _qy * _tx);
							}
						}

						_worldX = _dataCurrent[@ _index] + _centerRotX * _scale;
						_worldY = _dataCurrent[@(_index + 1)] + _centerRotY * _scale;
						_worldZ = _dataCurrent[@(_index + 2)] + _centerRotZ * _scale;
						_worldRadius = _radius * _scaleAbs * _matrixScale;

						if (!sphere_is_visible(_worldX, _worldY, _worldZ, _worldRadius))
						{
							_keep = false;
							_culledByFrustum = true;
						}
					}

					if (_keep && _ditherCullAll)
					{
						_keep = false;
						_culledByDistance = true;
					}

					if (!_keep)
					{
						var _slotIndex = _instanceIndex * _slotsPerInstance;
						repeat(_slotsPerInstance)
						{
							_dataCurrent[@ _slotIndex++] = 0.0;
						}
					}
					else
					{
						if (_ditherEnabled)
						{
							_dataCurrent[@(_index + 15)] = clamp(_ditherValue * _dataCurrent[@(_index
								+ 14)], 0.0, 1.0);
						}
						else
						{
							_dataCurrent[@(_index + 15)] = 1.0;
						}

						_hasData = true;
						++_visibleInstances;
					}

					if (_culledByFrustum)
					{
						++_frustumCulled;
					}

					if (_culledByDistance)
					{
						++_distanceCulled;
					}

					++_instanceIndex;
				}

				if (_hasData)
				{
					_scratchOutput[@ _filteredBatchCount] = _dataCurrent;
					++_filteredBatchCount;
				}

				++_batchIndex;
			}

			__filterScratchNested = _scratchNested;

			if (_filteredBatchCount > 0)
			{
				var _scratchOutputLength = array_length(_scratchOutput);
				if (_scratchOutputLength != _filteredBatchCount)
				{
					array_resize(_scratchOutput, _filteredBatchCount);
				}
				_filteredBatchData = _scratchOutput;
			}

			__filterScratchOutput = _scratchOutput;
		}
		else
		{
			var _idsCurrent = _ids;
			var _idsCount = array_length(_idsCurrent);
			var _sourceDataCurrent = _batchData;
			var _dataLength = array_length(_sourceDataCurrent);
			var _dataCurrent = __filterScratchFlat;

			if (array_length(_dataCurrent) != _dataLength)
			{
				_dataCurrent = array_create(_dataLength, 0.0);
				__filterScratchFlat = _dataCurrent;
			}

			array_copy(_dataCurrent, 0, _sourceDataCurrent, 0, _dataLength);

			var _hasData = false;

			var _instanceIndex = 0;
			repeat(_idsCount)
			{
				var _keep = false;
				var _culledByFrustum = false;
				var _culledByDistance = false;
				var _idCurrent = _idsCurrent[_instanceIndex];
				var _index = _instanceIndex * _slotsPerInstance;

				if (_idCurrent != 0)
				{
					_keep = true;
				}

				if (_keep && _filterByInstances && ds_list_find_index(_instances, _idCurrent) == -1)
				{
					_keep = false;
				}

				if (_keep && _filterByFrustum)
				{
					var _worldX = 0.0;
					var _worldY = 0.0;
					var _worldZ = 0.0;
					var _worldRadius = 0.0;

					var _scale = _dataCurrent[@(_index + 3)];
					var _scaleAbs = abs(_scale);
					var _centerRotX = _centerMatrixX;
					var _centerRotY = _centerMatrixY;
					var _centerRotZ = _centerMatrixZ;

					if (_slotsPerInstance >= 8)
					{
						var _qx = _dataCurrent[@(_index + 4)];
						var _qy = _dataCurrent[@(_index + 5)];
						var _qz = _dataCurrent[@(_index + 6)];
						var _qw = _dataCurrent[@(_index + 7)];
						var _lenSqr = _qx * _qx + _qy * _qy + _qz * _qz + _qw * _qw;

						if (_lenSqr > 0.0)
						{
							if (abs(_lenSqr - 1.0) > math_get_epsilon())
							{
								var _invLen = 1.0 / sqrt(_lenSqr);
								_qx *= _invLen;
								_qy *= _invLen;
								_qz *= _invLen;
								_qw *= _invLen;
							}

							var _tx = 2.0 * (_qy * _centerRotZ - _qz * _centerRotY);
							var _ty = 2.0 * (_qz * _centerRotX - _qx * _centerRotZ);
							var _tz = 2.0 * (_qx * _centerRotY - _qy * _centerRotX);

							_centerRotX = _centerRotX + _qw * _tx + (_qy * _tz - _qz * _ty);
							_centerRotY = _centerRotY + _qw * _ty + (_qz * _tx - _qx * _tz);
							_centerRotZ = _centerRotZ + _qw * _tz + (_qx * _ty - _qy * _tx);
						}
					}

					_worldX = _dataCurrent[@ _index] + _centerRotX * _scale;
					_worldY = _dataCurrent[@(_index + 1)] + _centerRotY * _scale;
					_worldZ = _dataCurrent[@(_index + 2)] + _centerRotZ * _scale;
					_worldRadius = _radius * _scaleAbs * _matrixScale;

					if (!sphere_is_visible(_worldX, _worldY, _worldZ, _worldRadius))
					{
						_keep = false;
						_culledByFrustum = true;
					}
				}

				if (_keep && _ditherCullAll)
				{
					_keep = false;
					_culledByDistance = true;
				}

				if (!_keep)
				{
					var _slotIndex = _instanceIndex * _slotsPerInstance;
					repeat(_slotsPerInstance)
					{
						_dataCurrent[@ _slotIndex++] = 0.0;
					}
				}
				else
				{
					if (_ditherEnabled)
					{
						_dataCurrent[@(_index + 15)] = clamp(_ditherValue * _dataCurrent[@(_index + 14)], 0.0,
							1.0);
					}
					else
					{
						_dataCurrent[@(_index + 15)] = 1.0;
					}

					_hasData = true;
					++_visibleInstances;
				}

				if (_culledByFrustum)
				{
					++_frustumCulled;
				}

				if (_culledByDistance)
				{
					++_distanceCulled;
				}

				++_instanceIndex;
			}

			if (_hasData)
			{
				_filteredBatchData = _dataCurrent;
			}
		}

		_result.BatchData = _filteredBatchData;
		_result.FadeData = _filteredFadeData;
		_result.VisibleInstances = _visibleInstances;
		_result.FrustumCulledInstances = _frustumCulled;
		_result.DistanceCulledInstances = _distanceCulled;
		_result.SkipDraw = (_visibleInstances <= 0);

		return _result;
	};

	static __draw_object = function (_method, _object, _materials, _fn = undefined)
	{
		if (!instance_exists(_object))
		{
			return;
		}

		_fn ??= DataWriter;

		var _slotsPerInstance = SlotsPerInstance;
		var _size = Size;
		var _dataSize = _size * _slotsPerInstance;
		var _data = array_create(_dataSize, 0.0);
		var _ids = array_create(_size, 0.0);
		var _indexData = 0;
		var _indexId = 0;
		var _batchData = [_data];
		var _batchIds = [_ids];

		with(_object)
		{
			method(self, _fn)(_data, _indexData);
			_indexData += _slotsPerInstance;

			_ids[@ _indexId++] = real(self[$ "id"] ?? 0.0);

			if (_indexData >= _dataSize)
			{
				_data = array_create(_dataSize, 0.0);
				_indexData = 0;
				array_push(_batchData, _data);

				_ids = array_create(_size, 0.0);
				_indexId = 0;
				array_push(_batchIds, _ids);
			}
		}

		_method(_materials, _batchData, _batchIds);
	};

	/// @func submit_object(_object[, _materials[, _fn]])
	///
	/// @desc Immediately submits all instances of an object for rendering in
	/// batches of {@link BBMOD_DynamicBatch.size}.
	///
	/// @param {Real} _object An object to submit.
	/// @param {Array<Struct.BBMOD_Materials>} [_materials] An array of materials
	/// to use.
	/// @param {Function} [_fn] A function that writes instance data to an array
	/// which is then passed to the material's shader. Defaults to
	/// {@link BBMOD_DynamicBatch.default_fn} if `undefined`.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	///
	/// @example
	/// ```gml
	/// carBatch.submit_object(OCar, [matCar], function (_data, _index) {
	///     // Position
	///     _data[@ _index] = x;
	///     _data[@ _index + 1] = y;
	///     _data[@ _index + 2] = z;
	///     // Uniform scale
	///     _data[@ _index + 3] = image_xscale;
	///     // Rotation
	///     new BBMOD_Quaternion()
	///         .FromAxisAngle(BBMOD_VEC3_UP, image_angle)
	///         .ToArray(_data, _index + 4);
	///     // ID
	///     _data[@ _index + 8] = ((id & $000000FF) >> 0) / 255;
	///     _data[@ _index + 9] = ((id & $0000FF00) >> 8) / 255;
	///     _data[@ _index + 10] = ((id & $00FF0000) >> 16) / 255;
	///     _data[@ _index + 11] = ((id & $FF000000) >> 24) / 255;
	/// });
	/// ```
	/// The function defined in this example is actually the implementation of
	/// {@link BBMOD_DynamicBatch.DataWriter}. You can use this to create you own
	/// variation of it.
	///
	/// @see BBMOD_DynamicBatch.submit
	/// @see BBMOD_DynamicBatch.render
	/// @see BBMOD_DynamicBatch.render_object
	/// @see BBMOD_DynamicBatch.DataWriter
	static submit_object = function (_object, _materials = undefined, _fn = undefined)
	{
		gml_pragma("forceinline");
		__draw_object(method(self, submit), _object, _materials, _fn);
		return self;
	};

	/// @func render_object(_object[, _materials[, _fn]])
	///
	/// @desc Enqueues all instances of an object for rendering in batches of
	/// {@link BBMOD_DynamicBatch.size}.
	///
	/// @param {Asset.GMObject} _object An object to render.
	/// @param {Array<Struct.BBMOD_Material>} [_materials] An array of materials
	/// to use.
	/// @param {Function} [_fn] A function that writes instance data to an
	/// array which is then passed to the material's shader. Defaults to
	/// {@link BBMOD_DynamicBatch.DataWriter} if `undefined`.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	///
	/// @example
	/// ```gml
	/// carBatch.render_object(OCar, [matCar], function (_data, _index) {
	///     // Position
	///     _data[@ _index] = x;
	///     _data[@ _index + 1] = y;
	///     _data[@ _index + 2] = z;
	///     // Uniform scale
	///     _data[@ _index + 3] = image_xscale;
	///     // Rotation
	///     new BBMOD_Quaternion()
	///         .FromAxisAngle(BBMOD_VEC3_UP, image_angle)
	///         .ToArray(_data, _index + 4);
	///     // ID
	///     _data[@ _index + 8] = ((id & $000000FF) >> 0) / 255;
	///     _data[@ _index + 9] = ((id & $0000FF00) >> 8) / 255;
	///     _data[@ _index + 10] = ((id & $00FF0000) >> 16) / 255;
	///     _data[@ _index + 11] = ((id & $FF000000) >> 24) / 255;
	/// });
	/// ```
	/// The function defined in this example is actually the implementation of
	/// {@link BBMOD_DynamicBatch.default_fn}. You can use this to create your
	/// own variation of it.
	///
	/// @see BBMOD_DynamicBatch.submit
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render
	/// @see BBMOD_DynamicBatch.DataWriter
	static render_object = function (_object, _materials = undefined, _fn = undefined)
	{
		gml_pragma("forceinline");
		__draw_object(method(self, render), _object, _materials, _fn);
		return self;
	};

	/// @func freeze()
	///
	/// @desc Freezes the dynamic batch. This makes it render faster.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	static freeze = function ()
	{
		gml_pragma("forceinline");
		Batch.freeze();
		return self;
	};

	static build_batch = function ()
	{
		if (Batch != undefined)
		{
			return;
		}

		Batch = Model.clone();
		var _vertexFormatOld = Batch.VertexFormat;
		var _vertexFormatNew;

		if (_vertexFormatOld != undefined)
		{
			_vertexFormatNew = new BBMOD_VertexFormat(
			{
				Vertices: _vertexFormatOld.Vertices,
				Normals: _vertexFormatOld.Normals,
				TextureCoords: _vertexFormatOld.TextureCoords,
				TextureCoords2: _vertexFormatOld.TextureCoords2,
				Colors: _vertexFormatOld.Colors,
				TangentW: _vertexFormatOld.TangentW,
				Bones: _vertexFormatOld.Bones,
				Ids: true,
			});
			Batch.VertexFormat = _vertexFormatNew;
		}

		for (var i = array_length(Batch.Meshes) - 1; i >= 0; --i)
		{
			var _mesh = Batch.Meshes[i];
			var _meshVertexFormatOld = _mesh.VertexFormat ?? _vertexFormatOld;
			var _byteSizeOld = _meshVertexFormatOld.get_byte_size();

			var _meshVertexFormatNew;
			if (_mesh.VertexFormat)
			{
				_meshVertexFormatNew = new BBMOD_VertexFormat(
				{
					Vertices: _meshVertexFormatOld.Vertices,
					Normals: _meshVertexFormatOld.Normals,
					TextureCoords: _meshVertexFormatOld.TextureCoords,
					TextureCoords2: _meshVertexFormatOld.TextureCoords2,
					Colors: _meshVertexFormatOld.Colors,
					TangentW: _meshVertexFormatOld.TangentW,
					Bones: _meshVertexFormatOld.Bones,
					Ids: true,
				});
			}
			else
			{
				_meshVertexFormatNew = _vertexFormatNew;
			}

			var _byteSizeNew = _meshVertexFormatNew.get_byte_size();
			var _vertexBufferOld = _mesh.VertexBuffer;
			var _bufferOld = buffer_create_from_vertex_buffer(_vertexBufferOld, buffer_fixed, 1);
			var _vertexCount = buffer_get_size(_bufferOld) / _byteSizeOld;
			var _bufferNew = buffer_create(Size * _vertexCount * _byteSizeNew, buffer_fixed, 1);
			var _offsetNew = 0;
			var _sizeOfF32 = buffer_sizeof(buffer_f32);

			var _id = 0;
			repeat(Size)
			{
				var _offsetOld = 0;
				repeat(_vertexCount)
					{
						buffer_copy(_bufferOld, _offsetOld, _byteSizeOld, _bufferNew, _offsetNew);
						_offsetOld += _byteSizeOld;
						_offsetNew += _byteSizeOld;
						buffer_poke(_bufferNew, _offsetNew, buffer_f32, _id);
						_offsetNew += _sizeOfF32;
					}
					++_id;
			}

			_mesh.VertexBuffer = vertex_create_buffer_from_buffer_ext(_bufferNew, _meshVertexFormatNew.Raw, 0, Size
				* _vertexCount);
			_mesh.VertexFormat = _meshVertexFormatNew;
			buffer_delete(_bufferNew);

			vertex_delete_buffer(_vertexBufferOld);
			buffer_delete(_bufferOld);
		}
	};

	static destroy = function ()
	{
		if (Batch != undefined)
		{
			Batch = Batch.destroy();
		}
		__data = undefined;
		ds_map_destroy(__instanceToIndex);
		ds_map_destroy(__indexToInstance);
		return undefined;
	};

	if (Model != undefined)
	{
		build_batch();
	}
}
