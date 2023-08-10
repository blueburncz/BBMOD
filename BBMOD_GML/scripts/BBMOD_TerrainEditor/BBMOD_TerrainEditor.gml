/// @module Terrain

/// @enum Enumeration of terrain edit modes.
enum BBMOD_ETerrainEditMode
{
	/// @member Editing terrain's height.
	Height,
	/// @member Editing terrain's splat map.
	Layer,
	/// @member Editing terrain's color map.
	Color,
	/// @member Total number of members of this enum.
	SIZE
};

/// @func BBMOD_TerrainEditor()
///
/// @implements {BBMOD_IDestructibe}
///
/// @desc A terrain editor.
///
/// @see BBMOD_BaseRenderer.TerrainEditor
function BBMOD_TerrainEditor() constructor
{
	/// @var {Bool} Use `true` (default) to enable the terrain editor.
	Enabled = true;

	/// @var {Struct.BBMOD_Terrain} The terrain to edit or `undefined`.
	Target = undefined;

	/// @var {Real} The current edit mode. Use values from {@link BBMOD_ETerrainEditMode}.
	/// Default is {@link BBMOD_ETerrainEditMode.Height}.
	EditMode = BBMOD_ETerrainEditMode.Height;

	/// @var {Struct.BBMOD_Vec3} The position of the brush. Default is `(0, 0, 0)`.
	Position = new BBMOD_Vec3();

	/// @var {Real} Default is 1.
	Radius = 1.0;

	/// @var {Real} Default is 1.
	Strength = 10.0;

	/// @var {Real} Default is 0.
	Layer = 0;

	/// @var {Constant.Color} Default is `c_white`.
	Color = c_white;

	/// @func update(_deltaTime)
	///
	/// @desc Updates the terrain editor.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_TerrainEditor} Returns `self`.
	static update = function (_deltaTime)
	{
		if (!Target)
		{
			return self;
		}

		switch (EditMode)
		{
		case BBMOD_ETerrainEditMode.Height:
			{
				if (keyboard_check(vk_space))
				{
					Target.add_height(Position.X, Position.Y, Radius, Strength);
				}
			}
			break;

		case BBMOD_ETerrainEditMode.Layer:
			{
			}
			break;

		case BBMOD_ETerrainEditMode.Color:
			{
			}
			break;

		default:
			break;
		}

		return self;
	};

	/// @func draw()
	///
	/// @desc Draws the terrain editor brush.
	///
	/// @return {Struct.BBMOD_TerrainEditor} Returns `self`.
	static draw = function ()
	{
		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		gpu_set_ztestenable(true);

		var _world = matrix_get(matrix_world);
		matrix_set(matrix_world, matrix_build_identity());

		var _vbuffer = global.__bbmodVBufferDebug;
		var _steps = 24;
		var _angle = 360 / _steps;
		var _direction = 0;

		vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

		repeat (_steps + 1)
		{
			var _x = Position.X + lengthdir_x(Radius, _direction);
			var _y = Position.Y + lengthdir_y(Radius, _direction);
			var _z = 0;

			if (Target)
			{
				_z = (Target.get_height(_x, _y) ?? 0) + 1;
			}

			vertex_position_3d(_vbuffer, _x, _y, _z); vertex_color(_vbuffer, c_white, 1.0);

			_direction += _angle;
		}

		vertex_end(_vbuffer);
		vertex_submit(_vbuffer, pr_linestrip, -1);

		matrix_set(matrix_world, _world);
		gpu_pop_state();

		return self;
	};

	static destroy = function ()
	{
		return undefined;
	};
}
