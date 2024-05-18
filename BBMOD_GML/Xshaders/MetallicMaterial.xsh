#pragma include("Material.xsh")
#pragma include("BRDFConstants.xsh")
#pragma include("Color.xsh")
#pragma include("RGBM.xsh")

/// @desc Unpacks material from textures.
/// @param texBaseOpacity RGB: base color, A: opacity
/// @param isRoughness
/// @param texNormalW
/// @param isMetallic
/// @param texMaterial
/// @param texSubsurface  RGB: subsurface color, A: intensity
/// @param texEmissive    RGBA: RGBM encoded emissive color
/// @param texLightmap    RGBA: RGBM encoded lightmap
/// @param uvLightmap     Lightmap texture coordinates
/// @param TBN            Tangent-bitangent-normal matrix
/// @param uv             Texture coordinates
Material UnpackMaterial(
	sampler2D texBaseOpacity,
	float isRoughness,
	sampler2D texNormalW,
#if !defined(X_TERRAIN)
	float isMetallic,
	sampler2D texMaterial,
#if !defined(X_LIGHTMAP) && !defined(X_PARTICLES) && !defined(X_OUTPUT_GBUFFER)
	sampler2D texSubsurface,
#endif
	sampler2D texEmissive,
#endif
#if defined(X_LIGHTMAP)
	sampler2D texLightmap,
	vec2 uvLightmap,
#endif
	mat3 TBN,
	vec2 uv)
{
	Material m = CreateMaterial();

	// Base color and opacity
	vec4 baseOpacity = texture2D(texBaseOpacity,
#if defined(X_2D)
		mix(bbmod_BaseOpacityUV.xy, bbmod_BaseOpacityUV.zw, uv)
#else
		uv
#endif
		);
	m.Base = xGammaToLinear(baseOpacity.rgb);
	m.Opacity = baseOpacity.a;

	// Normal vector and smoothness/roughness
	vec4 normalW = texture2D(texNormalW,
#if defined(X_2D)
		mix(bbmod_NormalWUV.xy, bbmod_NormalWUV.zw, uv)
#else
		uv
#endif
		);
	m.Normal = normalize(TBN * (normalW.rgb * 2.0 - 1.0));

#if !defined(X_TERRAIN)
	if (bbmod_TwoSided == 1.0 && !gl_FrontFacing)
	{
		m.Normal *= -1.0;
	}
#endif

	if (isRoughness == 1.0)
	{
		m.Roughness = mix(0.1, 0.9, normalW.a);
		m.Smoothness = 1.0 - m.Roughness;
	}
	else
	{
		m.Smoothness = mix(0.1, 0.9, normalW.a);
		m.Roughness = 1.0 - m.Smoothness;
	}

	// Material properties
#if defined(X_TERRAIN)
	m.Metallic = 0.0;
	m.AO = 1.0;
	m.Specular = F0_DEFAULT;
#else
	vec4 materialProps = texture2D(texMaterial,
#if defined(X_2D)
		mix(bbmod_MaterialUV.xy, bbmod_MaterialUV.zw, uv)
#else
		uv
#endif
		);

	if (isMetallic == 1.0)
	{
		m.Metallic = materialProps.r;
		m.AO = materialProps.g;
		m.Specular = mix(F0_DEFAULT, m.Base, m.Metallic);
		m.Base *= (1.0 - m.Metallic);
	}
	else
	{
		m.Specular = materialProps.rgb;
		m.SpecularPower = exp2(1.0 + (m.Smoothness * 10.0));
	}

#if !defined(X_LIGHTMAP) && !defined(X_PARTICLES) && !defined(X_OUTPUT_GBUFFER)
	// Subsurface (color and intensity)
	vec4 subsurface = texture2D(texSubsurface,
#if defined(X_2D)
		mix(bbmod_SubsurfaceUV.xy, bbmod_SubsurfaceUV.zw, uv)
#else
	uv
#endif
	);
	m.Subsurface = vec4(xGammaToLinear(subsurface.rgb).rgb, subsurface.a);
#endif

	// Emissive color
	m.Emissive = xGammaToLinear(xDecodeRGBM(texture2D(texEmissive,
#if defined(X_2D)
		mix(bbmod_EmissiveUV.xy, bbmod_EmissiveUV.zw, uv)
#else
	uv
#endif
	)));
#endif

#if defined(X_LIGHTMAP)
	// Lightmap
	m.Lightmap = xGammaToLinear(xDecodeRGBM(texture2D(texLightmap, uvLightmap)));
#endif

	return m;
}
