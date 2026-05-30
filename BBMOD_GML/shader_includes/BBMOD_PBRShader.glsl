// @include BBMOD_PunctualLightData
// @include BBMOD_Material
// @include BBMOD_GammaToLinear
// @include BBMOD_DoDirectionalLightPS
// @include BBMOD_DoPointLightPS
// @include BBMOD_DoSpotLightPS
// @include BBMOD_Exposure
// @include BBMOD_TonemapReinhard
// @include BBMOD_Fog
// @include BBMOD_GammaCorrect
// @include BBMOD_DiffuseIBL
// @include BBMOD_SpecularIBL
// @include BBMOD_ShadowMap
// @include BBMOD_Vec3ToOctahedronUV
// @include BBMOD_DecodeDepth
// @include BBMOD_Unproject

/// @desc Full PBR lighting pass. Writes the final color to gl_FragColor.
/// Requires defines: BBMOD_MAX_PUNCTUAL_LIGHTS (e.g. 8),
///                   SHADOWMAP_SAMPLE_COUNT (e.g. 12).
/// Requires helper functions: BBMOD_GetPunctualLightDataA,
///                            BBMOD_GetPunctualLightDataB.
/// Requires uniforms: bbmod_CamPos, bbmod_ZFar, bbmod_Exposure, bbmod_HDR,
///   bbmod_LightAmbientDirUp, bbmod_LightAmbientUp, bbmod_LightAmbientDown,
///   bbmod_LightDirectionalDir, bbmod_LightDirectionalColor,
///   bbmod_LightPunctualDataA[], bbmod_LightPunctualDataB[],
///   bbmod_IBLEnable, bbmod_IBL, bbmod_IBLTexel,
///   bbmod_ShadowmapEnablePS, bbmod_Shadowmap, bbmod_ShadowmapTexel,
///   bbmod_ShadowmapArea, bbmod_ShadowmapBias, bbmod_ShadowCasterIndex,
///   bbmod_ShadowmapNormalOffsetPS, bbmod_SSAO,
///   bbmod_DitherEnable, bbmod_FogColor, bbmod_FogIntensity,
///   bbmod_FogStart, bbmod_FogRcpRange.
/// @param material Unpacked material properties.
/// @param depth View-space depth of the fragment.
void BBMOD_PBRShader(BBMOD_Material material, float depth)
{
	vec3 N = material.Normal;
// @if defined(BBMOD_2D)
	vec3 V = v_vEye.xyz;
// @else
	vec3 V = (v_vEye.w == 1.0)
		? v_vEye.xyz
		: normalize(bbmod_CamPos - v_vVertex);
// @endif
	vec3 lightDiffuse = vec3(0.0);
	vec3 lightSpecular = vec3(0.0);

// @if defined(BBMOD_SUBSURFACE)
	vec3 lightSubsurface = vec3(0.0);
// @endif

	vec3 ambientUp = BBMOD_GammaToLinear(bbmod_LightAmbientUp.rgb)
		* bbmod_LightAmbientUp.a;
	vec3 ambientDown = BBMOD_GammaToLinear(bbmod_LightAmbientDown.rgb)
		* bbmod_LightAmbientDown.a;
	lightDiffuse += mix(ambientDown, ambientUp,
		dot(N, bbmod_LightAmbientDirUp) * 0.5 + 0.5);

	float shadow = 0.0;
// @if !defined(BBMOD_2D)
	if (bbmod_ShadowmapEnablePS == 1.0)
	{
		int shadowCasterIndex = int(bbmod_ShadowCasterIndex);
		bool isPoint = (shadowCasterIndex >= 0)
			&& (BBMOD_GetPunctualLightDataB(shadowCasterIndex * 2).x == 0.0);
		if (!isPoint)
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
			shadow = BBMOD_ShadowMap(
				bbmod_Shadowmap,
				bbmod_ShadowmapTexel,
				shadowmapPos.xy,
				shadowmapPos.z) * shadowmapAtt;
		}
		else
		{
			vec3 position =
				BBMOD_GetPunctualLightDataA(shadowCasterIndex * 2).xyz;
			vec3 lightVec = position - v_vVertex;
			vec2 uv = BBMOD_Vec3ToOctahedronUV(-lightVec);
			shadow = BBMOD_ShadowMap(
				bbmod_Shadowmap,
				bbmod_ShadowmapTexel,
				uv,
				(length(lightVec) - bbmod_ShadowmapNormalOffsetPS)
					/ bbmod_ShadowmapArea);
		}
	}
