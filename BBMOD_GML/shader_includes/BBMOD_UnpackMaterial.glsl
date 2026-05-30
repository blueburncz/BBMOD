// @include BBMOD_Material
// @include BBMOD_F0Default
// @include BBMOD_GammaToLinear
// @include BBMOD_DecodeRGBM

/// @desc Unpacks a BBMOD_Material from a set of PBR textures.
///
/// The function signature adapts at build time based on active defines:
///   BBMOD_TERRAIN:       terrain variant (no metallic/specular/emissive/
///                        subsurface).
///   BBMOD_EMISSIVE:      adds texEmissive parameter and emissive sampling.
///   BBMOD_SUBSURFACE:    adds texSubsurface parameter and subsurface
///                        sampling when not in lightmap or G-buffer mode.
///   BBMOD_LIGHTMAP:      adds texLightmap and uvLightmap parameters.
///   BBMOD_OUTPUT_GBUFFER: disables subsurface parameter/sampling.
///
// @if defined(BBMOD_TERRAIN)
/// @param texBaseOpacity RGB: base color, A: opacity.
/// @param isRoughness 1.0 if normal alpha is roughness, 0.0 for smoothness.
/// @param texNormalW RGB: tangent-space normal, A: roughness or smoothness.
/// @param TBN Tangent-bitangent-normal matrix.
/// @param uv Texture coordinates.
// @else
/// @param texBaseOpacity RGB: base color, A: opacity.
/// @param isRoughness 1.0 if normal alpha is roughness, 0.0 for smoothness.
/// @param texNormalW RGB: tangent-space normal, A: roughness or smoothness.
/// @param isMetallic 1.0 for metallic workflow, 0.0 for specular workflow.
/// @param texMaterial Metallic: R=metallic, G=AO. Specular: RGB=specular.
// @if defined(BBMOD_SUBSURFACE) && !defined(BBMOD_LIGHTMAP) && !defined(BBMOD_OUTPUT_GBUFFER)
/// @param texSubsurface RGB: subsurface color, A: intensity.
// @endif
// @if defined(BBMOD_EMISSIVE)
/// @param texEmissive RGBM encoded emissive color.
// @endif
// @if defined(BBMOD_LIGHTMAP)
/// @param texLightmap RGBM encoded lightmap.
/// @param uvLightmap Lightmap UV coordinates (second UV set).
// @endif
/// @param TBN Tangent-bitangent-normal matrix.
/// @param uv Texture coordinates.
// @endif
/// @return Unpacked material.
// @if defined(BBMOD_TERRAIN)
BBMOD_Material BBMOD_UnpackMaterial(
	sampler2D texBaseOpacity,
	float isRoughness,
	sampler2D texNormalW,
	mat3 TBN,
	vec2 uv)
// @else
BBMOD_Material BBMOD_UnpackMaterial(
	sampler2D texBaseOpacity,
	float isRoughness,
	sampler2D texNormalW,
	float isMetallic,
	sampler2D texMaterial,
// @if defined(BBMOD_SUBSURFACE) && !defined(BBMOD_LIGHTMAP) && !defined(BBMOD_OUTPUT_GBUFFER)
	sampler2D texSubsurface,
// @endif
// @if defined(BBMOD_EMISSIVE)
	sampler2D texEmissive,
// @endif
// @if defined(BBMOD_LIGHTMAP)
	sampler2D texLightmap,
	vec2 uvLightmap,
// @endif
	mat3 TBN,
	vec2 uv)
// @endif
{
	BBMOD_Material m = BBMOD_CreateMaterial();

// @if defined(BBMOD_2D)
	vec2 spriteUv = (uv - bbmod_BaseOpacityUV.xy)
		/ (bbmod_BaseOpacityUV.zw - bbmod_BaseOpacityUV.xy);
// @endif

	vec4 baseOpacity = texture2D(texBaseOpacity, uv);
	m.Base = BBMOD_GammaToLinear(baseOpacity.rgb);
	m.Opacity = baseOpacity.a;

	vec4 normalW = texture2D(texNormalW,
// @if defined(BBMOD_2D)
		mix(bbmod_NormalWUV.xy, bbmod_NormalWUV.zw, spriteUv)
// @else
		uv
// @endif
		);

// @if !defined(BBMOD_TERRAIN)
	if (bbmod_TwoSided == 1.0 && !gl_FrontFacing)
	{
		TBN[2] *= -1.0;
	}
// @endif

	vec3 normalTS = normalW.rgb * 2.0 - 1.0;
	float normalLength = length(normalTS);
	m.Normal = normalize(TBN * normalTS);

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

	float variance = 1.0 - normalLength;
	m.Roughness = sqrt(m.Roughness * m.Roughness + variance * variance);
	m.Smoothness = 1.0 - m.Roughness;

// @if defined(BBMOD_TERRAIN)
	m.Metallic = 0.0;
	m.AO = 1.0;
	m.Specular = BBMOD_F0_DEFAULT;
// @else
	vec4 materialProps = texture2D(texMaterial,
// @if defined(BBMOD_2D)
		mix(bbmod_MaterialUV.xy, bbmod_MaterialUV.zw, spriteUv)
// @else
		uv
// @endif
		);
	if (isMetallic == 1.0)
	{
		m.Metallic = materialProps.r;
		m.AO = materialProps.g;
		m.Specular = mix(BBMOD_F0_DEFAULT, m.Base, m.Metallic);
		m.Base *= (1.0 - m.Metallic);
	}
	else
	{
		m.Specular = materialProps.rgb;
		m.SpecularPower = exp2(1.0 + (m.Smoothness * 10.0));
	}

// @if defined(BBMOD_SUBSURFACE) && !defined(BBMOD_LIGHTMAP) && !defined(BBMOD_OUTPUT_GBUFFER)
	vec4 subsurface = texture2D(texSubsurface,
// @if defined(BBMOD_2D)
		mix(bbmod_SubsurfaceUV.xy, bbmod_SubsurfaceUV.zw, spriteUv)
// @else
		uv
// @endif
		);
	m.Subsurface = vec4(BBMOD_GammaToLinear(subsurface.rgb), subsurface.a);
// @endif

// @if defined(BBMOD_EMISSIVE)
	m.Emissive = BBMOD_GammaToLinear(BBMOD_DecodeRGBM(texture2D(texEmissive,
// @if defined(BBMOD_2D)
		mix(bbmod_EmissiveUV.xy, bbmod_EmissiveUV.zw, spriteUv)
// @else
		uv
// @endif
		)));
// @endif

// @if defined(BBMOD_LIGHTMAP)
	m.Lightmap = BBMOD_GammaToLinear(
		BBMOD_DecodeRGBM(texture2D(texLightmap, uvLightmap)));
// @endif
// @endif

	return m;
}
