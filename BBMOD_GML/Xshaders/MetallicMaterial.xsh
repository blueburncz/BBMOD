#pragma include("Material.xsh")
#pragma include("BRDFConstants.xsh")
#pragma include("Color.xsh")
#pragma include("RGBM.xsh")

/// @desc Unpacks material from textures.
/// @param texBaseOpacity     RGB: base color, A: opacity
/// @param texNormalRoughness RGB: tangent-space normal vector, A: roughness
/// @param texMetallicAO      R: metallic, G: ambient occlusion
/// @param texSubsurface      RGB: subsurface color, A: intensity
/// @param texEmissive        RGBA: RGBM encoded emissive color
/// @param TBN                Tangent-bitangent-normal matrix
/// @param uv                 Texture coordinates
Material UnpackMaterial(
	sampler2D texBaseOpacity,
	sampler2D texNormalRoughness,
	sampler2D texMetallicAO,
	sampler2D texSubsurface,
	sampler2D texEmissive,
	mat3 TBN,
	vec2 uv)
{
	Material m;

	// Base color and opacity
	vec4 baseOpacity = texture2D(texBaseOpacity, uv);
	m.Base = xGammaToLinear(baseOpacity.rgb);
	m.Opacity = baseOpacity.a;

	// Normal vector and roughness
	vec4 normalRoughness = texture2D(texNormalRoughness, uv);
	m.Normal = normalize(TBN * (normalRoughness.rgb * 2.0 - 1.0));
	m.Roughness = mix(0.1, 0.9, normalRoughness.a);

	// Metallic and ambient occlusion
	vec4 metallicAO = texture2D(texMetallicAO, uv);
	m.Metallic = metallicAO.r;
	m.AO = metallicAO.g;

	// Specular color
	m.Specular = mix(F0_DEFAULT, m.Base, m.Metallic);
	m.Base *= (1.0 - m.Metallic);

	// Subsurface (color and intensity)
	vec4 subsurface = texture2D(texSubsurface, uv);
	m.Subsurface = vec4(xGammaToLinear(subsurface.rgb).rgb, subsurface.a);

	// Emissive color
	m.Emissive = xGammaToLinear(xDecodeRGBM(texture2D(texEmissive, uv)));

	return m;
}
