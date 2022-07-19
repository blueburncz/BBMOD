#pragma include("Color.xsh")
#pragma include("DoDirectionalLightPS.xsh")
#pragma include("DoPointLightPS.xsh")
#pragma include("Exposure.xsh")
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
	vec3 lightDiffuse = vec3(0.0);
	vec3 lightSpecular = vec3(0.0);
	vec3 lightSubsurface = vec3(0.0);

	// Ambient light
	vec3 ambientUp = xGammaToLinear(bbmod_LightAmbientUp.rgb) * bbmod_LightAmbientUp.a;
	vec3 ambientDown = xGammaToLinear(bbmod_LightAmbientDown.rgb) * bbmod_LightAmbientDown.a;
	lightDiffuse += mix(ambientDown, ambientUp, N.z * 0.5 + 0.5);

	// Shadow mapping
	float shadow = 0.0;
#if !defined(X_2D)
	if (bbmod_ShadowmapEnablePS == 1.0)
	{
		shadow = ShadowMap(bbmod_Shadowmap, bbmod_ShadowmapTexel, v_vPosShadowmap.xy, v_vPosShadowmap.z);
	}
#endif

#if defined(X_2D)
	vec3 V = vec3(0.0, 0.0, 1.0);
#else
	vec3 V = normalize(bbmod_CamPos - v_vVertex);
#endif
	// IBL
	lightDiffuse += xDiffuseIBL(bbmod_IBL, bbmod_IBLTexel, N);
	lightSpecular += xSpecularIBL(bbmod_IBL, bbmod_IBLTexel, material.Specular, material.Roughness, N, V);
	// TODO: Subsurface scattering for IBL

	// Directional light
	vec3 directionalLightColor = xGammaToLinear(bbmod_LightDirectionalColor.rgb) * bbmod_LightDirectionalColor.a;
	DoDirectionalLightPS(
		bbmod_LightDirectionalDir,
		directionalLightColor,
		shadow,
		v_vVertex, N, V, material, lightDiffuse, lightSpecular, lightSubsurface);

#if !defined(X_PARTICLES)
	// SSAO
	float ssao = texture2D(bbmod_SSAO, xUnproject(v_vPosition)).r;
	lightDiffuse *= ssao;
	lightSpecular *= ssao;
#endif

	// Point lights
	for (int i = 0; i < MAX_POINT_LIGHTS; ++i)
	{
		vec4 positionRange = bbmod_LightPointData[i * 2];
		vec4 colorAlpha = bbmod_LightPointData[(i * 2) + 1];
		vec3 color = xGammaToLinear(colorAlpha.rgb) * colorAlpha.a;
		DoPointLightPS(positionRange.xyz, positionRange.w, color, v_vVertex, N, V,
			material, lightDiffuse, lightSpecular, lightSubsurface);
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
	GammaCorrect();
}
