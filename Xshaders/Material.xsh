#pragma include("Color.xsh", "glsl")

struct Material
{
	vec3 Base;
	float Opacity;
	vec3 Normal;
	float Roughness;
	float Metallic;
	float AO;
	vec4 Subsurface;
	vec3 Emissive;
	vec3 Specular;
};

Material UnpackMaterial(
	sampler2D texBaseOpacity,
	sampler2D texNormalRoughness,
	sampler2D texMetallicAO,
	sampler2D texSubsurface,
	sampler2D texEmissive,
	mat3 tbn,
	vec2 uv)
{
	vec4 baseOpacity = texture2D(texBaseOpacity, uv);
	vec3 base = xGammaToLinear(baseOpacity.rgb);
	float opacity = baseOpacity.a;

	vec4 normalRoughness = texture2D(texNormalRoughness, uv);
	vec3 normal = normalize(tbn * (normalRoughness.rgb * 2.0 - 1.0));
	float roughness = normalRoughness.a;

	vec4 metallicAO = texture2D(texMetallicAO, uv);
	float metallic = metallicAO.r;
	float AO = metallicAO.g;

	vec4 subsurface = texture2D(texSubsurface, uv);
	subsurface.rgb = xGammaToLinear(subsurface.rgb);

	vec3 emissive = xGammaToLinear(xDecodeRGBM(texture2D(texEmissive, uv)));

	vec3 specular = mix(X_F0_DEFAULT, base, metallic);
	base *= (1.0 - metallic);

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
}
