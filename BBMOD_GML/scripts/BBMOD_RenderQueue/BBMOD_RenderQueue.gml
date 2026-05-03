/// @module Core

/// @enum Enumeration of render queue categories. Defines the order in which
/// render queues are submitted during rendering. Values are spaced to allow
/// custom queues between standard ones (e.g., Opaque + 1).
enum BBMOD_ERenderQueue
{
	/// @member Render queue for terrain rendering.
	Terrain = 0,
		/// @member Render queue for opaque objects.
		Opaque = 1000,
		/// @member Render queue for transparent objects.
		Transparent = 2000,
		/// @member Render queue for sky rendering.
		Sky = 3000
};

/// @var {Id.DsMap} Map of render queue values to render queue instances.
/// @private
global.__bbmodRenderQueues = ds_map_create();

/// @var {Real} Version stamp for render queue map changes.
/// @private
global.__bbmodRenderQueuesVersion = 0;

/// @func bbmod_render_queue_get(_index)
///
/// @desc Retrieves the render queue instance for the given queue value.
/// Creates a new queue if one doesn't exist for this value.
///
/// @param {Real} _index The render queue value (e.g., BBMOD_ERenderQueue.Opaque,
/// BBMOD_ERenderQueue.Opaque + 1, etc.).
///
/// @return {Struct.BBMOD_RenderQueue} The render queue instance.
///
/// @see BBMOD_ERenderQueue
/// @see BBMOD_RenderQueue
function bbmod_render_queue_get(_index)
{
	gml_pragma("forceinline");
	if (!ds_map_exists(global.__bbmodRenderQueues, _index))
	{
		global.__bbmodRenderQueues[?  _index] = new BBMOD_RenderQueue("RenderQueue" + string(_index), _index);
		++global.__bbmodRenderQueuesVersion;
	}
	return global.__bbmodRenderQueues[?  _index];
}

/// @func bbmod_render_queues_get()
///
/// @desc Retrieves an array of existing render queues sorted by queue category
/// value (ascending).
///
/// @return {Array<Struct.BBMOD_RenderQueue>} The array of render queues.
///
/// @see BBMOD_RenderQueue
/// @see BBMOD_ERenderQueue
function bbmod_render_queues_get()
{
	static _renderQueues = [];
	static _queueKeys = [];
	static _cachedVersion = -1;

	static _sortFn = function (_a, _b)
	{
		if (_a < _b)
		{
			return -1;
		}

		if (_a > _b)
		{
			return 1;
		}

		return 0;
	};

	if (_cachedVersion == global.__bbmodRenderQueuesVersion)
	{
		return _renderQueues;
	}

	// Rebuild array from struct
	array_resize(_renderQueues, 0);
	array_resize(_queueKeys, 0);
	var _key = ds_map_find_first(global.__bbmodRenderQueues);
	while (_key != undefined)
	{
		array_push(_queueKeys, _key);
		_key = ds_map_find_next(global.__bbmodRenderQueues, _key);
	}

	array_sort(_queueKeys, _sortFn);

	var i = 0;
	repeat(array_length(_queueKeys))
	{
		var _queueKey = _queueKeys[i++];
		array_push(_renderQueues, global.__bbmodRenderQueues[?  _queueKey]);
	}

	_cachedVersion = global.__bbmodRenderQueuesVersion;

	return _renderQueues;
}

/// @func bbmod_render_queues_submit([_instances])
///
/// @desc Submits all existing render queues.
///
/// @param {Id.DsList<Id.Instance>} [_instances] If specified then only
/// meshes with an instance ID from the list are submitted. Defaults to
/// `undefined`.
///
/// @see BBMOD_RenderQueue.submit
function bbmod_render_queues_submit(_instances = undefined)
{
	gml_pragma("forceinline");
	var _renderQueues = bbmod_render_queues_get();
	var i = 0;
	repeat(array_length(_renderQueues))
	{
		_renderQueues[i++].submit(_instances);
	}
}

/// @func bbmod_render_queues_clear()
///
/// @desc Clears all existing render queues.
///
/// @see BBMOD_RenderQueue.clear
function bbmod_render_queues_clear()
{
	gml_pragma("forceinline");
	var _renderQueues = bbmod_render_queues_get();
	var i = 0;
	repeat(array_length(_renderQueues))
	{
		_renderQueues[i++].clear();
	}
}

