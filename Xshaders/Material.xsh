#pragma include("BRDF.xsh")
#pragma include("Color.xsh")
#pragma include("RGBM.xsh")

struct Material
{
	Vec3 Base;
	float Opacity;
	Vec3 Normal;
	float Roughness;
	float Metallic;
	float AO;
	Vec4 Subsurface;
	Vec3 Emissive;
	Vec3 Specular;
};

Material UnpackMaterial(
	Texture2D texBaseOpacity,
	Texture2D texNormalRoughness,
	Texture2D texMetallicAO,
	Texture2D texSubsurface,
	Texture2D texEmissive,
	Mat3 tbn,
	Vec2 uv)
{
	Vec4 baseOpacity = Sample(texBaseOpacity, uv);
	Vec3 base = xGammaToLinear(baseOpacity.rgb);
	float opacity = baseOpacity.a;

	Vec4 normalRoughness = Sample(texNormalRoughness, uv);
#if XGLSL
	vec3 normal = normalize(tbn * (normalRoughness.rgb * 2.0 - 1.0));
#else
	float3 normal = mul(normalRoughness.rgb * 2.0 - 1.0, tbn);
#endif
	float roughness = Lerp(0.1, 0.9, normalRoughness.a);

	Vec4 metallicAO = Sample(texMetallicAO, uv);
	float metallic = metallicAO.r;
	float AO = metallicAO.g;

	Vec4 subsurface = Sample(texSubsurface, uv);
	subsurface.rgb = xGammaToLinear(subsurface.rgb);

	Vec3 emissive = xGammaToLinear(xDecodeRGBM(Sample(texEmissive, uv)));

	Vec3 specular = Lerp(X_F0_DEFAULT, base, metallic);
	base *= (1.0 - metallic);

#if XGLSL
	return Material(
		base,
		opacity,
		normal,
		roughness,
		metallic,
		AO,
		subsurface,
		emissive,
		specular);
#else
	Material material;
	material.Base = base;
	material.Opacity = opacity;
	material.Normal = normal;
	material.Roughness = roughness;
	material.Metallic = metallic;
	material.AO = AO;
	material.Subsurface = subsurface;
	material.Emissive = emissive;
	material.Specular = specular;
	return material;
#endif
}
