/// @func BBMOD_Renderer()
///
/// @extends BBMOD_Class
///
/// @desc Implements a basic renderer, which executes
/// [render commands](./BBMOD_RenderCommand.html) created with method
/// [render](./BBMOD_Model.render.html).
///
/// Currently supports two render passes -
/// [BBMOD_ERenderPass.Shadows](./BBMOD_ERenderPass.Shadows.html) and
/// [BBMOD_ERenderPass.Forward](./BBMOD_ERenderPass.Forward.html).
///
/// @example
/// Following code is a typical use of the renderer.
/// ```gml
/// // Create event
/// renderer = new BBMOD_Renderer()
///     .add(OCharacter)
///     .add(OTree)
///     .add(OTerrain)
///     .add(OSky);
/// renderer.UseAppSurface = true;
/// renderer.EnableShadows = true;
///
/// camera = new BBMOD_Camera();
/// camera.FollowObject = OPlayer;
///
/// // Step event
/// camera.set_mouselook(true);
/// camera.update(delta_time);
/// renderer.update(delta_time);
///
/// // Draw event
/// camera.apply();
/// renderer.render();
///
/// // Post-Draw event
/// renderer.present();
///
/// // Clean Up event
/// renderer.destroy();
/// ```
///
/// @see BBMOD_IRenderable
/// @see BBMOD_Camera
function BBMOD_Renderer()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

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
	/// {@link BBMOD_Renderer.get_instance_id} for mouse-picking instances.
	/// Default value is `false`.
	RenderInstanceIDs = false;

	/// @var {Id.Surface} Surface for rendering highlight of selected instances.
	/// @private
	SurInstanceHighlight = noone;

	/// @var {Struct.BBMOD_Color} Outline color of instances selected by gizmo.
	/// Default value is {@link BBMOD_C_ORANGE}.
	/// @see BBMOD_Renderer.Gizmo
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
	/// @see BBMOD_Renderer.EditMode
	ButtonSelect = mb_left;

	/// @var {Constant.VirtualKey} The keyboard key used to add/remove instances
	/// from multiple selection when edit mode is enabled. Default value is
	/// `vk_shift`.
	/// @see BBMOD_Renderer.EditMode
	KeyMultiSelect = vk_shift;

	/// @var {Struct.BBMOD_Gizmo} A gizmo for transforming instances when
	/// {@link BBMOD_Renderer.EditMode} is enabled. This is by default `undefined`.
	/// @see BBMOD_Gizmo
	Gizmo = undefined;

	/// @var {Id.Surface} A surface containing the gizmo. Used to enable
	/// z-testing against itself, but ingoring the scene geometry.
	/// @private
	SurGizmo = noone;

	/// @var {Id.Surface} Surface for mouse-picking the gizmo.
	/// @private
	SurSelect = noone;

	/// @var {Array<Struct.BBMOD_IRenderable>} An array of renderable objects
	/// and structs. These are automatically rendered in
	/// {@link BBMOD_Renderer.render}.
	/// @readonly
	/// @see BBMOD_Renderer.add
	/// @see BBMOD_Renderer.remove
	/// @see BBMOD_IRenderable
	Renderables = [];

	/// @var {Bool} Set to `true` to enable the `application_surface`.
	/// Use method {@link BBMOD_Renderer.present} to draw the
	/// `application_surface` to the screen. Defaults to `false`.
	UseAppSurface = false;

	/// @var {Real} Resolution multiplier for the `application_surface`.
	/// {@link BBMOD_Renderer.UseAppSurface} must be enabled for this to
	/// have any effect. Defaults to 1. Use lower values to improve framerate.
	RenderScale = 1.0;

	/// @var {Bool} Enables rendering into a G-buffer in the deferred pass.
	/// Defaults to `false`.
	/// @see BBMOD_ERenderPass.Deferred
	EnableGBuffer = false;

	/// @var {Real} Resolution multiplier for the G-buffer surface. Defaults
	/// to 1.
	GBufferScale = 1.0;

	/// @var {Id.Surface} The G-buffer surface.
	/// @private
	SurGBuffer = noone;

	/// @var {Bool} Enables screen-space ambient occlusion. This requires
	/// the G-buffer. Defaults to `false`. Enabling this requires the
	/// [SSAO submodule](./SSAOSubmodule.html)!
	/// @see BBMOD_Renderer.EnableGBuffer
	EnableSSAO = false;

	/// @var {Id.Surface} The SSAO surface.
	/// @private
	SurSSAO = noone;

	/// @var {Id.Surface} Surface used for blurring SSAO.
	/// @private
	SurWork = noone;

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

	/// @var {Bool} Enables rendering into a shadowmap in the shadows render pass.
	/// Defauls to `false`.
	/// @see BBMOD_Renderer.ShadowmapArea
	/// @see BBMOD_Renderer.ShadowmapResolution
	EnableShadows = false;

	/// @var {Id.Surface} The surface used for rendering the scene's depth from the
	/// directional light's view.
	/// @private
	__surShadowmap = noone;

	/// @var {Real} The area captured by the shadowmap. Defaults to 1024.
	/// @obsolete This has been replaced with {@link BBMOD_DirectionalLight.ShadowmapArea}.
	ShadowmapArea = 1024.

	/// @var {Real} The resolution of the shadowmap surface. Must be power of 2.
	/// Defaults to 4096.
	/// @obsolete This has been replaced with {@link BBMOD_Light.ShadowmapArea}.
	ShadowmapResolution = 4096;

	/// @var {Real} When rendering shadows, offsets vertex position by its normal
	/// scaled by this value. Defaults to 1. Increasing the value can remove some
	/// artifacts but using too high value could make the objects appear flying
	/// above the ground.
	ShadowmapNormalOffset = 1;

	/// @var {Bool} Enables post-processing effects. Defaults to `false`. Enabling
	/// this requires the [Post-processing submodule](./PostProcessingSubmodule.html)!
	///
	/// @note {@link BBMOD_Renderer.UseAppSurface} must be enabled for this to
	/// have any effect!
	///
	/// @obsolete Post-processing is now handled through
	/// {@link BBMOD_Renderer.PostProcessor}!
	EnablePostProcessing = false;

	/// @var {Struct.BBMOD_PostProcessor} Handles post-processing effects if
	/// isn't `undefined` and {@link BBMOD_Renderer.UseAppSurface} is enabled.
	/// Default value is `undefined`.
	/// @see BBMOD_PostProcessor
	PostProcessor = undefined;

	/// @var {Id.Surface}
	/// @private
	__surFinal = noone;

	/// @func get_width()
	///
	/// @desc Retrieves the width of the renderer on the screen.
	///
	/// @return {Real} The width of the renderer on the screen.
	static get_width = function () {
		gml_pragma("forceinline");
		return max((Width == undefined) ? window_get_width() : Width, 1);
	};

	/// @func get_height()
	///
	/// @desc Retrieves the height of the renderer on the screen.
	///
	/// @return {Real} The height of the renderer on the screen.
	static get_height = function () {
		gml_pragma("forceinline");
		return max((Height == undefined) ? window_get_height() : Height, 1);
	};

	/// @func get_render_width()
	///
	/// @desc Retrieves the width of the renderer with
	///
	/// {@link BBMOD_Renderer.RenderScale} applied.
	///
	/// @return {Real} The width of the renderer after `RenderScale` is applied.
	static get_render_width = function () {
		gml_pragma("forceinline");
		return max(get_width() * RenderScale, 1);
	};

	/// @func get_render_height()
	///
	/// @desc Retrieves the height of the renderer with
	/// {@link BBMOD_Renderer.RenderScale} applied.
	///
	/// @return {Real} The height of the renderer after `RenderScale` is applied.
	static get_render_height = function () {
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
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	static set_position = function (_x, _y) {
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
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	static set_size = function (_width, _height) {
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
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	static set_rectangle = function (_x, _y, _width, _height) {
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
	/// @note {@link BBMOD_Renderer.Gizmo} must be defined.
	///
	/// @private
	static select_gizmo = function (_screenX, _screenY) {
		_screenX = clamp(_screenX - X, 0, get_width()) * RenderScale;
		_screenY = clamp(_screenY - Y, 0, get_height()) * RenderScale;

		Gizmo.EditAxis = BBMOD_EEditAxis.None;

		var _pixel = surface_getpixel_ext(SurSelect, _screenX, _screenY);
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
	/// @note {@link BBMOD_Renderer.RenderInstanceIDs} must be enabled.
	static get_instance_id = function (_screenX, _screenY) {
		gml_pragma("forceinline");
		if (!surface_exists(SurSelect))
		{
			return 0;
		}
		_screenX = clamp(_screenX - X, 0, get_width()) * RenderScale;
		_screenY = clamp(_screenY - Y, 0, get_height()) * RenderScale;
		return surface_getpixel_ext(SurSelect, _screenX, _screenY);
	};

	/// @func add(_renderable)
	///
	/// @desc Adds a renderable object or struct to the renderer.
	///
	/// @param {Struct.BBMOD_IRenderable} _renderable The renderable object or
	/// struct to add.
	///
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	///
	/// @see BBMOD_Renderer.remove
	/// @see BBMOD_IRenderable
	static add = function (_renderable) {
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
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	///
	/// @see BBMOD_Renderer.add
	/// @see BBMOD_IRenderable
	static remove = function (_renderable) {
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
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	static update = function (_deltaTime) {
		global.__bbmodRendererCurrent = self;

		if (UseAppSurface)
		{
			application_surface_enable(true);
			application_surface_draw_enable(false);

			var _surfaceWidth = get_render_width();
			var _surfaceHeight = get_render_height();

			if (surface_exists(application_surface)
				&& (surface_get_width(application_surface) != _surfaceWidth
				|| surface_get_height(application_surface) != _surfaceHeight))
			{
				surface_resize(application_surface, _surfaceWidth, _surfaceHeight);
			}
		}

		if (Gizmo && EditMode)
		{
			Gizmo.update(delta_time);
		}

		return self;
	};

	/// @func __render_shadowmap(_light)
	///
	/// @desc Renders a shadowmap for given light.
	///
	/// @param {Struct.BBMOD_Light} _light The light to render a shadowmap for.
	///
	/// @note This modifies render pass and view and projection matrices and
	/// for optimization reasons it does not reset them back! Make sure to do
	/// that yourself in the calling function if needed.
	///
	/// @private
	static __render_shadowmap = function (_light) {
		gml_pragma("forceinline");

		static _renderQueues = bbmod_render_queues_get();

		bbmod_render_pass_set(BBMOD_ERenderPass.Shadows);

		__surShadowmap = bbmod_surface_check(
			__surShadowmap, _light.ShadowmapResolution, _light.ShadowmapResolution);

		surface_set_target(__surShadowmap);
		draw_clear(c_red);
		matrix_set(matrix_view, _light.__getViewMatrix());
		matrix_set(matrix_projection, _light.__getProjMatrix());
		bbmod_shader_set_global_f("bbmod_ZFar", _light.__getZFar());

		var _rqi = 0;
		repeat (array_length(_renderQueues))
		{
			_renderQueues[_rqi++].submit();
		}

		surface_reset_target();
	};

	/// @func render(_clearQueues=true)
	///
	/// @desc Renders all added [renderables](./BBMOD_Renderer.Renderables.html)
	/// to the current render target.
	///
	/// @param {Bool} [_clearQueues] If true then all render queues are cleared
	/// at the end of this method. Default value is `true`.
	///
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	static render = function (_clearQueues=true) {
		global.__bbmodRendererCurrent = self;

		static _renderQueues = bbmod_render_queues_get();

		var _world = matrix_get(matrix_world);
		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);
		var _renderWidth = get_render_width();
		var _renderHeight = get_render_height();

		var i = 0;
		repeat (array_length(Renderables))
		{
			with (Renderables[i++])
			{
				render();
			}
		}

		bbmod_material_reset();

		////////////////////////////////////////////////////////////////////////
		//
		// Edit mode
		//
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
			Gizmo.Size = _gizmoSize
				* Gizmo.Position.Sub(bbmod_camera_get_position()).Length() / 100.0;
		}

		////////////////////////////////////////////////////////////////////////
		// Gizmo select
		if (_editMode
			&& _continueMousePick
			&& _mouseOver
			&& mouse_check_button_pressed(Gizmo.ButtonDrag))
		{
			SurSelect = bbmod_surface_check(SurSelect, _renderWidth, _renderHeight);
			surface_set_target(SurSelect);
			draw_clear_alpha(0, 0.0);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
			Gizmo.submit(Gizmo.MaterialsSelect);
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
			SurSelect = bbmod_surface_check(SurSelect, _renderWidth, _renderHeight);

			surface_set_target(SurSelect);
			draw_clear_alpha(0, 0.0);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
	
			bbmod_render_pass_set(BBMOD_ERenderPass.Id);

			var _rqi = 0;
			repeat (array_length(_renderQueues))
			{
				_renderQueues[_rqi++].submit();
			}

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
			SurInstanceHighlight = bbmod_surface_check(
				SurInstanceHighlight, _renderWidth, _renderHeight);

			surface_set_target(SurInstanceHighlight);
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

			surface_reset_target();

			////////////////////////////////////////////////////////////////////
			// Gizmo
			bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

			SurGizmo = bbmod_surface_check(SurGizmo, _renderWidth, _renderHeight);
			surface_set_target(SurGizmo);
			draw_clear_alpha(0, 0.0);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
			Gizmo.submit();
			surface_reset_target();
		}

		if (_editMode)
		{
			Gizmo.Size = _gizmoSize;
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Shadow map
		//
		var _shadowCaster = undefined;
		var _shadowCasterIndex = -1;
		var _shadowmapMatrix;
		var _shadowmapZFar;

		if (EnableShadows)
		{
			var _light = bbmod_light_directional_get();
			if (_light != undefined
				&& _light.CastShadows
				&& _light.__getZFar != undefined
				&& _light.__getShadowmapMatrix != undefined)
			{
				// Directional light
				_shadowCaster = _light;
				_shadowmapMatrix = _light.__getShadowmapMatrix();
				_shadowmapZFar = _light.__getZFar();
			}
			else
			{
				// Punctual lights
				var i = 0;
				repeat (array_length(global.__bbmodPunctualLights))
				{
					var _light = global.__bbmodPunctualLights[i];
					if (_light.CastShadows
						&& _light.__getZFar != undefined
						&& _light.__getShadowmapMatrix != undefined)
					{
						_shadowCaster = _light;
						_shadowCasterIndex = i;
						_shadowmapMatrix = _light.__getShadowmapMatrix();
						_shadowmapZFar = _light.__getZFar();
						break;
					}
					++i;
				}
			}
		}

		if (_shadowCaster != undefined)
		{
			__render_shadowmap(_shadowCaster);
		}
		else if (surface_exists(__surShadowmap))
		{
			surface_free(__surShadowmap);
			__surShadowmap = noone;
		}

		bbmod_shader_set_global_f("bbmod_ZFar", bbmod_camera_get_zfar());

		////////////////////////////////////////////////////////////////////////
		//
		// G-buffer pass
		//
		if (EnableGBuffer)
		{
			var _width = _renderWidth * GBufferScale;
			var _height = _renderHeight * GBufferScale;
			SurGBuffer = bbmod_surface_check(SurGBuffer, _width, _height);
			surface_set_target(SurGBuffer);
			draw_clear(c_white);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
			bbmod_render_pass_set(BBMOD_ERenderPass.Deferred);
			var _rqi = 0;
			repeat (array_length(_renderQueues))
			{
				_renderQueues[_rqi++].submit();
			}
			surface_reset_target();
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Render SSAO
		//
		if (EnableGBuffer && EnableSSAO)
		{
			bbmod_material_reset();
			var _width = _renderWidth * SSAOScale;
			var _height = _renderHeight * SSAOScale;
			SurSSAO = bbmod_surface_check(SurSSAO, _width, _height);
			SurWork = bbmod_surface_check(SurWork, _width, _height);
			bbmod_ssao_draw(SSAORadius * SSAOScale, SSAOPower, SSAOAngleBias,
				SSAODepthRange, SurSSAO, SurWork, SurGBuffer, _projection,
				bbmod_camera_get_zfar());
			bbmod_material_reset();
			bbmod_shader_set_global_sampler(
				"bbmod_SSAO", surface_get_texture(SurSSAO));
		}
		else
		{
			bbmod_shader_set_global_sampler(
				"bbmod_SSAO", sprite_get_texture(BBMOD_SprWhite, 0));
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Forward pass
		//
		bbmod_shader_set_global_sampler("bbmod_GBuffer", EnableGBuffer
			? surface_get_texture(SurGBuffer)
			: sprite_get_texture(BBMOD_SprWhite, 0));

		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		if (surface_exists(__surShadowmap))
		{
			var _shadowmapTexture = surface_get_texture(__surShadowmap);
			bbmod_shader_set_global_f("bbmod_ShadowmapEnableVS", 1.0);
			bbmod_shader_set_global_f("bbmod_ShadowmapEnablePS", 1.0);
			bbmod_shader_set_global_sampler("bbmod_Shadowmap", _shadowmapTexture);
			bbmod_shader_set_global_sampler_mip_enable("bbmod_Shadowmap", true);
			bbmod_shader_set_global_sampler_filter("bbmod_Shadowmap", true);
			bbmod_shader_set_global_sampler_repeat("bbmod_Shadowmap", false);
			bbmod_shader_set_global_f2("bbmod_ShadowmapTexel",
				texture_get_texel_width(_shadowmapTexture),
				texture_get_texel_height(_shadowmapTexture));
			bbmod_shader_set_global_f("bbmod_ShadowmapArea", _shadowmapZFar);
			bbmod_shader_set_global_f("bbmod_ShadowmapNormalOffset", ShadowmapNormalOffset);
			bbmod_shader_set_global_matrix_array("bbmod_ShadowmapMatrix", _shadowmapMatrix);
			bbmod_shader_set_global_f("bbmod_ShadowCasterIndex", _shadowCasterIndex);
		}
		else
		{
			bbmod_shader_set_global_f("bbmod_ShadowmapEnableVS", 0.0);
			bbmod_shader_set_global_f("bbmod_ShadowmapEnablePS", 0.0);
		}

		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		var _rqi = 0;
		repeat (array_length(_renderQueues))
		{
			var _queue = _renderQueues[_rqi++].submit();
			if (_clearQueues)
			{
				_queue.clear();
			}
		}

		// Unset in case it gets destroyed when the room changes etc.
		bbmod_shader_unset_global("bbmod_Shadowmap");
		bbmod_shader_unset_global("bbmod_SSAO");
		bbmod_shader_unset_global("bbmod_GBuffer");

		bbmod_material_reset();

		matrix_set(matrix_world, _world);
		return self;
	};

	/// @func present()
	///
	/// @desc Presents the rendered graphics on the screen, with post-processing
	/// applied (if {@link BBMOD_Renderer.PostProcessor} is defined).
	///
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	///
	/// @note If {@link BBMOD_Renderer.UseAppSurface} is `false`, then this only
	/// draws the gizmo and selected instances.
	static present = function () {
		global.__bbmodRendererCurrent = self;

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
					&& surface_exists(SurInstanceHighlight))
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
					draw_surface_stretched(SurInstanceHighlight, X, Y, _width, _height);
					shader_reset();
				}
			
				////////////////////////////////////////////////////////////////
				// Gizmo
				if (surface_exists(SurGizmo))
				{
					draw_surface_stretched(SurGizmo, X, Y, _width, _height);
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
			var _world = matrix_get(matrix_world);

			__surFinal = bbmod_surface_check(__surFinal, _width, _height);

			gpu_push_state();
			gpu_set_state(_gpuState);

			surface_set_target(__surFinal);
			matrix_set(matrix_world, matrix_build_identity());

			draw_surface_stretched(application_surface, 0, 0, _width, _height);

			if (EditMode && Gizmo && !ds_list_empty(Gizmo.Selected))
			{
				////////////////////////////////////////////////////////////////
				// Highlighted instances
				if (!ds_list_empty(Gizmo.Selected)
					&& surface_exists(SurInstanceHighlight))
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
					draw_surface_stretched(SurInstanceHighlight, 0, 0, _width, _height);
					shader_reset();
				}
			
				////////////////////////////////////////////////////////////////
				// Gizmo
				if (surface_exists(SurGizmo))
				{
					draw_surface_stretched(SurGizmo, 0, 0, _width, _height);
				}
			}

			surface_reset_target();
			matrix_set(matrix_world, _world);
			gpu_pop_state();

			PostProcessor.draw(__surFinal, X, Y);
		}

		if (surface_exists(__surShadowmap))
		{
			draw_surface_stretched(__surShadowmap, 0, 0, 256, 256);
		}

		return self;
	};

	static destroy = function () {
		Class_destroy();

		if (global.__bbmodRendererCurrent == self)
		{
			global.__bbmodRendererCurrent = undefined;
		}

		if (surface_exists(SurGBuffer))
		{
			surface_free(SurGBuffer);
		}

		if (surface_exists(SurSSAO))
		{
			surface_free(SurSSAO);
		}

		if (surface_exists(SurWork))
		{
			surface_free(SurWork);
		}

		if (surface_exists(SurSelect))
		{
			surface_free(SurSelect);
		}

		if (surface_exists(SurInstanceHighlight))
		{
			surface_free(SurInstanceHighlight);
		}

		if (surface_exists(SurGizmo))
		{
			surface_free(SurGizmo);
		}

		if (surface_exists(__surShadowmap))
		{
			surface_free(__surShadowmap);
		}

		if (surface_exists(__surFinal))
		{
			surface_free(__surFinal);
		}

		if (UseAppSurface)
		{
			application_surface_enable(false);
			application_surface_draw_enable(true);
		}

		return undefined;
	};
}
