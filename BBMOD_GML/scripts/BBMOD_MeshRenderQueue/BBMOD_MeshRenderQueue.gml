/// @module Core

/// @func BBMOD_MeshRenderQueue([_name[, _priority]])
///
/// @implements {BBMOD_IMeshRenderQueue}
///
/// @desc A render queue specialized for rendering of multiple instances of a
/// model, where all instances are using the same material. You can use this
/// instead of {@link BBMOD_RenderQueue} to increase rendering performance.
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

	/// @var {Array}
	/// @see BBMOD_ERenderCommand
	/// @private
	__renderCommands = [];

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

	static set_priority = function (_p)
	{
		gml_pragma("forceinline");
		Priority = _p;
		__bbmod_reindex_render_queues();
		return self;
	};

	static DrawMesh = function (_mesh, _material, _matrix)
	{
		gml_pragma("forceinline");

		if (__mesh != undefined && _mesh != __mesh)
		{
			show_error("BBMOD_IMeshRenderQueue cannot contain multiple different meshes!", true);
		}

		if (__material != undefined && _material != __material)
		{
			show_error("All meshes in BBMOD_IMeshRenderQueue must use the same material!", true);
		}

		if (__commandType != undefined && __commandType != BBMOD_ERenderCommand.DrawMesh)
		{
			show_error("BBMOD_IMeshRenderQueue cannot contain multiple types of render commands!", true);
		}

		__mesh = _mesh;
		__material = _material;
		__commandType = BBMOD_ERenderCommand.DrawMesh;
		__renderPasses |= _material.RenderPass;

		var _index = __index;
		__renderCommands[@ _index] = global.__bbmodInstanceID;
		__renderCommands[@ _index + 1] = global.__bbmodMaterialProps;
		__renderCommands[@ _index + 2] = _matrix;
		__index += 4;

		return self;
	};

	static DrawMeshAnimated = function (_mesh, _material, _matrix, _boneTransform)
	{
		gml_pragma("forceinline");

		if (__mesh != undefined && _mesh != __mesh)
		{
			show_error("BBMOD_IMeshRenderQueue cannot contain multiple different meshes!", true);
		}

		if (__material != undefined && _material != __material)
		{
			show_error("All meshes in BBMOD_IMeshRenderQueue must use the same material!", true);
		}

		if (__commandType != undefined && __commandType != BBMOD_ERenderCommand.DrawMeshAnimated)
		{
			show_error("BBMOD_IMeshRenderQueue cannot contain multiple types of render commands!", true);
		}

		__mesh = _mesh;
		__material = _material;
		__commandType = BBMOD_ERenderCommand.DrawMeshAnimated;
		__renderPasses |= _material.RenderPass;

		var _index = __index;
		__renderCommands[@ _index] = global.__bbmodInstanceID;
		__renderCommands[@ _index + 1] = global.__bbmodMaterialProps;
		__renderCommands[@ _index + 2] = _matrix;
		__renderCommands[@ _index + 3] = _boneTransform;
		__index += 4;

		return self;
	};

	static DrawMeshBatched = function (_mesh, _material, _matrix, _batchData)
	{
		gml_pragma("forceinline");

		if (__mesh != undefined && _mesh != __mesh)
		{
			show_error("BBMOD_IMeshRenderQueue cannot contain multiple different meshes!", true);
		}

		if (__material != undefined && _material != __material)
		{
			show_error("All meshes in BBMOD_IMeshRenderQueue must use the same material!", true);
		}

		if (__commandType != undefined && __commandType != BBMOD_ERenderCommand.DrawMeshBatched)
		{
			show_error("BBMOD_IMeshRenderQueue cannot contain multiple types of render commands!", true);
		}

		__mesh = _mesh;
		__material = _material;
		__commandType = BBMOD_ERenderCommand.DrawMeshBatched;
		__renderPasses |= _material.RenderPass;

		var _index = __index;
		__renderCommands[@ _index] = global.__bbmodInstanceID;
		__renderCommands[@ _index + 1] = global.__bbmodMaterialProps;
		__renderCommands[@ _index + 2] = _matrix;
		__renderCommands[@ _index + 3] = _batchData;
		__index += 4;

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

	static has_commands = function (_renderPass)
	{
		gml_pragma("forceinline");
		return (__renderPasses & (1 << _renderPass)) ? true : false;
	};

	static submit = function (_instances=undefined)
	{
		if (!has_commands(global.__bbmodRenderPass))
		{
			return self;
		}

		var _commandIndex = 0;
		var _renderCommands = __renderCommands;
		var _mesh = __mesh;
		var _primitiveType = _mesh.PrimitiveType;
		var _vertexBuffer = _mesh.VertexBuffer;
		var _material = __material;
		var _baseOpacity = _material.BaseOpacity;
		var _commandType = __commandType;

		var _materialPropsOld = global.__bbmodMaterialProps;
		global.__bbmodMaterialProps = undefined;

		if (!_material.apply(_mesh.VertexFormat))
		{
			global.__bbmodMaterialProps = _materialPropsOld;
			return self;
		}

		var _shaderCurrent = shader_current();
		var _uInstanceID = shader_get_uniform(_shaderCurrent, BBMOD_U_INSTANCE_ID);
		var _uMaterialIndex = shader_get_uniform(_shaderCurrent, BBMOD_U_MATERIAL_INDEX);
		var _uBoneData = shader_get_uniform(_shaderCurrent, BBMOD_U_BONES);
		var _uBatchData = shader_get_uniform(_shaderCurrent, BBMOD_U_BATCH_DATA);

		shader_set_uniform_f(_uMaterialIndex, _mesh.MaterialIndex);

		switch (_commandType)
		{
		case BBMOD_ERenderCommand.DrawMesh:
			{
				repeat (_index / 4)
				{
					var _id = _renderCommands[_commandIndex];
					var _materialProps = _renderCommands[_commandIndex + 1];
					var _matrix = _renderCommands[_commandIndex + 2];
					_commandIndex += 4;

					if (_instances != undefined && ds_list_find_index(_instances, _id) == -1)
					{
						continue;
					}

					var _texture = _baseOpacity;
					if (_materialProps != undefined)
					{
						_materialProps.apply(_shaderCurrent);
						var _baseOpacityProp = _materialProps.get(BBMOD_U_BASE_OPACITY);
						if (_baseOpacityProp != undefined)
						{
							_texture = _baseOpacityProp;
						}
					}

					matrix_set(matrix_world, _matrix);
					shader_set_uniform_f(_uInstanceID,
						((_id & $000000FF) >> 0) / 255,
						((_id & $0000FF00) >> 8) / 255,
						((_id & $00FF0000) >> 16) / 255,
						((_id & $FF000000) >> 24) / 255);
					vertex_submit(_vertexBuffer, _primitiveType, _texture);
				}
			}
			break;

		case BBMOD_ERenderCommand.DrawMeshAnimated:
			{
				repeat (__index / 4)
				{
					var _id = _renderCommands[_commandIndex];
					var _materialProps = _renderCommands[_commandIndex + 1];
					var _matrix = _renderCommands[_commandIndex + 2];
					var _boneData = _renderCommands[_commandIndex + 3];
					_commandIndex += 4;

					if (_instances != undefined && ds_list_find_index(_instances, _id) == -1)
					{
						continue;
					}

					var _texture = _baseOpacity;
					if (_materialProps != undefined)
					{
						_materialProps.apply(_shaderCurrent);
						var _baseOpacityProp = _materialProps.get(BBMOD_U_BASE_OPACITY);
						if (_baseOpacityProp != undefined)
						{
							_texture = _baseOpacityProp;
						}
					}

					matrix_set(matrix_world, _matrix);
					shader_set_uniform_f(_uInstanceID,
						((_id & $000000FF) >> 0) / 255,
						((_id & $0000FF00) >> 8) / 255,
						((_id & $00FF0000) >> 16) / 255,
						((_id & $FF000000) >> 24) / 255);
					shader_set_uniform_f_array(_uBoneData, _boneData);
					vertex_submit(_vertexBuffer, _primitiveType, _texture);
				}
			}
			break;

		case BBMOD_ERenderCommand.DrawMeshBatched:
			{
				repeat (__index / 4)
				{
					var _id = _renderCommands[_commandIndex];
					var _materialProps = _renderCommands[_commandIndex + 1];
					var _matrix = _renderCommands[_commandIndex + 2];
					var _batchData = _renderCommands[_commandIndex + 3];
					_commandIndex += 4;

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

					var _texture = _baseOpacity;
					if (_materialProps != undefined)
					{
						_materialProps.apply(_shaderCurrent);
						var _baseOpacityProp = _materialProps.get(BBMOD_U_BASE_OPACITY);
						if (_baseOpacityProp != undefined)
						{
							_texture = _baseOpacityProp;
						}
					}

					if (is_real(_id))
					{
						shader_set_uniform_f(_uInstanceID,
							((_id & $000000FF) >> 0) / 255,
							((_id & $0000FF00) >> 8) / 255,
							((_id & $00FF0000) >> 16) / 255,
							((_id & $FF000000) >> 24) / 255);
					}

					matrix_set(matrix_world, _matrix);

					if (is_array(_batchData[0]))
					{
						var _dataIndex = 0;
						repeat (array_length(_batchData))
						{
							shader_set_uniform_f_array(_uBatchData, _batchData[_dataIndex++]);
							vertex_submit(_vertexBuffer, _primitiveType, _texture);
						}
					}
					else
					{
						shader_set_uniform_f_array(_uBatchData, _batchData);
						vertex_submit(_vertexBuffer, _primitiveType, _texture);
					}
				}
			}
			break;
		}

		global.__bbmodMaterialProps = _materialPropsOld;

		return self;
	};

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
		__renderCommands = undefined;
		__bbmod_remove_render_queue(self);
		return undefined;
	};

	__bbmod_add_render_queue(self);
}
