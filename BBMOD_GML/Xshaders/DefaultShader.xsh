#pragma include("Color.xsh")
#pragma include("DoDirectionalLightPS.xsh")
#pragma include("DoPointLightPS.xsh")
#pragma include("Exposure.xsh")
#pragma include("Fog.xsh")
#pragma include("GammaCorrect.xsh")
#pragma include("IBL.xsh")
#pragma include("RGBM.xsh")
#pragma include("ShadowMap.xsh")
#pragma include("SpecularMaterial.xsh")

void DefaultShader(Material material, float depth)
{
	vec3 N = material.Normal;
	vec3 lightDiffuse = vec3(0.0);
	vec3 lightSpecular = vec3(0.0);
	vec3 lightSubsurface = vec3(0.0);

	// Ambient light
	vec3 ambientUp = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientUp));
	vec3 ambientDown = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientDown));
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

	// Directional light
	vec3 directionalLightColor = xGammaToLinear(xDecodeRGBM(bbmod_LightDirectionalColor));
	DoDirectionalLightPS(
		bbmod_LightDirectionalDir,
		directionalLightColor,
		shadow,
		v_vVertex, N, V, material, lightDiffuse, lightSpecular, lightSubsurface);

	// Point lights
	for (int i = 0; i < MAX_POINT_LIGHTS; ++i)
	{
		vec4 positionRange = bbmod_LightPointData[i * 2];
		vec3 color = xGammaToLinear(xDecodeRGBM(bbmod_LightPointData[(i * 2) + 1]));
		DoPointLightPS(positionRange.xyz, positionRange.w, color, v_vVertex, N, V,
			material, lightDiffuse, lightSpecular, lightSubsurface);
	}
	
	// Diffuse
	gl_FragColor.rgb = material.Base * lightDiffuse;
	// Specular
	gl_FragColor.rgb += lightSpecular;
	// Emissive
	gl_FragColor.rgb += material.Emissive;
	// Subsurface scattering
	gl_FragColor.rgb += lightSubsurface;
	// Opacity
	gl_FragColor.a = material.Opacity;
	// Fog
	Fog(depth);

	Exposure();
	GammaCorrect();
}
