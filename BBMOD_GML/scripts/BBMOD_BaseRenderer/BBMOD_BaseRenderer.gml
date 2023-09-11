/// @module Core

/// @var {Struct.BBMOD_Renderer} The last used renderer. Can be `undefined`.
/// @private
global.__bbmodRendererCurrent = undefined;

/// @func BBMOD_BaseRenderer()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Base struct for renderers. Renderers execute
/// [render commands](./BBMOD_ERenderCommand.html) created with method
/// [render](./BBMOD_Model.render.html).
function BBMOD_BaseRenderer() constructor
{
	/// @var {Real} The X position of the renderer on the screen. Default value
	/// is 0.
	X = 0;

	/// @var {Real} The Y position of the renderer on the screen. Default value
	/// is 0.
	Y = 0;

	/// @var {Real} The width of the renderer on the screen. If `undefined` then
	/// the window width is used. Default value is `undefined`.
	Width = undefined;

	/// @var {Real} The height of the renderer on the screen. If `undefined`
	/// then the window height is used. Default value is `undefined`.
	Height = undefined;

	/// @var {Bool} If `true` then rendering of instance IDs into an off-screen
	/// surface is enabled. This must be enabled if you would like to use method
	/// {@link BBMOD_BaseRenderer.get_instance_id} for mouse-picking instances.
	/// Default value is `false`.
	RenderInstanceIDs = false;

	/// @var {Id.Surface} Surface for rendering highlight of selected instances.
	/// @private
	__surInstanceHighlight = -1;

	/// @var {Struct.BBMOD_Color} Outline color of instances selected by gizmo.
	/// Default value is {@link BBMOD_C_ORANGE}.
	/// @see BBMOD_BaseRenderer.Gizmo
	InstanceHighlightColor = BBMOD_C_ORANGE;

	/// @var {Bool} If `true` then edit mode is enabled. Default value is `false`.
	EditMode = false;

	/// @var {Bool} If `true` then mousepicking of gizmo and instances is enabled.
	/// Default value is `true`.
	/// @note This can be useful for example to disable mousepicking when the
	/// mouse cursor is over UI.
	EnableMousepick = true;

	/// @var {Constant.MouseButton} The mouse button used to select instances when
	/// edit mode is enabled. Default value is `mb_left`.
	/// @see BBMOD_BaseRenderer.EditMode
	ButtonSelect = mb_left;

	/// @var {Constant.VirtualKey} The keyboard key used to add/remove instances
	/// from multiple selection when edit mode is enabled. Default value is
	/// `vk_shift`.
	/// @see BBMOD_BaseRenderer.EditMode
	KeyMultiSelect = vk_shift;

	/// @var {Struct.BBMOD_Gizmo} A gizmo for transforming instances when
	/// {@link BBMOD_BaseRenderer.EditMode} is enabled. This is by default `undefined`.
	/// @see BBMOD_Gizmo
	Gizmo = undefined;

	/// @var {Id.Surface} A surface containing the gizmo. Used to enable
	/// z-testing against itself, but ingoring the scene geometry.
	/// @private
	__surGizmo = -1;

	/// @var {Id.Surface} Surface for mouse-picking the gizmo.
	/// @private
	__surSelect = -1;

	/// @var {Array<Struct.BBMOD_IRenderable>} An array of renderable objects
	/// and structs. These are automatically rendered in
	/// {@link BBMOD_BaseRenderer.render}.
	/// @readonly
	/// @see BBMOD_BaseRenderer.add
	/// @see BBMOD_BaseRenderer.remove
	/// @see BBMOD_IRenderable
	Renderables = [];

	/// @var {Bool} Set to `true` to enable the `application_surface`.
	/// Use method {@link BBMOD_BaseRenderer.present} to draw the
	/// `application_surface` to the screen. Defaults to `false`.
	UseAppSurface = false;

	/// @var {Real} Resolution multiplier for the `application_surface`.
	/// {@link BBMOD_BaseRenderer.UseAppSurface} must be enabled for this to
	/// have any effect. Defaults to 1. Use lower values to improve framerate.
	RenderScale = 1.0;

	/// @var {Bool} Enables rendering into a shadowmap in the shadows render pass.
	/// Defauls to `false`.
	/// @see BBMOD_DirectionalLight.ShadowmapArea
	/// @see BBMOD_Light.ShadowmapResolution
	EnableShadows = false;

	/// @var {Id.DsList}
	/// @private
	__shadowmapLights = ds_list_create();

	/// @var {Id.DsList}
	/// @private
	__shadowmapHealth = ds_list_create();

	/// @var {Id.DsMap}
	/// @private
	__shadowmapSurfaces = ds_map_create();

	/// @var {Id.DsMap}
	/// @private
	__shadowmapCubes = ds_map_create();

	/// @var {Real} When rendering shadows, offsets vertex position by its normal
	/// scaled by this value. Defaults to 1. Increasing the value can remove some
	/// artifacts but using too high value could make the objects appear flying
	/// above the ground.
	ShadowmapNormalOffset = 1;

	/// @var {Struct.BBMOD_PostProcessor} Handles post-processing effects if
	/// isn't `undefined` and {@link BBMOD_BaseRenderer.UseAppSurface} is enabled.
	/// Default value is `undefined`.
	/// @see BBMOD_PostProcessor
	PostProcessor = undefined;

	/// @var {Id.Surface}
	/// @private
	__surFinal = -1;

	/// @var {Struct.BBMOD_Cubemap} For reflection probe capture.
	/// @private
	static __cubemap = new BBMOD_Cubemap(128);

	/// @var {Id.Surface} For reflection probe capture.
	/// @private
	__surProbe1 = -1;

	/// @var {Id.Surface} For reflection probe capture.
	/// @private
	__surProbe2 = -1;

	/// @var {Bool} Enables screen-space ambient occlusion. This requires
	/// the depth buffer. Defaults to `false`. Enabling this requires the
	/// [SSAO submodule](./SSAOSubmodule.html)!
	/// @see BBMOD_DefaultRenderer.EnableGBuffer
	EnableSSAO = false;

	/// @var {Id.Surface} The SSAO surface.
	/// @private
	__surSSAO = -1;

	/// @var {Id.Surface} Surface used for blurring SSAO.
	/// @private
	__surWork = -1;

	/// @var {Real} Resolution multiplier for SSAO surface. Defaults to 1.
	SSAOScale = 1.0;

	/// @var {Real} Screen-space radius of SSAO. Default value is 16.
	SSAORadius = 16.0;

	/// @var {Real} Strength of the SSAO effect. Should be greater than 0.
	/// Default value is 1.
	SSAOPower = 1.0;

	/// @var {Real} SSAO angle bias in radians. Default value is 0.03.
	SSAOAngleBias = 0.03;

	/// @var {Real} Maximum depth difference of SSAO samples. Samples farther
	/// away from the origin than this will not contribute to the effect.
	/// Default value is 10.
	SSAODepthRange = 10.0;

	/// @var {Real} Defaults to 0.01. Increase to fix self-occlusion.
	SSAOSelfOcclusionBias = 0.01;

	/// @var {Real} Maximum depth difference over which can be SSAO samples
	/// blurred. Defaults to 2.
	SSAOBlurDepthRange = 2.0;

	/// @func get_width()
	///
	/// @desc Retrieves the width of the renderer on the screen.
	///
	/// @return {Real} The width of the renderer on the screen.
	static get_width = function ()
	{
		gml_pragma("forceinline");
		return max((Width == undefined) ? window_get_width() : Width, 1);
	};

	/// @func get_height()
	///
	/// @desc Retrieves the height of the renderer on the screen.
	///
	/// @return {Real} The height of the renderer on the screen.
	static get_height = function ()
	{
		gml_pragma("forceinline");
		return max((Height == undefined) ? window_get_height() : Height, 1);
	};

	/// @func get_render_width()
	///
	/// @desc Retrieves the width of the renderer with
	///
	/// {@link BBMOD_BaseRenderer.RenderScale} applied.
	///
	/// @return {Real} The width of the renderer after `RenderScale` is applied.
	static get_render_width = function ()
	{
		gml_pragma("forceinline");
		return max(get_width() * RenderScale, 1);
	};

	/// @func get_render_height()
	///
	/// @desc Retrieves the height of the renderer with
	/// {@link BBMOD_BaseRenderer.RenderScale} applied.
	///
	/// @return {Real} The height of the renderer after `RenderScale` is applied.
	static get_render_height = function ()
	{
		gml_pragma("forceinline");
		return max(get_height() * RenderScale, 1);
	};

	/// @func set_position(_x, _y)
	///
	/// @desc Changes the renderer's position on the screen.
	///
	/// @param {Real} _x The new X position on the screen.
	/// @param {Real} _y The new Y position on the screen.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	static set_position = function (_x, _y)
	{
		gml_pragma("forceinline");
		X = _x;
		Y = _y;
		return self;
	};

	/// @func set_size(_width, _height)
	///
	/// @desc Changes the renderer's size on the screen.
	///
	/// @param {Real} _width The new width on the screen.
	/// @param {Real} _height The new height on the screen.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	static set_size = function (_width, _height)
	{
		gml_pragma("forceinline");
		Width = _width;
		Height = _height;
		return self;
	};

	/// @func set_rectangle(_x, _y, _width, _height)
	///
	/// @desc Changes the renderer's position and size on the screen.
	///
	/// @param {Real} _x The new X position on the screen.
	/// @param {Real} _y The new Y position on the screen.
	/// @param {Real} _width The new width on the screen.
	/// @param {Real} _height The new height on the screen.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	static set_rectangle = function (_x, _y, _width, _height)
	{
		gml_pragma("forceinline");
		set_position(_x, _y);
		set_size(_width, _height);
		return self;
	};

	/// @func select_gizmo(_screenX, _screenY)
	///
	/// @desc Tries to select a gizmo at given screen coordinates and
	/// automatically changes its {@link BBMOD_Gizmo.EditAxis} and
	/// {@link BBMOD_Gizmo.EditType} based on which part of the gizmo
	/// was selected.
	///
	/// @param {Real} _screenX The X position on the screen.
	/// @param {Real} _screenY The Y position on the screen.
	///
	/// @return {Bool} Returns `true` if the gizmo was selected.
	///
	/// @note {@link BBMOD_BaseRenderer.Gizmo} must be defined.
	///
	/// @private
	static select_gizmo = function (_screenX, _screenY)
	{
		_screenX = clamp(_screenX - X, 0, get_width()) * RenderScale;
		_screenY = clamp(_screenY - Y, 0, get_height()) * RenderScale;

		Gizmo.EditAxis = BBMOD_EEditAxis.None;

		var _pixel = surface_getpixel_ext(__surSelect, _screenX, _screenY);
		if (_pixel & $FF000000 == 0)
		{
			return false;
		}

		var _blue = (_pixel >> 16) & 255;
		var _green = (_pixel >> 8) & 255;
		var _red = _pixel & 255;
		var _value = max(_red, _green, _blue);

		Gizmo.EditAxis = 0
			| (BBMOD_EEditAxis.X * (_red > 0))
			| (BBMOD_EEditAxis.Y * (_green > 0))
			| (BBMOD_EEditAxis.Z * (_blue > 0));

		Gizmo.EditType = ((_value == 255) ? BBMOD_EEditType.Position
			: ((_value == 128) ? BBMOD_EEditType.Rotation
			: BBMOD_EEditType.Scale));

		return true;
	};

	/// @func get_instance_id(_screenX, _screenY)
	///
	/// @desc Retrieves an ID of an instance at given position on the screen.
	///
	/// @param {Real} _screenX The X position on the screen.
	/// @param {Real} _screenY The Y position on the screen.
	///
	/// @return {Id.Instance} The ID of the instance or 0 if no instance was
	/// found at the given position.
	///
	/// @note {@link BBMOD_BaseRenderer.RenderInstanceIDs} must be enabled.
	static get_instance_id = function (_screenX, _screenY)
	{
		gml_pragma("forceinline");
		if (!surface_exists(__surSelect))
		{
			return 0;
		}
		_screenX = clamp(_screenX - X, 0, get_width()) * RenderScale;
		_screenY = clamp(_screenY - Y, 0, get_height()) * RenderScale;
		return surface_getpixel_ext(__surSelect, _screenX, _screenY);
	};

	/// @func add(_renderable)
	///
	/// @desc Adds a renderable object or struct to the renderer.
	///
	/// @param {Struct.BBMOD_IRenderable} _renderable The renderable object or
	/// struct to add.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	///
	/// @see BBMOD_BaseRenderer.remove
	/// @see BBMOD_IRenderable
	static add = function (_renderable)
	{
		gml_pragma("forceinline");
		array_push(Renderables, _renderable);
		return self;
	};

	/// @func remove(_renderable)
	///
	/// @desc Removes a renderable object or a struct from the renderer.
	///
	/// @param {Struct.BBMOD_IRenderable} _renderable The renderable object or
	/// struct to remove.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	///
	/// @see BBMOD_BaseRenderer.add
	/// @see BBMOD_IRenderable
	static remove = function (_renderable)
	{
		gml_pragma("forceinline");
		for (var i = array_length(Renderables) - 1; i >= 0; --i)
		{
			if (Renderables[i] == _renderable)
			{
				array_delete(Renderables, i, 1);
			}
		}
		return self;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Updates the renderer. This should be called in the Step event.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	static update = function (_deltaTime)
	{
		global.__bbmodRendererCurrent = self;

		if (UseAppSurface)
		{
			application_surface_enable(true);
			application_surface_draw_enable(false);

			var _surfaceWidth = get_render_width();
			var _surfaceHeight = get_render_height();

			bbmod_surface_check(application_surface, _surfaceWidth, _surfaceHeight, surface_rgba8unorm, true);
		}

		if (Gizmo && EditMode)
		{
			Gizmo.update(_deltaTime);
		}

		return self;
	};

	/// @func __incr_shadowmap_health(_light)
	///
	/// @desc Increments health of a light's shadowmap.
	///
	/// @param {Struct.BBMOD_Light} _light The light.
	///
	/// @private
	static __incr_shadowmap_health = function (_light)
	{
		var _lightIndex = ds_list_find_index(__shadowmapLights, _light);
		if (_lightIndex == -1)
		{
			_lightIndex = ds_list_size(__shadowmapLights);
			ds_list_add(__shadowmapLights, _light);
			ds_list_add(__shadowmapHealth, 1);
		}
		++__shadowmapHealth[| _lightIndex];
	};

	/// @func __gc_collect_shadowmaps()
	///
	/// @desc Decrements health of all shadowmaps and frees them from memory
	/// when it reaches or drops below 0.
	///
	/// @private
	static __gc_collect_shadowmaps = function ()
	{
		for (var i = ds_list_size(__shadowmapLights) - 1; i >= 0; --i)
		{
			var _light = __shadowmapLights[| i];
			if (--__shadowmapHealth[| i] <= 0)
			{
				ds_list_delete(__shadowmapLights, i);
				ds_list_delete(__shadowmapHealth, i);

				if (ds_map_exists(__shadowmapSurfaces, _light))
				{
					var _surface = __shadowmapSurfaces[? _light];
					if (surface_exists(_surface))
					{
						surface_free(_surface);
					}
					ds_map_delete(__shadowmapSurfaces, _light);
				}

				if (ds_map_exists(__shadowmapCubes, _light))
				{
					__shadowmapCubes[? _light].destroy();
					ds_map_delete(__shadowmapCubes, _light);
				}
			}
		}
	};

	/// @func __render_shadowmap_impl(_light)
	///
	/// @desc Re-captures light's shadowmap if required and always increments
	/// shadowmap health.
	///
	/// @param {Struct.BBMOD_Light} _light The light to capture shadowmap for.
	///
	/// @private
	static __render_shadowmap_impl = function (_light)
	{
		static _renderQueues = bbmod_render_queues_get();

		__incr_shadowmap_health(_light);

		if ((!_light.Static || _light.NeedsUpdate)
			&& _light.__frameskipCurrent == 0)
		{
			var _shadowCaster = _light;
			var _shadowmapMatrix;
			var _shadowmapZFar = _light.__getZFar();
			var _surShadowmap = -1;

			bbmod_render_pass_set(BBMOD_ERenderPass.Shadows);

			if (is_instanceof(_light, BBMOD_PointLight))
			{
				var _cubemap;
				if (ds_map_exists(__shadowmapCubes, _light))
				{
					_cubemap = __shadowmapCubes[? _light];
				}
				else
				{
					_cubemap = new BBMOD_Cubemap(_light.ShadowmapResolution);
					__shadowmapCubes[? _light] = _cubemap;
				}

				_light.Position.Copy(_cubemap.Position);
				bbmod_shader_set_global_f(BBMOD_U_ZFAR, _shadowmapZFar);
				bbmod_shader_set_global_f("u_fOutputDistance", 1.0);

				while (_cubemap.set_target())
				{
					draw_clear(c_red);
					var _rqi = 0;
					repeat (array_length(_renderQueues))
					{
						_renderQueues[_rqi++].submit();
					}
					_cubemap.reset_target();
				}
				bbmod_material_reset();

				bbmod_shader_set_global_f("u_fOutputDistance", 0.0);

				_cubemap.to_single_surface();
				_cubemap.to_octahedron();
				__shadowmapSurfaces[? _light] = _cubemap.SurfaceOctahedron;
			}
			else
			{
				var _surShadowmapOld = -1;
				if (ds_map_exists(__shadowmapSurfaces, _light))
				{
					_surShadowmapOld = __shadowmapSurfaces[? _light];
				}

				_surShadowmap = bbmod_surface_check(
					_surShadowmapOld, _light.ShadowmapResolution, _light.ShadowmapResolution, surface_rgba8unorm, true);

				if (_surShadowmap != _surShadowmapOld)
				{
					__shadowmapSurfaces[? _light] = _surShadowmap;
				}

				surface_set_target(_surShadowmap);
				draw_clear(c_red);
				matrix_set(matrix_view, _light.__getViewMatrix());
				matrix_set(matrix_projection, _light.__getProjMatrix());
				bbmod_shader_set_global_f(BBMOD_U_ZFAR, _shadowmapZFar);
				var _rqi = 0;
				repeat (array_length(_renderQueues))
				{
					_renderQueues[_rqi++].submit();
				}
				bbmod_material_reset();
				surface_reset_target();
			}

			_light.NeedsUpdate = false;
		}

		if (_light.Frameskip == infinity)
		{
			_light.__frameskipCurrent = -1;
		}
		else if (++_light.__frameskipCurrent > _light.Frameskip)
		{
			_light.__frameskipCurrent = 0;
		}
	};

	/// @func __render_shadowmaps()
	///
	/// @desc Renders a shadowmap.
	///
	/// @note This modifies render pass and view and projection matrices and
	/// for optimization reasons it does not reset them back! Make sure to do
	/// that yourself in the calling function if needed.
	///
	/// @private
	static __render_shadowmaps = function ()
	{
		var _shadowCaster = undefined;
		var _shadowCasterIndex = -1;

		if (EnableShadows)
		{
			var _light = bbmod_light_directional_get();
			if (_light != undefined
				&& _light.CastShadows)
			{
				// Directional light
				_shadowCaster = _light;
			}
			else
			{
				// Punctual lights
				var i = 0;
				repeat (array_length(global.__bbmodPunctualLights))
				{
					_light = global.__bbmodPunctualLights[i];
					if (_light.CastShadows)
					{
						_shadowCaster = _light;
						_shadowCasterIndex = i;
						break;
					}
					++i;
				}
			}
		}

		if (_shadowCaster == undefined)
		{
			bbmod_shader_unset_global(BBMOD_U_SHADOWMAP);
			bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_ENABLE_VS, 0.0);
			bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_ENABLE_PS, 0.0);
			__gc_collect_shadowmaps();
			return;
		}

		__render_shadowmap_impl(_shadowCaster);

		var _shadowmapTexture = surface_get_texture(__shadowmapSurfaces[? _shadowCaster]);
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_ENABLE_VS, 1.0);
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_ENABLE_PS, 1.0);
		bbmod_shader_set_global_sampler(BBMOD_U_SHADOWMAP, _shadowmapTexture);
		bbmod_shader_set_global_sampler_mip_enable(BBMOD_U_SHADOWMAP, true);
		bbmod_shader_set_global_sampler_filter(BBMOD_U_SHADOWMAP, true);
		bbmod_shader_set_global_sampler_repeat(BBMOD_U_SHADOWMAP, false);
		bbmod_shader_set_global_f2(BBMOD_U_SHADOWMAP_TEXEL,
			texture_get_texel_width(_shadowmapTexture),
			texture_get_texel_height(_shadowmapTexture));
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_AREA, _shadowCaster.__getZFar());
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_NORMAL_OFFSET_VS, ShadowmapNormalOffset);
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_NORMAL_OFFSET_PS, ShadowmapNormalOffset);
		bbmod_shader_set_global_matrix_array(BBMOD_U_SHADOWMAP_MATRIX, _shadowCaster.__getShadowmapMatrix());
		bbmod_shader_set_global_f(BBMOD_U_SHADOW_CASTER_INDEX, _shadowCasterIndex);
		__gc_collect_shadowmaps();
	};

	/// @func __render_reflection_probes()
	///
	/// @desc
	///
	/// @note This modifies render pass and view and projection matrices and
	/// for optimization reasons it does not reset them back! Make sure to do
	/// that yourself in the calling function if needed.
	///
	/// @private
	static __render_reflection_probes = function ()
	{
		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);
		var _exposure = bbmod_camera_get_exposure();

		global.__bbmodReflectionProbeTexture = pointer_null;
		bbmod_camera_set_exposure(1.0);

		static _renderQueues = bbmod_render_queues_get();

		var _cubemap = __cubemap;
		var _reflectionProbes = global.__bbmodReflectionProbes;

		var i = 0;
		repeat (array_length(_reflectionProbes))
		{
			with (_reflectionProbes[i++])
			{
				if (!Enabled || !NeedsUpdate)
				{
					continue;
				}

				// Copy reflection probe settings to cubemap
				Position.Copy(_cubemap.Position);
				_cubemap.Resolution = Resolution;

				// Render shadows
				with (other)
				{
					var _enableShadows = EnableShadows;
					EnableShadows &= other.EnableShadows; // Temporarily modify renderer's EnableShadows
					__render_shadowmaps();
					EnableShadows = _enableShadows;
				}

				// Fill cubemap
				bbmod_render_pass_set(BBMOD_ERenderPass.ReflectionCapture);

				while (_cubemap.set_target())
				{
					draw_clear(c_black);
					var _rqi = 0;
					repeat (array_length(_renderQueues))
					{
						_renderQueues[_rqi++].submit();
					}
					_cubemap.reset_target();
				}

				// Prefilter and apply
				_cubemap.to_single_surface();
				_cubemap.to_octahedron();
				var _sprite = _cubemap.prefilter_ibl();
				set_sprite(_sprite);

				NeedsUpdate = false;
			}
		}

		var _to = (global.__bbmodImageBasedLight != undefined)
			? global.__bbmodImageBasedLight.Texture
			: sprite_get_texture(BBMOD_SprBlack, 0);

		var _reflectionProbe = bbmod_reflection_probe_find(bbmod_camera_get_position());
		if (_reflectionProbe != undefined)
		{
			_to = sprite_get_texture(_reflectionProbe.Sprite, 0);
		}

		var _world = matrix_get(matrix_world);
		matrix_set(matrix_world, matrix_build_identity());

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		gpu_set_blendenable(false);
		gpu_set_tex_filter(false);

		var _height = 128;
		var _width = _height * 8;

		var _surOld = __surProbe1;
		__surProbe1 = bbmod_surface_check(__surProbe1, _width, _height, surface_rgba8unorm, false);
		__surProbe2 = bbmod_surface_check(__surProbe2, _width, _height, surface_rgba8unorm, false);

		if (__surProbe1 != _surOld)
		{
			surface_set_target(__surProbe1);
			draw_clear_alpha(c_black, 0);

			var _camera = camera_create();
			camera_set_view_size(_camera, _width, _height);
			camera_apply(_camera);

			shader_set(BBMOD_ShMixRGBM);
			texture_set_stage(shader_get_sampler_index(BBMOD_ShMixRGBM, "u_texTo"), _to);
			shader_set_uniform_f(shader_get_uniform(BBMOD_ShMixRGBM, "u_fFactor"), 1.0);
			draw_surface(__surProbe2, 0, 0);
			shader_reset();

			surface_reset_target();
			camera_destroy(_camera);
		}

		{
			surface_set_target(__surProbe2);
			draw_clear_alpha(c_black, 0);
			var _camera = camera_create();
			camera_set_view_size(_camera, _width, _height);
			camera_apply(_camera);
			draw_surface(__surProbe1, 0, 0);
			surface_reset_target();
			camera_destroy(_camera);
		}

		{
			surface_set_target(__surProbe1);
			draw_clear_alpha(c_black, 0);

			var _camera = camera_create();
			camera_set_view_size(_camera, _width, _height);
			camera_apply(_camera);

			shader_set(BBMOD_ShMixRGBM);
			texture_set_stage(shader_get_sampler_index(BBMOD_ShMixRGBM, "u_texTo"), _to);
			shader_set_uniform_f(shader_get_uniform(BBMOD_ShMixRGBM, "u_fFactor"), 0.1);
			draw_surface(__surProbe2, 0, 0);
			shader_reset();

			surface_reset_target();
			camera_destroy(_camera);
		}

		gpu_pop_state();

		matrix_set(matrix_world, _world);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		global.__bbmodReflectionProbeTexture = surface_get_texture(__surProbe1);
		bbmod_camera_set_exposure(_exposure);
	};

	/// @func __render_gizmo_and_instance_ids()
	///
	/// @desc Renders gizmo and instance IDs into dedicated surfaces.
	///
	/// @private
	static __render_gizmo_and_instance_ids = function ()
	{
		static _renderQueues = bbmod_render_queues_get();

		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);
		var _renderWidth = get_render_width();
		var _renderHeight = get_render_height();

		var _editMode = (EditMode && Gizmo);
		var _mouseX = window_mouse_get_x();
		var _mouseY = window_mouse_get_y();
		var _mouseOver = (_mouseX >= X && _mouseX < X + get_width()
			&& _mouseY >= Y && _mouseY < Y + get_height());
		var _continueMousePick = EnableMousepick;
		var _gizmoSize;

		if (_editMode)
		{
			_gizmoSize = Gizmo.Size;

			if (_projection[11] != 0.0)
			{
				Gizmo.Size = _gizmoSize
					* Gizmo.Position.Sub(bbmod_camera_get_position()).Length() / 100.0;
			}
		}

		////////////////////////////////////////////////////////////////////////
		// Gizmo select
		if (_editMode
			&& _continueMousePick
			&& _mouseOver
			&& mouse_check_button_pressed(Gizmo.ButtonDrag))
		{
			bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

			__surSelect = bbmod_surface_check(__surSelect, _renderWidth, _renderHeight, surface_rgba8unorm, true);
			surface_set_target(__surSelect);
			draw_clear_alpha(0, 0.0);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
			Gizmo.submit(Gizmo.MaterialsSelect);
			bbmod_material_reset();
			surface_reset_target();

			if (select_gizmo(_mouseX, _mouseY))
			{
				Gizmo.IsEditing = true;
				_continueMousePick = false;
			}
		}

		////////////////////////////////////////////////////////////////////////
		// Instance IDs
		var _mousePickInstance = (_editMode && _continueMousePick
			&& _mouseOver && mouse_check_button_pressed(ButtonSelect));

		if (_mousePickInstance || RenderInstanceIDs)
		{
			__surSelect = bbmod_surface_check(__surSelect, _renderWidth, _renderHeight, surface_rgba8unorm, true);

			surface_set_target(__surSelect);
			draw_clear_alpha(0, 0.0);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
	
			bbmod_render_pass_set(BBMOD_ERenderPass.Id);

			var _rqi = 0;
			repeat (array_length(_renderQueues))
			{
				_renderQueues[_rqi++].submit();
			}
			bbmod_material_reset();

			surface_reset_target();

			// Select instance
			if (_mousePickInstance)
			{
				if (!keyboard_check(KeyMultiSelect))
				{
					Gizmo.clear_selection();
				}

				var _id = get_instance_id(_mouseX, _mouseY);
				if (_id != 0)
				{
					Gizmo.toggle_select(_id).update_position();
					Gizmo.Size = _gizmoSize
						* Gizmo.Position.Sub(bbmod_camera_get_position()).Length() / 100.0;
				}
			}
		}

		if (_editMode && !ds_list_empty(Gizmo.Selected))
		{
			////////////////////////////////////////////////////////////////////
			// Instance highlight
			__surInstanceHighlight = bbmod_surface_check(
				__surInstanceHighlight, _renderWidth, _renderHeight, surface_rgba8unorm, true);

			surface_set_target(__surInstanceHighlight);
			draw_clear_alpha(0, 0.0);

			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
	
			bbmod_render_pass_set(BBMOD_ERenderPass.Id);

			var _selectedInstances = Gizmo.Selected;
			var _rqi = 0;
			repeat (array_length(_renderQueues))
			{
				_renderQueues[_rqi++].submit(_selectedInstances);
			}
			bbmod_material_reset();

			surface_reset_target();

			////////////////////////////////////////////////////////////////////
			// Gizmo
			bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

			__surGizmo = bbmod_surface_check(__surGizmo, _renderWidth, _renderHeight, surface_rgba8unorm, true);
			surface_set_target(__surGizmo);
			draw_clear_alpha(0, 0.0);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
			Gizmo.submit();
			bbmod_material_reset();
			surface_reset_target();
		}

		if (_editMode)
		{
			Gizmo.Size = _gizmoSize;
		}
	};

	static __render_ssao = function (_surDepth, _projection)
	{
		if (EnableSSAO)
		{
			var _width = get_render_width() * SSAOScale;
			var _height = get_render_height() * SSAOScale;

			__surSSAO = bbmod_surface_check(__surSSAO, _width, _height, surface_rgba8unorm, false);
			__surWork = bbmod_surface_check(__surWork, _width, _height, surface_rgba8unorm, false);

			bbmod_ssao_draw(SSAORadius * SSAOScale, SSAOPower, SSAOAngleBias,
				SSAODepthRange, __surSSAO, __surWork, _surDepth, _projection,
				bbmod_camera_get_zfar(), SSAOSelfOcclusionBias, SSAOBlurDepthRange);

			bbmod_shader_set_global_sampler(
				BBMOD_U_SSAO, surface_get_texture(__surSSAO));
		}
		else
		{
			bbmod_shader_set_global_sampler(
				BBMOD_U_SSAO, sprite_get_texture(BBMOD_SprWhite, 0));
		}
	};

	/// @func render(_clearQueues=true)
	///
	/// @desc Renders all added [renderables](./BBMOD_BaseRenderer.Renderables.html)
	/// to the current render target.
	///
	/// @param {Bool} [_clearQueues] If true then all render queues are cleared
	/// at the end of this method. Default value is `true`.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	static render = function (_clearQueues=true)
	{
		global.__bbmodRendererCurrent = self;

		static _renderQueues = bbmod_render_queues_get();

		var _world = matrix_get(matrix_world);
		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);

		var i = 0;
		repeat (array_length(Renderables))
		{
			with (Renderables[i++])
			{
				render();
			}
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Reflection probes
		//
		__render_reflection_probes();

		////////////////////////////////////////////////////////////////////////
		//
		// Edit mode
		//
		__render_gizmo_and_instance_ids();

		////////////////////////////////////////////////////////////////////////
		//
		// Shadow map
		//
		__render_shadowmaps();

		////////////////////////////////////////////////////////////////////////
		//
		// Background
		//
		bbmod_shader_set_global_f(BBMOD_U_ZFAR, bbmod_camera_get_zfar());

		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		bbmod_render_pass_set(BBMOD_ERenderPass.Background);

		var _rqi = 0;
		repeat (array_length(_renderQueues))
		{
			_renderQueues[_rqi++].submit();
		}
		bbmod_material_reset();

		////////////////////////////////////////////////////////////////////////
		//
		// Forward pass
		//
		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		_rqi = 0;
		repeat (array_length(_renderQueues))
		{
			_renderQueues[_rqi++].submit();
		}
		bbmod_material_reset();

		////////////////////////////////////////////////////////////////////////
		//
		// Alpha pass
		//
		bbmod_render_pass_set(BBMOD_ERenderPass.Alpha);

		_rqi = 0;
		repeat (array_length(_renderQueues))
		{
			var _queue = _renderQueues[_rqi++].submit();
			if (_clearQueues)
			{
				_queue.clear();
			}
		}
		bbmod_material_reset();

		// Reset render pass back to Forward at the end!
		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		// Unset in case it gets destroyed when the room changes etc.
		bbmod_shader_unset_global(BBMOD_U_SHADOWMAP);

		matrix_set(matrix_world, _world);
		return self;
	};

	/// @func present()
	///
	/// @desc Presents the rendered graphics on the screen, with post-processing
	/// applied (if {@link BBMOD_BaseRenderer.PostProcessor} is defined).
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	///
	/// @note If {@link BBMOD_BaseRenderer.UseAppSurface} is `false`, then this only
	/// draws the gizmo and selected instances. The world matrix is automatically
	/// set to identity before drawing the surfaces and then reset back.
	static present = function ()
	{
		global.__bbmodRendererCurrent = self;

		var _world = matrix_get(matrix_world);
		matrix_set(matrix_world, matrix_build_identity());

		static _gpuState = undefined;
		if (_gpuState == undefined)
		{
			gpu_push_state();
			gpu_set_state(bbmod_gpu_get_default_state());
			gpu_set_tex_filter(true);
			gpu_set_tex_repeat(false);
			gpu_set_blendenable(true);
			_gpuState = gpu_get_state();
			gpu_pop_state();
		}

		var _width = get_width();
		var _height = get_height();
		var _texelWidth = 1.0 / _width;
		var _texelHeight = 1.0 / _height;

		if (!UseAppSurface // Can't use post-processing even if it was defined
			|| (PostProcessor == undefined || !PostProcessor.Enabled))
		{
			////////////////////////////////////////////////////////////////////
			//
			// Post-processing DISABLED
			//
			gpu_push_state();
			gpu_set_state(_gpuState);

			if (UseAppSurface)
			{
				gpu_set_blendenable(false);
				draw_surface_stretched(application_surface, X, Y, _width, _height);
				gpu_set_blendenable(true);
			}

			if (EditMode && Gizmo && !ds_list_empty(Gizmo.Selected))
			{
				////////////////////////////////////////////////////////////////
				// Highlighted instances
				if (!ds_list_empty(Gizmo.Selected)
					&& surface_exists(__surInstanceHighlight))
				{
					var _shader = BBMOD_ShInstanceHighlight;
					shader_set(_shader);
					shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"),
						_texelWidth, _texelHeight);
					shader_set_uniform_f(shader_get_uniform(_shader, "u_vColor"),
						InstanceHighlightColor.Red / 255.0,
						InstanceHighlightColor.Green / 255.0,
						InstanceHighlightColor.Blue / 255.0,
						InstanceHighlightColor.Alpha);
					draw_surface_stretched(__surInstanceHighlight, X, Y, _width, _height);
					shader_reset();
				}
			
				////////////////////////////////////////////////////////////////
				// Gizmo
				if (surface_exists(__surGizmo))
				{
					draw_surface_stretched(__surGizmo, X, Y, _width, _height);
				}
			}

			gpu_pop_state();
		}
		else
		{
			////////////////////////////////////////////////////////////////////
			//
			// Post-processing ENABLED
			//
			__surFinal = bbmod_surface_check(__surFinal, _width, _height, surface_rgba8unorm, false);

			gpu_push_state();
			gpu_set_state(_gpuState);

			surface_set_target(__surFinal);

			draw_surface_stretched(application_surface, 0, 0, _width, _height);

			if (EditMode && Gizmo && !ds_list_empty(Gizmo.Selected))
			{
				////////////////////////////////////////////////////////////////
				// Highlighted instances
				if (!ds_list_empty(Gizmo.Selected)
					&& surface_exists(__surInstanceHighlight))
				{
					var _shader = BBMOD_ShInstanceHighlight;
					shader_set(_shader);
					shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"),
						_texelWidth, _texelHeight);
					shader_set_uniform_f(shader_get_uniform(_shader, "u_vColor"),
						InstanceHighlightColor.Red / 255.0,
						InstanceHighlightColor.Green / 255.0,
						InstanceHighlightColor.Blue / 255.0,
						InstanceHighlightColor.Alpha);
					draw_surface_stretched(__surInstanceHighlight, 0, 0, _width, _height);
					shader_reset();
				}
			
				////////////////////////////////////////////////////////////////
				// Gizmo
				if (surface_exists(__surGizmo))
				{
					draw_surface_stretched(__surGizmo, 0, 0, _width, _height);
				}
			}

			surface_reset_target();
			gpu_pop_state();

			PostProcessor.draw(__surFinal, X, Y);
		}

		matrix_set(matrix_world, _world);

		return self;
	};

	static destroy = function ()
	{
		if (global.__bbmodRendererCurrent == self)
		{
			global.__bbmodRendererCurrent = undefined;
		}

		if (surface_exists(__surSelect))
		{
			surface_free(__surSelect);
		}

		if (surface_exists(__surInstanceHighlight))
		{
			surface_free(__surInstanceHighlight);
		}

		if (surface_exists(__surGizmo))
		{
			surface_free(__surGizmo);
		}

		if (surface_exists(__surFinal))
		{
			surface_free(__surFinal);
		}

		if (surface_exists(__surProbe1))
		{
			surface_free(__surProbe1);
		}

		if (surface_exists(__surProbe2))
		{
			surface_free(__surProbe2);
		}

		if (surface_exists(__surSSAO))
		{
			surface_free(__surSSAO);
		}

		if (surface_exists(__surWork))
		{
			surface_free(__surWork);
		}

		if (UseAppSurface)
		{
			application_surface_enable(false);
			application_surface_draw_enable(true);
		}

		ds_list_destroy(__shadowmapLights);
		ds_list_destroy(__shadowmapHealth);

		var _key = ds_map_find_first(__shadowmapSurfaces);
		repeat (ds_map_size(__shadowmapSurfaces))
		{
			var _surface = __shadowmapSurfaces[? _key];
			if (surface_exists(_surface))
			{
				surface_free(_surface);
			}
			_key = ds_map_find_next(__shadowmapSurfaces, _key);
		}
		ds_map_destroy(__shadowmapSurfaces);

		_key = ds_map_find_first(__shadowmapCubes);
		repeat (ds_map_size(__shadowmapCubes))
		{
			__shadowmapCubes[? _key].destroy();
			_key = ds_map_find_next(__shadowmapCubes, _key);
		}
		ds_map_destroy(__shadowmapCubes);

		return undefined;
	};
}
