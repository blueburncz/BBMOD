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

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Real} The X position of the renderer on the screen. Default value
	/// is 0.
	X = 0;

	/// @var {Real} The Y position of the renderer on the screen. Default value
	/// is 0.
	Y = 0;

	/// @var {Real/Undefined} The width of the renderer on the screen.
	/// If `undefined` then the window width is used. Default value is
	/// `undefined`.
	Width = undefined;

	/// @var {Real/Undefined} The height of the renderer on the screen.
	/// If `undefined` then the window height is used. Default value is
	/// `undefined`.
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

	/// @var {Constant.MouseButton} The mouse button used to select instances when
	/// edit mode is enabled. Default value is `mb_left`.
	/// @see BBMOD_Renderer.EditMode
	ButtonSelect = mb_left;

	/// @var {Constant.VirtualKey} The keyboard key used to add/remove instances
	/// from multiple selection when edit mode is enabled. Default value is `vk_shift`.
	/// @see BBMOD_Renderer.EditMode
	KeyMultiSelect = vk_shift;

	/// @var {Struct.BBMOD_Gizmo/Undefined} A gizmo for transforming instances when
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

	/// @var <Struct.BBMOD_IRenderable>} An array of renderable objects and
	/// structs.
	/// These are automatically rendered in {@link BBMOD_Renderer.render}.
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

	/// @var {Bool} Enables rendering into a shadowmap in the shadows render pass.
	/// Defauls to `false`.
	/// @see BBMOD_Renderer.ShadowmapArea
	/// @see BBMOD_Renderer.ShadowmapResolution
	EnableShadows = false;

	/// @var {Id.Surface} The surface used for rendering the scene's depth from the
	/// directional light's view.
	/// @private
	SurShadowmap = noone;

	/// @var {Real} The area captured by the shadowmap. Defaults to 1024.
	ShadowmapArea = 1024;

	/// @var {Real} The resolution of the shadowmap surface. Must be power of 2.
	/// Defaults to 4096.
	ShadowmapResolution = 4096;

	/// @var {Real} When rendering shadows, offsets vertex position by its normal
	/// scaled by this value. Defaults to 1. Increasing the value can remove some
	/// artifacts but using too high value could make the objects appear flying
	/// above the ground.
	ShadowmapNormalOffset = 1;

	/// @var {Bool} Enables post-processing effects. Defaults to `false`. Enabling
	/// this requires the [Post-processing submodule](./PostProcessingSubmodule.html)!
	/// @note {@link BBMOD_Renderer.UseAppSurface} must be enabled for this to
	/// have any effect!
	EnablePostProcessing = false;

	/// @var {Id.Surface}
	/// @private
	SurPostProcess = noone;

	/// @var {Pointer.Texture} The lookup table texture used for color grading.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	ColorGradingLUT = sprite_get_texture(BBMOD_SprColorGradingLUT, 0);

	/// @var {Real} The strength of the chromatic aberration effect. Use 0 to
	/// disable the effect. Defaults to 0.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	ChromaticAberration = 0.0;

	/// @var {Real} The strength of the grayscale effect. Use values in range 0..1,
	/// where 0 means the original color and 1 means grayscale. Defaults to 0.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	Grayscale = 0.0;

	/// @var {Real} The strength of the vignette effect. Defaults to 0.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	Vignette = 0.0;

	/// @var {Real} The color of the vignette effect. Defaults to `c_black`.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	VignetteColor = c_black;

	/// @var {Enum.BBMOD_EAntialiasing} Antialiasing technique to use. Defaults
	/// to {@link BBMOD_EAntialiasing.None}.
	/// @see BBMOD_EAntialiasing
	Antialiasing = BBMOD_EAntialiasing.None;

	/// @func get_width()
	/// @desc Retrieves the width of the renderer on the screen.
	/// @return {Real} The width of the renderer on the screen.
	static get_width = function () {
		gml_pragma("forceinline");
		return ((Width == undefined) ? window_get_width() : max(Width, 1));
	};

	/// @func get_height()
	/// @desc Retrieves the height of the renderer on the screen.
	/// @return {Real} The height of the renderer on the screen.
	static get_height = function () {
		gml_pragma("forceinline");
		return ((Height == undefined) ? window_get_height() : max(Height, 1));
	};

	/// @func get_render_width()
	/// @desc Retrieves the width of the renderer with
	/// {@link BBMOD_Renderer.RenderScale} applied.
	/// @return {Real} The width of the renderer after `RenderScale` is applied.
	static get_render_width = function () {
		gml_pragma("forceinline");
		return (get_width() * RenderScale);
	};

	/// @func get_render_height()
	/// @desc Retrieves the height of the renderer with
	/// {@link BBMOD_Renderer.RenderScale} applied.
	/// @return {Real} The height of the renderer after `RenderScale` is applied.
	static get_render_height = function () {
		gml_pragma("forceinline");
		return (get_height() * RenderScale);
	};

	/// @func set_position(_x, _y)
	/// @desc Changes the renderer's position on the screen.
	/// @param {Real} _x The new X position on the screen.
	/// @param {Real} _y The new Y position on the screen.
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	static set_position = function (_x, _y) {
		gml_pragma("forceinline");
		X = _x;
		Y = _y;
		return self;
	};

	/// @func set_size(_width, _height)
	/// @desc Changes the renderer's size on the screen.
	/// @param {Real} _width The new width on the screen.
	/// @param {Real} _height The new height on the screen.
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	static set_size = function (_width, _height) {
		gml_pragma("forceinline");
		Width = _width;
		Height = _height;
		return self;
	};

	/// @func set_rectangle(_x, _y, _width, _height)
	/// @desc Changes the renderer's position and size on the screen.
	/// @param {Real} _x The new X position on the screen.
	/// @param {Real} _y The new Y position on the screen.
	/// @param {Real} _width The new width on the screen.
	/// @param {Real} _height The new height on the screen.
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	static set_rectangle = function (_x, _y, _width, _height) {
		gml_pragma("forceinline");
		set_position(_x, _y);
		set_size(_width, _height);
		return self;
	};

	/// @func select_gizmo(_screenX, _screenY)
	/// @desc Tries to select a gizmo at given screen coordinates and
	/// automatically changes its {@link BBMOD_Gizmo.EditAxis} and
	/// {@link BBMOD_Gizmo.EditType} based on which part of the gizmo
	/// was selected.
	/// @param {Real} _screenX The X position on the screen.
	/// @param {Real} _screenY The Y position on the screen.
	/// @return {Bool} Returns `true` if the gizmo was selected.
	/// @note {@link BBMOD_Renderer.Gizmo} must be defined.
	/// @obsolete
	static select_gizmo = function (_screenX, _screenY) {
		if (!Gizmo || !Gizmo.Visible || !surface_exists(SurSelect))
		{
			return false;
		}

		_screenX = clamp(_screenX - X, 0, get_width()) * RenderScale;
		_screenY = clamp(_screenY - Y, 0, get_height()) * RenderScale;

		Gizmo.EditAxis = BBMOD_EEditAxis.None;

		var _pixel = surface_getpixel_ext(SurSelect, _screenX, _screenY);
		if (_pixel & $FF000000 == 0)
		{
			return false;
		}

		if (_pixel & $FFFFFF == $FFFFFF)
		{
			Gizmo.EditAxis = BBMOD_EEditAxis.All;
			Gizmo.EditType = BBMOD_EEditType.Scale;
			return true;
		}

		var _blue = (_pixel >> 16) & 255;
		var _green = (_pixel >> 8) & 255;
		var _red = _pixel & 255;
		var _value = max(_red, _green, _blue);

		Gizmo.EditAxis = ((_value == _red) ? BBMOD_EEditAxis.X
			: ((_value == _green) ? BBMOD_EEditAxis.Y
			: BBMOD_EEditAxis.Z));

		Gizmo.EditType = ((_value == 255) ? BBMOD_EEditType.Position
			: ((_value == 128) ? BBMOD_EEditType.Rotation
			: BBMOD_EEditType.Scale));

		return true;
	};

	/// @func get_instance_id(_screenX, _screenY)
	/// @desc Retrieves an ID of an instance at given position on the screen.
	/// @param {Real} _screenX The X position on the screen.
	/// @param {Real} _screenY The Y position on the screen.
	/// @return {Id.Instance} The ID of the instance or 0 if no instance was
	/// found at the given position.
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
	/// @desc Adds a renderable object or struct to the renderer.
	/// @param {Struct.BBMOD_IRenderable} _renderable The renderable object or struct
	/// to add.
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	/// @see BBMOD_Renderer.remove
	/// @see BBMOD_IRenderable
	static add = function (_renderable) {
		gml_pragma("forceinline");
		array_push(Renderables, _renderable);
		return self;
	};

	/// @func remove(_renderable)
	/// @desc Removes a renderable object or a struct from the renderer.
	/// @param {Struct.BBMOD_IRenderable} _renderable The renderable object or struct
	/// to remove.
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
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
	/// @desc Updates the renderer. This should be called in the Step event.
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
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

	static get_shadowmap_view = function () {
		gml_pragma("forceinline");
		var _directionalLight = bbmod_light_directional_get();
		if (_directionalLight == undefined)
		{
			return matrix_build_identity();
		}
		var _directionalLightPosition = bbmod_camera_get_position();
		var _directionalLightDirection = _directionalLight.Direction;
		return matrix_build_lookat(
			_directionalLightPosition.X,
			_directionalLightPosition.Y,
			_directionalLightPosition.Z,
			_directionalLightPosition.X + _directionalLightDirection.X,
			_directionalLightPosition.Y + _directionalLightDirection.Y,
			_directionalLightPosition.Z + _directionalLightDirection.Z,
			0.0, 0.0, 1.0); // TODO: Find the up vector
	};

	static get_shadowmap_projection = function () {
		gml_pragma("forceinline");
		return matrix_build_projection_ortho(
			ShadowmapArea, ShadowmapArea, -ShadowmapArea * 0.5, ShadowmapArea * 0.5);
	};

	static get_shadowmap_matrix = function () {
		gml_pragma("forceinline");
		if (bbmod_light_directional_get() == undefined)
		{
			return matrix_build_identity();
		}
		return matrix_multiply(
			get_shadowmap_view(),
			get_shadowmap_projection());
	};

	/// @func render_shadowmap()
	/// @desc Renders shadowmap.
	/// @note This modifies render pass and view and projection matrices and
	/// for optimization reasons it does not reset them back! Make sure to do
	/// that yourself in the calling function if needed.
	/// @private
	static render_shadowmap = function () {
		gml_pragma("forceinline");

		var _directionalLight = bbmod_light_directional_get();

		if (EnableShadows
			&& _directionalLight != undefined
			&& _directionalLight.CastShadows)
		{
			SurShadowmap = bbmod_surface_check(SurShadowmap, ShadowmapResolution, ShadowmapResolution);
			surface_set_target(SurShadowmap);
			draw_clear(c_red);
			matrix_set(matrix_view, get_shadowmap_view());
			matrix_set(matrix_projection, get_shadowmap_projection());
			var _shadowmapArea = ShadowmapArea;
			bbmod_render_pass_set(BBMOD_ERenderPass.Shadows);

			bbmod_shader_set_global_f("bbmod_ZFar", _shadowmapArea);

			var _renderQueues = global.bbmod_render_queues;
			var _rqi = 0;
			repeat (array_length(_renderQueues))
			{
				_renderQueues[_rqi++].submit();
			}

			surface_reset_target();
		}
		else if (surface_exists(SurShadowmap))
		{
			surface_free(SurShadowmap);
		}
	};

	/// @func render(_clearQueues=true)
	/// @desc Renders all added [renderables](./BBMOD_Renderer.Renderables.html)
	/// to the current render target.
	/// @param {Bool} [_clearQueues] If true then all render queues are cleared
	/// at the end of this method. Default value is `true`.
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	static render = function (_clearQueues=true) {
		global.__bbmodRendererCurrent = self;

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
		var _continueMousePick = true;
		var _gizmoSize;

		if (_editMode)
		{
			_gizmoSize = Gizmo.Size;
			Gizmo.Size = _gizmoSize * Gizmo.Position.Sub(bbmod_camera_get_position()).Length() / 100.0;
		}

		////////////////////////////////////////////////////////////////////////
		// Gizmo select
		if (_editMode && mouse_check_button_pressed(Gizmo.ButtonDrag))
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
		var _mousePickInstance = (_continueMousePick && mouse_check_button_pressed(ButtonSelect));

		if (_mousePickInstance || RenderInstanceIDs)
		{
			SurSelect = bbmod_surface_check(SurSelect, _renderWidth, _renderHeight);

			surface_set_target(SurSelect);
			draw_clear_alpha(0, 0.0);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
	
			bbmod_render_pass_set(BBMOD_ERenderPass.Id);

			var _renderQueues = global.bbmod_render_queues;
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
					Gizmo.Size = _gizmoSize * Gizmo.Position.Sub(bbmod_camera_get_position()).Length() / 100.0;
				}
			}
		}

		if (_editMode && !ds_list_empty(Gizmo.Selected))
		{
			////////////////////////////////////////////////////////////////////
			// Instance highlight
			SurInstanceHighlight = bbmod_surface_check(SurInstanceHighlight, _renderWidth, _renderHeight);

			surface_set_target(SurInstanceHighlight);
			draw_clear_alpha(0, 0.0);

			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
	
			bbmod_render_pass_set(BBMOD_ERenderPass.Id);

			var _selectedInstances = Gizmo.Selected;
			var _renderQueues = global.bbmod_render_queues;
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
		render_shadowmap();

		////////////////////////////////////////////////////////////////////////
		//
		// Forward pass
		//
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		if (surface_exists(SurShadowmap))
		{
			var _shadowmapTexture = surface_get_texture(SurShadowmap);
			bbmod_shader_set_global_f("bbmod_ShadowmapEnableVS", 1.0);
			bbmod_shader_set_global_f("bbmod_ShadowmapEnablePS", 1.0);
			bbmod_shader_set_global_sampler("bbmod_Shadowmap", _shadowmapTexture);
			bbmod_shader_set_global_sampler_mip_enable("bbmod_Shadowmap", true);
			bbmod_shader_set_global_sampler_filter("bbmod_Shadowmap", true);
			bbmod_shader_set_global_sampler_repeat("bbmod_Shadowmap", false);
			bbmod_shader_set_global_f2("bbmod_ShadowmapTexel",
				texture_get_texel_width(_shadowmapTexture),
				texture_get_texel_height(_shadowmapTexture));
			bbmod_shader_set_global_f("bbmod_ShadowmapAreaVS", ShadowmapArea);
			bbmod_shader_set_global_f("bbmod_ShadowmapAreaPS", ShadowmapArea);
			bbmod_shader_set_global_f("bbmod_ShadowmapNormalOffset", ShadowmapNormalOffset);
			bbmod_shader_set_global_matrix_array("bbmod_ShadowmapMatrix", get_shadowmap_matrix());
		}
		else
		{
			bbmod_shader_set_global_f("bbmod_ShadowmapEnableVS", 0.0);
			bbmod_shader_set_global_f("bbmod_ShadowmapEnablePS", 0.0);
		}

		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		var _renderQueues = global.bbmod_render_queues;
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

		bbmod_material_reset();

		matrix_set(matrix_world, _world);
		return self;
	};

	/// @func present()
	/// @desc Presents the rendered graphics on the screen.
	/// @return {Struct.BBMOD_Renderer} Returns `self`.
	/// @note If {@link BBMOD_Renderer.UseAppSurface} is `false`, then this only
	/// draws {@link BBMOD_Renderer.Gizmo} (if defined).
	static present = function () {
		global.__bbmodRendererCurrent = self;

		var _world = matrix_get(matrix_world);
		var _width = get_width();
		var _height = get_height();
		var _renderWidth = get_render_width();
		var _renderHeight = get_render_height();
		var _texelWidth = 1.0 / _width;
		var _texelHeight = 1.0 / _height;
		gpu_push_state();
		gpu_set_tex_filter(true);
		gpu_set_tex_repeat(false);

		if (UseAppSurface)
		{
			var _surFinal = application_surface;
			if (EditMode && Gizmo && !ds_list_empty(Gizmo.Selected))
			{
				surface_set_target(_surFinal);
				matrix_set(matrix_world, matrix_build_identity());

				////////////////////////////////////////////////////////////////
				// Highlighted instances
				if (surface_exists(SurInstanceHighlight))
				{
					var _shader = BBMOD_ShInstanceHighlight;
					shader_set(_shader);
					shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), _texelWidth, _texelHeight);
					shader_set_uniform_f(shader_get_uniform(_shader, "u_vColor"),
						InstanceHighlightColor.Red / 255.0,
						InstanceHighlightColor.Green / 255.0,
						InstanceHighlightColor.Blue / 255.0,
						InstanceHighlightColor.Alpha);
					draw_surface_stretched(SurInstanceHighlight, 0, 0, _renderWidth, _renderHeight);
					shader_reset();
				}

				////////////////////////////////////////////////////////////////
				// Gizmo
				if (surface_exists(SurGizmo))
				{
					draw_surface_stretched(SurGizmo, 0, 0, _renderWidth, _renderHeight);
				}

				surface_reset_target();
				matrix_set(matrix_world, _world);
			}
			////////////////////////////////////////////////////////////////////
			// Post-processing
			if (EnablePostProcessing)
			{
				if (Antialiasing != BBMOD_EAntialiasing.None)
				{
					SurPostProcess = bbmod_surface_check(SurPostProcess, _width, _height);
					surface_set_target(SurPostProcess);
					matrix_set(matrix_world, matrix_build_identity());
				}
				var _shader = BBMOD_ShPostProcess;
				shader_set(_shader);
				var _uLut = shader_get_sampler_index(_shader, "u_texLut");
				texture_set_stage(_uLut, ColorGradingLUT);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), _texelWidth, _texelHeight);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_fDistortion"), ChromaticAberration);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_fGrayscale"), Grayscale);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_fVignette"), Vignette);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vVignetteColor"),
					color_get_red(VignetteColor) / 255,
					color_get_green(VignetteColor) / 255,
					color_get_blue(VignetteColor) / 255);
				draw_surface_stretched(
					application_surface,
					(Antialiasing == BBMOD_EAntialiasing.None) ? X : 0,
					(Antialiasing == BBMOD_EAntialiasing.None) ? Y : 0,
					_width, _height);
				shader_reset();
				if (Antialiasing != BBMOD_EAntialiasing.None)
				{
					surface_reset_target();
					matrix_set(matrix_world, _world);
					_surFinal = SurPostProcess;
				}
			}
			////////////////////////////////////////////////////////////////////
			// Anti-aliasing
			if (Antialiasing == BBMOD_EAntialiasing.FXAA)
			{
				var _shader = BBMOD_ShFXAA;
				shader_set(_shader);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexelVS"), _texelWidth, _texelHeight);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexelPS"), _texelWidth, _texelHeight);
				draw_surface_stretched(_surFinal, X, Y, _width, _height);
				shader_reset();
			}
			else if (!EnablePostProcessing)
			{
				draw_surface_stretched(application_surface, X, Y, _width, _height);
			}
		}
		else
		{
			if (EditMode && Gizmo && !ds_list_empty(Gizmo.Selected))
			{
				////////////////////////////////////////////////////////////////
				// Highlighted instances
				if (!ds_list_empty(Gizmo.Selected)
					&& surface_exists(SurInstanceHighlight))
				{
					var _shader = BBMOD_ShInstanceHighlight;
					shader_set(_shader);
					shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), _texelWidth, _texelHeight);
					shader_set_uniform_f(shader_get_uniform(_shader, "u_vColor"),
						InstanceHighlightColor.Red / 255.0,
						InstanceHighlightColor.Green / 255.0,
						InstanceHighlightColor.Blue / 255.0,
						InstanceHighlightColor.Alpha);
					draw_surface_stretched(SurInstanceHighlight, X, Y, _width, _height)
					shader_reset();
				}
			
				////////////////////////////////////////////////////////////////
				// Gizmo
				if (surface_exists(SurGizmo))
				{
					draw_surface_stretched(SurGizmo, X, Y, _width, _height);
				}
			}
		}

		gpu_pop_state();

		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		if (global.__bbmodRendererCurrent == self)
		{
			global.__bbmodRendererCurrent = undefined;
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
		if (surface_exists(SurShadowmap))
		{
			surface_free(SurShadowmap);
		}
		if (surface_exists(SurPostProcess))
		{
			surface_free(SurPostProcess);
		}
		if (UseAppSurface)
		{
			application_surface_enable(false);
			application_surface_draw_enable(true);
		}
		return undefined;
	};
}
