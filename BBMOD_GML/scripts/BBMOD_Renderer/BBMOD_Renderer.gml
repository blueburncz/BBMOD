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

	/// @var {BBMOD_IRenderable[]} An array of renderable objects and structs.
	/// These are automatically rendered in {@link BBMOD_Renderer.render}.
	/// @readonly
	/// @see BBMOD_Renderer.add
	/// @see BBMOD_Renderer.remove
	/// @see BBMOD_IRenderable
	Renderables = [];

	/// @var {bool} Set to `true` to enable the `application_surface`.
	/// Use method {@link BBMOD_Renderer.present} to draw the
	/// `application_surface` to the screen. Defaults to `false`.
	UseAppSurface = false;

	/// @var {real} Resolution multiplier for the `application_surface`.
	/// {@link BBMOD_Renderer.UseAppSurface} must be enabled for this to
	/// have any effect. Defaults to 1. Use lower values to improve framerate.
	RenderScale = 1.0;

	/// @var {bool} Enables rendering into a shadowmap in the shadows render pass.
	/// Defauls to `false`.
	/// @see BBMOD_Renderer.ShadowmapArea
	/// @see BBMOD_Renderer.ShadowmapResolution
	EnableShadows = false;

	/// @var {surface} The surface used for rendering the scene's depth from the
	/// directional light's view.
	/// @private
	SurShadowmap = noone;

	/// @var {real} The area captured by the shadowmap. Defaults to 1024.
	ShadowmapArea = 1024;

	/// @var {uint} The resolution of the shadowmap surface. Must be power of 2.
	/// Defaults to 4096.
	ShadowmapResolution = 4096;

	/// @var {real} When rendering shadows, offsets vertex position by its normal
	/// scaled by this value. Defaults to 1. Increasing the value can remove some
	/// artifacts but using too high value could make the objects appear flying
	/// above the ground.
	ShadowmapNormalOffset = 1;

	/// @var {bool} Enables post-processing effects. Defaults to `false`. Enabling
	/// this requires the [Post-processing submodule](./PostProcessingSubmodule.html)!
	/// @note {@link BBMOD_Renderer.UseAppSurface} must be enabled for this to
	/// have any effect!
	EnablePostProcessing = false;

	/// @var {surface}
	/// @private
	SurPostProcess = noone;

	/// @var {ptr} The lookup table texture used for color grading.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	ColorGradingLUT = sprite_get_texture(BBMOD_SprColorGradingLUT, 0);

	/// @var {real} The strength of the chromatic aberration effect. Use 0 to
	/// disable the effect. Defaults to 0.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	ChromaticAberration = 0.0;

	/// @var {real} The strength of the grayscale effect. Use values in range 0..1,
	/// where 0 means the original color and 1 means grayscale. Defaults to 0.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	Grayscale = 0.0;

	/// @var {real} The strength of the vignette effect. Defaults to 0.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	Vignette = 0.0;

	/// @var {uint} The color of the vignette effect. Defaults to `c_black`.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	VignetteColor = c_black;

	/// @var {BBMOD_EAntialiasing} Antialiasing technique to use. Defaults to
	/// {@link BBMOD_EAntialiasing.None}.
	/// @see BBMOD_EAntialiasing
	Antialiasing = BBMOD_EAntialiasing.None;

	/// @func add(_renderable)
	/// @desc Adds a renderable object or struct to the renderer.
	/// @param {BBMOD_IRenderable} _renderable The renderable object or struct
	/// to add.
	/// @return {BBMOD_Renderer} Returns `self`.
	/// @see BBMOD_Renderer.remove
	/// @see BBMOD_IRenderable
	static add = function (_renderable) {
		gml_pragma("forceinline");
		array_push(Renderables, _renderable);
		return self;
	};

	/// @func remove(_renderable)
	/// @desc Removes a renderable object or a struct from the renderer.
	/// @param {BBMOD_IRenderable} _renderable The renderable object or struct
	/// to remove.
	/// @return {BBMOD_Renderer} Returns `self`.
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
	/// @param {real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @return {BBMOD_Renderer} Returns `self`.
	static update = function (_deltaTime) {
		if (UseAppSurface)
		{
			application_surface_enable(true);
			application_surface_draw_enable(false);

			var _windowWidth = max(window_get_width(), 1);
			var _windowHeight = max(window_get_height(), 1);
			var _surfaceWidth = floor(max(_windowWidth * RenderScale, 1.0));
			var _surfaceHeight = floor(max(_windowHeight * RenderScale, 1.0));

			if (surface_exists(application_surface)
				&& (surface_get_width(application_surface) != _surfaceWidth
				|| surface_get_height(application_surface) != _surfaceHeight))
			{
				surface_resize(application_surface, _surfaceWidth, _surfaceHeight);
			}
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
			var _materials = bbmod_get_materials(BBMOD_ERenderPass.Shadows);
			var m = 0;
			repeat (array_length(_materials))
			{
				var _material = _materials[m++];
				var _materialRenderQueue = _material.RenderQueue;
				if (_materialRenderQueue.is_empty()
					|| !_material.apply())
				{
					continue;
				}
				BBMOD_SHADER_CURRENT.set_zfar(_shadowmapArea);
				_materialRenderQueue.submit();
			}
			surface_reset_target();
		}
		else if (surface_exists(SurShadowmap))
		{
			surface_free(SurShadowmap);
		}
	};

	/// @func render()
	/// @desc Renders all added [renderables](./BBMOD_Renderer.Renderables.html)
	/// to the current render target.
	/// @return {BBMOD_Renderer} Returns `self`.
	static render = function () {
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

		bbmod_material_reset();

		////////////////////////////////////////////////////////////////////////
		// Shadow map
		render_shadowmap();

		////////////////////////////////////////////////////////////////////////
		// Forward pass
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		var _passShadowmap = surface_exists(SurShadowmap);
		var _shadowmapTexture, _shadowmapMatrix, _shadowmapArea, _shadowmapNormalOffset;
		if (_passShadowmap)
		{
			_shadowmapTexture = surface_get_texture(SurShadowmap);
			_shadowmapMatrix = get_shadowmap_matrix();
			_shadowmapArea = ShadowmapArea;
			_shadowmapNormalOffset = ShadowmapNormalOffset;
		}

		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);
		var _materials = bbmod_get_materials(BBMOD_ERenderPass.Forward);
		var i = 0;
		repeat (array_length(_materials))
		{
			var _material = _materials[i++];
			var _materialRenderQueue = _material.RenderQueue;
			if (_materialRenderQueue.is_empty()
				|| !_material.apply())
			{
				continue;
			}
			if (_passShadowmap)
			{
				BBMOD_SHADER_CURRENT.set_shadowmap(
					_shadowmapTexture,
					_shadowmapMatrix,
					_shadowmapArea,
					_shadowmapNormalOffset);
			}
			_materialRenderQueue.submit().clear();
		}

		bbmod_material_reset();

		matrix_set(matrix_world, _world);
		return self;
	};

	/// @func present()
	/// @desc Renders the `application_surface` to the screen.
	/// {@link BBMOD_Renderer.UseAppSurface} must be enabled for this to
	/// have any effect.
	/// @return {BBMOD_Renderer} Returns `self`.
	static present = function () {
		if (UseAppSurface)
		{
			var _surFinal = application_surface;
			var _windowWidth = window_get_width();
			var _windowHeight = window_get_height();
			var _texelWidth = 1.0 / _windowWidth;
			var _texelHeight = 1.0 / _windowHeight;
			gpu_push_state();
			gpu_set_tex_filter(true);
			gpu_set_tex_repeat(false);
			////////////////////////////////////////////////////////////////////
			// Post-processing
			if (EnablePostProcessing)
			{
				if (Antialiasing != BBMOD_EAntialiasing.None)
				{
					SurPostProcess = bbmod_surface_check(SurPostProcess, _windowWidth, _windowHeight);
					surface_set_target(SurPostProcess);
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
				draw_surface_stretched(application_surface, 0, 0, _windowWidth, _windowHeight);
				shader_reset();
				if (Antialiasing != BBMOD_EAntialiasing.None)
				{
					surface_reset_target();
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
				draw_surface_stretched(_surFinal, 0, 0, _windowWidth, _windowHeight);
				shader_reset();
			}
			else if (!EnablePostProcessing)
			{
				draw_surface_stretched(application_surface, 0, 0, _windowWidth, _windowHeight);
			}
			gpu_pop_state();
		}
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
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
	};
}