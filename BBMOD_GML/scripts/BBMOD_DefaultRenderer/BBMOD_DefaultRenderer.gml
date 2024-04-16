/// @module Core

/// @func BBMOD_DefaultRenderer()
///
/// @extends BBMOD_BaseRenderer
///
/// @desc A forward renderer with support for a small number of lights and only
/// a single shadow casting lights. Implemented render passes are:
/// {@link BBMOD_ERenderPass.ReflectionCapture},
/// {@link BBMOD_ERenderPass.Id},
/// {@link BBMOD_ERenderPass.Shadows},
/// {@link BBMOD_ERenderPass.DepthOnly},
/// {@link BBMOD_ERenderPass.Background},
/// {@link BBMOD_ERenderPass.Forward} and
/// {@link BBMOD_ERenderPass.Alpha}.
///
/// @example
/// Following code is a typical use of the renderer.
/// ```gml
/// /// @desc Create event
/// renderer = new BBMOD_DefaultRenderer();
/// renderer.UseAppSurface = true;
/// renderer.EnableShadows = true;
///
/// camera = new BBMOD_Camera();
/// camera.FollowObject = OPlayer;
///
/// /// @desc Step event
/// camera.set_mouselook(true);
/// camera.update(delta_time);
/// renderer.update(delta_time);
///
/// /// @desc Draw event
/// camera.apply();
/// renderer.render();
///
/// /// @desc Post-Draw event
/// renderer.present();
///
/// /// @desc Clean Up event
/// renderer = renderer.destroy();
/// ```
///
/// @see BBMOD_Camera
function BBMOD_DefaultRenderer()
	: BBMOD_BaseRenderer() constructor
{
	static BaseRenderer_destroy = destroy;

	/// @var {Bool} Enables rendering scene depth into a depth buffer during the
	/// {@link BBMOD_ERenderPass.DepthOnly} render pass pass. Defaults to `false`.
	EnableGBuffer = false;

	/// @var {Real} Resolution multiplier for the depth buffer surface. Defaults
	/// to 1.
	GBufferScale = 1.0;

	/// @var {Id.Surface} The G-buffer surface.
	/// @private
	__surDepthBuffer = -1;

	static render = function (_clearQueues=true)
	{
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

		////////////////////////////////////////////////////////////////////////
		//
		// Reflection probes
		//
		__render_reflection_probes();

		////////////////////////////////////////////////////////////////////////
		//
		// Edit mode
		//
		__render_gizmo_and_instance_ids(false);

		////////////////////////////////////////////////////////////////////////
		//
		// Shadow map
		//
		__render_shadowmaps();

		bbmod_shader_set_global_f(BBMOD_U_ZFAR, bbmod_camera_get_zfar());

		////////////////////////////////////////////////////////////////////////
		//
		// G-buffer pass
		//
		if (EnableGBuffer)
		{
			var _width = _renderWidth * GBufferScale;
			var _height = _renderHeight * GBufferScale;

			__surDepthBuffer = bbmod_surface_check(__surDepthBuffer, _width, _height, surface_rgba8unorm, true);

			surface_set_target(__surDepthBuffer);
			draw_clear(c_white);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
			bbmod_render_pass_set(BBMOD_ERenderPass.DepthOnly);
			bbmod_render_queues_submit();
			surface_reset_target();
		}
		bbmod_material_reset();

		////////////////////////////////////////////////////////////////////////
		//
		// SSAO
		//
		if (EnableGBuffer)
		{
			__render_ssao(__surDepthBuffer, _projection);
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Background
		//
		bbmod_shader_set_global_sampler(BBMOD_U_GBUFFER, EnableGBuffer
			? surface_get_texture(__surDepthBuffer)
			: sprite_get_texture(BBMOD_SprWhite, 0));

		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		bbmod_render_pass_set(BBMOD_ERenderPass.Background);

		bbmod_render_queues_submit();
		bbmod_material_reset();

		////////////////////////////////////////////////////////////////////////
		//
		// Forward pass
		//
		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		bbmod_render_queues_submit();
		bbmod_material_reset();

		////////////////////////////////////////////////////////////////////////
		//
		// Alpha pass
		//
		bbmod_render_pass_set(BBMOD_ERenderPass.Alpha);

		bbmod_render_queues_submit();
		if (_clearQueues)
		{
			bbmod_render_queues_clear();
		}
		bbmod_material_reset();

		////////////////////////////////////////////////////////////////////////
		//
		// Draw gizmo and highlight selected instances
		//
		__overlay_gizmo_and_instance_highlight();

		////////////////////////////////////////////////////////////////////////

		// Reset render pass back to Forward at the end!
		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		matrix_set(matrix_world, _world);

		// Unset in case it gets destroyed when the room changes etc.
		bbmod_shader_unset_global(BBMOD_U_SHADOWMAP);
		bbmod_shader_unset_global(BBMOD_U_SSAO);
		bbmod_shader_unset_global(BBMOD_U_GBUFFER);

		return self;
	};

	static present = function ()
	{
		global.__bbmodRendererCurrent = self;

		if (UseAppSurface)
		{
			var _world = matrix_get(matrix_world);
			matrix_set(matrix_world, matrix_build_identity());
			if (PostProcessor != undefined
				&& PostProcessor.Enabled)
			{
				PostProcessor.draw(application_surface, X, Y, __surDepthBuffer);
			}
			else
			{
				draw_surface(application_surface, X, Y);
			}
			matrix_set(matrix_world, _world);
		}

		return self;
	};

	static destroy = function ()
	{
		BaseRenderer_destroy();

		if (surface_exists(__surDepthBuffer))
		{
			surface_free(__surDepthBuffer);
		}

		return undefined;
	};
}
