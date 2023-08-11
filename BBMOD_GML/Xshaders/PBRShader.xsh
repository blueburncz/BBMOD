#pragma include("Color.xsh")
#pragma include("DoDirectionalLightPS.xsh")
#pragma include("DoPointLightPS.xsh")
#pragma include("DoSpotLightPS.xsh")
#pragma include("Exposure.xsh")
#pragma include("TonemapReinhard.xsh")
#pragma include("Fog.xsh")
#pragma include("GammaCorrect.xsh")
#pragma include("IBL.xsh")
#pragma include("MetallicMaterial.xsh")
#pragma include("Projecting.xsh")
#pragma include("RGBM.xsh")
#pragma include("ShadowMap.xsh")

void PBRShader(Material material, float depth)
{
	vec3 N = material.Normal;
#if defined(X_2D)
	vec3 V = v_vEye.xyz;
#else
	vec3 V = (v_vEye.w == 1.0) ? v_vEye.xyz : normalize(bbmod_CamPos - v_vVertex);
#endif
	vec3 lightDiffuse = vec3(0.0);
	vec3 lightSpecular = vec3(0.0);
	vec3 lightSubsurface = vec3(0.0);

	// Ambient light
	vec3 ambientUp = xGammaToLinear(bbmod_LightAmbientUp.rgb) * bbmod_LightAmbientUp.a;
	vec3 ambientDown = xGammaToLinear(bbmod_LightAmbientDown.rgb) * bbmod_LightAmbientDown.a;
	lightDiffuse += mix(ambientDown, ambientUp, dot(N, bbmod_LightAmbientDirUp) * 0.5 + 0.5);

	// Shadow mapping
	float shadow = 0.0;
#if !defined(X_2D)
	if (bbmod_ShadowmapEnablePS == 1.0)
	{
		vec4 shadowmapPos = v_vPosShadowmap;
		shadowmapPos.xy /= shadowmapPos.w;
		float shadowmapAtt = (bbmod_ShadowCasterIndex == -1.0)
			? clamp((1.0 - length(shadowmapPos.xy)) / 0.1, 0.0, 1.0)
			: 1.0;
		shadowmapPos.xy = shadowmapPos.xy * 0.5 + 0.5;
	#if defined(_YY_HLSL11_) || defined(_YY_PSSL_)
		shadowmapPos.y = 1.0 - shadowmapPos.y;
	#endif
		shadowmapPos.z /= bbmod_ShadowmapArea;

		shadow = ShadowMap(bbmod_Shadowmap, bbmod_ShadowmapTexel, shadowmapPos.xy, shadowmapPos.z)
			* shadowmapAtt;
	}
#endif

	// IBL
	if (bbmod_IBLEnable == 1.0)
	{
		lightDiffuse += xDiffuseIBL(bbmod_IBL, bbmod_IBLTexel, N);
		lightSpecular += xSpecularIBL(bbmod_IBL, bbmod_IBLTexel, material.Specular, material.Roughness, N, V);
		// TODO: Subsurface scattering for IBL
	}

	// Directional light
	vec3 directionalLightColor = xGammaToLinear(bbmod_LightDirectionalColor.rgb) * bbmod_LightDirectionalColor.a;
	DoDirectionalLightPS(
		bbmod_LightDirectionalDir,
		directionalLightColor,
		(bbmod_ShadowCasterIndex == -1.0) ? shadow : 0.0,
		v_vVertex, N, V, material, lightDiffuse, lightSpecular, lightSubsurface);

#if !defined(X_PARTICLES)
	// SSAO
	float ssao = texture2D(bbmod_SSAO, xUnproject(v_vPosition)).r;
	lightDiffuse *= ssao;
	lightSpecular *= ssao;
#endif

	// Punctual lights
	for (int i = 0; i < BBMOD_MAX_PUNCTUAL_LIGHTS; ++i)
	{
		vec4 positionRange = bbmod_LightPunctualDataA[i * 2];
		vec4 colorAlpha = bbmod_LightPunctualDataA[(i * 2) + 1];
		vec3 isSpotInnerOuter = bbmod_LightPunctualDataB[i * 2];
		vec3 direction = bbmod_LightPunctualDataB[(i * 2) + 1];
		vec3 color = xGammaToLinear(colorAlpha.rgb) * colorAlpha.a;

		if (isSpotInnerOuter.x == 1.0)
		{
			DoSpotLightPS(
				positionRange.xyz, positionRange.w, color,
				(bbmod_ShadowCasterIndex == float(i)) ? shadow : 0.0,
				direction, isSpotInnerOuter.y, isSpotInnerOuter.z,
				v_vVertex, N, V, material,
				lightDiffuse, lightSpecular, lightSubsurface);
		}
		else
		{
			DoPointLightPS(
				positionRange.xyz, positionRange.w, color,
				(bbmod_ShadowCasterIndex == float(i)) ? shadow : 0.0,
				v_vVertex, N, V, material,
				lightDiffuse, lightSpecular, lightSubsurface);
		}
	}

	// Lightmap
#if defined(X_LIGHTMAP)
	lightDiffuse += material.Lightmap;
#endif

	// Diffuse
	gl_FragColor.rgb = material.Base * lightDiffuse;
	// Specular
	gl_FragColor.rgb += lightSpecular;
	// Ambient occlusion
	gl_FragColor.rgb *= material.AO;
	// Emissive
	gl_FragColor.rgb += material.Emissive;
	// Subsurface scattering
	gl_FragColor.rgb += lightSubsurface;
	// Opacity
	gl_FragColor.a = material.Opacity;
	// Soft particles
#if defined(X_PARTICLES)
	if (bbmod_SoftDistance > 0.0)
	{
		float sceneDepth = xDecodeDepth(texture2D(bbmod_GBuffer, xUnproject(v_vPosition)).rgb) * bbmod_ZFar;
		float softness = clamp((sceneDepth - v_vPosition.z) / bbmod_SoftDistance, 0.0, 1.0);
		gl_FragColor.a *= softness;
	}
#endif
	// Fog
	Fog(depth);

	Exposure();
	TonemapReinhard();
	GammaCorrect();
}
