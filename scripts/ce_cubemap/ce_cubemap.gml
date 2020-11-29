/// @enum Enumeration of cube sides, compatible with
/// [Xpanda](https://github.com/GameMakerDiscord/Xpanda)'s cubemap layout.
enum CE_ECubeSide
{
	/// @member Front cube side.
	PosX,
	/// @member Back cube side.
	NegX,
	/// @member Right cube side.
	PosY,
	/// @member Left cube side.
	NegY,
	/// @member Top cube side.
	PosZ,
	/// @member Bottom cube side.
	NegZ,
	/// @member Number of cube sides.
	SIZE
};

/// @func CE_Cubemap(_resolution)
/// @desc A cubemap.
/// @param {uint} _resolution A resolution of single cubemap side. Must be power
/// of two.
function CE_Cubemap(_resolution) constructor
{
	/// @var {array} The position of the cubemap in the world space.
	/// @see CE_Cubemap.get_view_matrix
	Position = ce_vec3_create(0);

	/// @var {real} Distance to the near clipping plane used in the cubemap's
	/// projection matrix. Defaults to `0.1`.
	/// @see CE_Cubemap.get_projection_matrix
	ZNear = 0.1;

	/// @var {real} Distance to the far clipping plane used in the cubemap's
	/// projection matrix. Defaults to `8192`.
	/// @see CE_Cubemap.get_projection_matrix
	ZFar = 8192;

	/// @var {array<surface>} An array of surfaces.
	/// @readonly
	Sides = array_create(CE_ECubeSide.SIZE, noone);

	/// @var {surface} A single surface containing all cubemap sides.
	/// This can be passed as uniform to a shader for cubemapping.
	/// @readonly
	Surface = noone;

	/// @var {uint} A resolution of single cubemap side. Must be power of two.
	/// @readonly
	Resolution = _resolution;

	/// @var {CE_ECubeSide} An index of a side that we are currently rendering to.
	/// @see CE_Cubemap.set_target
	/// @private
	RenderTo = 0;

	/// @func get_surface(_side)
	/// @desc Gets a surface for given cubemap side. If the surface is corrupted,
	/// then a new one is created.
	/// @param {CE_ECubeSide} _side The cubemap side.
	/// @return {real} The surface.
	static get_surface = function (_side) {
		var _surOld = Sides[_side];
		var _sur = ce_surface_check(_surOld, Resolution, Resolution);
		if (_sur != _surOld)
		{
			Sides[@ _side] = _sur;
		}
		return _sur;
	};

	/// @func to_single_surface(_surface, _clearColor, _clearAlpha)
	/// @desc Puts all faces of the cubemap into a single surface.
	/// @param {uint} _clearColor
	/// @param {real} _clearAlpha
	/// @see CE_Cubemap.Surface
	static to_single_surface = function (_clearColor, _clearAlpha) {
		Surface = ce_surface_check(Surface, Resolution * 8, Resolution);
		surface_set_target(Surface);
		draw_clear_alpha(_clearColor, _clearAlpha);
		var _x = 0;
		var i = 0;
		repeat (CE_ECubeSide.SIZE)
		{
			draw_surface(Sides[i++], _x, 0);
			_x += Resolution;
		}
		surface_reset_target();
	};

	/// @func get_view_matrix(_side)
	/// @desc Creates a view matrix for given cubemap side.
	/// @param {ECubemapSide} side The cubemap side.
	/// @return {matrix} The created view matrix.
	static get_view_matrix = function (_side) {
		var _negEye = ce_vec3_clone(Position);
		ce_vec3_scale(_negEye, -1);
		var _x, _y, _z;

		switch (_side)
		{
		case CE_ECubeSide.PosX:
			_x = ce_vec3_create(0, +1, 0);
			_y = ce_vec3_create(0, 0, +1);
			_z = ce_vec3_create(+1, 0, 0);
			break;

		case CE_ECubeSide.NegX:
			_x = ce_vec3_create(0, -1, 0);
			_y = ce_vec3_create(0, 0, +1);
			_z = ce_vec3_create(-1, 0, 0);
			break;

		case CE_ECubeSide.PosY:
			_x = ce_vec3_create(-1, 0, 0);
			_y = ce_vec3_create(0, 0, +1);
			_z = ce_vec3_create(0, +1, 0);
			break;

		case CE_ECubeSide.NegY:
			_x = ce_vec3_create(+1, 0, 0);
			_y = ce_vec3_create(0, 0, +1);
			_z = ce_vec3_create(0, -1, 0);
			break;

		case CE_ECubeSide.PosZ:
			_x = ce_vec3_create(0, +1, 0);
			_y = ce_vec3_create(-1, 0, 0);
			_z = ce_vec3_create(0, 0, +1);
			break;

		case CE_ECubeSide.NegZ:
			_x = ce_vec3_create(0, +1, 0);
			_y = ce_vec3_create(+1, 0, 0);
			_z = ce_vec3_create(0, 0, -1);
			break;
		}

		return [
			_x[0], _y[0], _z[0], 0,
			_x[1], _y[1], _z[1], 0,
			_x[2], _y[2], _z[2], 0,
			ce_vec3_dot(_x, _negEye), ce_vec3_dot(_y, _negEye), ce_vec3_dot(_z, _negEye), 1
		];
	}

	/// @func get_projection_matrix()
	/// @desc Creates a projection matrix for the cubemap.
	/// @return {matrix} The created projection matrix.
	static get_projection_matrix = function () {
		gml_pragma("forceinline");
		return matrix_build_projection_perspective_fov(90, 1, ZNear, ZFar);
	};

	/// @func set_target()
	/// @desc Sets next cubemap side surface as the render target and sets
	/// the current view and projection matrices appropriately.
	/// @return {bool} Returns `true` if the render target was set or `false`
	/// if all cubemap sides were iterated through,
	/// @example
	/// ```gml
	/// while (cubemap.set_target())
	/// {
	///     draw_clear(c_black);
	///     // Render to cubemap here...
	///     cubemap.reset_target();
	/// }
	/// ```
	/// @see CE_Cubemap.reset_target
	static set_target = function () {
		var _renderTo = RenderTo++;
		if (_renderTo < CE_ECubeSide.SIZE)
		{
			surface_set_target(get_surface(_renderTo));
			matrix_set(matrix_view, get_view_matrix(_renderTo));
			matrix_set(matrix_projection, get_projection_matrix());
			return true;
		}
		RenderTo = 0;
		return false;
	};

	/// @func reset_target()
	/// @desc Resets the render target.
	/// @see CE_Cubemap.set_target
	static reset_target = function () {
		gml_pragma("forceinline");
		surface_reset_target();
	};

	/// @func destroy()
	/// @desc Frees memory used by the cubemap.
	static destroy = function () {
		var i = 0;
		repeat (CE_ECubeSide.SIZE)
		{
			var _surface = Sides[i++];
			if (surface_exists(_surface))
			{
				surface_free(_surface);
			}
		}
	};
}