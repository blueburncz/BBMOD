/// @desc PBR material properties.
struct BBMOD_Material
{
	vec3 Base;
	float Opacity;
	vec3 Normal;
	float Metallic;
	float Roughness;
	vec3 Specular;
	float Smoothness;
	float SpecularPower;
	float AO;

// @if defined(BBMOD_EMISSIVE)
	vec3 Emissive;
// @endif

// @if defined(BBMOD_SUBSURFACE)
	vec4 Subsurface;
// @endif

	vec3 Lightmap;
};

/// @desc Creates a default BBMOD_Material with sensible initial values.
/// @return Default material.
BBMOD_Material BBMOD_CreateMaterial()
{
	BBMOD_Material m;
	m.Base = vec3(1.0);
	m.Opacity = 1.0;
	m.Normal = vec3(0.0, 0.0, 1.0);
	m.Metallic = 0.0;
	m.Roughness = 1.0;
	m.Specular = vec3(0.0);
	m.Smoothness = 0.0;
	m.SpecularPower = 1.0;
	m.AO = 1.0;

// @if defined(BBMOD_EMISSIVE)
	m.Emissive = vec3(0.0);
// @endif

// @if defined(BBMOD_SUBSURFACE)
	m.Subsurface = vec4(0.0);
// @endif

	m.Lightmap = vec3(0.0);
	return m;
}