/// @func BBMOD_RenderQueue([_name[, _priority]])
///
/// @desc A container of render commands.
///
/// @param {String} [_name] The name of the render queue. Defaults to
/// "RenderQueue" + number of created render queues - 1 (e.g. "RenderQueue0",
/// "RenderQueue1" etc.) if `undefined`.
/// @param {Real} [_priority] Obsolete priority argument. Ignored.
///
/// @see bbmod_render_queue_get_default
/// @see BBMOD_ERenderCommand
function BBMOD_RenderQueue(_name = undefined, _priority = 0) constructor
{
	static IdNext = 0;

	/// @var {String} The name of the render queue. This can be useful for
	/// debugging purposes.
	Name = _name ?? ("RenderQueue" + string(IdNext++));

	/// @var {Real} The priority of the render queue.
	/// @obsolete This property is obsolete and has no effect. Render queue order
	/// is determined only by BBMOD_ERenderQueue values.
	/// @readonly
	Priority = 0;

	/// @var {Array<Id.DsGrid>} Array of grids storing render commands, one per render pass.
	/// Each row is a command. Column 0 = command type, Column 1 = material hash, Column 2 = data array.
	/// @see BBMOD_ERenderCommand
	/// @see BBMOD_ERenderPass
	/// @private
	__renderCommands = array_create(BBMOD_ERenderPass.SIZE, undefined);

	/// @var {Array<Real>} Current row index in each render pass's grid.
	/// @private
	__index = array_create(BBMOD_ERenderPass.SIZE, 0);

	/// @var {Array<Bool>} Whether each render pass's grid is currently sorted.
	/// @private
	__isSorted = array_create(BBMOD_ERenderPass.SIZE, true);

	// Initialize grids for each render pass
	var i = 0;
	repeat(BBMOD_ERenderPass.SIZE)
	{
		var _grid = ds_grid_create(3, 128);
		// Fill column 1 with max value so unused rows sort to the end
		ds_grid_set_region(_grid, 1, 0, 1, 127, infinity);
		__renderCommands[@ i] = _grid;
		++i;
	}

	/// @var {Real} Render passes that the queue has commands for (bitfield).
	/// @private
	__renderPasses = 0;

	/// @func set_priority(_p)
	///
	/// @desc Obsolete no-op retained for backwards compatibility.
	///
	/// @param {Real} _p The new priority value.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete and has no effect. Render queue order
	/// is determined only by BBMOD_ERenderQueue values.
	static set_priority = function (_p)
	{
		gml_pragma("forceinline");
		return self;
	};

	/// @func ApplyMaterial(_material, _vertexFormat[, _enabledPasses])
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.ApplyMaterial} command into
	/// the queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to apply.
	/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format of
	/// models that will be rendered using this material.
	/// @param {Real} [_enabledPasses] Mask of enabled rendering passes. The
	/// material will not be applied if the current rendering pass is not one
	/// of them.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static ApplyMaterial = function (_material, _vertexFormat, _enabledPasses = ~0)
	{
		__bbmod_warning("BBMOD_RenderQueue.ApplyMaterial is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func ApplyMaterialProps(_materialPropertyBlock)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.ApplyMaterialProps} command
	/// into the queue.
	///
	/// @param {Struct.BBMOD_MaterialPropertyBlock} _materialPropertyBlock The
	/// material property block to apply.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static ApplyMaterialProps = function (_materialPropertyBlock)
	{
		__bbmod_warning("BBMOD_RenderQueue.ApplyMaterialProps is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func BeginConditionalBlock()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.BeginConditionalBlock} command
	/// into the queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static BeginConditionalBlock = function ()
	{
		__bbmod_warning("BBMOD_RenderQueue.BeginConditionalBlock is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func CallFunction(_function[, _arguments])
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.CallFunction} command into the
	/// queue.
	///
	/// @param {Function} _function The function to execute.
	/// @param {Array} [_arguments] Arguments to be passed to the function.
	/// Defaults to an empty array.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static CallFunction = function (_function, _arguments = [])
	{
		__bbmod_warning("BBMOD_RenderQueue.CallFunction is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func CheckRenderPass(_passes)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.CheckRenderPass} command into
	/// the queue.
	///
	/// @param {Real} [_passes] Mask of allowed rendering passes.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static CheckRenderPass = function (_passes)
	{
		__bbmod_warning("BBMOD_RenderQueue.CheckRenderPass is obsolete. Use Draw* methods instead.");
		return self;
	};

	static DrawMesh = function (_mesh, _material, _matrix)
	{
		gml_pragma("forceinline");
		var _materialPasses = _material.RenderPass;
		__renderPasses |= _materialPasses;
		var _materialHash = _material.get_hash();
		var _instanceID = global.__bbmodInstanceID;
		var _ditherEnableSnapshot = bbmod_dither_get_enabled();
		var _ditherValueSnapshot = bbmod_dither_get_value();

		// Add command to all render pass grids that this material supports
		var _pass = 0;
		repeat(BBMOD_ERenderPass.SIZE)
		{
			if (_materialPasses & (1 << _pass))
			{
				// Inline row allocation for performance
				var _row = __index[_pass];
				var _grid = __renderCommands[_pass];
				var _height = ds_grid_height(_grid);
				if (_row >= _height)
				{
					var _newHeight = _height * 2;
					ds_grid_resize(_grid, 3, _newHeight);
					ds_grid_set_region(_grid, 1, _height, 1, _newHeight - 1, infinity);
				}
				__index[@ _pass] = _row + 1;

				_grid[# 0, _row] = BBMOD_ERenderCommand.DrawMesh;
				_grid[# 1, _row] = _materialHash;
				var _data = _grid[# 2, _row];
				if (!is_array(_data) || array_length(_data) < 6)
				{
					_data = array_create(6);
					_grid[# 2, _row] = _data;
				}
				_data[@ 0] = _instanceID;
				_data[@ 1] = _mesh;
				_data[@ 2] = _material;
				_data[@ 3] = _matrix;
				_data[@ 4] = _ditherEnableSnapshot;
				_data[@ 5] = _ditherValueSnapshot;
				__isSorted[@ _pass] = false;
			}
			++_pass;
		}
		return self;
	};

	static DrawMeshAnimated = function (_mesh, _material, _matrix, _boneTransform)
	{
		gml_pragma("forceinline");
		var _materialPasses = _material.RenderPass;
		__renderPasses |= _materialPasses;
		var _materialHash = _material.get_hash();
		var _instanceID = global.__bbmodInstanceID;
		var _ditherEnableSnapshot = bbmod_dither_get_enabled();
		var _ditherValueSnapshot = bbmod_dither_get_value();

		// Add command to all render pass grids that this material supports
		var _pass = 0;
		repeat(BBMOD_ERenderPass.SIZE)
		{
			if (_materialPasses & (1 << _pass))
			{
				// Inline row allocation for performance
				var _row = __index[_pass];
				var _grid = __renderCommands[_pass];
				var _height = ds_grid_height(_grid);
				if (_row >= _height)
				{
					var _newHeight = _height * 2;
					ds_grid_resize(_grid, 3, _newHeight);
					ds_grid_set_region(_grid, 1, _height, 1, _newHeight - 1, infinity);
				}
				__index[@ _pass] = _row + 1;

				_grid[# 0, _row] = BBMOD_ERenderCommand.DrawMeshAnimated;
				_grid[# 1, _row] = _materialHash;
				var _data = _grid[# 2, _row];
				if (!is_array(_data) || array_length(_data) < 7)
				{
					_data = array_create(7);
					_grid[# 2, _row] = _data;
				}
				_data[@ 0] = _instanceID;
				_data[@ 1] = _mesh;
				_data[@ 2] = _material;
				_data[@ 3] = _matrix;
				_data[@ 4] = _boneTransform;
				_data[@ 5] = _ditherEnableSnapshot;
				_data[@ 6] = _ditherValueSnapshot;
				__isSorted[@ _pass] = false;
			}
			++_pass;
		}
		return self;
	};

	static DrawMeshBatched = function (_mesh, _material, _matrix, _batchData)
	{
		gml_pragma("forceinline");
		var _materialPasses = _material.RenderPass;
		__renderPasses |= _materialPasses;
		var _materialHash = _material.get_hash();
		var _instanceID = global.__bbmodInstanceIDBatch ?? global.__bbmodInstanceID;
		var _batchContext = global.__bbmodDynamicBatchContext;
		var _batchVisibleInstances = variable_global_exists("__bbmodBatchVisibleInstances")
			? global.__bbmodBatchVisibleInstances
			: undefined;
		var _ditherEnableSnapshot = bbmod_dither_get_enabled();
		var _ditherValueSnapshot = bbmod_dither_get_value();

		// Add command to all render pass grids that this material supports
		var _pass = 0;
		repeat(BBMOD_ERenderPass.SIZE)
		{
			if (_materialPasses & (1 << _pass))
			{
				// Inline row allocation for performance
				var _row = __index[_pass];
				var _grid = __renderCommands[_pass];
				var _height = ds_grid_height(_grid);
				if (_row >= _height)
				{
					var _newHeight = _height * 2;
					ds_grid_resize(_grid, 3, _newHeight);
					ds_grid_set_region(_grid, 1, _height, 1, _newHeight - 1, infinity);
				}
				__index[@ _pass] = _row + 1;

				_grid[# 0, _row] = BBMOD_ERenderCommand.DrawMeshBatched;
				_grid[# 1, _row] = _materialHash;
				var _data = _grid[# 2, _row];
				if (!is_array(_data) || array_length(_data) < 9)
				{
					_data = array_create(9);
					_grid[# 2, _row] = _data;
				}
				_data[@ 0] = _instanceID;
				_data[@ 1] = _mesh;
				_data[@ 2] = _material;
				_data[@ 3] = _matrix;
				_data[@ 4] = _batchData;
				_data[@ 5] = _batchContext;
				_data[@ 6] = _batchVisibleInstances;
				_data[@ 7] = _ditherEnableSnapshot;
				_data[@ 8] = _ditherValueSnapshot;
				__isSorted[@ _pass] = false;
			}
			++_pass;
		}
		return self;
	};

	static DrawTerrain = function (_terrain)
	{
		gml_pragma("forceinline");
		var _material = _terrain.Material;
		var _materialPasses = _material.RenderPass;
		__renderPasses |= _materialPasses;
		var _materialHash = _material.get_hash();
		var _instanceID = global.__bbmodInstanceID;

		// Add command to all render pass grids that this material supports
		var _pass = 0;
		repeat(BBMOD_ERenderPass.SIZE)
		{
			if (_materialPasses & (1 << _pass))
			{
				// Inline row allocation for performance
				var _row = __index[_pass];
				var _grid = __renderCommands[_pass];
				var _height = ds_grid_height(_grid);
				if (_row >= _height)
				{
					var _newHeight = _height * 2;
					ds_grid_resize(_grid, 3, _newHeight);
					ds_grid_set_region(_grid, 1, _height, 1, _newHeight - 1, infinity);
				}
				__index[@ _pass] = _row + 1;

				_grid[# 0, _row] = BBMOD_ERenderCommand.DrawTerrain;
				_grid[# 1, _row] = _materialHash;
				var _data = _grid[# 2, _row];
				if (!is_array(_data) || array_length(_data) < 2)
				{
					_data = array_create(2);
					_grid[# 2, _row] = _data;
				}
				_data[@ 0] = _instanceID;
				_data[@ 1] = _terrain;
				__isSorted[@ _pass] = false;
			}
			++_pass;
		}
		return self;
	};

	/// @func __enqueue_material_command(_material, _commandType, _dataValues)
	///
	/// @desc Enqueues a material draw command into all compatible render-pass grids.
	///
	/// @param {Struct.BBMOD_Material} _material The command material.
	/// @param {Real} _commandType One of {@link BBMOD_ERenderCommand} values.
	/// @param {Array} _dataValues Command payload written into column 2.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @private
	static __enqueue_material_command = function (_material, _commandType, _dataValues)
	{
		gml_pragma("forceinline");

		var _materialPasses = _material.RenderPass;
		__renderPasses |= _materialPasses;
		var _materialHash = _material.get_hash();
		var _valueCount = array_length(_dataValues);

		var _pass = 0;
		repeat(BBMOD_ERenderPass.SIZE)
		{
			if (_materialPasses & (1 << _pass))
			{
				var _row = __index[_pass];
				var _grid = __renderCommands[_pass];
				var _height = ds_grid_height(_grid);
				if (_row >= _height)
				{
					var _newHeight = _height * 2;
					ds_grid_resize(_grid, 3, _newHeight);
					ds_grid_set_region(_grid, 1, _height, 1, _newHeight - 1, infinity);
				}
				__index[@ _pass] = _row + 1;

				_grid[# 0, _row] = _commandType;
				_grid[# 1, _row] = _materialHash;

				var _data = _grid[# 2, _row];
				if (!is_array(_data) || array_length(_data) < _valueCount)
				{
					_data = array_create(_valueCount);
					_grid[# 2, _row] = _data;
				}

				var i = 0;
				repeat(_valueCount)
				{
					_data[@ i] = _dataValues[i];
					++i;
				}

				__isSorted[@ _pass] = false;
			}
			++_pass;
		}

		return self;
	};

	/// @func DrawSprite(_material, _sprite, _subimg, _x, _y)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSprite} command into the
	/// queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to use when drawing the sprite.
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSprite = function (_material, _sprite, _subimg, _x, _y)
	{
		return __enqueue_material_command(_material, BBMOD_ERenderCommand.DrawSprite,
			[_material, _sprite, _subimg, _x, _y]);
	};

	/// @func DrawSpriteExt(_material, _sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _col, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteExt} command into the
	/// queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to use when drawing the sprite.
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	/// @param {Real} _xscale The horizontal scaling of the sprite.
	/// @param {Real} _yscale The vertical scaling of the sprite.
	/// @param {Real} _rot The rotation of the sprite.
	/// @param {Constant.Color} _col The color with which to blend the sprite.
	/// @param {Real} _alpha The alpha of the sprite.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSpriteExt = function (
		_material, _sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _col, _alpha)
	{
		return __enqueue_material_command(_material, BBMOD_ERenderCommand.DrawSpriteExt,
			[_material, _sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _col, _alpha]);
	};

	/// @func DrawSpriteGeneral(_material, _sprite, _subimg, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _rot, _c1, _c2, _c3, _c4, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteGeneral} command into
	/// the queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to use when drawing the sprite.
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _left The x position on the sprite of the top left corner
	/// of the area to draw.
	/// @param {Real} _top The y position on the sprite of the top left corner
	/// of the area to draw.
	/// @param {Real} _width The width of the area to draw.
	/// @param {Real} _height The height of the area to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	/// @param {Real} _xscale The horizontal scaling of the sprite.
	/// @param {Real} _yscale The vertical scaling of the sprite.
	/// @param {Real} _rot The rotation of the sprite.
	/// @param {Constant.Color} _c1 The color with which to blend the top left
	/// area of the sprite.
	/// @param {Constant.Color} _c2 The color with which to blend the top right
	/// area of the sprite.
	/// @param {Constant.Color} _c3 The color with which to blend the bottom
	/// right area of the sprite.
	/// @param {Constant.Color} _c4 The color with which to blend the bottom
	/// left area of the sprite.
	/// @param {Real} _alpha The alpha of the sprite.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSpriteGeneral = function (
		_material, _sprite, _subimg, _left, _top, _width, _height, _x, _y, _xscale, _yscale,
		_rot, _c1, _c2, _c3, _c4, _alpha)
	{
		return __enqueue_material_command(_material, BBMOD_ERenderCommand.DrawSpriteGeneral,
			[_material, _sprite, _subimg, _left, _top, _width, _height, _x, _y, _xscale, _yscale,
				_rot, _c1, _c2, _c3, _c4, _alpha
			]);
	};

	/// @func DrawSpritePart(_material, _sprite, _subimg, _left, _top, _width, _height, _x, _y)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpritePart} command into
	/// the queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to use when drawing the sprite.
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _left The x position on the sprite of the top left corner
	/// of the area to draw.
	/// @param {Real} _top The y position on the sprite of the top left corner
	/// of the area to draw.
	/// @param {Real} _width The width of the area to draw.
	/// @param {Real} _height The height of the area to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSpritePart = function (
		_material, _sprite, _subimg, _left, _top, _width, _height, _x, _y)
	{
		return __enqueue_material_command(_material, BBMOD_ERenderCommand.DrawSpritePart,
			[_material, _sprite, _subimg, _left, _top, _width, _height, _x, _y]);
	};

	/// @func DrawSpritePartExt(_material, _sprite, _subimg, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _col, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpritePartExt} command into
	/// the queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to use when drawing the sprite.
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _left The x position on the sprite of the top left corner
	/// of the area to draw.
	/// @param {Real} _top The y position on the sprite of the top left corner
	/// of the area to draw.
	/// @param {Real} _width The width of the area to draw.
	/// @param {Real} _height The height of the area to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	/// @param {Real} _xscale The horizontal scaling of the sprite.
	/// @param {Real} _yscale The vertical scaling of the sprite.
	/// @param {Constant.Color} _col The color with which to blend the sprite.
	/// @param {Real} _alpha The alpha of the sprite.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSpritePartExt = function (
		_material, _sprite, _subimg, _left, _top, _width, _height, _x, _y, _xscale, _yscale,
		_col, _alpha)
	{
		return __enqueue_material_command(_material, BBMOD_ERenderCommand.DrawSpritePartExt,
			[_material, _sprite, _subimg, _left, _top, _width, _height, _x, _y, _xscale, _yscale,
				_col, _alpha
			]);
	};

	/// @func DrawSpritePos(_material, _sprite, _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpritePos} command into the
	/// queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to use when drawing the sprite.
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _x1 The first x coordinate.
	/// @param {Real} _y1 The first y coordinate.
	/// @param {Real} _x2 The second x coordinate.
	/// @param {Real} _y2 The second y coordinate.
	/// @param {Real} _x3 The third x coordinate.
	/// @param {Real} _y3 The third y coordinate.
	/// @param {Real} _x4 The fourth x coordinate.
	/// @param {Real} _y4 The fourth y coordinate.
	/// @param {Real} _alpha The alpha of the sprite.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSpritePos = function (
		_material, _sprite, _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha)
	{
		return __enqueue_material_command(_material, BBMOD_ERenderCommand.DrawSpritePos,
			[_material, _sprite, _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha]);
	};

	/// @func DrawSpriteStretched(_material, _sprite, _subimg, _x, _y, _w, _h)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteStretched} command
	/// into the queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to use when drawing the sprite.
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	/// @param {Real} _w The width of the area the stretched sprite will occupy.
	/// @param {Real} _h The height of the area the stretched sprite will occupy.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSpriteStretched = function (_material, _sprite, _subimg, _x, _y, _w, _h)
	{
		return __enqueue_material_command(_material, BBMOD_ERenderCommand.DrawSpriteStretched,
			[_material, _sprite, _subimg, _x, _y, _w, _h]);
	};

	/// @func DrawSpriteStretchedExt(_material, _sprite, _subimg, _x, _y, _w, _h, _col, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteStretchedExt} command
	/// into the queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to use when drawing the sprite.
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	/// @param {Real} _w The width of the area the stretched sprite will occupy.
	/// @param {Real} _h The height of the area the stretched sprite will occupy.
	/// @param {Constant.Color} _col The color with which to blend the sprite.
	/// @param {Real} _alpha The alpha of the sprite.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSpriteStretchedExt = function (
		_material, _sprite, _subimg, _x, _y, _w, _h, _col, _alpha)
	{
		return __enqueue_material_command(_material, BBMOD_ERenderCommand.DrawSpriteStretchedExt,
			[_material, _sprite, _subimg, _x, _y, _w, _h, _col, _alpha]);
	};

	/// @func DrawSpriteTiled(_material, _sprite, _subimg, _x, _y)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteTiled} command into
	/// the queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to use when drawing the sprite.
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSpriteTiled = function (_material, _sprite, _subimg, _x, _y)
	{
		return __enqueue_material_command(_material, BBMOD_ERenderCommand.DrawSpriteTiled,
			[_material, _sprite, _subimg, _x, _y]);
	};

	/// @func DrawSpriteTiledExt(_material, _sprite, _subimg, _x, _y, _xscale, _yscale, _col, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteTiledExt} command
	/// into the queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to use when drawing the sprite.
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	/// @param {Real} _xscale The horizontal scaling of the sprite.
	/// @param {Real} _yscale The vertical scaling of the sprite.
	/// @param {Constant.Color} _col The color with which to blend the sprite.
	/// @param {Real} _alpha The alpha of the sprite.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSpriteTiledExt = function (
		_material, _sprite, _subimg, _x, _y, _xscale, _yscale, _col, _alpha)
	{
		return __enqueue_material_command(_material, BBMOD_ERenderCommand.DrawSpriteTiledExt,
			[_material, _sprite, _subimg, _x, _y, _xscale, _yscale, _col, _alpha]);
	};

	/// @func EndConditionalBlock()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.EndConditionalBlock} command
	/// into the queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static EndConditionalBlock = function ()
	{
		__bbmod_warning("BBMOD_RenderQueue.EndConditionalBlock is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func PopGpuState()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.PopGpuState} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static PopGpuState = function ()
	{
		__bbmod_warning("BBMOD_RenderQueue.PopGpuState is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func PushGpuState()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.PushGpuState} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static PushGpuState = function ()
	{
		__bbmod_warning("BBMOD_RenderQueue.PushGpuState is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func ResetMaterial()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.ResetMaterial} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static ResetMaterial = function ()
	{
		__bbmod_warning("BBMOD_RenderQueue.ResetMaterial is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func ResetMaterialProps()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.ResetMaterialProps} command
	/// into the queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static ResetMaterialProps = function ()
	{
		__bbmod_warning("BBMOD_RenderQueue.ResetMaterialProps is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func ResetShader()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.ResetShader} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static ResetShader = function ()
	{
		__bbmod_warning("BBMOD_RenderQueue.ResetShader is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuAlphaTestEnable(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuAlphaTestEnable} command
	/// into the queue.
	///
	/// @param {Bool} _enable Use `true` to enable alpha testing.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuAlphaTestEnable = function (_enable)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuAlphaTestEnable is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuAlphaTestRef(_value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuAlphaTestRef} command
	/// into the queue.
	///
	/// @param {Real} _value The new alpha test threshold value.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuAlphaTestRef = function (_value)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuAlphaTestRef is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuBlendEnable(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendEnable} command into
	/// the queue.
	///
	/// @param {Bool} _enable Use `true` to enable alpha blending.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuBlendEnable = function (_enable)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuBlendEnable is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuBlendMode(_blendmode)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendMode} command into
	/// the queue.
	///
	/// @param {Constant.BlendMode} _blendmode The new blend mode.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuBlendMode = function (_blendmode)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuBlendMode is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuBlendModeExt(_src, _dest)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendModeExt} command
	/// into the queue.
	///
	/// @param {Constant.BlendMode} _src Source blend mode.
	/// @param {Constant.BlendMode} _dest Destination blend mode.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuBlendModeExt = function (_src, _dest)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuBlendModeExt is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuBlendModeExtSepAlpha(_src, _dest, _srcalpha, _destalpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendModeExtSepAlpha}
	/// command into the queue.
	///
	/// @param {Constant.BlendMode} _src Source blend mode.
	/// @param {Constant.BlendMode} _dest Destination blend mode.
	/// @param {Constant.BlendMode} _srcalpha Blend mode for source alpha channel.
	/// @param {Constant.BlendMode} _destalpha Blend mode for destination alpha
	/// channel.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuBlendModeExtSepAlpha = function (_src, _dest, _srcalpha, _destalpha)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuBlendModeExtSepAlpha is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuColorWriteEnable(_red, _green, _blue, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuColorWriteEnable} command
	/// into the queue.
	///
	/// @param {Bool} _red Use `true` to enable writing to the red color
	/// channel.
	/// @param {Bool} _green Use `true` to enable writing to the green color
	/// channel.
	/// @param {Bool} _blue Use `true` to enable writing to the blue color
	/// channel.
	/// @param {Bool} _alpha Use `true` to enable writing to the alpha channel.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuColorWriteEnable = function (_red, _green, _blue, _alpha)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuColorWriteEnable is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuCullMode(_cullmode)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuCullMode} command into
	/// the queue.
	///
	/// @param {Constant.CullMode} _cullmode The new coll mode.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuCullMode = function (_cullmode)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuCullMode is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuDepth(_depth)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuDepth} command into
	/// the queue.
	///
	/// @param {Real} _depth The new z coordinate to draw sprites and text at.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuDepth = function (_depth)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuDepth is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuFog(_enable, _color, _start, _end)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuFog} command into the
	/// queue.
	///
	/// @param {Bool} _enable Use `true` to enable fog.
	/// @param {Constant.Color} _color The color of the fog.
	/// @param {Real} _start The distance from the camera at which the fog
	/// starts.
	/// @param {Real} _end The distance from the camera at which the fog reaches
	/// maximum intensity.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuFog = function (_enable, _color, _start, _end)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuFog is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuState(_state)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuState} command into the
	/// queue.
	///
	/// @param {Id.DsMap} _state The new GPU state.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuState = function (_state)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuState is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexFilter(_linear)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexFilter} command into
	/// the queue.
	///
	/// @param {Bool} _linear Use `true` to enable linear texture filtering.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexFilter = function (_linear)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexFilter is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexFilterExt(_name, _linear)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexFilterExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Bool} _linear Use `true` to enable linear texture filtering for
	/// the sampler.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexFilterExt = function (_name, _linear)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexFilterExt is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMaxAniso(_value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxAniso} command into
	/// the queue.
	///
	/// @param {Real} _value The maximum level of anisotropy.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMaxAniso = function (_value)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMaxAniso is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMaxAnisoExt(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxAnisoExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The maximum level of anisotropy.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMaxAnisoExt = function (_name, _value)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMaxAnisoExt is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMaxMip(_value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxMip} command into
	/// the queue.
	///
	/// @param {Real} _value The maximum mipmap level.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMaxMip = function (_value)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMaxMip is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMaxMipExt(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxMipExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The maximum mipmap level.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMaxMipExt = function (_name, _value)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMaxMipExt is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMinMip(_value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMinMip} command into
	/// the queue.
	///
	/// @param {Real} _value The minimum mipmap level.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMinMip = function (_value)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMinMip is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMinMipExt(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMinMipExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The minimum mipmap level.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMinMipExt = function (_name, _value)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMinMipExt is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMipBias(_value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipBias} command into
	/// the queue.
	///
	/// @param {Real} _value The mipmap bias.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMipBias = function (_value)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMipBias is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMipBiasExt(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipBiasExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The mipmap bias.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMipBiasExt = function (_name, _value)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMipBiasExt is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMipEnable(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipEnable} command
	/// into the queue.
	///
	/// @param {Bool} _enable Use `true` to enable mipmapping.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMipEnable = function (_enable)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMipEnable is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMipEnableExt(_name, _enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipEnableExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Bool} _enable Use `true` to enable mipmapping.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMipEnableExt = function (_name, _enable)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMipEnableExt is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMipFilter(_filter)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipFilter} command
	/// into the queue.
	///
	/// @param {Constant.MipFilter} _filter The mipmap filter.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMipFilter = function (_filter)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMipFilter is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexMipFilterExt(_name, _filter)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipFilterExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Constant.MipFilter} _filter The mipmap filter.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexMipFilterExt = function (_name, _filter)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexMipFilterExt is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexRepeat(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexRepeat} command into
	/// the queue.
	///
	/// @param {Bool} _enable Use `true` to enable texture repeat.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexRepeat = function (_enable)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexRepeat is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuTexRepeatExt(_name, _enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexRepeatExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Bool} _enable Use `true` to enable texture repeat.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuTexRepeatExt = function (_name, _enable)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuTexRepeatExt is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuZFunc(_func)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuZFunc} command into the
	/// queue.
	///
	/// @param {Constant.CmpFunc} _func The depth test function.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuZFunc = function (_func)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuZFunc is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuZTestEnable(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuZTestEnable} command into
	/// the queue.
	///
	/// @param {Bool} _enable Use `true` to enable testing against the detph
	/// buffer.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuZTestEnable = function (_enable)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuZTestEnable is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetGpuZWriteEnable(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuZWriteEnable} command
	/// into the queue.
	///
	/// @param {Bool} _enable Use `true` to enable writing to the depth buffer.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetGpuZWriteEnable = function (_enable)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetGpuZWriteEnable is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetMaterialProps(_materialPropertyBlock)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetMaterialProps} command into
	/// the queue.
	///
	/// @param {Struct.BBMOD_MaterialPropertyBlock} _materialPropertyBlock The
	/// material property block to set as the current one.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetMaterialProps = function (_materialPropertyBlock)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetMaterialProps is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetProjectionMatrix(_matrix)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetProjectionMatrix} command
	/// into the queue.
	///
	/// @param {Array<Real>} _matrix The new projection matrix.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetProjectionMatrix = function (_matrix)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetProjectionMatrix is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetSampler(_nameOrIndex, _texture)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetSampler} command into the
	/// queue.
	///
	/// @param {String, Real} _nameOrIndex The name or index of the sampler.
	/// @param {Pointer.Texture} _texture The new texture.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetSampler = function (_nameOrIndex, _texture)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetSampler is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetShader(_shader)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetShader} command into the
	/// queue.
	///
	/// @param {Asset.GMShader} _shader The shader to set.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetShader = function (_shader)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetShader is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformFloat(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _value The new uniform value.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformFloat = function (_name, _value)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformFloat is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformFloat2(_name, _v1, _v2)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat2} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformFloat2 = function (_name, _v1, _v2)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformFloat2 is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformFloat3(_name, _v1, _v2, _v3)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat3} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformFloat3 = function (_name, _v1, _v2, _v3)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformFloat3 is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformFloat4(_name, _v1, _v2, _v3, _v4)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat4} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	/// @param {Real} _v4 The value of the fourth component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformFloat4 = function (_name, _v1, _v2, _v3, _v4)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformFloat4 is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformFloatArray(_name, _array)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloatArray} command
	/// into the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Array<Real>} _array The array of values.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformFloatArray = function (_name, _array)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformFloatArray is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformInt(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt} command into the
	/// queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _value The new uniform value.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformInt = function (_name, _value)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformInt is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformInt2(_name, _v1, _v2)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt2} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformInt2 = function (_name, _v1, _v2)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformInt2 is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformInt3(_name, _v1, _v2, _v3)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt3} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformInt3 = function (_name, _v1, _v2, _v3)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformInt3 is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformInt4(_name, _v1, _v2, _v3, _v4)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt4} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	/// @param {Real} _v4 The value of the fourth component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformInt4 = function (_name, _v1, _v2, _v3, _v4)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformInt4 is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformIntArray(_name, _array)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformIntArray} command
	/// into the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Array<Real>} _array The array of values.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformIntArray = function (_name, _array)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformIntArray is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformMatrix(_name)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformMatrix} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformMatrix = function (_name)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformMatrix is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetUniformMatrixArray(_name, _array)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformMatrixArray} command
	/// into the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Array<Real>} _array The array of values.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetUniformMatrixArray = function (_name, _array)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetUniformMatrixArray is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetViewMatrix(_matrix)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetViewMatrix} command into the
	/// queue.
	///
	/// @param {Array<Real>} _matrix The new view matrix.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetViewMatrix = function (_matrix)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetViewMatrix is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SetWorldMatrix(_matrix)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetWorldMatrix} command into
	/// the queue.
	///
	/// @param {Array<Real>} _matrix The new world matrix.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SetWorldMatrix = function (_matrix)
	{
		__bbmod_warning("BBMOD_RenderQueue.SetWorldMatrix is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SubmitRenderQueue(_renderQueue)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SubmitRenderQueue} command
	/// into the queue.
	///
	/// @param {Struct.BBMOD_RenderQueue} _renderQueue The vertex buffer to submit.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SubmitRenderQueue = function (_renderQueue)
	{
		__bbmod_warning("BBMOD_RenderQueue.SubmitRenderQueue is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func SubmitVertexBuffer(_vertexBuffer, _prim, _texture)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SubmitVertexBuffer} command
	/// into the queue.
	///
	/// @param {Id.VertexBuffer} _vertexBuffer The vertex buffer to submit.
	/// @param {Constant.PrimitiveType} _prim Primitive type of the vertex
	/// buffer.
	/// @param {Pointer.Texture} _texture The texture to use.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @obsolete This method is obsolete. Use `Draw*` methods instead.
	static SubmitVertexBuffer = function (_vertexBuffer, _prim, _texture)
	{
		__bbmod_warning("BBMOD_RenderQueue.SubmitVertexBuffer is obsolete. Use Draw* methods instead.");
		return self;
	};

	/// @func is_empty()
	///
	/// @desc Returns whether this queue has no commands in any render pass.
	///
	/// @return {Bool} `true` if the queue is empty, otherwise `false`.
	static is_empty = function ()
	{
		gml_pragma("forceinline");
		return (__renderPasses == 0);
	};

	/// @func has_commands(_renderPass)
	///
	/// @desc Returns whether this queue has commands for a specific render pass.
	///
	/// @param {Enum.BBMOD_ERenderPass} _renderPass Render pass to check.
	///
	/// @return {Bool} `true` when the pass has commands, otherwise `false`.
	static has_commands = function (_renderPass)
	{
		gml_pragma("forceinline");
		return (__renderPasses & (1 << _renderPass)) ? true : false;
	};

	/// @func submit([_instances])
	///
	/// @desc Submits commands for the active render pass.
	///
	/// @param {Id.DsList<Id.Instance>} [_instances] Optional instance filter.
	/// When provided, draw commands are only submitted for matching instance IDs.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @see bbmod_render_pass_get
	static submit = function (_instances = undefined)
	{
		// Get current render pass
		var _currentPass = bbmod_render_pass_get();

		// Check if this render pass has any commands
		if (!(__renderPasses & (1 << _currentPass)))
		{
			return self;
		}

		// Use the grid for the current render pass only
		var _grid = __renderCommands[_currentPass];
		var _gridIndex = __index[_currentPass];
		var _lastMaterial = undefined;
		var _lastVertexFormat = undefined;

		// Cached shader and uniform locations (updated when material changes)
		var _shaderCurrent = undefined;
		var _uInstanceID = undefined;
		var _uMaterialIndex = undefined;
		var _uBones = undefined;
		var _uBatchData = undefined;
		var _uBaseOpacityUV = undefined;
		var _uDitherEnable = undefined;
		var _uDitherSeed = undefined;
		var _uDitherFade = undefined;

		// Sort grid by material hash (column 1) for better batching
		// Unused rows have infinity in column 1, so they sort to the end
		if (!__isSorted[_currentPass])
		{
			ds_grid_sort(_grid, 1, true);
			__isSorted[@ _currentPass] = true;
		}

		for (var _row = 0; _row < _gridIndex; ++_row)
		{
			var _commandType = _grid[# 0, _row];

			switch (_commandType)
			{
				case BBMOD_ERenderCommand.DrawMesh:
				{
					var _data = _grid[# 2, _row];
					var _id = _data[0];
					var _mesh = _data[1];
					var _material = _data[2];
					var _matrix = _data[3];
					var _ditherEnable = _data[4] ? 1.0 : 0.0;
					var _ditherFade = _data[5];

					if (_instances != undefined && ds_list_find_index(_instances, _id) == -1)
					{
						continue;
					}

					// Frustum culling
					if (global.__bbmodFrustumCulling && _mesh.BoundingSphereCenter != undefined)
					{
						var _center = _mesh.BoundingSphereCenter;
						var _centerX = _center.X;
						var _centerY = _center.Y;
						var _centerZ = _center.Z;

						// Transform center to world space
						var _worldX = _matrix[12] + _centerX * _matrix[0] + _centerY * _matrix[4] + _centerZ
							* _matrix[8];
						var _worldY = _matrix[13] + _centerX * _matrix[1] + _centerY * _matrix[5] + _centerZ
							* _matrix[9];
						var _worldZ = _matrix[14] + _centerX * _matrix[2] + _centerY * _matrix[6] + _centerZ
							* _matrix[10];

						// Get maximum scale from matrix
						var _scaleX = sqrt(_matrix[0] * _matrix[0] + _matrix[1] * _matrix[1] + _matrix[2] * _matrix[
							2]);
						var _scaleY = sqrt(_matrix[4] * _matrix[4] + _matrix[5] * _matrix[5] + _matrix[6] * _matrix[
							6]);
						var _scaleZ = sqrt(_matrix[8] * _matrix[8] + _matrix[9] * _matrix[9] + _matrix[10]
							* _matrix[10]);
						var _maxScale = max(_scaleX, _scaleY, _scaleZ);
						var _worldRadius = _mesh.BoundingSphereRadius * _maxScale;

						// Test visibility
						if (!sphere_is_visible(_worldX, _worldY, _worldZ, _worldRadius))
						{
							__bbmod_render_statistics_count(
								__BBMOD_ERenderStatisticsCounter.MeshDrawCallsFrustumCulled);
							continue;
						}
					}

					if (_ditherEnable > 0.0 && _ditherFade <= 0.0)
					{
						__bbmod_render_statistics_count(
							__BBMOD_ERenderStatisticsCounter.MeshDrawCallsDistanceCulled);
						continue;
					}

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial
						|| _mesh.VertexFormat != _lastVertexFormat)
					{
						if (!_material.apply(_mesh.VertexFormat))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = _mesh.VertexFormat;

						// Cache shader and uniform locations
						_shaderCurrent = shader_current();
						_uInstanceID = shader_get_uniform(_shaderCurrent, BBMOD_U_INSTANCE_ID);
						_uMaterialIndex = shader_get_uniform(_shaderCurrent, BBMOD_U_MATERIAL_INDEX);
						_uDitherEnable = shader_get_uniform(_shaderCurrent, BBMOD_U_DITHER_ENABLE);
						_uDitherSeed = shader_get_uniform(_shaderCurrent, BBMOD_U_DITHER_SEED);
						_uDitherFade = shader_get_uniform(_shaderCurrent, BBMOD_U_DITHER_FADE);
					}

					shader_set_uniform_f(
						_uInstanceID,
						((_id & $000000FF) >> 0) / 255,
						((_id & $0000FF00) >> 8) / 255,
						((_id & $00FF0000) >> 16) / 255,
						((_id & $FF000000) >> 24) / 255);
					matrix_set(matrix_world, _matrix);
					shader_set_uniform_f(
						_uMaterialIndex,
						_mesh.MaterialIndex);
					shader_set_uniform_f(_uDitherEnable, _ditherEnable);
					shader_set_uniform_f(_uDitherSeed, _id);
					shader_set_uniform_f(_uDitherFade, _ditherFade);

					__bbmod_render_statistics_count(
						__BBMOD_ERenderStatisticsCounter.MeshDrawCallsDrawn);

					vertex_submit(_mesh.VertexBuffer, _mesh.PrimitiveType, _material.BaseOpacity);
				}
				break;

				case BBMOD_ERenderCommand.DrawMeshAnimated:
				{
					var _data = _grid[# 2, _row];
					var _id = _data[0];
					var _mesh = _data[1];
					var _material = _data[2];
					var _matrix = _data[3];
					var _boneData = _data[4];
					var _ditherEnable = _data[5] ? 1.0 : 0.0;
					var _ditherFade = _data[6];

					if (_instances != undefined && ds_list_find_index(_instances, _id) == -1)
					{
						continue;
					}

					// Frustum culling
					if (global.__bbmodFrustumCulling && _mesh.BoundingSphereCenter != undefined)
					{
						var _center = _mesh.BoundingSphereCenter;
						var _centerX = _center.X;
						var _centerY = _center.Y;
						var _centerZ = _center.Z;

						// Transform center to world space
						var _worldX = _matrix[12] + _centerX * _matrix[0] + _centerY * _matrix[4] + _centerZ
							* _matrix[8];
						var _worldY = _matrix[13] + _centerX * _matrix[1] + _centerY * _matrix[5] + _centerZ
							* _matrix[9];
						var _worldZ = _matrix[14] + _centerX * _matrix[2] + _centerY * _matrix[6] + _centerZ
							* _matrix[10];

						// Get maximum scale from matrix
						var _scaleX = sqrt(_matrix[0] * _matrix[0] + _matrix[1] * _matrix[1] + _matrix[2] * _matrix[
							2]);
						var _scaleY = sqrt(_matrix[4] * _matrix[4] + _matrix[5] * _matrix[5] + _matrix[6] * _matrix[
							6]);
						var _scaleZ = sqrt(_matrix[8] * _matrix[8] + _matrix[9] * _matrix[9] + _matrix[10]
							* _matrix[10]);
						var _maxScale = max(_scaleX, _scaleY, _scaleZ);
						var _worldRadius = _mesh.BoundingSphereRadius * _maxScale;

						// Test visibility
						if (!sphere_is_visible(_worldX, _worldY, _worldZ, _worldRadius))
						{
							__bbmod_render_statistics_count(
								__BBMOD_ERenderStatisticsCounter.AnimatedMeshDrawCallsFrustumCulled);
							continue;
						}
					}

					if (_ditherEnable > 0.0 && _ditherFade <= 0.0)
					{
						__bbmod_render_statistics_count(
							__BBMOD_ERenderStatisticsCounter.AnimatedMeshDrawCallsDistanceCulled);
						continue;
					}

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial
						|| _mesh.VertexFormat != _lastVertexFormat)
					{
						if (!_material.apply(_mesh.VertexFormat))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = _mesh.VertexFormat;

						// Cache shader and uniform locations
						_shaderCurrent = shader_current();
						_uInstanceID = shader_get_uniform(_shaderCurrent, BBMOD_U_INSTANCE_ID);
						_uMaterialIndex = shader_get_uniform(_shaderCurrent, BBMOD_U_MATERIAL_INDEX);
						_uBones = shader_get_uniform(_shaderCurrent, BBMOD_U_BONES);
						_uDitherEnable = shader_get_uniform(_shaderCurrent, BBMOD_U_DITHER_ENABLE);
						_uDitherSeed = shader_get_uniform(_shaderCurrent, BBMOD_U_DITHER_SEED);
						_uDitherFade = shader_get_uniform(_shaderCurrent, BBMOD_U_DITHER_FADE);
					}

					shader_set_uniform_f(
						_uInstanceID,
						((_id & $000000FF) >> 0) / 255,
						((_id & $0000FF00) >> 8) / 255,
						((_id & $00FF0000) >> 16) / 255,
						((_id & $FF000000) >> 24) / 255);
					matrix_set(matrix_world, _matrix);
					shader_set_uniform_f(
						_uMaterialIndex,
						_mesh.MaterialIndex);
					shader_set_uniform_f(_uDitherEnable, _ditherEnable);
					shader_set_uniform_f(_uDitherSeed, _id);
					shader_set_uniform_f(_uDitherFade, _ditherFade);
					shader_set_uniform_f_array(
						_uBones,
						_boneData);

					__bbmod_render_statistics_count(
						__BBMOD_ERenderStatisticsCounter.AnimatedMeshDrawCallsDrawn);

					vertex_submit(_mesh.VertexBuffer, _mesh.PrimitiveType, _material.BaseOpacity);
				}
				break;

				case BBMOD_ERenderCommand.DrawMeshBatched:
				{
					var _data = _grid[# 2, _row];
					var _id = _data[0];
					var _mesh = _data[1];
					var _material = _data[2];
					var _matrix = _data[3];
					var _batchData = _data[4];
					var _dynamicBatch = _data[5];
					var _visibleInstancesHint = _data[6];
					var _ditherEnableSnapshot = _data[7];
					var _ditherValueSnapshot = _data[8];
					var _batchedInstancesExecuted = 0;

					////////////////////////////////////////////////////////////
					// Filter batch data by frustum visibility and instance IDs

					var _filterResult = _dynamicBatch.DataFilter(
						_mesh,
						_matrix,
						_batchData,
						_id,
						_instances,
						_visibleInstancesHint,
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

					if (_filterResult.SkipDraw)
					{
						continue;
					}

					if (_batchedInstancesExecuted <= 0)
					{
						continue;
					}

					////////////////////////////////////////////////////////////

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial
						|| _mesh.VertexFormat != _lastVertexFormat)
					{
						if (!_material.apply(_mesh.VertexFormat))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = _mesh.VertexFormat;

						// Cache shader and uniform locations
						_shaderCurrent = shader_current();
						_uInstanceID = shader_get_uniform(_shaderCurrent, BBMOD_U_INSTANCE_ID);
						_uMaterialIndex = shader_get_uniform(_shaderCurrent, BBMOD_U_MATERIAL_INDEX);
						_uBatchData = shader_get_uniform(_shaderCurrent, BBMOD_U_BATCH_DATA);
						_uDitherEnable = shader_get_uniform(_shaderCurrent, BBMOD_U_DITHER_ENABLE);
						_uDitherSeed = shader_get_uniform(_shaderCurrent, BBMOD_U_DITHER_SEED);
						_uDitherFade = shader_get_uniform(_shaderCurrent, BBMOD_U_DITHER_FADE);
					}

					if (is_real(_id))
					{
						shader_set_uniform_f(
							_uInstanceID,
							((_id & $000000FF) >> 0) / 255,
							((_id & $0000FF00) >> 8) / 255,
							((_id & $00FF0000) >> 16) / 255,
							((_id & $FF000000) >> 24) / 255);
					}
					shader_set_uniform_f(
						_uMaterialIndex,
						_mesh.MaterialIndex);
					shader_set_uniform_f(_uDitherEnable, _ditherEnableSnapshot ? 1.0 : 0.0);
					shader_set_uniform_f(_uDitherSeed, is_real(_id) ? _id : 0.0);
					shader_set_uniform_f(_uDitherFade, _ditherValueSnapshot);

					matrix_set(matrix_world, _matrix);

					var _primitiveType = _mesh.PrimitiveType;
					var _vertexBuffer = _mesh.VertexBuffer;

					__bbmod_render_statistics_count(
						__BBMOD_ERenderStatisticsCounter.BatchedMeshDrawCallsDrawn,
						_batchedInstancesExecuted);

					if (is_array(_batchData[0]))
					{
						var _dataIndex = 0;
						repeat(array_length(_batchData))
						{
							var _batchChunk = _batchData[_dataIndex];
							shader_set_uniform_f_array(
								_uBatchData,
								_batchChunk);
							++_dataIndex;
							vertex_submit(_vertexBuffer, _primitiveType, _material.BaseOpacity);
						}
					}
					else
					{
						shader_set_uniform_f_array(
							_uBatchData,
							_batchData);
						vertex_submit(_vertexBuffer, _primitiveType, _material.BaseOpacity);
					}
				}
				break;

				case BBMOD_ERenderCommand.DrawTerrain:
				{
					var _data = _grid[# 2, _row];
					var _id = _data[0];
					var _terrain = _data[1];

					if (_instances != undefined && ds_list_find_index(_instances, _id) == -1)
					{
						continue;
					}

					_terrain.submit();
					bbmod_material_reset();
				}
				break;

				case BBMOD_ERenderCommand.DrawSprite:
				{
					var _data = _grid[# 2, _row];
					var _material = _data[0];
					var _sprite = _data[1];
					var _subimg = _data[2];
					var _x = _data[3];
					var _y = _data[4];

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial || BBMOD_VFORMAT_DEFAULT != _lastVertexFormat)
					{
						if (!_material.apply(BBMOD_VFORMAT_DEFAULT))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = BBMOD_VFORMAT_DEFAULT;

						// Cache shader and uniform location
						_shaderCurrent = shader_current();
						_uBaseOpacityUV = shader_get_uniform(_shaderCurrent, BBMOD_U_BASE_OPACITY_UV);
					}

					var _uv = sprite_get_uvs(_sprite, _subimg);
					shader_set_uniform_f(
						_uBaseOpacityUV,
						_uv[0],
						_uv[1],
						_uv[2],
						_uv[3]);
					__bbmod_render_statistics_count(__BBMOD_ERenderStatisticsCounter.SpriteDrawCallsDrawn);
					draw_sprite(_sprite, _subimg, _x, _y);
				}
				break;

				case BBMOD_ERenderCommand.DrawSpriteExt:
				{
					var _data = _grid[# 2, _row];
					var _material = _data[0];
					var _sprite = _data[1];
					var _subimg = _data[2];
					var _x = _data[3];
					var _y = _data[4];
					var _xscale = _data[5];
					var _yscale = _data[6];
					var _rot = _data[7];
					var _col = _data[8];
					var _alpha = _data[9];

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial || BBMOD_VFORMAT_DEFAULT != _lastVertexFormat)
					{
						if (!_material.apply(BBMOD_VFORMAT_DEFAULT))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = BBMOD_VFORMAT_DEFAULT;

						// Cache shader and uniform location
						_shaderCurrent = shader_current();
						_uBaseOpacityUV = shader_get_uniform(_shaderCurrent, BBMOD_U_BASE_OPACITY_UV);
					}

					var _uv = sprite_get_uvs(_sprite, _subimg);
					shader_set_uniform_f(
						_uBaseOpacityUV,
						_uv[0],
						_uv[1],
						_uv[2],
						_uv[3]);
					__bbmod_render_statistics_count(__BBMOD_ERenderStatisticsCounter.SpriteDrawCallsDrawn);
					draw_sprite_ext(_sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _col, _alpha);
				}
				break;

				case BBMOD_ERenderCommand.DrawSpriteGeneral:
				{
					var _data = _grid[# 2, _row];
					var _material = _data[0];
					var _sprite = _data[1];
					var _subimg = _data[2];
					var _left = _data[3];
					var _top = _data[4];
					var _width = _data[5];
					var _height = _data[6];
					var _x = _data[7];
					var _y = _data[8];
					var _xscale = _data[9];
					var _yscale = _data[10];
					var _rot = _data[11];
					var _c1 = _data[12];
					var _c2 = _data[13];
					var _c3 = _data[14];
					var _c4 = _data[15];
					var _alpha = _data[16];

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial || BBMOD_VFORMAT_DEFAULT != _lastVertexFormat)
					{
						if (!_material.apply(BBMOD_VFORMAT_DEFAULT))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = BBMOD_VFORMAT_DEFAULT;

						// Cache shader and uniform location
						_shaderCurrent = shader_current();
						_uBaseOpacityUV = shader_get_uniform(_shaderCurrent, BBMOD_U_BASE_OPACITY_UV);
					}

					var _uv = sprite_get_uvs(_sprite, _subimg);
					shader_set_uniform_f(
						_uBaseOpacityUV,
						_uv[0],
						_uv[1],
						_uv[2],
						_uv[3]);
					__bbmod_render_statistics_count(__BBMOD_ERenderStatisticsCounter.SpriteDrawCallsDrawn);
					draw_sprite_general(_sprite, _subimg, _left, _top, _width, _height, _x, _y,
						_xscale, _yscale, _rot, _c1, _c2, _c3, _c4, _alpha);
				}
				break;

				case BBMOD_ERenderCommand.DrawSpritePart:
				{
					var _data = _grid[# 2, _row];
					var _material = _data[0];
					var _sprite = _data[1];
					var _subimg = _data[2];
					var _left = _data[3];
					var _top = _data[4];
					var _width = _data[5];
					var _height = _data[6];
					var _x = _data[7];
					var _y = _data[8];

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial || BBMOD_VFORMAT_DEFAULT != _lastVertexFormat)
					{
						if (!_material.apply(BBMOD_VFORMAT_DEFAULT))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = BBMOD_VFORMAT_DEFAULT;

						// Cache shader and uniform location
						_shaderCurrent = shader_current();
						_uBaseOpacityUV = shader_get_uniform(_shaderCurrent, BBMOD_U_BASE_OPACITY_UV);
					}

					var _uv = sprite_get_uvs(_sprite, _subimg);
					shader_set_uniform_f(
						_uBaseOpacityUV,
						_uv[0],
						_uv[1],
						_uv[2],
						_uv[3]);
					__bbmod_render_statistics_count(__BBMOD_ERenderStatisticsCounter.SpriteDrawCallsDrawn);
					draw_sprite_part(_sprite, _subimg, _left, _top, _width, _height, _x, _y);
				}
				break;

				case BBMOD_ERenderCommand.DrawSpritePartExt:
				{
					var _data = _grid[# 2, _row];
					var _material = _data[0];
					var _sprite = _data[1];
					var _subimg = _data[2];
					var _left = _data[3];
					var _top = _data[4];
					var _width = _data[5];
					var _height = _data[6];
					var _x = _data[7];
					var _y = _data[8];
					var _xscale = _data[9];
					var _yscale = _data[10];
					var _col = _data[11];
					var _alpha = _data[12];

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial || BBMOD_VFORMAT_DEFAULT != _lastVertexFormat)
					{
						if (!_material.apply(BBMOD_VFORMAT_DEFAULT))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = BBMOD_VFORMAT_DEFAULT;

						// Cache shader and uniform location
						_shaderCurrent = shader_current();
						_uBaseOpacityUV = shader_get_uniform(_shaderCurrent, BBMOD_U_BASE_OPACITY_UV);
					}

					var _uv = sprite_get_uvs(_sprite, _subimg);
					shader_set_uniform_f(
						_uBaseOpacityUV,
						_uv[0],
						_uv[1],
						_uv[2],
						_uv[3]);
					__bbmod_render_statistics_count(__BBMOD_ERenderStatisticsCounter.SpriteDrawCallsDrawn);
					draw_sprite_part_ext(_sprite, _subimg, _left, _top, _width, _height, _x, _y,
						_xscale, _yscale, _col, _alpha);
				}
				break;

				case BBMOD_ERenderCommand.DrawSpritePos:
				{
					var _data = _grid[# 2, _row];
					var _material = _data[0];
					var _sprite = _data[1];
					var _subimg = _data[2];
					var _x1 = _data[3];
					var _y1 = _data[4];
					var _x2 = _data[5];
					var _y2 = _data[6];
					var _x3 = _data[7];
					var _y3 = _data[8];
					var _x4 = _data[9];
					var _y4 = _data[10];
					var _alpha = _data[11];

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial || BBMOD_VFORMAT_DEFAULT != _lastVertexFormat)
					{
						if (!_material.apply(BBMOD_VFORMAT_DEFAULT))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = BBMOD_VFORMAT_DEFAULT;

						// Cache shader and uniform location
						_shaderCurrent = shader_current();
						_uBaseOpacityUV = shader_get_uniform(_shaderCurrent, BBMOD_U_BASE_OPACITY_UV);
					}

					var _uv = sprite_get_uvs(_sprite, _subimg);
					shader_set_uniform_f(
						_uBaseOpacityUV,
						_uv[0],
						_uv[1],
						_uv[2],
						_uv[3]);
					__bbmod_render_statistics_count(__BBMOD_ERenderStatisticsCounter.SpriteDrawCallsDrawn);
					draw_sprite_pos(_sprite, _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha);
				}
				break;

				case BBMOD_ERenderCommand.DrawSpriteStretched:
				{
					var _data = _grid[# 2, _row];
					var _material = _data[0];
					var _sprite = _data[1];
					var _subimg = _data[2];
					var _x = _data[3];
					var _y = _data[4];
					var _w = _data[5];
					var _h = _data[6];

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial || BBMOD_VFORMAT_DEFAULT != _lastVertexFormat)
					{
						if (!_material.apply(BBMOD_VFORMAT_DEFAULT))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = BBMOD_VFORMAT_DEFAULT;

						// Cache shader and uniform location
						_shaderCurrent = shader_current();
						_uBaseOpacityUV = shader_get_uniform(_shaderCurrent, BBMOD_U_BASE_OPACITY_UV);
					}

					var _uv = sprite_get_uvs(_sprite, _subimg);
					shader_set_uniform_f(
						_uBaseOpacityUV,
						_uv[0],
						_uv[1],
						_uv[2],
						_uv[3]);
					__bbmod_render_statistics_count(__BBMOD_ERenderStatisticsCounter.SpriteDrawCallsDrawn);
					draw_sprite_stretched(_sprite, _subimg, _x, _y, _w, _h);
				}
				break;

				case BBMOD_ERenderCommand.DrawSpriteStretchedExt:
				{
					var _data = _grid[# 2, _row];
					var _material = _data[0];
					var _sprite = _data[1];
					var _subimg = _data[2];
					var _x = _data[3];
					var _y = _data[4];
					var _w = _data[5];
					var _h = _data[6];
					var _col = _data[7];
					var _alpha = _data[8];

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial || BBMOD_VFORMAT_DEFAULT != _lastVertexFormat)
					{
						if (!_material.apply(BBMOD_VFORMAT_DEFAULT))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = BBMOD_VFORMAT_DEFAULT;

						// Cache shader and uniform location
						_shaderCurrent = shader_current();
						_uBaseOpacityUV = shader_get_uniform(_shaderCurrent, BBMOD_U_BASE_OPACITY_UV);
					}

					var _uv = sprite_get_uvs(_sprite, _subimg);
					shader_set_uniform_f(
						_uBaseOpacityUV,
						_uv[0],
						_uv[1],
						_uv[2],
						_uv[3]);
					__bbmod_render_statistics_count(__BBMOD_ERenderStatisticsCounter.SpriteDrawCallsDrawn);
					draw_sprite_stretched_ext(_sprite, _subimg, _x, _y, _w, _h, _col, _alpha);
				}
				break;

				case BBMOD_ERenderCommand.DrawSpriteTiled:
				{
					var _data = _grid[# 2, _row];
					var _material = _data[0];
					var _sprite = _data[1];
					var _subimg = _data[2];
					var _x = _data[3];
					var _y = _data[4];

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial || BBMOD_VFORMAT_DEFAULT != _lastVertexFormat)
					{
						if (!_material.apply(BBMOD_VFORMAT_DEFAULT))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = BBMOD_VFORMAT_DEFAULT;

						// Cache shader and uniform location
						_shaderCurrent = shader_current();
						_uBaseOpacityUV = shader_get_uniform(_shaderCurrent, BBMOD_U_BASE_OPACITY_UV);
					}

					var _uv = sprite_get_uvs(_sprite, _subimg);
					shader_set_uniform_f(
						_uBaseOpacityUV,
						_uv[0],
						_uv[1],
						_uv[2],
						_uv[3]);
					__bbmod_render_statistics_count(__BBMOD_ERenderStatisticsCounter.SpriteDrawCallsDrawn);
					draw_sprite_tiled(_sprite, _subimg, _x, _y);
				}
				break;

				case BBMOD_ERenderCommand.DrawSpriteTiledExt:
				{
					var _data = _grid[# 2, _row];
					var _material = _data[0];
					var _sprite = _data[1];
					var _subimg = _data[2];
					var _x = _data[3];
					var _y = _data[4];
					var _xscale = _data[5];
					var _yscale = _data[6];
					var _col = _data[7];
					var _alpha = _data[8];

					// Only apply material if it changed or vertex format changed
					if (_material != _lastMaterial || BBMOD_VFORMAT_DEFAULT != _lastVertexFormat)
					{
						if (!_material.apply(BBMOD_VFORMAT_DEFAULT))
						{
							continue;
						}
						_lastMaterial = _material;
						_lastVertexFormat = BBMOD_VFORMAT_DEFAULT;

						// Cache shader and uniform location
						_shaderCurrent = shader_current();
						_uBaseOpacityUV = shader_get_uniform(_shaderCurrent, BBMOD_U_BASE_OPACITY_UV);
					}

					var _uv = sprite_get_uvs(_sprite, _subimg);
					shader_set_uniform_f(
						_uBaseOpacityUV,
						_uv[0],
						_uv[1],
						_uv[2],
						_uv[3]);
					__bbmod_render_statistics_count(__BBMOD_ERenderStatisticsCounter.SpriteDrawCallsDrawn);
					draw_sprite_tiled_ext(_sprite, _subimg, _x, _y, _xscale, _yscale, _col, _alpha);
				}
				break;
			}

		}

		return self;
	};

	/// @func clear()
	///
	/// @desc Clears all queued commands for all render passes.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static clear = function ()
	{
		gml_pragma("forceinline");
		__renderPasses = 0;
		// Clear all render pass grids
		var i = 0;
		repeat(BBMOD_ERenderPass.SIZE)
		{
			__index[@ i] = 0;
			__isSorted[@ i] = true;
			++i;
		}
		return self;
	};

	/// @func destroy()
	///
	/// @desc Destroys internal command grids and unregisters the queue.
	///
	/// @return {Undefined} Returns `undefined`.
	static destroy = function ()
	{
		if (__renderCommands != undefined)
		{
			// Destroy all render pass grids
			var i = 0;
			repeat(BBMOD_ERenderPass.SIZE)
			{
				ds_grid_destroy(__renderCommands[i]);
				++i;
			}
			__renderCommands = undefined;
		}
		__bbmod_remove_render_queue(self);
		return undefined;
	};

	// Note: Render queues are now managed through BBMOD_ERenderQueue enum.
	// This constructor no longer automatically registers the queue.
}

/// @func __bbmod_add_render_queue(_renderQueue)
/// @deprecated This function is obsolete and no longer has any effect.
/// Render queues are now managed through the BBMOD_ERenderQueue enum.
/// @private
function __bbmod_add_render_queue(_renderQueue)
{
	gml_pragma("forceinline");
	// Obsolete - render queues are now fixed based on BBMOD_ERenderQueue
}

/// @func __bbmod_remove_render_queue(_renderQueue)
/// @deprecated This function is obsolete. Render queues are now managed through
/// the BBMOD_ERenderQueue enum.
/// @private
function __bbmod_remove_render_queue(_renderQueue)
{
	gml_pragma("forceinline");
	if (!is_struct(_renderQueue))
	{
		return;
	}

	var _key = ds_map_find_first(global.__bbmodRenderQueues);
	while (_key != undefined)
	{
		var _nextKey = ds_map_find_next(global.__bbmodRenderQueues, _key);
		if (global.__bbmodRenderQueues[?  _key] == _renderQueue)
		{
			ds_map_delete(global.__bbmodRenderQueues, _key);
			++global.__bbmodRenderQueuesVersion;
			break;
		}
		_key = _nextKey;
	}
}

/// @func __bbmod_reindex_render_queues()
/// @deprecated This function is obsolete and no longer has any effect.
/// Render queues are now managed through the BBMOD_ERenderQueue enum.
/// @private
function __bbmod_reindex_render_queues()
{
	gml_pragma("forceinline");
	// Obsolete - render queue order is now fixed based on BBMOD_ERenderQueue
}

/// @func bbmod_render_queue_get_default()
///
/// @desc Retrieves the default render queue (Opaque).
///
/// @return {Struct.BBMOD_RenderQueue} The default render queue.
///
/// @see BBMOD_RenderQueue
/// @see BBMOD_ERenderQueue
function bbmod_render_queue_get_default()
{
	gml_pragma("forceinline");
	return bbmod_render_queue_get(BBMOD_ERenderQueue.Opaque);
}

/// @func __bbmod_render_queues_init()
///
/// @desc Initializes the global render queues with default instances.
/// Called automatically during BBMOD initialization.
///
/// @private
function __bbmod_render_queues_init()
{
	gml_pragma("forceinline");

	var _renderQueues = bbmod_render_queues_get();
	var i = 0;
	repeat(array_length(_renderQueues))
	{
		_renderQueues[i++].destroy();
	}

	ds_map_clear(global.__bbmodRenderQueues);
	global.__bbmodRenderQueues[?  BBMOD_ERenderQueue.Terrain] = new BBMOD_RenderQueue("Terrain",
		BBMOD_ERenderQueue.Terrain);
	global.__bbmodRenderQueues[?  BBMOD_ERenderQueue.Opaque] = new BBMOD_RenderQueue("Opaque", BBMOD_ERenderQueue
		.Opaque);
	global.__bbmodRenderQueues[?  BBMOD_ERenderQueue.Transparent] = new BBMOD_RenderQueue("Transparent",
		BBMOD_ERenderQueue.Transparent);
	global.__bbmodRenderQueues[?  BBMOD_ERenderQueue.Sky] = new BBMOD_RenderQueue("Sky", BBMOD_ERenderQueue.Sky);
	++global.__bbmodRenderQueuesVersion;
}

// Initialize render queues immediately
__bbmod_render_queues_init();
