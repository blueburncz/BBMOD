function BBMOD_DeferredRenderer()
	: BBMOD_BaseRenderer() constructor
{
	static BaseRenderer_destroy = destroy;
	static BaseRenderer_present = present;

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
		bbmod_material_reset();

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
		draw_clear(c_black);

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

		{
			var _pos = global.__bbmodCameraPosition;
			shader_set_uniform_f(shader_get_uniform(shader_current(), BBMOD_U_CAM_POS), _pos.X, _pos.Y, _pos.Z);
		}

		{
			shader_set_uniform_f(shader_get_uniform(shader_current(), BBMOD_U_EXPOSURE), global.__bbmodCameraExposure);
		}

		{
			var _texture = pointer_null;
			var _texel;

			var _ibl = global.__bbmodImageBasedLight;

			if (_ibl != undefined
				&& _ibl.Enabled)
			{
				_texture = _ibl.Texture;
				_texel = _ibl.Texel;
			}

			if (global.__bbmodReflectionProbeTexture != pointer_null)
			{
				_texture = global.__bbmodReflectionProbeTexture;
				_texel = texture_get_texel_height(_texture);
			}

			var _shaderCurrent = shader_current();

			if (_texture != pointer_null)
			{
				var _uIBL = shader_get_sampler_index(_shaderCurrent, BBMOD_U_IBL);

				texture_set_stage(_uIBL, _texture);
				gpu_set_tex_mip_enable_ext(_uIBL, mip_off)
				gpu_set_tex_filter_ext(_uIBL, true);
				gpu_set_tex_repeat_ext(_uIBL, false);
				shader_set_uniform_f(
					shader_get_uniform(_shaderCurrent, BBMOD_U_IBL_TEXEL),
					_texel, _texel);
				shader_set_uniform_f(
					shader_get_uniform(_shaderCurrent, BBMOD_U_IBL_ENABLE),
					1.0);
			}
			else
			{
				shader_set_uniform_f(
					shader_get_uniform(_shaderCurrent, BBMOD_U_IBL_ENABLE),
					0.0);
			}
		}

		{
			var _up = global.__bbmodAmbientLightUp;
			var _down = global.__bbmodAmbientLightDown;
			var _dir = global.__bbmodAmbientLightDirUp;
			var _shaderCurrent = shader_current();
			shader_set_uniform_f(
				shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_AMBIENT_UP),
				_up.Red / 255.0, _up.Green / 255.0, _up.Blue / 255.0, _up.Alpha);
			shader_set_uniform_f(
				shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_AMBIENT_DOWN),
				_down.Red / 255.0, _down.Green / 255.0, _down.Blue / 255.0, _down.Alpha);
			shader_set_uniform_f(
				shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_AMBIENT_DIR_UP),
				_dir.X, _dir.Y, _dir.Z);
		}

		{
			var _light = global.__bbmodDirectionalLight;
			var _shaderCurrent = shader_current();
			var _uLightDirectionalDir = shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_DIRECTIONAL_DIR);
			var _uLightDirectionalColor = shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_DIRECTIONAL_COLOR);
			if (_light != undefined	&& _light.Enabled)
			{
				var _direction = _light.Direction;
				shader_set_uniform_f(_uLightDirectionalDir,
					_direction.X, _direction.Y, _direction.Z);
				var _color = _light.Color;
				shader_set_uniform_f(_uLightDirectionalColor,
					_color.Red / 255.0,
					_color.Green / 255.0,
					_color.Blue / 255.0,
					_color.Alpha);
			}
			else
			{
				shader_set_uniform_f(_uLightDirectionalDir, 0.0, 0.0, -1.0);
				shader_set_uniform_f(_uLightDirectionalColor, 0.0, 0.0, 0.0, 0.0);
			}
		}

		//{
		//	var _color = global.__bbmodFogColor;
		//	var _intensity = global.__bbmodFogIntensity;
		//	var _start = global.__bbmodFogStart;
		//	var _end = global.__bbmodFogEnd;
		//	var _rcpFogRange = 1.0 / (_end - _start);
		//	var _shaderCurrent = shader_current();
		//	shader_set_uniform_f(
		//		shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_COLOR),
		//		_color.Red / 255.0,
		//		_color.Green / 255.0,
		//		_color.Blue / 255.0,
		//		_color.Alpha);
		//	shader_set_uniform_f(
		//		shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_INTENSITY),
		//		_intensity);
		//	shader_set_uniform_f(
		//		shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_START),
		//		_start);
		//	shader_set_uniform_f(
		//		shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_RCP_RANGE),
		//		_rcpFogRange);
		//}

		//{
		//	texture_set_stage(
		//		shader_get_sampler_index(shader_current(), BBMOD_U_SSAO),
		//		sprite_get_texture(BBMOD_SprWhite, 0));
		//}

		draw_surface(__surGBuffer[0], 0, 0);
		shader_reset();

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

		{
			var _pos = global.__bbmodCameraPosition;
			shader_set_uniform_f(shader_get_uniform(shader_current(), BBMOD_U_CAM_POS), _pos.X, _pos.Y, _pos.Z);
		}

		{
			shader_set_uniform_f(shader_get_uniform(shader_current(), BBMOD_U_EXPOSURE), global.__bbmodCameraExposure);
		}

		{
			var _texture = pointer_null;
			var _texel;

			var _ibl = global.__bbmodImageBasedLight;

			if (_ibl != undefined
				&& _ibl.Enabled)
			{
				_texture = _ibl.Texture;
				_texel = _ibl.Texel;
			}

			if (global.__bbmodReflectionProbeTexture != pointer_null)
			{
				_texture = global.__bbmodReflectionProbeTexture;
				_texel = texture_get_texel_height(_texture);
			}

			var _shaderCurrent = shader_current();

			if (_texture != pointer_null)
			{
				var _uIBL = shader_get_sampler_index(_shaderCurrent, BBMOD_U_IBL);

				texture_set_stage(_uIBL, _texture);
				gpu_set_tex_mip_enable_ext(_uIBL, mip_off)
				gpu_set_tex_filter_ext(_uIBL, true);
				gpu_set_tex_repeat_ext(_uIBL, false);
				shader_set_uniform_f(
					shader_get_uniform(_shaderCurrent, BBMOD_U_IBL_TEXEL),
					_texel, _texel);
				shader_set_uniform_f(
					shader_get_uniform(_shaderCurrent, BBMOD_U_IBL_ENABLE),
					1.0);
			}
			else
			{
				shader_set_uniform_f(
					shader_get_uniform(_shaderCurrent, BBMOD_U_IBL_ENABLE),
					0.0);
			}
		}

		{
			var _up = global.__bbmodAmbientLightUp;
			var _down = global.__bbmodAmbientLightDown;
			var _dir = global.__bbmodAmbientLightDirUp;
			var _shaderCurrent = shader_current();
			shader_set_uniform_f(
				shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_AMBIENT_UP),
				_up.Red / 255.0, _up.Green / 255.0, _up.Blue / 255.0, _up.Alpha);
			shader_set_uniform_f(
				shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_AMBIENT_DOWN),
				_down.Red / 255.0, _down.Green / 255.0, _down.Blue / 255.0, _down.Alpha);
			shader_set_uniform_f(
				shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_AMBIENT_DIR_UP),
				_dir.X, _dir.Y, _dir.Z);
		}

		{
			var _light = global.__bbmodDirectionalLight;
			var _shaderCurrent = shader_current();
			var _uLightDirectionalDir = shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_DIRECTIONAL_DIR);
			var _uLightDirectionalColor = shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_DIRECTIONAL_COLOR);
			if (_light != undefined	&& _light.Enabled)
			{
				var _direction = _light.Direction;
				shader_set_uniform_f(_uLightDirectionalDir,
					_direction.X, _direction.Y, _direction.Z);
				var _color = _light.Color;
				shader_set_uniform_f(_uLightDirectionalColor,
					_color.Red / 255.0,
					_color.Green / 255.0,
					_color.Blue / 255.0,
					_color.Alpha);
			}
			else
			{
				shader_set_uniform_f(_uLightDirectionalDir, 0.0, 0.0, -1.0);
				shader_set_uniform_f(_uLightDirectionalColor, 0.0, 0.0, 0.0, 0.0);
			}
		}

		//{
		//	var _color = global.__bbmodFogColor;
		//	var _intensity = global.__bbmodFogIntensity;
		//	var _start = global.__bbmodFogStart;
		//	var _end = global.__bbmodFogEnd;
		//	var _rcpFogRange = 1.0 / (_end - _start);
		//	var _shaderCurrent = shader_current();
		//	shader_set_uniform_f(
		//		shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_COLOR),
		//		_color.Red / 255.0,
		//		_color.Green / 255.0,
		//		_color.Blue / 255.0,
		//		_color.Alpha);
		//	shader_set_uniform_f(
		//		shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_INTENSITY),
		//		_intensity);
		//	shader_set_uniform_f(
		//		shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_START),
		//		_start);
		//	shader_set_uniform_f(
		//		shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_RCP_RANGE),
		//		_rcpFogRange);
		//}

		//{
		//	texture_set_stage(
		//		shader_get_sampler_index(shader_current(), BBMOD_U_SSAO),
		//		sprite_get_texture(BBMOD_SprWhite, 0));
		//}

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
		surface_set_target(__surGBuffer[0]);

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
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
		draw_surface(__surGBuffer[0], 0, 0);
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

		matrix_set(matrix_world, _world);
		return self;
	};

	static present = function ()
	{
		BaseRenderer_present();

		//var _s = 1/4;
		//var _w = _width * _s;
		//var _h = _height * _s;
		//var _x = X;
		//var _y = Y;

		//shader_set(BBMOD_ShGBufferExtractRGB);
		//draw_surface_stretched(__surGBuffer[1], _x, _y, _w, _h); _y += _h;
		//shader_reset();

		//shader_set(BBMOD_ShGBufferExtractA);
		//draw_surface_stretched(__surGBuffer[1], _x, _y, _w, _h); _y += _h;
		//shader_reset();

		//shader_set(BBMOD_ShGBufferExtractRGB);
		//draw_surface_stretched(__surGBuffer[2], _x, _y, _w, _h); _y += _h;
		//shader_reset();

		//shader_set(BBMOD_ShGBufferExtractA);
		//draw_surface_stretched(__surGBuffer[2], _x, _y, _w, _h); _y += _h;
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
