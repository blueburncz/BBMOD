/// @func BBMOD_DeferredRenderer()
///
/// @extends BBMOD_BaseRenderer
///
/// @desc A deferred renderer with support for unlimited number of lights and
/// shadow casters. Implemented render passes are:
/// {@link BBMOD_ERenderPass.ReflectionCapture},
/// {@link BBMOD_ERenderPass.Id},
/// {@link BBMOD_ERenderPass.Shadows},
/// {@link BBMOD_ERenderPass.GBuffer},
/// {@link BBMOD_ERenderPass.Forward} and
/// {@link BBMOD_ERenderPass.Alpha}.
///
/// @example
/// Following code is a typical use of the renderer.
/// ```gml
/// /// @desc Create event
/// renderer = new BBMOD_DeferredRenderer();
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
function BBMOD_DeferredRenderer()
	: BBMOD_BaseRenderer() constructor
{
	static BaseRenderer_destroy = destroy;
	static BaseRenderer_present = present;

	/// @var {Bool} Enables high dynamic range (HDR) rendering. Default value is
	/// `true`.
	EnableHDR = true;

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

	/// @var {Id.Surface}
	/// @private
	__surFinal = -1;

	/// @var {Real}
	/// @private
	__gBufferZFar = 1.0;

	/// @var {Id.Camera}
	/// @private
	__camera2D = camera_create();

	/// @var {Struct.BBMOD_Model}
	/// @private
	static __sphere = new BBMOD_Model("Data/BBMOD/Models/Sphere.bbmod").freeze();

	static __render_shadowmaps = function ()
	{
		bbmod_shader_unset_global(BBMOD_U_SHADOWMAP);
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_ENABLE_VS, 0.0);
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_ENABLE_PS, 0.0);

		if (!EnableShadows)
		{
			return;
		}

		var _light;

		// Directional light
		_light = bbmod_light_directional_get();
		if (_light != undefined
			&& _light.CastShadows)
		{
			__render_shadowmap_impl(_light);
		}
			
		// Punctual lights
		var i = 0;
		repeat (array_length(global.__bbmodPunctualLights))
		{
			_light = global.__bbmodPunctualLights[i];
			if (_light.CastShadows)
			{
				__render_shadowmap_impl(_light);
			}
			++i;
		}
	};

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

		__gBufferZFar = bbmod_camera_get_zfar();
		var _hdr = (EnableHDR && bbmod_hdr_is_supported());

		bbmod_shader_set_global_f(BBMOD_U_ZFAR, __gBufferZFar);
		bbmod_shader_set_global_f(BBMOD_U_HDR, _hdr ? 1.0 : 0.0);

		////////////////////////////////////////////////////////////////////////
		//
		// G-buffer pass
		//
		__surGBuffer[@ 0] = bbmod_surface_check(__surGBuffer[0], _renderWidth, _renderHeight, surface_rgba8unorm, false);
		__surGBuffer[@ 1] = bbmod_surface_check(__surGBuffer[1], _renderWidth, _renderHeight, surface_rgba8unorm, false);
		__surGBuffer[@ 2] = bbmod_surface_check(__surGBuffer[2], _renderWidth, _renderHeight, surface_rgba8unorm, false);
		__surLBuffer      = bbmod_surface_check(__surLBuffer,    _renderWidth, _renderHeight, _hdr ? surface_rgba16float : surface_rgba8unorm, false);
		__surFinal        = bbmod_surface_check(__surFinal,      _renderWidth, _renderHeight, _hdr ? surface_rgba16float : surface_rgba8unorm, true);

		surface_set_target_ext(0, __surFinal);
		surface_set_target_ext(1, __surGBuffer[1]);
		surface_set_target_ext(2, __surGBuffer[2]);
		draw_clear_alpha(c_black, 0.0);
		surface_reset_target();

		surface_set_target(__surLBuffer);
		draw_clear(c_black);
		surface_reset_target();

		surface_set_target_ext(0, __surFinal);
		surface_set_target_ext(1, __surGBuffer[1]);
		surface_set_target_ext(2, __surGBuffer[2]);
		surface_set_target_ext(3, __surLBuffer);

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
		bbmod_material_reset();

		gpu_pop_state();
		surface_reset_target();

		////////////////////////////////////////////////////////////////////////
		//
		// Clone base color surface
		//
		surface_set_target(__surGBuffer[0]);
		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		draw_clear_alpha(c_black, 0.0);
		gpu_set_blendenable(false);
		matrix_set(matrix_world, matrix_build_identity());
		draw_surface(__surFinal, 0, 0);
		matrix_set(matrix_world, _world);
		gpu_pop_state();
		surface_reset_target();

		////////////////////////////////////////////////////////////////////////
		//
		// SSAO
		//
		__render_ssao(__surGBuffer[2], _projection);

		////////////////////////////////////////////////////////////////////////
		//
		// Lighting pass
		//
		camera_set_view_size(__camera2D, _renderWidth, _renderHeight);

		surface_set_target(__surLBuffer);
		gpu_push_state();
		gpu_set_blendmode(bm_add);

		////////////////////////////////////////////////////////////////////////
		// Fullscreen
		camera_apply(__camera2D);
		matrix_set(matrix_world, matrix_build_identity());
		var _shader = BBMOD_ShDeferredFullscreen;
		shader_set(_shader);
		__bbmod_shader_set_globals(shader_current());
		texture_set_stage(shader_get_sampler_index(_shader, "u_texGB1"), surface_get_texture(__surGBuffer[1]));
		texture_set_stage(shader_get_sampler_index(_shader, "u_texGB2"), surface_get_texture(__surGBuffer[2]));
		shader_set_uniform_matrix_array(shader_get_uniform(_shader, "u_mView"), _view);
		shader_set_uniform_matrix_array(shader_get_uniform(_shader, "u_mViewInverse"),
			(new BBMOD_Matrix(_view)).Inverse().Raw);
		shader_set_uniform_matrix_array(shader_get_uniform(_shader, "u_mProjection"), _projection);
		var _tanAspect = __bbmod_matrix_proj_get_tanaspect(_projection);
		shader_set_uniform_f_array(shader_get_uniform(_shader, "u_vTanAspect"), _tanAspect);
		bbmod_shader_set_cam_pos(_shader);
		bbmod_shader_set_exposure(_shader);
		bbmod_shader_set_ibl(_shader);
		bbmod_shader_set_ambient_light(_shader);
		bbmod_shader_set_directional_light(_shader);
		draw_surface(__surGBuffer[0], 0, 0);
		shader_reset();
		gpu_pop_state();

		////////////////////////////////////////////////////////////////////////
		// Point lights
		camera_apply(__camera2D);
		matrix_set(matrix_world, matrix_build_identity());

		var _shader = BBMOD_ShDeferredPunctual;
		shader_set(_shader);
		__bbmod_shader_set_globals(shader_current());
		texture_set_stage(shader_get_sampler_index(_shader, "u_texGB1"), surface_get_texture(__surGBuffer[1]));
		texture_set_stage(shader_get_sampler_index(_shader, "u_texGB2"), surface_get_texture(__surGBuffer[2]));
		shader_set_uniform_matrix_array(shader_get_uniform(_shader, "u_mViewInverse"),
			(new BBMOD_Matrix(_view)).Inverse().Raw);
		var _tanAspect = __bbmod_matrix_proj_get_tanaspect(_projection);
		shader_set_uniform_f_array(shader_get_uniform(_shader, "u_vTanAspect"), _tanAspect);

		bbmod_shader_set_cam_pos(_shader);
		bbmod_shader_set_exposure(_shader);

		var _uLightPosition = shader_get_uniform(shader_current(), "bbmod_LightPosition");
		var _uLightRange = shader_get_uniform(shader_current(), "bbmod_LightRange");
		var _uLightColor = shader_get_uniform(shader_current(), "bbmod_LightColor");
		var _uLightIsSpot = shader_get_uniform(shader_current(), "bbmod_LightIsSpot");
		var _uLightDirection = shader_get_uniform(shader_current(), "bbmod_LightDirection");
		var _uLightInner = shader_get_uniform(shader_current(), "bbmod_LightInner");
		var _uLightOuter = shader_get_uniform(shader_current(), "bbmod_LightOuter");
		var _uShadowmapEnablePS = shader_get_uniform(shader_current(), BBMOD_U_SHADOWMAP_ENABLE_PS);
		var _uShadowmap = shader_get_sampler_index(shader_current(), BBMOD_U_SHADOWMAP);
		var _uShadowmapTexel = shader_get_uniform(shader_current(), BBMOD_U_SHADOWMAP_TEXEL);
		var _uShadowmapArea = shader_get_uniform(shader_current(), BBMOD_U_SHADOWMAP_AREA);
		var _uShadowmapNormalOffset = shader_get_uniform(shader_current(), BBMOD_U_SHADOWMAP_NORMAL_OFFSET);
		var _uShadowmapMatrix = shader_get_uniform(shader_current(), BBMOD_U_SHADOWMAP_MATRIX);
		var _uShadowmapBias = shader_get_uniform(shader_current(), BBMOD_U_SHADOWMAP_BIAS);
		var _sphere = __sphere.Meshes[0].VertexBuffer;
		var _texGB0 = surface_get_texture(__surGBuffer[0]);

		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		gpu_set_blendmode(bm_add);
		gpu_set_zwriteenable(false);
		gpu_set_ztestenable(true);
		gpu_set_cullmode(cull_clockwise);

		for (var i = array_length(global.__bbmodPunctualLights) - 1; i >= 0; --i)
		{
			with (global.__bbmodPunctualLights[i])
			{
				if (!Enabled)
				{
					continue;
				}
				matrix_set(matrix_world, matrix_build(
					Position.X, Position.Y, Position.Z,
					0, 0, 0,
					Range, Range, Range
				));
				shader_set_uniform_f(_uLightPosition, Position.X, Position.Y, Position.Z);
				shader_set_uniform_f(_uLightRange, Range);
				shader_set_uniform_f(_uLightColor,
					Color.Red / 255.0,
					Color.Green / 255.0,
					Color.Blue / 255.0,
					Color.Alpha
				);
				if (is_instanceof(self, BBMOD_SpotLight))
				{
					shader_set_uniform_f(_uLightIsSpot, 1.0);
					shader_set_uniform_f(_uLightDirection, Direction.X, Direction.Y, Direction.Z);
					shader_set_uniform_f(_uLightInner, dcos(AngleInner));
					shader_set_uniform_f(_uLightOuter, dcos(AngleOuter));

					if (CastShadows)
					{
						var _shadowmapMatrix = __getShadowmapMatrix();
						var _shadowmapZFar = __getZFar();
						var _shadowmapSurface = other.__shadowmapSurfaces[? self];
						if (surface_exists(_shadowmapSurface))
						{
							var _shadowmapTexture = surface_get_texture(_shadowmapSurface);
							shader_set_uniform_f(_uShadowmapEnablePS, 1.0);
							texture_set_stage(_uShadowmap, _shadowmapTexture);
							gpu_set_tex_mip_enable_ext(_uShadowmap, true);
							gpu_set_tex_filter_ext(_uShadowmap, true);
							gpu_set_tex_repeat_ext(_uShadowmap, false);
							shader_set_uniform_f(_uShadowmapTexel,
								texture_get_texel_width(_shadowmapTexture),
								texture_get_texel_height(_shadowmapTexture));
							shader_set_uniform_f(_uShadowmapArea, _shadowmapZFar);
							shader_set_uniform_f(_uShadowmapNormalOffset, other.ShadowmapNormalOffset);
							shader_set_uniform_f(_uShadowmapBias, 0.0);
							shader_set_uniform_matrix_array(_uShadowmapMatrix, _shadowmapMatrix);
						}
						else
						{
							shader_set_uniform_f(_uShadowmapEnablePS, 0.0);
						}
					}
					else
					{
						shader_set_uniform_f(_uShadowmapEnablePS, 0.0);
					}
				}
				else
				{
					shader_set_uniform_f(_uLightIsSpot, 0.0);
					if (CastShadows)
					{
						var _shadowmapZFar = __getZFar();
						var _shadowmapSurface = other.__shadowmapSurfaces[? self];
						if (surface_exists(_shadowmapSurface))
						{
							var _shadowmapTexture = surface_get_texture(_shadowmapSurface);
							shader_set_uniform_f(_uShadowmapEnablePS, 1.0);
							texture_set_stage(_uShadowmap, _shadowmapTexture);
							gpu_set_tex_mip_enable_ext(_uShadowmap, true);
							gpu_set_tex_filter_ext(_uShadowmap, true);
							gpu_set_tex_repeat_ext(_uShadowmap, false);
							shader_set_uniform_f(_uShadowmapTexel,
								texture_get_texel_width(_shadowmapTexture),
								texture_get_texel_height(_shadowmapTexture));
							shader_set_uniform_f(_uShadowmapArea, _shadowmapZFar);
							shader_set_uniform_f(_uShadowmapNormalOffset, other.ShadowmapNormalOffset);
							shader_set_uniform_f(_uShadowmapBias, 0.0);
						}
						else
						{
							shader_set_uniform_f(_uShadowmapEnablePS, 0.0);
						}
					}
					else
					{
						shader_set_uniform_f(_uShadowmapEnablePS, 0.0);
					}
				}
				vertex_submit(_sphere, pr_trianglelist, _texGB0);
			}
		}

		matrix_set(matrix_world, _world);

		gpu_pop_state();
		shader_reset();
		surface_reset_target();

		////////////////////////////////////////////////////////////////////////
		//
		// Combine
		//
		surface_set_target(__surFinal);

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		gpu_set_blendenable(false);
		gpu_set_zwriteenable(false);
		gpu_set_ztestenable(false);
		camera_apply(__camera2D);
		matrix_set(matrix_world, matrix_build_identity());
		draw_surface(__surLBuffer, 0, 0);
		gpu_pop_state();

		gpu_push_state();
		gpu_set_colorwriteenable(true, true, true, false);
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
		//bbmod_material_reset();

		bbmod_render_pass_set(BBMOD_ERenderPass.Alpha);
		_rqi = 0;
		repeat (array_length(_renderQueues))
		{
			_renderQueues[_rqi++].submit();
		}
		bbmod_material_reset();

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

		////////////////////////////////////////////////////////////////////////
		//
		// Blit
		//
		camera_apply(__camera2D);
		matrix_set(matrix_world, matrix_build_identity());
		if (_hdr)
		{
			shader_set(BBMOD_ShHDRToSDR);
			shader_set_uniform_f(shader_get_uniform(shader_current(), BBMOD_U_EXPOSURE), global.__bbmodCameraExposure);
		}
		draw_surface(__surFinal, 0, 0);
		if (_hdr)
		{
			shader_reset();
		}
		matrix_set(matrix_world, _world);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		////////////////////////////////////////////////////////////////////////

		// Reset render pass back to Forward at the end!
		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		// Unset in case it gets destroyed when the room changes etc.
		bbmod_shader_unset_global(BBMOD_U_SHADOWMAP);
		bbmod_shader_unset_global(BBMOD_U_SSAO);
		bbmod_shader_unset_global(BBMOD_U_GBUFFER);

		bbmod_shader_set_global_f(BBMOD_U_HDR, 0.0);

		matrix_set(matrix_world, _world);
		return self;
	};

	static present = function ()
	{
		BaseRenderer_present();

		//var _s = 1/6;
		//var _w = get_width() * _s;
		//var _h = get_height() * _s;
		//var _x = X;
		//var _y = Y;

		//for (var i = 0; i < array_length(__surGBuffer); ++i)
		//{
		//	shader_set(BBMOD_ShGBufferExtractRGB);
		//	draw_surface_stretched(__surGBuffer[i], _x, _y, _w, _h); _y += _h;
		//	shader_reset();

		//	shader_set(BBMOD_ShGBufferExtractA);
		//	draw_surface_stretched(__surGBuffer[i], _x, _y, _w, _h); _y += _h;
		//	shader_reset();
		//}

		return self;
	};

	static destroy = function ()
	{
		BaseRenderer_destroy();

		for (var i = array_length(__surGBuffer) - 1; i >= 0; --i)
		{
			if (surface_exists(__surGBuffer[i]))
			{
				surface_free(__surGBuffer[i]);
			}
		}

		if (surface_exists(__surLBuffer))
		{
			surface_free(__surLBuffer);
		}

		if (surface_exists(__surFinal))
		{
			surface_free(__surFinal);
		}

		camera_destroy(__camera2D);

		return undefined;
	};
}
