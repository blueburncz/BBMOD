function BBMOD_DeferredRenderer()
	: BBMOD_BaseRenderer() constructor
{
	static BaseRenderer_destroy = destroy;
	//static BaseRenderer_present = present;

	/// @var {Array<Id.Surface>}
	/// @private
	__surGBuffer = [
		    // R  | G  | B  | A
		    // -- | -- | -- | --
		-1, //  Albedo.rgb  | AO
		-1, //  Normal.xyz  | Roughness
		-1, //  Depth 24bit | Metallic
		    //  Emissive (using the L-buffer)
	];

	/// @var {Id.Surface}
	/// @private
	__surLBuffer = -1;

	/// @var {Real}
	/// @private
	__gBufferZFar = 1.0;

	/// @var {Id.Camera}
	/// @private
	__camera2D = camera_create();

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
		__render_shadowmap();

		__gBufferZFar = bbmod_camera_get_zfar();
		bbmod_shader_set_global_f(BBMOD_U_ZFAR, __gBufferZFar);

		////////////////////////////////////////////////////////////////////////
		//
		// G-buffer pass
		//
		__surGBuffer[@ 0] = bbmod_surface_check(__surGBuffer[0], _renderWidth, _renderHeight);
		__surGBuffer[@ 1] = bbmod_surface_check(__surGBuffer[1], _renderWidth, _renderHeight);
		__surGBuffer[@ 2] = bbmod_surface_check(__surGBuffer[2], _renderWidth, _renderHeight);
		__surLBuffer      = bbmod_surface_check(__surLBuffer,    _renderWidth, _renderHeight);

		surface_set_target_ext(0, __surGBuffer[0]);
		surface_set_target_ext(1, __surGBuffer[1]);
		surface_set_target_ext(2, __surGBuffer[2]);
		surface_set_target_ext(3, __surLBuffer);

		draw_clear_alpha(c_black, 0);

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		gpu_set_blendenable(false);

		matrix_set(matrix_world, _world);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		bbmod_render_pass_set(BBMOD_ERenderPass.GBuffer);
		var _rqi = 0;
		repeat (array_length(_renderQueues))
		{
			_renderQueues[_rqi++].submit();
		}

		gpu_pop_state();
		surface_reset_target();

		////////////////////////////////////////////////////////////////////////
		//
		// Lighting pass
		//
		camera_set_view_size(__camera2D, _renderWidth, _renderHeight);

		//surface_set_target(__surLBuffer);
		//draw_clear_alpha(c_black, 0);

		//camera_apply(__camera2D);
		//matrix_set(matrix_world, matrix_build_identity());

		//var _shader = BBMOD_ShDeferredLighting;
		//shader_set(_shader);
		//texture_set_stage(
		//	shader_get_sampler_index(_shader, "u_texGB1"),
		//	surface_get_texture(__surGBuffer[1]));
		//texture_set_stage(
		//	shader_get_sampler_index(_shader, "u_texGB2"),
		//	surface_get_texture(__surGBuffer[2]));
		//shader_set_uniform_f(
		//	shader_get_uniform(_shader, "u_vTexel"),
		//	1.0 / _renderWidth, 1.0 / _renderHeight);
		//draw_surface(__surGBuffer[0], 0, 0);
		//shader_reset();

		//surface_reset_target();

		////////////////////////////////////////////////////////////////////////
		//
		// Combine
		//
		surface_set_target(__surGBuffer[0]);

		//gpu_push_state();
		//gpu_set_state(bbmod_gpu_get_default_state());
		//gpu_set_zwriteenable(false);
		//gpu_set_ztestenable(false);
		//camera_apply(__camera2D);
		//matrix_set(matrix_world, matrix_build_identity());
		//draw_surface(__surLBuffer, 0, 0);
		//gpu_pop_state();

		gpu_push_state();
		matrix_set(matrix_world, _world);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		bbmod_shader_set_global_sampler(BBMOD_U_GBUFFER, surface_get_texture(__surGBuffer[2]));

		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);
		_rqi = 0;
		repeat (array_length(_renderQueues))
		{
			_renderQueues[_rqi++].submit();
		}

		gpu_set_colorwriteenable(true, true, true, false);
		bbmod_render_pass_set(BBMOD_ERenderPass.Alpha);
		_rqi = 0;
		repeat (array_length(_renderQueues))
		{
			_renderQueues[_rqi++].submit();
		}

		gpu_pop_state();
		surface_reset_target();

		////////////////////////////////////////////////////////////////////////
		//
		// Clear queues
		//

		if (_clearQueues)
		{
			_rqi = 0;
			repeat (array_length(_renderQueues))
			{
				_renderQueues[_rqi++].clear();
			}
		}

		// Reset render pass back to Forward at the end!
		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		// Unset in case it gets destroyed when the room changes etc.
		bbmod_shader_unset_global(BBMOD_U_SHADOWMAP);
		bbmod_shader_unset_global(BBMOD_U_GBUFFER);

		matrix_set(matrix_world, _world);
		return self;
	};

	static present = function () {
		//BaseRenderer_present();

		var _width = get_width();
		var _height = get_height();

		draw_surface_stretched(__surGBuffer[0], X, Y, _width, _height);
		draw_surface_stretched(__surGBuffer[1], X, Y, _width * 0.25, _height * 0.25);

		//shader_set(BBMOD_ShGBufferExtractBaseColor);
		//shader_set_uniform_f(
		//	shader_get_uniform(BBMOD_ShGBufferExtractBaseColor, "u_vTexel"),
		//	1.0 / _width, 1.0 / _height);
		//draw_surface_stretched(__surGBuffer[0], X, Y, _width, _height);
		//shader_reset();

		//shader_set(BBMOD_ShGBufferExtractMetallic);
		//draw_surface_stretched(__surGBuffer[0], X, Y, _width, _height);
		//shader_reset();

		//shader_set(BBMOD_ShGBufferExtractAO);
		//draw_surface_stretched(__surGBuffer[0], X, Y, _width, _height);
		//shader_reset();

		//shader_set(BBMOD_ShGBufferExtractNormal);
		//draw_surface_stretched(__surGBuffer[1], X, Y, _width, _height);
		//shader_reset();

		//shader_set(BBMOD_ShGBufferExtractRoughness);
		//draw_surface_stretched(__surGBuffer[1], X, Y, _width, _height);
		//shader_reset();

		//shader_set(BBMOD_ShGBufferExtractDepth);
		//shader_set_uniform_f(
		//	shader_get_uniform(BBMOD_ShGBufferExtractDepth, "u_fDepthScale"),
		//	__gBufferZFar / 255.0);
		//draw_surface_stretched(__surGBuffer[2], X, Y, _width, _height);
		//shader_reset();

		return self;
	};

	static destroy = function ()
	{
		BaseRenderer_destroy();

		if (surface_exists(__surGBuffer[0]))
		{
			surface_free(__surGBuffer[0]);
		}

		if (surface_exists(__surGBuffer[1]))
		{
			surface_free(__surGBuffer[1]);
		}

		if (surface_exists(__surGBuffer[2]))
		{
			surface_free(__surGBuffer[2]);
		}

		if (surface_exists(__surLBuffer))
		{
			surface_free(__surLBuffer);
		}

		camera_destroy(__camera2D);

		return undefined;
	};
}