// @endif

	if (bbmod_IBLEnable == 1.0)
	{
		lightDiffuse += BBMOD_DiffuseIBL(bbmod_IBL, bbmod_IBLTexel, N);
		lightSpecular += BBMOD_SpecularIBL(
			bbmod_IBL, bbmod_IBLTexel,
			material.Specular, material.Roughness, N, V);
	}

	vec3 directionalLightColor =
		BBMOD_GammaToLinear(bbmod_LightDirectionalColor.rgb)
		* bbmod_LightDirectionalColor.a;
	BBMOD_DoDirectionalLightPS(
		bbmod_LightDirectionalDir,
		directionalLightColor,
		(bbmod_ShadowCasterIndex == -1.0) ? shadow : 0.0,
		v_vVertex, N, V, material,
		lightDiffuse, lightSpecular
// @if defined(BBMOD_SUBSURFACE)
		, lightSubsurface
// @endif
		);

// @if !defined(BBMOD_PARTICLES)
	float ssao = texture2D(bbmod_SSAO, BBMOD_Unproject(v_vPosition)).r;
	lightDiffuse *= ssao;
	lightSpecular *= ssao;
// @endif

	for (int i = 0; i < BBMOD_MAX_PUNCTUAL_LIGHTS; ++i)
	{
		vec4 positionRange = BBMOD_GetPunctualLightDataA(i * 2);
		vec4 colorAlpha = BBMOD_GetPunctualLightDataA((i * 2) + 1);
		vec3 isSpotInnerOuter = BBMOD_GetPunctualLightDataB(i * 2);
		vec3 direction = BBMOD_GetPunctualLightDataB((i * 2) + 1);
		vec3 color = BBMOD_GammaToLinear(colorAlpha.rgb) * colorAlpha.a;
		if (isSpotInnerOuter.x == 1.0)
		{
			BBMOD_DoSpotLightPS(
				positionRange.xyz, positionRange.w, color,
				(bbmod_ShadowCasterIndex == float(i)) ? shadow : 0.0,
				direction, isSpotInnerOuter.y, isSpotInnerOuter.z,
				v_vVertex, N, V, material,
				lightDiffuse, lightSpecular
// @if defined(BBMOD_SUBSURFACE)
				, lightSubsurface
// @endif
				);
		}
		else
		{
			BBMOD_DoPointLightPS(
				positionRange.xyz, positionRange.w, color,
				(bbmod_ShadowCasterIndex == float(i)) ? shadow : 0.0,
				v_vVertex, N, V, material,
				lightDiffuse, lightSpecular
// @if defined(BBMOD_SUBSURFACE)
				, lightSubsurface
// @endif
				);
		}
	}

// @if defined(BBMOD_LIGHTMAP)
	lightDiffuse += material.Lightmap;
// @endif

	gl_FragColor.rgb = material.Base * lightDiffuse;
	gl_FragColor.rgb += lightSpecular;
	gl_FragColor.rgb *= material.AO;

// @if defined(BBMOD_EMISSIVE)
	gl_FragColor.rgb += material.Emissive;
// @endif

// @if defined(BBMOD_SUBSURFACE)
	gl_FragColor.rgb += lightSubsurface;
// @endif

	gl_FragColor.a = material.Opacity;

// @if defined(BBMOD_PARTICLES)
	if (bbmod_SoftDistance > 0.0)
	{
		float sceneDepth = BBMOD_DecodeDepth(
			texture2D(bbmod_GBuffer,
				BBMOD_Unproject(v_vPosition)).rgb) * bbmod_ZFar;
		float softness = clamp(
			(sceneDepth - v_vPosition.z) / bbmod_SoftDistance, 0.0, 1.0);
		gl_FragColor.a *= softness;
	}
// @endif

	gl_FragColor.rgb = BBMOD_Fog(gl_FragColor.rgb, depth);

	if (bbmod_HDR == 0.0)
	{
		gl_FragColor.rgb = BBMOD_Exposure(gl_FragColor.rgb);
		gl_FragColor.rgb = BBMOD_TonemapReinhard(gl_FragColor.rgb);
		gl_FragColor.rgb = BBMOD_GammaCorrect(gl_FragColor.rgb);
	}
}
