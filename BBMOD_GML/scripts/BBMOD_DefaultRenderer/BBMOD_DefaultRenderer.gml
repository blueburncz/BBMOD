/// @module Core

/// @func BBMOD_DefaultRenderer()
///
/// @extends BBMOD_BaseRenderer
///
/// @desc A forward renderer. Implemented render passes are:
/// {@link BBMOD_ERenderPass.ReflectionCapture},
/// {@link BBMOD_ERenderPass.Id},
/// {@link BBMOD_ERenderPass.Shadows},
/// {@link BBMOD_ERenderPass.DepthOnly},
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
/// @see BBMOD_IRenderable
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

	static render = function (_clearQueues=true)
	{
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
			var _width = _renderWidth * SSAOScale;
			var _height = _renderHeight * SSAOScale;

			__surSSAO = bbmod_surface_check(__surSSAO, _width, _height, surface_rgba8unorm, false);
			__surWork = bbmod_surface_check(__surWork, _width, _height, surface_rgba8unorm, false);

			bbmod_ssao_draw(SSAORadius * SSAOScale, SSAOPower, SSAOAngleBias,
				SSAODepthRange, __surSSAO, __surWork, __surDepthBuffer, _projection,
				bbmod_camera_get_zfar(), SSAOSelfOcclusionBias, SSAOBlurDepthRange);

			bbmod_shader_set_global_sampler(
				BBMOD_U_SSAO, surface_get_texture(__surSSAO));
		}
		else
		{
			bbmod_shader_set_global_sampler(
				BBMOD_U_SSAO, sprite_get_texture(BBMOD_SprWhite, 0));
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Forward pass
		//
		bbmod_shader_set_global_sampler(BBMOD_U_GBUFFER, EnableGBuffer
			? surface_get_texture(__surDepthBuffer)
			: sprite_get_texture(BBMOD_SprWhite, 0));

		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		var _rqi = 0;
		repeat (array_length(_renderQueues))
		{
			_renderQueues[_rqi++].submit();
		}

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

		// Reset render pass back to Forward at the end!
		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		// Unset in case it gets destroyed when the room changes etc.
		bbmod_shader_unset_global(BBMOD_U_SHADOWMAP);
		bbmod_shader_unset_global(BBMOD_U_SSAO);
		bbmod_shader_unset_global(BBMOD_U_GBUFFER);

		matrix_set(matrix_world, _world);
		return self;
	};

	static destroy = function ()
	{
		BaseRenderer_destroy();

		if (surface_exists(__surDepthBuffer))
		{
			surface_free(__surDepthBuffer);
		}

		if (surface_exists(__surSSAO))
		{
			surface_free(__surSSAO);
		}

		if (surface_exists(__surWork))
		{
			surface_free(__surWork);
		}

		return undefined;
	};
}
