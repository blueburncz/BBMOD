/// @module Core

/// @func BBMOD_MeshRenderQueue([_name[, _priority]])
///
/// @implements {BBMOD_IRenderQueue}
///
/// @desc A render queue specialized for rendering of multiple instances of a
/// model, where all instances are using the same material.
///
/// @param {String} [_name] The name of the render queue. Defaults to
/// "RenderQueue" + number of created render queues - 1 (e.g. "RenderQueue0",
/// "RenderQueue1" etc.) if `undefined`.
/// @param {Real} [_priority] The priority of the render queue. Defaults to 0.
function BBMOD_MeshRenderQueue(_name=undefined, _priority=0) constructor
{
	static IdNext = 0;

	/// @var {String} The name of the render queue. This can be useful for
	/// debugging purposes.
	Name = _name ?? ("MeshRenderQueue" + string(IdNext++));

	/// @var {Real} The priority of the render queue. Render queues with lower
	/// priority come first in the array returned by {@link bbmod_render_queues_get}.
	/// @readonly
	Priority = _priority;

	/// @var {Id.DsGrid}
	/// @see BBMOD_ERenderCommand
	/// @private
	__renderCommands = ds_grid_create(4, 1024);

	/// @var {Real}
	/// @private
	__index = 0;

	/// @var {Real} Render passes that the queue has commands for.
	/// @private
	__renderPasses = 0;

	/// @var {Struct.BBMOD_Mesh}
	/// @private
	__mesh = undefined;

	/// @var {Struct.BBMOD_Material}
	/// @private
	__material = undefined;

	/// @var {Real}
	/// @see BBMOD_ERenderCommand
	/// @private
	__commandType = undefined;

	/// @func set_priority(_p)
	///
	/// @desc Changes the priority of the render queue. Render queues with lower
	/// priority come first in the array returned by {@link bbmod_render_queues_get}.
	///
	/// @param {Real} _p The new priority of the render queue.
	///
	/// @return {Struct.BBMOD_MeshRenderQueue} Returns `self`.
	static set_priority = function (_p)
	{
		gml_pragma("forceinline");
		Priority = _p;
		__bbmod_reindex_render_queues();
		return self;
	};

	/// @func DrawMesh(_mesh, _material, _matrix)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMesh} command into the
	/// queue.
	///
	/// @param {Struct.BBMOD_Mesh} _mesh The mesh to draw.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array<Real>} _matrix The world matrix.
	///
	/// @return {Struct.BBMOD_MeshRenderQueue} Returns `self`.
	static DrawMesh = function (_mesh, _material, _matrix)
	{
		gml_pragma("forceinline");

		// FIXME: Add proper error messages

		if (__mesh != undefined && _mesh != __mesh)
		{
			show_error("", true);
		}

		if (__material != undefined && _material != __material)
		{
			show_error("", true);
		}

		if (__commandType != undefined && __commandType != BBMOD_ERenderCommand.DrawMesh)
		{
			show_error("", true);
		}

		__mesh = _mesh;
		__material = _material;
		__commandType = BBMOD_ERenderCommand.DrawMesh;
		__renderPasses |= _material.RenderPass;

		var _index = __index;
		__renderCommands[# 0, _index] = global.__bbmodInstanceID;
		__renderCommands[# 1, _index] = global.__bbmodMaterialProps;
		__renderCommands[# 2, _index] = _matrix;
		++__index;

		return self;
	};

	/// @func DrawMeshAnimated(_mesh_material, _matrix, _boneTransform)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMeshAnimated} command into
	/// the queue.
	///
	/// @param {Struct.BBMOD_Mesh} _mesh The mesh to draw.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array<Real>} _matrix The world matrix.
	/// @param {Array<Real>} _boneTransform An array with bone transformation
	/// data.
	///
	/// @return {Struct.BBMOD_MeshRenderQueue} Returns `self`.
	static DrawMeshAnimated = function (_mesh, _material, _matrix, _boneTransform)
	{
		gml_pragma("forceinline");

		// FIXME: Add proper error messages

		if (__mesh != undefined && _mesh != __mesh)
		{
			show_error("", true);
		}

		if (__material != undefined && _material != __material)
		{
			show_error("", true);
		}

		if (__commandType != undefined && __commandType != BBMOD_ERenderCommand.DrawMeshAnimated)
		{
			show_error("", true);
		}

		__mesh = _mesh;
		__material = _material;
		__commandType = BBMOD_ERenderCommand.DrawMeshAnimated;
		__renderPasses |= _material.RenderPass;

		var _index = __index;
		__renderCommands[# 0, _index] = global.__bbmodInstanceID;
		__renderCommands[# 1, _index] = global.__bbmodMaterialProps;
		__renderCommands[# 2, _index] = _matrix;
		__renderCommands[# 3, _index] = _boneTransform;
		++__index;

		return self;
	};

	/// @func DrawMeshBatched(_mesh, _material, _matrix, _batchData)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMeshBatched} command into
	/// the queue.
	///
	/// @param {Struct.BBMOD_Mesh} _mesh The mesh to draw.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array<Real>} _matrix The world matrix.
	/// @param {Array<Real>, Array<Array<Real>>} _batchData Either a single array
	/// of batch data or an array of arrays of batch data.
	///
	/// @return {Struct.BBMOD_MeshRenderQueue} Returns `self`.
	static DrawMeshBatched = function (_mesh, _material, _matrix, _batchData)
	{
		gml_pragma("forceinline");

		// FIXME: Add proper error messages

		if (__mesh != undefined && _mesh != __mesh)
		{
			show_error("", true);
		}

		if (__material != undefined && _material != __material)
		{
			show_error("", true);
		}

		if (__commandType != undefined && __commandType != BBMOD_ERenderCommand.DrawMeshBatched)
		{
			show_error("", true);
		}

		__mesh = _mesh;
		__material = _material;
		__commandType = BBMOD_ERenderCommand.DrawMeshBatched;
		__renderPasses |= _material.RenderPass;

		var _index = __index;
		__renderCommands[# 0, _index] = global.__bbmodInstanceID;
		__renderCommands[# 1, _index] = global.__bbmodMaterialProps;
		__renderCommands[# 2, _index] = _matrix;
		__renderCommands[# 3, _index] = _batchData;
		++__index;

		return self;
	};

	/// @func is_empty()
	///
	/// @desc Checks whether the render queue is empty.
	///
	/// @return {Bool} Returns `true` if there are no commands in the render
	/// queue.
	static is_empty = function ()
	{
		gml_pragma("forceinline");
		return (__index == 0);
	};

	/// @func has_commands(_renderPass)
	///
	/// @desc Checks whether the render queue has commands for given render pass.
	///
	/// @param {Real} _renderPass The render pass.
	///
	/// @return {Bool} Returns `true` if the render queue has commands for given
	/// render pass.
	///
	/// @see BBMOD_ERenderPass
	static has_commands = function (_renderPass)
	{
		gml_pragma("forceinline");
		return (__renderPasses & (1 << _renderPass)) ? true : false;
	};

	/// @func submit([_instances])
	///
	/// @desc Submits render commands.
	///
	/// @param {Id.DsList<Id.Instance>} [_instances] If specified then only
	/// meshes with an instance ID from the list are submitted. Defaults to
	/// `undefined`.
	///
	/// @return {Struct.BBMOD_MeshRenderQueue} Returns `self`.
	///
	/// @see BBMOD_MeshRenderQueue.has_commands
	/// @see BBMOD_MeshRenderQueue.clear
	static submit = function (_instances=undefined)
	{
		if (!has_commands(global.__bbmodRenderPass))
		{
			return self;
		}

		var _commandIndex = 0;
		var _renderCommands = __renderCommands;
		var _mesh = __mesh;
		var _material = __material;
		var _commandType = __commandType;

		var _materialPropsOld = global.__bbmodMaterialProps;
		global.__bbmodMaterialProps = undefined;

		if (!_material.apply(_mesh.VertexFormat))
		{
			global.__bbmodMaterialProps = _materialPropsOld;
			return self;
		}

		BBMOD_SHADER_CURRENT.set_material_index(_mesh.MaterialIndex);

		switch (_commandType)
		{
		case BBMOD_ERenderCommand.DrawMesh:
			repeat (_index)
			{
				var _id = _renderCommands[# 0, _commandIndex];
				var _materialProps = _renderCommands[# 1, _commandIndex];
				var _matrix = _renderCommands[# 2, _commandIndex];
				++_commandIndex;

				if (_instances != undefined && ds_list_find_index(_instances, _id) == -1)
				{
					continue;
				}

				if (_materialProps != undefined)
				{
					_materialProps.apply();
				}

				BBMOD_SHADER_CURRENT.set_instance_id(_id);

				matrix_set(matrix_world, _matrix);
				vertex_submit(_mesh.VertexBuffer, _mesh.PrimitiveType, _material.BaseOpacity);
			}
			break;

		case BBMOD_ERenderCommand.DrawMeshAnimated:
			repeat (__index)
			{
				var _id = _renderCommands[# 0, _commandIndex];
				var _materialProps = _renderCommands[# 1, _commandIndex];
				var _matrix = _renderCommands[# 2, _commandIndex];
				var _boneData = _renderCommands[# 3, _commandIndex];
				++_commandIndex;

				if (_instances != undefined && ds_list_find_index(_instances, _id) == -1)
				{
					continue;
				}

				if (_materialProps != undefined)
				{
					_materialProps.apply();
				}

				with (BBMOD_SHADER_CURRENT)
				{
					set_instance_id(_id);
					set_bones(_boneData);
				}

				matrix_set(matrix_world, _matrix);
				vertex_submit(_mesh.VertexBuffer, _mesh.PrimitiveType, _material.BaseOpacity);
			}
			break;

		case BBMOD_ERenderCommand.DrawMeshBatched:
			repeat (__index)
			{
				var _id = _renderCommands[# 0, _commandIndex];
				var _materialProps = _renderCommands[# 1, _commandIndex];
				var _matrix = _renderCommands[# 2, _commandIndex];
				var _batchData = _renderCommands[# 3, _commandIndex];
				++_commandIndex;

				////////////////////////////////////////////////////////////
				// Filter batch data by instance ID

				if (_instances != undefined)
				{
					if (is_array(_id))
					{
						var _hasInstances = false;

						if (is_array(_id[0]))
						{
							////////////////////////////////////////////////////
							// _id is an array of arrays of IDs

							_batchData = bbmod_array_clone(_batchData);

							var j = 0;
							repeat (array_length(_id))
							{
								var _idsCurrent = _id[j];
								var _idsCount = array_length(_idsCurrent);
								var _dataCurrent = bbmod_array_clone(_batchData[j]);
								_batchData[@ j] = _dataCurrent;
								var _slotsPerInstance = array_length(_dataCurrent) / _idsCount;
								var _hasData = false;

								var k = 0;
								repeat (_idsCount)
								{
									if (ds_list_find_index(_instances, _idsCurrent[k]) == -1)
									{
										var l = 0;
										repeat (_slotsPerInstance)
										{
											_dataCurrent[@ (k * _slotsPerInstance) + l] = 0.0;
											++l;
										}
									}
									else
									{
										_hasData = true;
										_hasInstances = true;
									}
									++k;
								}

								if (!_hasData)
								{
									// Filtered out all instances in _dataCurrent,
									// we can remove it from _batchData
									array_delete(_batchData, j, 1);
								}
								else
								{
									++j;
								}
							}
						}
						else
						{
							////////////////////////////////////////////////////
							// _id is an array of IDs

							_batchData = bbmod_array_clone(_batchData);

							var _idsCurrent = _id;
							var _idsCount = array_length(_idsCurrent);
							var _dataCurrent = _batchData;
							var _slotsPerInstance = array_length(_dataCurrent) / _idsCount;

							var k = 0;
							repeat (_idsCount)
							{
								if (ds_list_find_index(_instances, _idsCurrent[k]) == -1)
								{
									var l = 0;
									repeat (_slotsPerInstance)
									{
										_dataCurrent[@ (k * _slotsPerInstance) + l] = 0.0;
										++l;
									}
								}
								else
								{
									_hasInstances = true;
								}
								++k;
							}
						}

						if (!_hasInstances)
						{
							continue;
						}
					}
					else
					{
						////////////////////////////////////////////////////
						// _id is a single ID
						if (ds_list_find_index(_instances, _id) == -1)
						{
							continue;
						}
					}
				}

				////////////////////////////////////////////////////////////

				if (_materialProps != undefined)
				{
					_materialProps.apply();
				}

				if (is_real(_id))
				{
					BBMOD_SHADER_CURRENT.set_instance_id(_id);
				}

				matrix_set(matrix_world, _matrix);

				var _primitiveType = _mesh.PrimitiveType;
				var _vertexBuffer = _mesh.VertexBuffer;

				if (is_array(_batchData[0]))
				{
					var _dataIndex = 0;
					repeat (array_length(_batchData))
					{
						BBMOD_SHADER_CURRENT.set_batch_data(_batchData[_dataIndex++]);
						vertex_submit(_vertexBuffer, _primitiveType, _material.BaseOpacity);
					}
				}
				else
				{
					BBMOD_SHADER_CURRENT.set_batch_data(_batchData);
					vertex_submit(_vertexBuffer, _primitiveType, _material.BaseOpacity);
				}
			}
			break;
		}

		global.__bbmodMaterialProps = _materialPropsOld;

		return self;
	};

	/// @func clear()
	///
	/// @desc Clears the render queue.
	///
	/// @return {Struct.BBMOD_MeshRenderQueue} Returns `self`.
	static clear = function ()
	{
		gml_pragma("forceinline");
		__mesh = undefined;
		__material = undefined;
		__commandType = undefined;
		__renderPasses = 0;
		__index = 0;
		return self;
	};

	static destroy = function ()
	{
		ds_grid_destroy(__renderCommands);
		__bbmod_remove_render_queue(self);
		return undefined;
	};

	__bbmod_add_render_queue(self);
}
