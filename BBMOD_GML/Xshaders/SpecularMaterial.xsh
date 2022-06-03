#pragma include("Material.xsh")
#pragma include("Color.xsh")
#pragma include("RGBM.xsh")

/// @desc Unpacks material from textures.
/// @param texBaseOpacity      RGB: base color, A: opacity
/// @param texNormalSmoothness RGB: tangent-space normal vector, A: smoothness
/// @param texSpecularColor    RGB: specular color
/// @param TBN                 Tangent-bitangent-normal matrix
/// @param uv                  Texture coordinates
Material UnpackMaterial(
	sampler2D texBaseOpacity,
	sampler2D texNormalSmoothness,
	sampler2D texSpecularColor,
	mat3 TBN,
	vec2 uv)
{
	Material m = CreateMaterial(TBN);

#if defined(X_2D)
	// Base color and opacity
	vec4 baseOpacity = texture2D(texBaseOpacity,
		mix(bbmod_BaseOpacityUV.xy, bbmod_BaseOpacityUV.zw, uv));
	m.Base = xGammaToLinear(baseOpacity.rgb);
	m.Opacity = baseOpacity.a;

	uv = (uv - bbmod_BaseOpacityUV.xy) / (bbmod_BaseOpacityUV.zw - bbmod_BaseOpacityUV.xy);

	// Normal vector and smoothness
	vec4 normalSmoothness = texture2D(texNormalSmoothness,
		mix(bbmod_NormalSmoothnessUV.xy, bbmod_NormalSmoothnessUV.zw, uv));
	m.Normal = normalize(TBN * (normalSmoothness.rgb * 2.0 - 1.0));
	m.Smoothness = normalSmoothness.a;

	// Specular color
	vec4 specularColor = texture2D(texSpecularColor,
		mix(bbmod_SpecularColorUV.xy, bbmod_SpecularColorUV.zw, uv));
	m.Specular = xGammaToLinear(specularColor.rgb);
#else
	// Base color and opacity
	vec4 baseOpacity = texture2D(texBaseOpacity, uv);
	m.Base = xGammaToLinear(baseOpacity.rgb);
	m.Opacity = baseOpacity.a;

	// Normal vector and smoothness
	vec4 normalSmoothness = texture2D(texNormalSmoothness, uv);
	m.Normal = normalize(TBN * (normalSmoothness.rgb * 2.0 - 1.0));
	m.Smoothness = normalSmoothness.a;

	// Specular color
	vec4 specularColor = texture2D(texSpecularColor, uv);
	m.Specular = xGammaToLinear(specularColor.rgb);
#endif

	// Roughness
	m.Roughness = 1.0 - m.Smoothness;

	// Specular power
	m.SpecularPower = exp2(1.0 + (m.Smoothness * 10.0));

	return m;
}
