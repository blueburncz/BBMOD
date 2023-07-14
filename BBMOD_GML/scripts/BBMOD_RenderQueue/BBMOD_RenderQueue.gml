/// @module Core

/// @func bbmod_render_queues_get()
///
/// @desc Retrieves a read-only array of existing render queues, sorted by
/// their priority in an asceding order.
///
/// @return {Array<Struct.BBMOD_RenderQueue>} The array of render queues.
///
/// @see BBMOD_RenderQueue
function bbmod_render_queues_get()
{
	gml_pragma("forceinline");
	static _renderQueues = [];
	return _renderQueues;
}

/// @func BBMOD_RenderQueue([_name[, _priority]])
///
/// @implements {BBMOD_IMeshRenderQueue}
///
/// @desc A cointainer of render commands.
///
/// @param {String} [_name] The name of the render queue. Defaults to
/// "RenderQueue" + number of created render queues - 1 (e.g. "RenderQueue0",
/// "RenderQueue1" etc.) if `undefined`.
/// @param {Real} [_priority] The priority of the render queue. Defaults to 0.
///
/// @see bbmod_render_queue_get_default
/// @see BBMOD_ERenderCommand
function BBMOD_RenderQueue(_name=undefined, _priority=0) constructor
{
	static IdNext = 0;

	/// @var {String} The name of the render queue. This can be useful for
	/// debugging purposes.
	Name = _name ?? ("RenderQueue" + string(IdNext++));

	/// @var {Real} The priority of the render queue. Render queues with lower
	/// priority come first in the array returned by {@link bbmod_render_queues_get}.
	/// @readonly
	Priority = _priority;

	/// @var {Array<Array>}
	/// @see BBMOD_ERenderCommand
	/// @private
	__renderCommands = [];

	/// @var {Real}
	/// @private
	__index = 0;

	/// @var {Real} Render passes that the queue has commands for.
	/// @private
	__renderPasses = 0;

	/// @func __get_next(_size)
	///
	/// @desc Retreives next render command available to reuse.
	///
	/// @param {Real} _size The size of the render command.
	///
	/// @return {Array} The render command.
	///
	/// @private
	static __get_next = function (_size)
	{
		gml_pragma("forceinline");
		var _command;
		if (array_length(__renderCommands) > __index)
		{
			_command = __renderCommands[__index++];
			if (array_length(_command) < _size)
			{
				array_resize(_command, _size);
			}
		}
		else
		{
			_command = array_create(_size);
			array_push(__renderCommands, _command);
			++__index;
		}
		return _command;
	};

	static set_priority = function (_p)
	{
		gml_pragma("forceinline");
		Priority = _p;
		__bbmod_reindex_render_queues();
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
	static ApplyMaterial = function (_material, _vertexFormat, _enabledPasses=~0)
	{
		gml_pragma("forceinline");
		__renderPasses |= _material.RenderPass;
		var _command = __get_next(5);
		_command[@ 0] = BBMOD_ERenderCommand.ApplyMaterial;
		_command[@ 1] = global.__bbmodMaterialProps;
		_command[@ 2] = _vertexFormat;
		_command[@ 3] = _material;
		_command[@ 4] = _enabledPasses;
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
	static ApplyMaterialProps = function (_materialPropertyBlock)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.ApplyMaterialProps;
		_command[@ 1] = _materialPropertyBlock;
		return self;
	};

	/// @func BeginConditionalBlock()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.BeginConditionalBlock} command
	/// into the queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static BeginConditionalBlock = function ()
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(1);
		_command[@ 0] = BBMOD_ERenderCommand.BeginConditionalBlock;
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
	static CheckRenderPass = function (_passes)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.CheckRenderPass;
		_command[@ 1] = _passes;
		return self;
	};

	static DrawMesh = function (_mesh, _material, _matrix)
	{
		gml_pragma("forceinline");
		__renderPasses |= _material.RenderPass;
		var _command = __get_next(6);
		_command[@ 0] = BBMOD_ERenderCommand.DrawMesh;
		_command[@ 1] = global.__bbmodInstanceID;
		_command[@ 2] = global.__bbmodMaterialProps;
		_command[@ 3] = _mesh;
		_command[@ 4] = _material;
		_command[@ 5] = _matrix;
		return self;
	};

	static DrawMeshAnimated = function (_mesh, _material, _matrix, _boneTransform)
	{
		gml_pragma("forceinline");
		__renderPasses |= _material.RenderPass;
		var _command = __get_next(7);
		_command[@ 0] = BBMOD_ERenderCommand.DrawMeshAnimated;
		_command[@ 1] = global.__bbmodInstanceID;
		_command[@ 2] = global.__bbmodMaterialProps;
		_command[@ 3] = _mesh;
		_command[@ 4] = _material;
		_command[@ 5] = _matrix;
		_command[@ 6] = _boneTransform;
		return self;
	};

	static DrawMeshBatched = function (_mesh, _material, _matrix, _batchData)
	{
		gml_pragma("forceinline");
		__renderPasses |= _material.RenderPass;
		var _command = __get_next(7);
		_command[@ 0] = BBMOD_ERenderCommand.DrawMeshBatched;
		_command[@ 1] = global.__bbmodInstanceIDBatch ?? global.__bbmodInstanceID;
		_command[@ 2] = global.__bbmodMaterialProps;
		_command[@ 3] = _mesh;
		_command[@ 4] = _material;
		_command[@ 5] = _matrix;
		_command[@ 6] = _batchData;
		return self;
	};

	/// @func DrawSprite(_sprite, _subimg, _x, _y)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSprite} command into the
	/// queue.
	///
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSprite = function (_sprite, _subimg, _x, _y)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(5);
		_command[@ 0] = BBMOD_ERenderCommand.DrawSprite;
		_command[@ 1] = _sprite;
		_command[@ 2] = _subimg;
		_command[@ 3] = _x;
		_command[@ 4] = _y;
		return self;
	};

	/// @func DrawSpriteExt(_sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _col, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteExt} command into the
	/// queue.
	///
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
		_sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _col, _alpha)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(10);
		_command[@ 0] = BBMOD_ERenderCommand.DrawSpriteExt;
		_command[@ 1] = _sprite;
		_command[@ 2] = _subimg;
		_command[@ 3] = _x;
		_command[@ 4] = _y;
		_command[@ 5] = _xscale;
		_command[@ 6] = _yscale;
		_command[@ 7] = _rot;
		_command[@ 8] = _col;
		_command[@ 9] = _alpha;
		return self;
	};

	/// @func DrawSpriteGeneral(_sprite, _subimg, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _rot, _c1, _c2, _c3, _c4, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteGeneral} command into
	/// the queue.
	///
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
		_sprite, _subimg, _left, _top, _width, _height, _x, _y, _xscale, _yscale,
		_rot, _c1, _c2, _c3, _c4, _alpha)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(17);
		_command[@  0] = BBMOD_ERenderCommand.DrawSpriteGeneral;
		_command[@  1] = _sprite;
		_command[@  2] = _subimg;
		_command[@  3] = _left;
		_command[@  4] = _top;
		_command[@  5] = _width;
		_command[@  6] = _height;
		_command[@  7] = _x;
		_command[@  8] = _y;
		_command[@  9] = _xscale;
		_command[@ 10] = _yscale;
		_command[@ 11] = _rot;
		_command[@ 12] = _c1;
		_command[@ 13] = _c2;
		_command[@ 14] = _c3;
		_command[@ 15] = _c4;
		_command[@ 16] = _alpha;
		return self;
	};

	/// @func DrawSpritePart(_sprite, _subimg, _left, _top, _width, _height, _x, _y)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpritePart} command into
	/// the queue.
	///
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
		_sprite, _subimg, _left, _top, _width, _height, _x, _y)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(9);
		_command[@ 0] = BBMOD_ERenderCommand.DrawSpritePart;
		_command[@ 1] = _sprite;
		_command[@ 2] = _subimg;
		_command[@ 3] = _left;
		_command[@ 4] = _top;
		_command[@ 5] = _width;
		_command[@ 6] = _height;
		_command[@ 7] = _x;
		_command[@ 8] = _y;
		return self;
	};

	/// @func DrawSpritePartExt(_sprite, _subimg, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _col, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpritePartExt} command into
	/// the queue.
	///
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
		_sprite, _subimg, _left, _top, _width, _height, _x, _y, _xscale, _yscale,
		_col, _alpha)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(13);
		_command[@  0] = BBMOD_ERenderCommand.DrawSpritePartExt;
		_command[@  1] = _sprite;
		_command[@  2] = _subimg;
		_command[@  3] = _left;
		_command[@  4] = _top;
		_command[@  5] = _width;
		_command[@  6] = _height;
		_command[@  7] = _x;
		_command[@  8] = _y;
		_command[@  9] = _xscale;
		_command[@ 10] = _yscale;
		_command[@ 11] = _col;
		_command[@ 12] = _alpha;
		return self;
	};

	/// @func DrawSpritePos(_sprite, _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpritePos} command into the
	/// queue.
	///
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
		_sprite, _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(12);
		_command[@  0] = BBMOD_ERenderCommand.DrawSpritePos;
		_command[@  1] = _sprite;
		_command[@  2] = _subimg;
		_command[@  3] = _x1;
		_command[@  4] = _y1;
		_command[@  5] = _x2;
		_command[@  6] = _y2;
		_command[@  7] = _x3;
		_command[@  8] = _y3;
		_command[@  9] = _x4;
		_command[@ 10] = _y4;
		_command[@ 11] = _alpha;
		return self;
	};

	/// @func DrawSpriteStretched(_sprite, _subimg, _x, _y, _w, _h)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteStretched} command
	/// into the queue.
	///
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	/// @param {Real} _w The width of the area the stretched sprite will occupy.
	/// @param {Real} _h The height of the area the stretched sprite will occupy.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSpriteStretched = function (_sprite, _subimg, _x, _y, _w, _h)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(7);
		_command[@ 0] = BBMOD_ERenderCommand.DrawSpriteStretched;
		_command[@ 1] = _sprite;
		_command[@ 2] = _subimg;
		_command[@ 3] = _x;
		_command[@ 4] = _y;
		_command[@ 5] = _w;
		_command[@ 6] = _h;
		return self;
	};

	/// @func DrawSpriteStretchedExt(_sprite, _subimg, _x, _y, _w, _h, _col, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteStretchedExt} command
	/// into the queue.
	///
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
		_sprite, _subimg, _x, _y, _w, _h, _col, _alpha)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(9);
		_command[@ 0] = BBMOD_ERenderCommand.DrawSpriteStretchedExt;
		_command[@ 1] = _sprite;
		_command[@ 2] = _subimg;
		_command[@ 3] = _x;
		_command[@ 4] = _y;
		_command[@ 5] = _w;
		_command[@ 6] = _h;
		_command[@ 7] = _col;
		_command[@ 8] = _alpha;
		return self;
	};

	/// @func DrawSpriteTiled(_sprite, _subimg, _x, _y)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteTiled} command into
	/// the queue.
	///
	/// @param {Asset.GMSprite} _sprite The sprite to draw.
	/// @param {Real} _subimg The sub-image of the sprite to draw.
	/// @param {Real} _x The x coordinate of where to draw the sprite.
	/// @param {Real} _y The y coordinate of where to draw the sprite.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static DrawSpriteTiled = function (_sprite, _subimg, _x, _y)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(5);
		_command[@ 0] = BBMOD_ERenderCommand.DrawSpriteTiled;
		_command[@ 1] = _sprite;
		_command[@ 2] = _subimg;
		_command[@ 3] = _x;
		_command[@ 4] = _y;
		return self;
	};

	/// @func DrawSpriteTiledExt(_sprite, _subimg, _x, _y, _xscale, _yscale, _col, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawSpriteTiledExt} command
	/// into the queue.
	///
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
		_sprite, _subimg, _x, _y, _xscale, _yscale, _col, _alpha)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(9);
		_command[@ 0] = BBMOD_ERenderCommand.DrawSpriteTiledExt;
		_command[@ 1] = _sprite;
		_command[@ 2] = _subimg;
		_command[@ 3] = _x;
		_command[@ 4] = _y;
		_command[@ 5] = _xscale;
		_command[@ 6] = _yscale;
		_command[@ 7] = _col;
		_command[@ 8] = _alpha;
		return self;
	};

	/// @func EndConditionalBlock()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.EndConditionalBlock} command
	/// into the queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static EndConditionalBlock = function ()
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(1);
		_command[@ 0] = BBMOD_ERenderCommand.EndConditionalBlock;
		return self;
	};

	/// @func PopGpuState()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.PopGpuState} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static PopGpuState = function ()
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(1);
		_command[@ 0] = BBMOD_ERenderCommand.PopGpuState;
		return self;
	};

	/// @func PushGpuState()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.PushGpuState} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static PushGpuState = function ()
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(1);
		_command[@ 0] = BBMOD_ERenderCommand.PushGpuState;
		return self;
	};

	/// @func ResetMaterial()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.ResetMaterial} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static ResetMaterial = function ()
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(1);
		_command[@ 0] = BBMOD_ERenderCommand.ResetMaterial;
		return self;
	};

	/// @func ResetMaterialProps()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.ResetMaterialProps} command
	/// into the queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static ResetMaterialProps = function ()
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(1);
		_command[@ 0] = BBMOD_ERenderCommand.ResetMaterialProps;
		return self;
	};

	/// @func ResetShader()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.ResetShader} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static ResetShader = function ()
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(1);
		_command[@ 0] = BBMOD_ERenderCommand.ResetShader;
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
	static SetGpuAlphaTestEnable = function (_enable)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuAlphaTestEnable;
		_command[@ 1] = _enable;
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
	static SetGpuAlphaTestRef = function (_value)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuAlphaTestRef;
		_command[@ 1] = _value;
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
	static SetGpuBlendEnable = function (_enable)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuBlendEnable;
		_command[@ 1] = _enable;
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
	static SetGpuBlendMode = function (_blendmode)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuBlendMode;
		_command[@ 1] = _blendmode;
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
	static SetGpuBlendModeExt = function (_src, _dest)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuBlendModeExt;
		_command[@ 1] = _src;
		_command[@ 2] = _dest;
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
	static SetGpuBlendModeExtSepAlpha = function (_src, _dest, _srcalpha, _destalpha)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(5);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuBlendModeExtSepAlpha;
		_command[@ 1] = _src;
		_command[@ 2] = _dest;
		_command[@ 3] = _srcalpha;
		_command[@ 4] = _destalpha;
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
	static SetGpuColorWriteEnable = function (_red, _green, _blue, _alpha)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(5);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuColorWriteEnable;
		_command[@ 1] = _red;
		_command[@ 2] = _green;
		_command[@ 3] = _blue;
		_command[@ 4] = _alpha;
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
	static SetGpuCullMode = function (_cullmode)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuCullMode;
		_command[@ 1] = _cullmode;
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
	static SetGpuFog = function (_enable, _color, _start, _end)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(5);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuFog;
		_command[@ 1] = _enable;
		_command[@ 2] = _color;
		_command[@ 3] = _start;
		_command[@ 4] = _end;
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
	static SetGpuState = function (_state)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuState;
		_command[@ 1] = _state;
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
	static SetGpuTexFilter = function (_linear)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexFilter;
		_command[@ 1] = _linear;
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
	static SetGpuTexFilterExt = function (_name, _linear)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexFilterExt;
		_command[@ 1] = _name;
		_command[@ 2] = _linear;
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
	static SetGpuTexMaxAniso = function (_value)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMaxAniso;
		_command[@ 1] = _value;
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
	static SetGpuTexMaxAnisoExt = function (_name, _value)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMaxAnisoExt;
		_command[@ 1] = _name;
		_command[@ 2] = _value;
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
	static SetGpuTexMaxMip = function (_value)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMaxMip;
		_command[@ 1] = _value;
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
	static SetGpuTexMaxMipExt = function (_name, _value)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMaxMipExt;
		_command[@ 1] = _name;
		_command[@ 2] = _value;
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
	static SetGpuTexMinMip = function (_value)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMinMip;
		_command[@ 1] = _value;
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
	static SetGpuTexMinMipExt = function (_name, _value)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMinMipExt;
		_command[@ 1] = _name;
		_command[@ 2] = _value;
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
	static SetGpuTexMipBias = function (_value)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMipBias;
		_command[@ 1] = _value;
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
	static SetGpuTexMipBiasExt = function (_name, _value)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMipBiasExt;
		_command[@ 1] = _name;
		_command[@ 2] = _value;
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
	static SetGpuTexMipEnable = function (_enable)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMipEnable;
		_command[@ 1] = _enable;
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
	static SetGpuTexMipEnableExt = function (_name, _enable)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMipEnableExt;
		_command[@ 1] = _name;
		_command[@ 2] = _enable;
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
	static SetGpuTexMipFilter = function (_filter)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMipFilter;
		_command[@ 1] = _filter;
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
	static SetGpuTexMipFilterExt = function (_name, _filter)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexMipFilterExt;
		_command[@ 1] = _name;
		_command[@ 2] = _filter;
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
	static SetGpuTexRepeat = function (_enable)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexRepeat;
		_command[@ 1] = _enable;
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
	static SetGpuTexRepeatExt = function (_name, _enable)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuTexRepeatExt;
		_command[@ 1] = _name;
		_command[@ 2] = _enable;
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
	static SetGpuZFunc = function (_func)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuZFunc;
		_command[@ 1] = _func;
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
	static SetGpuZTestEnable = function (_enable)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuZTestEnable;
		_command[@ 1] = _enable;
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
	static SetGpuZWriteEnable = function (_enable)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetGpuZWriteEnable;
		_command[@ 1] = _enable;
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
	static SetMaterialProps = function (_materialPropertyBlock)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetMaterialProps;
		_command[@ 1] = _materialPropertyBlock;
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
	static SetProjectionMatrix = function (_matrix)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetProjectionMatrix;
		_command[@ 1] = _matrix;
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
	static SetSampler = function (_nameOrIndex, _texture)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetSampler;
		_command[@ 1] = _nameOrIndex;
		_command[@ 2] = _texture;
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
	static SetShader = function (_shader)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetShader;
		_command[@ 1] = _shader;
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
	static SetUniformFloat = function (_name, _value)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformFloat;
		_command[@ 1] = _name;
		_command[@ 2] = _value;
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
	static SetUniformFloat2 = function (_name, _v1, _v2)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(4);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformFloat2;
		_command[@ 1] = _name;
		_command[@ 2] = _v1;
		_command[@ 3] = _v2;
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
	static SetUniformFloat3 = function (_name, _v1, _v2, _v3)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(5);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformFloat3;
		_command[@ 1] = _name;
		_command[@ 2] = _v1;
		_command[@ 3] = _v2;
		_command[@ 4] = _v3;
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
	static SetUniformFloat4 = function (_name, _v1, _v2, _v3, _v4)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(6);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformFloat4;
		_command[@ 1] = _name;
		_command[@ 2] = _v1;
		_command[@ 3] = _v2;
		_command[@ 4] = _v3;
		_command[@ 5] = _v4;
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
	static SetUniformFloatArray = function (_name, _array)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformFloatArray;
		_command[@ 1] = _name;
		_command[@ 2] = _array;
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
	static SetUniformInt = function (_name, _value)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformInt;
		_command[@ 1] = _name;
		_command[@ 2] = _value;
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
	static SetUniformInt2 = function (_name, _v1, _v2)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(4);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformInt2;
		_command[@ 1] = _name;
		_command[@ 2] = _v1;
		_command[@ 3] = _v2;
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
	static SetUniformInt3 = function (_name, _v1, _v2, _v3)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(5);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformInt3;
		_command[@ 1] = _name;
		_command[@ 2] = _v1;
		_command[@ 3] = _v2;
		_command[@ 4] = _v3;
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
	static SetUniformInt4 = function (_name, _v1, _v2, _v3, _v4)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(6);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformInt4;
		_command[@ 1] = _name;
		_command[@ 2] = _v1;
		_command[@ 3] = _v2;
		_command[@ 4] = _v3;
		_command[@ 5] = _v4;
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
	static SetUniformIntArray = function (_name, _array)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformIntArray;
		_command[@ 1] = _name;
		_command[@ 2] = _array;
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
	static SetUniformMatrix = function (_name)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformMatrix;
		_command[@ 1] = _name;
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
	static SetUniformMatrixArray = function (_name, _array)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(3);
		_command[@ 0] = BBMOD_ERenderCommand.SetUniformMatrixArray;
		_command[@ 1] = _name;
		_command[@ 2] = _array;
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
	static SetViewMatrix = function (_matrix)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetViewMatrix;
		_command[@ 1] = _matrix;
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
	static SetWorldMatrix = function (_matrix)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SetWorldMatrix;
		_command[@ 1] = _matrix;
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
	static SubmitRenderQueue = function (_renderQueue)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(2);
		_command[@ 0] = BBMOD_ERenderCommand.SubmitRenderQueue;
		_command[@ 1] = _renderQueue;
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
	static SubmitVertexBuffer = function (_vertexBuffer, _prim, _texture)
	{
		gml_pragma("forceinline");
		__renderPasses |= 0xFFFFFFFF;
		var _command = __get_next(4);
		_command[@ 0] = BBMOD_ERenderCommand.SubmitVertexBuffer;
		_command[@ 1] = _vertexBuffer;
		_command[@ 2] = _prim;
		_command[@ 3] = _texture;
		return self;
	};

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
		var _condition = false;
		var _skipCounter = 0;
		var _matchCounter = 0;

		repeat (__index)
		{
			var _command = _renderCommands[_commandIndex++];
			var i = 0;
			var _commandType = _command[i++];

			if (_skipCounter > 0)
			{
				switch (_commandType)
				{
				case BBMOD_ERenderCommand.BeginConditionalBlock:
					++_skipCounter;
					break;

				case BBMOD_ERenderCommand.EndConditionalBlock:
					--_skipCounter;
					break;
				}

				continue;
			}

			switch (_commandType)
			{
			case BBMOD_ERenderCommand.ApplyMaterial:
				{
					var _materialPropsOld = global.__bbmodMaterialProps;
					global.__bbmodMaterialProps = _command[i++];
					var _vertexFormat = _command[i++];
					var _material = _command[i++];
					var _enabledPasses = _command[i++];
					if (((1 << bbmod_render_pass_get()) & _enabledPasses) == 0
						|| !_material.apply(_vertexFormat))
					{
						global.__bbmodMaterialProps = _materialPropsOld;
						_condition = false;
						continue;
					}
					global.__bbmodMaterialProps = _materialPropsOld;
				}
				break;

			case BBMOD_ERenderCommand.ApplyMaterialProps:
				_command[i++].apply();
				break;

			case BBMOD_ERenderCommand.BeginConditionalBlock:
				if (!_condition)
				{
					++_skipCounter;
				}
				else
				{
					++_matchCounter;
				}
				break;

			case BBMOD_ERenderCommand.CheckRenderPass:
				if (((1 << bbmod_render_pass_get()) & _command[i++]) == 0)
				{
					_condition = false;
					continue;
				}
				break;

			case BBMOD_ERenderCommand.DrawMesh:
				{
					var _id = _command[1];
					var _materialProps = _command[2];
					var _mesh = _command[3];
					var _material = _command[4];
					var _matrix = _command[5];

					var _materialPropsOld = global.__bbmodMaterialProps;
					global.__bbmodMaterialProps = _materialProps;

					if ((_instances != undefined && ds_list_find_index(_instances, _id) == -1)
						|| !_material.apply(_mesh.VertexFormat))
					{
						global.__bbmodMaterialProps = _materialPropsOld;
						_condition = false;
						continue;
					}

					with (BBMOD_SHADER_CURRENT)
					{
						set_instance_id(_id);
						matrix_set(matrix_world, _matrix);
						set_material_index(_mesh.MaterialIndex);
					}

					vertex_submit(_mesh.VertexBuffer, _mesh.PrimitiveType, _material.BaseOpacity);

					global.__bbmodMaterialProps = _materialPropsOld;
				}
				break;

			case BBMOD_ERenderCommand.DrawMeshAnimated:
				{
					var _id = _command[1];
					var _materialProps = _command[2];
					var _mesh = _command[3];
					var _material = _command[4];
					var _matrix = _command[5];
					var _boneData = _command[6];

					var _materialPropsOld = global.__bbmodMaterialProps;
					global.__bbmodMaterialProps = _materialProps;

					if ((_instances != undefined && ds_list_find_index(_instances, _id) == -1)
						|| !_material.apply(_mesh.VertexFormat))
					{
						global.__bbmodMaterialProps = _materialPropsOld;
						_condition = false;
						continue;
					}

					with (BBMOD_SHADER_CURRENT)
					{
						set_instance_id(_id);
						matrix_set(matrix_world, _matrix);
						set_material_index(_mesh.MaterialIndex);
						set_bones(_boneData);
					}

					vertex_submit(_mesh.VertexBuffer, _mesh.PrimitiveType, _material.BaseOpacity);

					global.__bbmodMaterialProps = _materialPropsOld;
				}
				break;

			case BBMOD_ERenderCommand.DrawMeshBatched:
				{
					var _id = _command[1];
					var _materialProps = _command[2];
					var _mesh = _command[3];
					var _material = _command[4];
					var _matrix = _command[5];
					var _batchData = _command[6];

					var _materialPropsOld = global.__bbmodMaterialProps;
					global.__bbmodMaterialProps = _materialProps;

					if (!_material.apply(_mesh.VertexFormat))
					{
						global.__bbmodMaterialProps = _materialPropsOld;
						_condition = false;
						continue;
					}

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
								global.__bbmodMaterialProps = _materialPropsOld;
								_condition = false;
								continue;
							}
						}
						else
						{
							////////////////////////////////////////////////////
							// _id is a single ID
							if (ds_list_find_index(_instances, _id) == -1)
							{
								global.__bbmodMaterialProps = _materialPropsOld;
								_condition = false;
								continue;
							}
						}
					}

					////////////////////////////////////////////////////////////

					with (BBMOD_SHADER_CURRENT)
					{
						if (is_real(_id))
						{
							set_instance_id(_id);
						}
						set_material_index(_mesh.MaterialIndex);
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

					global.__bbmodMaterialProps = _materialPropsOld;
				}
				break;

			case BBMOD_ERenderCommand.DrawSprite:
				{
					var _sprite = _command[i++];
					var _subimg = _command[i++];
					var _x = _command[i++];
					var _y = _command[i++];
					draw_sprite(_sprite, _subimg, _x, _y);
				}
				break;

			case BBMOD_ERenderCommand.DrawSpriteExt:
				{
					var _sprite = _command[i++];
					var _subimg = _command[i++];
					var _x = _command[i++];
					var _y = _command[i++];
					var _xscale = _command[i++];
					var _yscale = _command[i++];
					var _rot = _command[i++];
					var _col = _command[i++];
					var _alpha = _command[i++];
					draw_sprite_ext(_sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _col, _alpha);
				}
				break;

			case BBMOD_ERenderCommand.DrawSpriteGeneral:
				{
					var _sprite = _command[i++];
					var _subimg = _command[i++];
					var _left = _command[i++];
					var _top = _command[i++];
					var _width = _command[i++];
					var _height = _command[i++];
					var _x = _command[i++];
					var _y = _command[i++];
					var _xscale = _command[i++];
					var _yscale = _command[i++];
					var _rot = _command[i++];
					var _c1 = _command[i++];
					var _c2 = _command[i++];
					var _c3 = _command[i++];
					var _c4 = _command[i++];
					var _alpha = _command[i++];
					draw_sprite_general(_sprite, _subimg, _left, _top, _width, _height, _x, _y,
						_xscale, _yscale, _rot, _c1, _c2, _c3, _c4, _alpha);
				}
				break;

			case BBMOD_ERenderCommand.DrawSpritePart:
				{
					var _sprite = _command[i++];
					var _subimg = _command[i++];
					var _left = _command[i++];
					var _top = _command[i++];
					var _width = _command[i++];
					var _height = _command[i++];
					var _x = _command[i++];
					var _y = _command[i++];
					draw_sprite_part(_sprite, _subimg, _left, _top, _width, _height, _x, _y);
				}
				break;

			case BBMOD_ERenderCommand.DrawSpritePartExt:
				{
					var _sprite = _command[i++];
					var _subimg = _command[i++];
					var _left = _command[i++];
					var _top = _command[i++];
					var _width = _command[i++];
					var _height = _command[i++];
					var _x = _command[i++];
					var _y = _command[i++];
					var _xscale = _command[i++];
					var _yscale = _command[i++];
					var _col = _command[i++];
					var _alpha = _command[i++];
					draw_sprite_part_ext(_sprite, _subimg, _left, _top, _width, _height, _x, _y,
						_xscale, _yscale, _col, _alpha);
				}
				break;

			case BBMOD_ERenderCommand.DrawSpritePos:
				{
					var _sprite = _command[i++];
					var _subimg = _command[i++];
					var _x1 = _command[i++];
					var _y1 = _command[i++];
					var _x2 = _command[i++];
					var _y2 = _command[i++];
					var _x3 = _command[i++];
					var _y3 = _command[i++];
					var _x4 = _command[i++];
					var _y4 = _command[i++];
					var _alpha = _command[i++];
					draw_sprite_pos(_sprite, _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha);
				}
				break;

			case BBMOD_ERenderCommand.DrawSpriteStretched:
				{
					var _sprite = _command[i++];
					var _subimg = _command[i++];
					var _x = _command[i++];
					var _y = _command[i++];
					var _w = _command[i++];
					var _h = _command[i++];
					draw_sprite_stretched(_sprite, _subimg, _x, _y, _w, _h);
				}
				break;

			case BBMOD_ERenderCommand.DrawSpriteStretchedExt:
				{
					var _sprite = _command[i++];
					var _subimg = _command[i++];
					var _x = _command[i++];
					var _y = _command[i++];
					var _w = _command[i++];
					var _h = _command[i++];
					var _col = _command[i++];
					var _alpha = _command[i++];
					draw_sprite_stretched_ext(_sprite, _subimg, _x, _y, _w, _h, _col, _alpha);
				}
				break;

			case BBMOD_ERenderCommand.DrawSpriteTiled:
				{
					var _sprite = _command[i++];
					var _subimg = _command[i++];
					var _x = _command[i++];
					var _y = _command[i++];
					draw_sprite_tiled(_sprite, _subimg, _x, _y);
				}
				break;

			case BBMOD_ERenderCommand.DrawSpriteTiledExt:
				{
					var _sprite = _command[i++];
					var _subimg = _command[i++];
					var _x = _command[i++];
					var _y = _command[i++];
					var _xscale = _command[i++];
					var _yscale = _command[i++];
					var _col = _command[i++];
					var _alpha = _command[i++];
					draw_sprite_tiled_ext(_sprite, _subimg, _x, _y, _xscale, _yscale, _col, _alpha);
				}
				break;

			case BBMOD_ERenderCommand.EndConditionalBlock:
				if (--_matchCounter < 0)
				{
					show_error("Found unmatching end of conditional block in render queue " + Name + "!", true);
				}
				break;

			case BBMOD_ERenderCommand.PopGpuState:
				gpu_pop_state();
				break;

			case BBMOD_ERenderCommand.PushGpuState:
				gpu_push_state();
				break;

			case BBMOD_ERenderCommand.ResetMaterial:
				bbmod_material_reset();
				break;

			case BBMOD_ERenderCommand.ResetMaterialProps:
				bbmod_material_props_reset();
				break;

			case BBMOD_ERenderCommand.ResetShader:
				shader_reset();
				break;

			case BBMOD_ERenderCommand.SetGpuAlphaTestEnable:
				gpu_set_alphatestenable(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuAlphaTestRef:
				gpu_set_alphatestref(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuBlendEnable:
				gpu_set_blendenable(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuBlendMode:
				gpu_set_blendmode(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuBlendModeExt:
				{
					var _src = _command[i++];
					var _dest = _command[i++];
					gpu_set_blendmode_ext(_src, _dest);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuBlendModeExtSepAlpha:
				{
					var _src = _command[i++];
					var _dest = _command[i++];
					var _srcalpha = _command[i++];
					var _destalpha = _command[i++];
					gpu_set_blendmode_ext_sepalpha(_src, _dest, _srcalpha, _destalpha);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuColorWriteEnable:
				{
					var _red = _command[i++];
					var _green = _command[i++];
					var _blue = _command[i++];
					var _alpha = _command[i++];
					gpu_set_colorwriteenable(_red, _green, _blue, _alpha);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuCullMode:
				gpu_set_cullmode(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuFog:
				if (_command[i++])
				{
					var _color = _command[i++];
					var _start = _command[i++];
					var _end = _command[i++];
					gpu_set_fog(true, _color, _start, _end);
				}
				else
				{
					gpu_set_fog(false, c_black, 0, 1);
				}
				break;
			
			case BBMOD_ERenderCommand.SetGpuState:
				gpu_set_state(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexFilter:
				gpu_set_tex_filter(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexFilterExt:
				{
					var _index = shader_get_sampler_index(shader_current(), _command[i++]);
					gpu_set_tex_filter_ext(_index, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuTexMaxAniso:
				gpu_set_tex_max_aniso(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMaxAnisoExt:
				{
					var _index = shader_get_sampler_index(shader_current(), _command[i++]);
					gpu_set_tex_max_aniso_ext(_index, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuTexMaxMip:
				gpu_set_tex_max_mip(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMaxMipExt:
				{
					var _index = shader_get_sampler_index(shader_current(), _command[i++]);
					gpu_set_tex_max_mip_ext(_index, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuTexMinMip:
				gpu_set_tex_min_mip(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMinMipExt:
				{
					var _index = shader_get_sampler_index(shader_current(), _command[i++]);
					gpu_set_tex_min_mip_ext(_index, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipBias:
				gpu_set_tex_mip_bias(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipBiasExt:
				{
					var _index = shader_get_sampler_index(shader_current(), _command[i++]);
					gpu_set_tex_mip_bias_ext(_index, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipEnable:
				gpu_set_tex_mip_enable(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipEnableExt:
				{
					var _index = shader_get_sampler_index(shader_current(), _command[i++]);
					gpu_set_tex_mip_enable_ext(_index, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipFilter:
				gpu_set_tex_mip_filter(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipFilterExt:
				{
					var _index = shader_get_sampler_index(shader_current(), _command[i++]);
					gpu_set_tex_mip_filter_ext(_index, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuTexRepeat:
				gpu_set_tex_repeat(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexRepeatExt:
				{
					var _index = shader_get_sampler_index(shader_current(), _command[i++]);
					gpu_set_tex_repeat_ext(_index, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuZFunc:
				gpu_set_zfunc(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuZTestEnable:
				gpu_set_ztestenable(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuZWriteEnable:
				gpu_set_zwriteenable(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetMaterialProps:
				bbmod_material_props_set(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetProjectionMatrix:
				matrix_set(matrix_projection, _command[i++]);
				break;

			case BBMOD_ERenderCommand.SetSampler:
				{
					var _nameOrIndex = _command[i++];
					var _index = is_string(_nameOrIndex)
						? shader_get_sampler_index(shader_current(), _nameOrIndex)
						: _nameOrIndex;
					texture_set_stage(_index, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetShader:
				shader_set(_command[i++]);
				break;

			case BBMOD_ERenderCommand.SetUniformFloat:
				{
					var _uniform = shader_get_uniform(shader_current(), _command[i++]);
					shader_set_uniform_f(_uniform, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetUniformFloat2:
				{
					var _uniform = shader_get_uniform(shader_current(), _command[i++]);
					var _v1 = _command[i++];
					var _v2 = _command[i++];
					shader_set_uniform_f(_uniform, _v1, _v2);
				}
				break;

			case BBMOD_ERenderCommand.SetUniformFloat3:
				{
					var _uniform = shader_get_uniform(shader_current(), _command[i++]);
					var _v1 = _command[i++];
					var _v2 = _command[i++];
					var _v3 = _command[i++];
					shader_set_uniform_f(_uniform, _v1, _v2, _v3);
				}
				break;

			case BBMOD_ERenderCommand.SetUniformFloat4:
				{
					var _uniform = shader_get_uniform(shader_current(), _command[i++]);
					var _v1 = _command[i++];
					var _v2 = _command[i++];
					var _v3 = _command[i++];
					var _v4 = _command[i++];
					shader_set_uniform_f(_uniform, _v1, _v2, _v3, _v4);
				}
				break;

			case BBMOD_ERenderCommand.SetUniformFloatArray:
				{
					var _uniform = shader_get_uniform(shader_current(), _command[i++]);
					shader_set_uniform_f_array(_uniform, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetUniformInt:
				{
					var _uniform = shader_get_uniform(shader_current(), _command[i++]);
					shader_set_uniform_i(_uniform, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetUniformInt2:
				{
					var _uniform = shader_get_uniform(shader_current(), _command[i++]);
					var _v1 = _command[i++];
					var _v2 = _command[i++];
					shader_set_uniform_i(_uniform, _v1, _v2);
				}
				break;

			case BBMOD_ERenderCommand.SetUniformInt3:
				{
					var _uniform = shader_get_uniform(shader_current(), _command[i++]);
					var _v1 = _command[i++];
					var _v2 = _command[i++];
					var _v3 = _command[i++];
					shader_set_uniform_i(_uniform, _v1, _v2, _v3);
				}
				break;

			case BBMOD_ERenderCommand.SetUniformInt4:
				{
					var _uniform = shader_get_uniform(shader_current(), _command[i++]);
					var _v1 = _command[i++];
					var _v2 = _command[i++];
					var _v3 = _command[i++];
					var _v4 = _command[i++];
					shader_set_uniform_i(_uniform, _v1, _v2, _v3, _v4);
				}
				break;

			case BBMOD_ERenderCommand.SetUniformIntArray:
				{
					var _uniform = shader_get_uniform(shader_current(), _command[i++]);
					shader_set_uniform_i_array(_uniform, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetUniformMatrix:
				shader_set_uniform_matrix(shader_get_uniform(shader_current(), _command[i++]));
				break;

			case BBMOD_ERenderCommand.SetUniformMatrixArray:
				{
					var _uniform = shader_get_uniform(shader_current(), _command[i++]);
					shader_set_uniform_matrix_array(_uniform, _command[i++]);
				}
				break;

			case BBMOD_ERenderCommand.SetViewMatrix:
				matrix_set(matrix_view, _command[i++]);
				break;

			case BBMOD_ERenderCommand.SetWorldMatrix:
				matrix_set(matrix_world, _command[i++]);
				break;

			case BBMOD_ERenderCommand.SubmitRenderQueue:
				_command[i++].submit(_instances);
				break;

			case BBMOD_ERenderCommand.SubmitVertexBuffer:
				{
					var _vertexBuffer = _command[i++];
					var _prim = _command[i++];
					var _texture = _command[i++];
					vertex_submit(_vertexBuffer, _prim, _texture);
				}
				break;
			}

			_condition = true;
		}

		return self;
	};

	static clear = function ()
	{
		gml_pragma("forceinline");
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

function __bbmod_add_render_queue(_renderQueue)
{
	gml_pragma("forceinline");
	static _renderQueues = bbmod_render_queues_get();
	array_push(_renderQueues, _renderQueue);
	__bbmod_reindex_render_queues();
}

function __bbmod_remove_render_queue(_renderQueue)
{
	gml_pragma("forceinline");
	static _renderQueues = bbmod_render_queues_get();
	var _renderQueueCount = array_length(_renderQueues);
	for (var i = 0; i < _renderQueueCount; ++i)
	{
		if (_renderQueues[i] == _renderQueue)
		{
			array_delete(_renderQueues, i, 1);
			break;
		}
	}
	__bbmod_reindex_render_queues();
}

function __bbmod_reindex_render_queues()
{
	gml_pragma("forceinline");
	static _renderQueues = bbmod_render_queues_get();
	static _sortFn = function (_a, _b)
	{
		if (_b.Priority > _a.Priority) return -1;
		if (_b.Priority < _a.Priority) return +1;
		return 0;
	};
	array_sort(_renderQueues, _sortFn);
}

/// @func bbmod_render_queue_get_default()
///
/// @desc Retrieves the default render queue.
///
/// @return {Struct.BBMOD_RenderQueue} The default render queue.
///
/// @see BBMOD_RenderQueue
function bbmod_render_queue_get_default()
{
	gml_pragma("forceinline");
	static _renderQueue = new BBMOD_RenderQueue("Default");
	return _renderQueue;
}
