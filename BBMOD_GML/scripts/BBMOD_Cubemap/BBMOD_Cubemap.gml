/// @module Core

/// @enum Enumeration of cube sides, compatible with
/// [Xpanda](https://github.com/GameMakerDiscord/Xpanda)'s cubemap layout.
enum BBMOD_ECubeSide
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
	SIZE,
};

/// @func BBMOD_Cubemap(_resolution)
///
/// @implements {BBMOD_IDestructible}
/// @implements {BBMOD_IRenderTarget}
///
/// @desc Used for capturing surrounding scene at given position into a texture.
///
/// @param {Real} _resolution A resolution of single cubemap side. Must be power
/// of 2!
///
/// @example
/// ```gml
/// /// @desc Create event
/// // Create a renderer
/// renderer = new BBMOD_DefaultRenderer();
/// // Create a cubemap
/// cubemap = new BBMOD_Cubemap(128);
/// cubemap.Position = new BBMOD_Vec3(x, y, z);
///
/// /// @desc Draw event
/// // Draw the scene into the cubemap
/// while (cubemap.set_target())
/// {
///     draw_clear(c_black);
///     renderer.render();
///     cubemap.reset_target();
/// }
///
/// // Draw the scene into the app. surface
/// renderer.render();
///
/// /// @desc Clean Up event
/// cubemap = cubemap.destroy();
/// renderer = renderer.destroy();
/// ```
function BBMOD_Cubemap(_resolution) constructor
{
	/// @var {Array} The position of the cubemap in the world space.
	/// @see BBMOD_Cubemap.get_view_matrix
	Position = new BBMOD_Vec3();

	/// @var {Real} Distance to the near clipping plane used in the cubemap's
	/// projection matrix. Defaults to `0.1`.
	/// @see BBMOD_Cubemap.get_projection_matrix
	ZNear = 0.1;

	/// @var {Real} Distance to the far clipping plane used in the cubemap's
	/// projection matrix. Defaults to `8192`.
	/// @see BBMOD_Cubemap.get_projection_matrix
	ZFar = 8192.0;

	/// @var {Real} The format of created surfaces. Use one of the `surface_`
	/// constants. Default value is `surface_rgba8unorm`.
	/// @see BBMOD_Cubemap.Sides
	/// @see BBMOD_Cubemap.Surface
	/// @see BBMOD_Cubemap.SurfaceOctahedron
	Format = surface_rgba8unorm;

	/// @var {Array<Id.Surface>} An array of surfaces.
	/// @readonly
	Sides = array_create(BBMOD_ECubeSide.SIZE, -1);

	/// @var {Id.Surface} A single surface containing all cubemap sides.
	/// This can be passed as uniform to a shader for cubemapping.
	/// @see BBMOD_Cubemap.to_single_surface
	/// @readonly
	Surface = -1;

	/// @var {Id.Surface} A surface with the cubemap converted into an
	/// octahedral map.
	/// @see BBMOD_Cubemap.to_octahedron
	/// @readonly
	SurfaceOctahedron = -1;

	/// @var {Real} A resolution of single cubemap side. Must be power of two.
	/// @readonly
	Resolution = _resolution;

	/// @var {Real} An index of a side that we are currently rendering to.
	/// Contains values from {@link BBMOD_ECubeSide}.
	/// @see BBMOD_Cubemap.set_target
	/// @private
	__renderTo = 0;

	/// @var {Struct.BBMOD_Vec3}
	/// @private
	__camPosBackup = undefined;

	/// @var {Id.Camera}
	/// @private
	static __camera = camera_create();

	/// @var {Id.Camera}
	/// @private
	static __camera2D = camera_create();

	/// @func get_surface(_side)
	///
	/// @desc Gets a surface for given cubemap side. If the surface is corrupted,
	/// then a new one is created.
	///
	/// @param {Real} _side The cubemap side.
	///
	/// @return {Id.Surface} The surface.
	///
	/// @see BBMOD_ECubeSide
	static get_surface = function (_side)
	{
		var _surOld = Sides[_side];
		var _sur = bbmod_surface_check(_surOld, Resolution, Resolution, Format);
		if (_sur != _surOld)
		{
			Sides[@ _side] = _sur;
		}
		return _sur;
	};

	/// @func to_single_surface([_clearColor[, _clearAlpha]])
	///
	/// @desc Puts all faces of the cubemap into a single surface.
	///
	/// @param {Real} [_clearColor] The color to clear the target surface with
	/// before the cubemap is rendered into it. Defaults to `c_black`.
	/// @param {Real} [_clearAlpha] The alpha to clear the targe surface with
	/// before the cubemap is rendered into it. Defaults to 1.
	///
	/// @see BBMOD_Cubemap.Surface
	static to_single_surface = function (_clearColor=c_black, _clearAlpha=1)
	{
		var _width = Resolution * 8;
		var _height = Resolution;
		var _world = matrix_get(matrix_world);
		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		matrix_set(matrix_world, matrix_build_identity());
		Surface = bbmod_surface_check(Surface, _width, _height, Format, false);
		surface_set_target(Surface);
		draw_clear_alpha(_clearColor, _clearAlpha);
		camera_set_view_size(__camera2D, _width, _height);
		camera_apply(__camera2D);
		var _x = 0;
		var i = 0;
		repeat (BBMOD_ECubeSide.SIZE)
		{
			draw_surface(Sides[i++], _x, 0);
			_x += Resolution;
		}
		surface_reset_target();
		matrix_set(matrix_world, _world);
		gpu_pop_state();
	};

	/// @func to_octahedron([_clearColor[, _clearAlpha]])
	///
	/// @desc Converts the cubmap into an octahedral map.
	///
	/// @param {Real} [_clearColor] The color to clear the target surface with
	/// before the cubemap is rendered into it. Defaults to `c_black`.
	/// @param {Real} [_clearAlpha] The alpha to clear the targe surface with
	/// before the cubemap is rendered into it. Defaults to 1.
	///
	/// @note You must use {@link BBMOD_Cubemap.to_single_surface} first for
	/// this method to work!
	///
	/// @see BBMOD_Cubemap.SurfaceOctahedron
	static to_octahedron = function (_clearColor=c_black, _clearAlpha=1)
	{
		var _world = matrix_get(matrix_world);
		SurfaceOctahedron = bbmod_surface_check(SurfaceOctahedron, Resolution, Resolution, Format, false);
		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		gpu_set_tex_filter(true);
		matrix_set(matrix_world, matrix_build_identity());
		surface_set_target(SurfaceOctahedron);
		draw_clear_alpha(_clearColor, _clearAlpha);
		camera_set_view_size(__camera2D, Resolution, Resolution);
		camera_apply(__camera2D);
		shader_set(BBMOD_ShCubemapToOctahedron);
		shader_set_uniform_f(
			shader_get_uniform(BBMOD_ShCubemapToOctahedron, "u_vTexel"),
			1 / Resolution,
			1 / Resolution);
		draw_surface_stretched(Surface, 0, 0, Resolution, Resolution);
		shader_reset();
		surface_reset_target();
		matrix_set(matrix_world, _world);
		gpu_pop_state();
	};

	/// @func prefilter_ibl()
	///
	/// @desc Prefilters the cubemap for use with image based lighting.
	///
	/// @return {Asset.GMSprite} The prefiltered sprite. This can be used for
	/// reflections with {@link BBMOD_ReflectionProbe}s.
	///
	/// @note You must use {@link BBMOD_Cubemap.to_octahedron} first for
	/// this method to work!
	static prefilter_ibl = function ()
	{
		var _x = 0;

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		gpu_set_tex_filter(true);
		gpu_set_blendenable(false);

		var _width = Resolution * 8;
		var _height = Resolution;
		var _world = matrix_get(matrix_world);
		var _surface = bbmod_surface_check(-1, _width, _height, surface_rgba8unorm, false);
		surface_set_target(_surface);

		matrix_set(matrix_world, matrix_build_identity());
		camera_set_view_size(__camera2D, _width, _height);
		camera_apply(__camera2D);

		var _hdr = bbmod_hdr_is_supported();

		shader_set(BBMOD_ShPrefilterSpecular);
		shader_set_uniform_f(
			shader_get_uniform(BBMOD_ShPrefilterSpecular, "bbmod_HDR"),
			_hdr ? 1.0 : 0.0);
		var _uRoughness = shader_get_uniform(BBMOD_ShPrefilterSpecular, "u_fRoughness");
		for (var i = 0; i <= 6; ++i)
		{
			shader_set_uniform_f(_uRoughness, i / 6);
			draw_surface(SurfaceOctahedron, _x, 0);
			_x += Resolution;
		}
		shader_reset();

		shader_set(BBMOD_ShPrefilterDiffuse);
		shader_set_uniform_f(
			shader_get_uniform(BBMOD_ShPrefilterDiffuse, "bbmod_HDR"),
			_hdr ? 1.0 : 0.0);
		draw_surface(SurfaceOctahedron, _x, 0);
		_x += Resolution;
		shader_reset();

		surface_reset_target();

		gpu_pop_state();
		matrix_set(matrix_world, _world);

		var _sprite = sprite_create_from_surface(_surface, 0, 0, _width, _height, false, false, 0, 0);
		surface_free(_surface);
		return _sprite;
	};

	/// @func get_view_matrix(_side)
	///
	/// @desc Creates a view matrix for given cubemap side.
	///
	/// @param {Real} _side The cubemap side. Use values from
	/// {@link BBMOD_ECubeSide}.
	///
	/// @return {Array<Real>} The created view matrix.
	static get_view_matrix = function (_side)
	{
		var _negEye = Position.Scale(-1.0);
		var _x, _y, _z;

		switch (_side)
		{
		case BBMOD_ECubeSide.PosX:
			_x = new BBMOD_Vec3(0.0, +1.0, 0.0);
			_y = new BBMOD_Vec3(0.0, 0.0, +1.0);
			_z = new BBMOD_Vec3(+1.0, 0.0, 0.0);
			break;

		case BBMOD_ECubeSide.NegX:
			_x = new BBMOD_Vec3(0.0, -1.0, 0.0);
			_y = new BBMOD_Vec3(0.0, 0.0, +1.0);
			_z = new BBMOD_Vec3(-1.0, 0.0, 0.0);
			break;

		case BBMOD_ECubeSide.PosY:
			_x = new BBMOD_Vec3(-1.0, 0.0, 0.0);
			_y = new BBMOD_Vec3(0.0, 0.0, +1.0);
			_z = new BBMOD_Vec3(0.0, +1.0, 0.0);
			break;

		case BBMOD_ECubeSide.NegY:
			_x = new BBMOD_Vec3(+1.0, 0.0, 0.0);
			_y = new BBMOD_Vec3(0.0, 0.0, +1.0);
			_z = new BBMOD_Vec3(0.0, -1.0, 0.0);
			break;

		case BBMOD_ECubeSide.PosZ:
			_x = new BBMOD_Vec3(0.0, +1.0, 0.0);
			_y = new BBMOD_Vec3(-1.0, 0.0, 0.0);
			_z = new BBMOD_Vec3(0.0, 0.0, +1.0);
			break;

		case BBMOD_ECubeSide.NegZ:
			_x = new BBMOD_Vec3(0.0, +1.0, 0.0);
			_y = new BBMOD_Vec3(+1.0, 0.0, 0.0);
			_z = new BBMOD_Vec3(0.0, 0.0, -1.0);
			break;
		}

		camera_set_view_mat(__camera, [
			_x.X, _y.X, _z.X, 0.0,
			_x.Y, _y.Y, _z.Y, 0.0,
			_x.Z, _y.Z, _z.Z, 0.0,
			_x.Dot(_negEye), _y.Dot(_negEye), _z.Dot(_negEye), 1.0
		]);
		return camera_get_view_mat(__camera);
	}

	/// @func get_projection_matrix()
	///
	/// @desc Creates a projection matrix for the cubemap.
	///
	/// @return {Array<Real>} The created projection matrix.
	static get_projection_matrix = function ()
	{
		gml_pragma("forceinline");
		camera_set_proj_mat(__camera, matrix_build_projection_perspective_fov(
			90.0 * global.__bbmodCameraFovFlip, 1.0 * global.__bbmodCameraAspectFlip, ZNear, ZFar));
		return camera_get_proj_mat(__camera);
	};

	/// @func set_target()
	///
	/// @desc Sets next cubemap side surface as the render target and sets
	/// the current view and projection matrices appropriately.
	///
	/// @return {Bool} Returns `true` if the render target was set or `false`
	/// if all cubemap sides were iterated through.
	///
	/// @example
	/// ```gml
	/// while (cubemap.set_target())
	/// {
	///     draw_clear(c_black);
	///     // Render to cubemap here...
	///     cubemap.reset_target();
	/// }
	/// ```
	///
	/// @note This also sets the camera position using {@link bbmod_camera_set_position}
	/// and it is reset back to its original value when the `reset_target` method
	/// is called.
	///
	/// @see BBMOD_IRenderTarget.reset_target
	static set_target = function ()
	{
		var _renderTo = __renderTo++;
		if (_renderTo < BBMOD_ECubeSide.SIZE)
		{
			__camPosBackup = bbmod_camera_get_position();
			bbmod_camera_set_position(Position);
			surface_set_target(get_surface(_renderTo));
			matrix_set(matrix_view, get_view_matrix(_renderTo));
			matrix_set(matrix_projection, get_projection_matrix());
			return true;
		}
		__renderTo = 0;
		return false;
	};

	static reset_target = function ()
	{
		gml_pragma("forceinline");
		bbmod_camera_set_position(__camPosBackup);
		surface_reset_target();
		return self;
	};

	/// @func draw_cross(_x, _y[, _scale])
	///
	/// @desc Draws a cubemap cross at given position.
	///
	/// @param {Real} _x The X position to draw the cubemap at.
	/// @param {Real} _y The Y position to draw the cubemap at.
	/// @param {Real} [_scale] The scale of the cubemap. Default value is 1.
	///
	/// @return {Struct.BBMOD_Cubemap} Returns `self`.
	static draw_cross = function (_x, _y, _scale=1.0)
	{
		var _s = Resolution * _scale;
		_y += _s;
		draw_surface_stretched(get_surface(BBMOD_ECubeSide.NegX), _x, _y, _s, _s); _x += _s;
		draw_surface_stretched(get_surface(BBMOD_ECubeSide.NegY), _x, _y, _s, _s); _x += _s;
		draw_surface_stretched(get_surface(BBMOD_ECubeSide.PosZ), _x, _y - _s, _s, _s);
		draw_surface_stretched(get_surface(BBMOD_ECubeSide.NegZ), _x, _y + _s, _s, _s);
		draw_surface_stretched(get_surface(BBMOD_ECubeSide.PosX), _x, _y, _s, _s); _x += _s;
		draw_surface_stretched(get_surface(BBMOD_ECubeSide.PosY), _x, _y, _s, _s); _x += _s;
		return self;
	};

	static destroy = function ()
	{
		var i = 0;
		repeat (BBMOD_ECubeSide.SIZE)
		{
			var _surface = Sides[i++];
			if (surface_exists(_surface))
			{
				surface_free(_surface);
			}
		}
		if (surface_exists(Surface))
		{
			surface_free(Surface);
		}
		if (surface_exists(SurfaceOctahedron))
		{
			surface_free(SurfaceOctahedron);
		}
		return undefined;
	};
}
