// @define BBMOD_PBR
// @define BBMOD_SUBSURFACE
// @include BBMOD_UberPS

// FIXME: Temporary fix!
precision highp float;

// Maximum number of punctual (point and spot) lights.
#define BBMOD_MAX_PUNCTUAL_LIGHTS 8
// Number of samples used when computing shadows.
#define SHADOWMAP_SAMPLE_COUNT 12

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

////////////////////////////////////////////////////////////////////////////////
// Material

// RGB: Base color, A: Opacity.
#define bbmod_BaseOpacity gm_BaseTexture

// RGBA multiplier applied to base color and opacity.
uniform vec4 bbmod_BaseOpacityMultiplier;
// 1.0 if the material uses roughness workflow.
uniform float bbmod_IsRoughness;
// RGB: Tangent-space normal, A: Smoothness or roughness.
uniform sampler2D bbmod_NormalW;
// 1.0 if the material uses metallic workflow.
uniform float bbmod_IsMetallic;
// Metallic: R=metallic, G=AO. Specular: RGB=specular color.
uniform sampler2D bbmod_Material;

// RGB: Subsurface color, A: Intensity.
uniform sampler2D bbmod_Subsurface;

// 1.0 to flip the normal before shading backfaces.
uniform float bbmod_TwoSided;

// Pixels with alpha below this value are discarded.
uniform float bbmod_AlphaTest;

////////////////////////////////////////////////////////////////////////////////
// Camera

// Camera position in world space.
uniform vec3 bbmod_CamPos;

// Distance to the far clipping plane.
uniform float bbmod_ZFar;
// Camera exposure value.
uniform float bbmod_Exposure;

////////////////////////////////////////////////////////////////////////////////
// Fog

// The color of the fog.
uniform vec4 bbmod_FogColor;
// Maximum fog intensity.
uniform float bbmod_FogIntensity;
// Distance at which the fog starts.
uniform float bbmod_FogStart;
// 1.0 / (fogEnd - fogStart).
uniform float bbmod_FogRcpRange;

////////////////////////////////////////////////////////////////////////////////
// Ambient light

// Ambient light up direction.
uniform vec3 bbmod_LightAmbientDirUp;
// Ambient light color on the upper hemisphere.
uniform vec4 bbmod_LightAmbientUp;
// Ambient light color on the lower hemisphere.
uniform vec4 bbmod_LightAmbientDown;

////////////////////////////////////////////////////////////////////////////////
// Directional light

// Direction of the directional light.
uniform vec3 bbmod_LightDirectionalDir;
// Color of the directional light.
uniform vec4 bbmod_LightDirectionalColor;

////////////////////////////////////////////////////////////////////////////////
// SSAO

// SSAO texture.
uniform sampler2D bbmod_SSAO;

////////////////////////////////////////////////////////////////////////////////
// Image based lighting

// 1.0 to enable IBL.
uniform float bbmod_IBLEnable;
// Prefiltered octahedron env. map.
uniform sampler2D bbmod_IBL;
// Texel size of one octahedron face.
uniform vec2 bbmod_IBLTexel;

////////////////////////////////////////////////////////////////////////////////
// Shadow mapping

// 1.0 to enable shadows.
uniform float bbmod_ShadowmapEnablePS;
// Shadowmap texture.
uniform sampler2D bbmod_Shadowmap;
// (1.0/shadowmapWidth, 1.0/shadowmapHeight).
uniform vec2 bbmod_ShadowmapTexel;
// The area that the shadowmap captures.
uniform float bbmod_ShadowmapArea;
// The range over which meshes smoothly transition into shadow.
uniform float bbmod_ShadowmapBias;
// Index of the light that casts shadows. Use -1 for directional light.
uniform float bbmod_ShadowCasterIndex;
// Offsets vertex position by its normal scaled by this value.
uniform float bbmod_ShadowmapNormalOffsetPS;

////////////////////////////////////////////////////////////////////////////////
// HDR rendering

// 0.0 = apply exposure, tonemap and gamma correct; 1.0 = output raw values.
uniform float bbmod_HDR;

////////////////////////////////////////////////////////////////////////////////
// Distance dithering

// 0.0 = disabled, > 0.0 = enabled.
uniform float bbmod_DitherEnable;
// (fadeInStart, fadeInEnd, fadeOutStart, fadeOutEnd).
uniform vec4 bbmod_DitherDistance;

varying vec3 v_vVertex;

varying vec2 v_vTexCoord;

varying mat3 v_mTBN;
varying vec4 v_vPosition;
varying float v_fDitherSeed;
varying float v_fDitherFadeMultiplier;

varying vec4 v_vPosShadowmap;

varying vec4 v_vEye;
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

	vec4 Subsurface;

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

	m.Subsurface = vec4(0.0);

	m.Lightmap = vec3(0.0);
	return m;
}
/// @macro {vec3} Default Fresnel reflectance at normal incidence for
/// dielectric (non-metallic) materials.
#define BBMOD_F0_DEFAULT vec3(0.04)
/// @desc Converts gamma space color to linear space.
/// @param rgb Color in gamma space.
/// @return Color in linear space.
vec3 BBMOD_GammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(2.2));
}
/// @desc Decodes RGBM encoded HDR color.
/// @param rgbm RGBM encoded color (RGB in rgb channels, multiplier in alpha).
/// @return Decoded HDR color.
/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
vec3 BBMOD_DecodeRGBM(vec4 rgbm)
{
	return 6.0 * rgbm.rgb * rgbm.a;
}

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
/// @param texBaseOpacity RGB: base color, A: opacity.
/// @param isRoughness 1.0 if normal alpha is roughness, 0.0 for smoothness.
/// @param texNormalW RGB: tangent-space normal, A: roughness or smoothness.
/// @param isMetallic 1.0 for metallic workflow, 0.0 for specular workflow.
/// @param texMaterial Metallic: R=metallic, G=AO. Specular: RGB=specular.
/// @param texSubsurface RGB: subsurface color, A: intensity.
/// @param TBN Tangent-bitangent-normal matrix.
/// @param uv Texture coordinates.
/// @return Unpacked material.
BBMOD_Material BBMOD_UnpackMaterial(
	sampler2D texBaseOpacity,
	float isRoughness,
	sampler2D texNormalW,
	float isMetallic,
	sampler2D texMaterial,
	sampler2D texSubsurface,
	mat3 TBN,
	vec2 uv)
{
	BBMOD_Material m = BBMOD_CreateMaterial();

	vec4 baseOpacity = texture2D(texBaseOpacity, uv);
	m.Base = BBMOD_GammaToLinear(baseOpacity.rgb);
	m.Opacity = baseOpacity.a;

	vec4 normalW = texture2D(texNormalW,
		uv
		);

	if (bbmod_TwoSided == 1.0 && !gl_FrontFacing)
	{
		TBN[2] *= -1.0;
	}

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

	vec4 materialProps = texture2D(texMaterial,
		uv
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

	vec4 subsurface = texture2D(texSubsurface,
		uv
		);
	m.Subsurface = vec4(BBMOD_GammaToLinear(subsurface.rgb), subsurface.a);

	return m;
}
/// @desc Punctual light position/range/color data.
/// Layout: [(x,y,z,range), (r,g,b,intensity), ...]
uniform vec4 bbmod_LightPunctualDataA[(BBMOD_MAX_PUNCTUAL_LIGHTS + BBMOD_MAX_PUNCTUAL_LIGHTS)];

/// @desc Punctual light spot-cone and direction data.
/// Layout: [(isSpot,dcosInner,dcosOuter), (dX,dY,dZ), ...]
uniform vec3 bbmod_LightPunctualDataB[(BBMOD_MAX_PUNCTUAL_LIGHTS + BBMOD_MAX_PUNCTUAL_LIGHTS)];

/// @desc Gets an entry from the punctual light position/range/color array.
/// @param index Array index.
/// @return vec4 data entry at that index.
vec4 BBMOD_GetPunctualLightDataA(int index)
{
#if defined(_YY_GLSL_) || defined(_YY_HLSL11_) || defined(_YY_PSSL_)
	return bbmod_LightPunctualDataA[index];
#else
	if (index == 0)       return bbmod_LightPunctualDataA[0];
	else if (index == 1)  return bbmod_LightPunctualDataA[1];
	else if (index == 2)  return bbmod_LightPunctualDataA[2];
	else if (index == 3)  return bbmod_LightPunctualDataA[3];
	else if (index == 4)  return bbmod_LightPunctualDataA[4];
	else if (index == 5)  return bbmod_LightPunctualDataA[5];
	else if (index == 6)  return bbmod_LightPunctualDataA[6];
	else if (index == 7)  return bbmod_LightPunctualDataA[7];
	else if (index == 8)  return bbmod_LightPunctualDataA[8];
	else if (index == 9)  return bbmod_LightPunctualDataA[9];
	else if (index == 10) return bbmod_LightPunctualDataA[10];
	else if (index == 11) return bbmod_LightPunctualDataA[11];
	else if (index == 12) return bbmod_LightPunctualDataA[12];
	else if (index == 13) return bbmod_LightPunctualDataA[13];
	else if (index == 14) return bbmod_LightPunctualDataA[14];
	else if (index == 15) return bbmod_LightPunctualDataA[15];
	else                  return vec4(0.0);
#endif
}

/// @desc Gets an entry from the punctual light spot-cone/direction array.
/// @param index Array index.
/// @return vec3 data entry at that index.
vec3 BBMOD_GetPunctualLightDataB(int index)
{
#if defined(_YY_GLSL_) || defined(_YY_HLSL11_) || defined(_YY_PSSL_)
	return bbmod_LightPunctualDataB[index];
#else
	if (index == 0)       return bbmod_LightPunctualDataB[0];
	else if (index == 1)  return bbmod_LightPunctualDataB[1];
	else if (index == 2)  return bbmod_LightPunctualDataB[2];
	else if (index == 3)  return bbmod_LightPunctualDataB[3];
	else if (index == 4)  return bbmod_LightPunctualDataB[4];
	else if (index == 5)  return bbmod_LightPunctualDataB[5];
	else if (index == 6)  return bbmod_LightPunctualDataB[6];
	else if (index == 7)  return bbmod_LightPunctualDataB[7];
	else if (index == 8)  return bbmod_LightPunctualDataB[8];
	else if (index == 9)  return bbmod_LightPunctualDataB[9];
	else if (index == 10) return bbmod_LightPunctualDataB[10];
	else if (index == 11) return bbmod_LightPunctualDataB[11];
	else if (index == 12) return bbmod_LightPunctualDataB[12];
	else if (index == 13) return bbmod_LightPunctualDataB[13];
	else if (index == 14) return bbmod_LightPunctualDataB[14];
	else if (index == 15) return bbmod_LightPunctualDataB[15];
	else                  return vec3(0.0);
#endif
}
/// @desc Computes a cheap subsurface scattering approximation.
/// @param subsurface Subsurface color (rgb) and thickness/intensity (a).
/// @param eye View direction (normalized, pointing from vertex toward camera).
/// @param normal Surface normal (normalized).
/// @param light Light direction (normalized, pointing toward light source).
/// @param lightColor Light color and intensity.
/// @return Subsurface scattering contribution.
/// @source https://colinbarrebrisebois.com/2011/03/07/gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurface-scattering-look/
vec3 BBMOD_CheapSubsurface(
	vec4 subsurface, vec3 eye, vec3 normal, vec3 light, vec3 lightColor)
{
	const float fLTPower = 1.0;
	const float fLTScale = 1.0;
	vec3 vLTLight = light + normal;
	float fLTDot = pow(clamp(dot(eye, -vLTLight), 0.0, 1.0), fLTPower) * fLTScale;
	float fLT = fLTDot * subsurface.a;
	return subsurface.rgb * lightColor * fLT;
}
/// @desc GGX normal distribution function.
/// @param roughness Material roughness.
/// @param NdotH Dot product of the surface normal and half vector.
/// @return NDF value.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float BBMOD_SpecularD_GGX(float roughness, float NdotH)
{
	float r = roughness * roughness * roughness * roughness;
	float a = NdotH * NdotH * (r - 1.0) + 1.0;
	return r / (3.14159265359 * a * a);
}
/// @desc Schlick Fresnel approximation.
/// @param f0 Reflectance at normal incidence (specular color).
/// @param VdotH Dot product of the view direction and half vector.
/// @return Fresnel factor.
/// @source https://en.wikipedia.org/wiki/Schlick%27s_approximation
vec3 BBMOD_SpecularF_Schlick(vec3 f0, float VdotH)
{
	float x = 1.0 - VdotH;
	return f0 + (1.0 - f0) * (x * x * x * x * x);
}
/// @desc Schlick-GGX geometric attenuation (Smith approximation).
/// @param k Remapped roughness (use BBMOD_K_Analytic or BBMOD_K_IBL).
/// @param NdotL Dot product of the surface normal and light direction.
/// @param NdotV Dot product of the surface normal and view direction.
/// @return Geometric attenuation factor.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float BBMOD_SpecularG_Schlick(float k, float NdotL, float NdotV)
{
	return (NdotL / (NdotL * (1.0 - k) + k))
		* (NdotV / (NdotV * (1.0 - k) + k));
}
/// @desc Roughness remapping for analytic (direct) lights, used in
/// Schlick-GGX geometric attenuation.
/// @param roughness Material roughness.
/// @return Remapped k value.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float BBMOD_K_Analytic(float roughness)
{
	float r1 = roughness + 1.0;
	return (r1 * r1) * 0.125;
}

/// @desc Cook-Torrance microfacet specular BRDF.
/// @param f0 Fresnel reflectance at normal incidence (specular color).
/// @param roughness Material roughness.
/// @param NdotL Dot product of the surface normal and light direction.
/// @param NdotV Dot product of the surface normal and view direction.
/// @param NdotH Dot product of the surface normal and half vector.
/// @param VdotH Dot product of the view direction and half vector.
/// @return Specular BRDF value.
/// @note N = normalize(vertexNormal), L = normalize(light - vertex),
///       V = normalize(camera - vertex), H = normalize(L + V).
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 BBMOD_BRDF(
	vec3 f0, float roughness,
	float NdotL, float NdotV, float NdotH, float VdotH)
{
	vec3 specular = BBMOD_SpecularD_GGX(roughness, NdotH)
		* BBMOD_SpecularF_Schlick(f0, VdotH)
		* BBMOD_SpecularG_Schlick(BBMOD_K_Analytic(roughness), NdotL, NdotV);
	return specular / ((4.0 * NdotL * NdotV) + 0.1);
}

/// @desc Evaluates Cook-Torrance GGX specular for a light direction.
/// @param m Material properties.
/// @param N Surface normal (normalized).
/// @param V View direction (normalized, pointing toward camera).
/// @param L Light direction (normalized, pointing toward light).
/// @return Specular BRDF value.
vec3 BBMOD_SpecularGGX(BBMOD_Material m, vec3 N, vec3 V, vec3 L)
{
	vec3 H = normalize(L + V);
	float NdotL = max(dot(N, L), 0.0);
	float NdotV = max(dot(N, V), 0.0);
	float NdotH = max(dot(N, H), 0.0);
	float VdotH = max(dot(V, H), 0.0);
	return BBMOD_BRDF(m.Specular, m.Roughness, NdotL, NdotV, NdotH, VdotH);
}
/// @desc Evaluates Blinn-Phong specular for a light direction.
/// @param m Material properties.
/// @param N Surface normal (normalized).
/// @param V View direction (normalized, pointing toward camera).
/// @param L Light direction (normalized, pointing toward light).
/// @return Specular value.
vec3 BBMOD_SpecularBlinnPhong(BBMOD_Material m, vec3 N, vec3 V, vec3 L)
{
	vec3 H = normalize(L + V);
	float NdotH = max(dot(N, H), 0.0);
	float VdotH = max(dot(V, H), 0.0);
	vec3 fresnel = m.Specular + (1.0 - m.Specular) * pow(1.0 - VdotH, 5.0);
	float visibility = 0.25;
	float A = m.SpecularPower / log(2.0);
	float blinnPhong = exp2(A * NdotH - A);
	float blinnNormalization = (m.SpecularPower + 8.0) / 8.0;
	float normalDistribution = blinnPhong * blinnNormalization;
	return fresnel * visibility * normalDistribution;
}

/// @desc Accumulates directional light contribution to diffuse, specular, and
/// subsurface outputs.
/// @param direction World-space light direction (pointing away from light).
/// @param color Light color (linear, pre-multiplied by intensity).
/// @param shadow Shadow factor in [0, 1]; 1 = fully in shadow.
/// @param vertex World-space vertex position.
/// @param N Surface normal (normalized).
/// @param V View direction (normalized, pointing toward camera).
/// @param m Material properties.
/// @param diffuse Accumulated diffuse light (inout).
/// @param specular Accumulated specular light (inout).
/// @param subsurface Accumulated subsurface light (inout).
void BBMOD_DoDirectionalLightPS(
	vec3 direction,
	vec3 color,
	float shadow,
	vec3 vertex,
	vec3 N,
	vec3 V,
	BBMOD_Material m,
	inout vec3 diffuse,
	inout vec3 specular
	,
	inout vec3 subsurface
	)
{
	vec3 L = normalize(-direction);
	float NdotL = max(dot(N, L), 0.0);
	subsurface += BBMOD_CheapSubsurface(m.Subsurface, V, N, L, color);
	color *= (1.0 - shadow) * NdotL;
	diffuse += color;
	specular += color * BBMOD_SpecularGGX(m, N, V, L);
}
/// @desc Accumulates point light contribution to diffuse, specular, and
/// subsurface outputs.
/// @param position World-space light position.
/// @param range Light attenuation range.
/// @param color Light color (linear, pre-multiplied by intensity).
/// @param shadow Shadow factor in [0, 1]; 1 = fully in shadow.
/// @param vertex World-space vertex position.
/// @param N Surface normal (normalized).
/// @param V View direction (normalized, pointing toward camera).
/// @param m Material properties.
/// @param diffuse Accumulated diffuse light (inout).
/// @param specular Accumulated specular light (inout).
/// @param subsurface Accumulated subsurface light (inout).
void BBMOD_DoPointLightPS(
	vec3 position,
	float range,
	vec3 color,
	float shadow,
	vec3 vertex,
	vec3 N,
	vec3 V,
	BBMOD_Material m,
	inout vec3 diffuse,
	inout vec3 specular
	,
	inout vec3 subsurface
	)
{
	vec3 L = position - vertex;
	float dist = length(L);
	L = normalize(L);
	float att = clamp(1.0 - (dist / range), 0.0, 1.0);
	att *= att;
	float NdotL = max(dot(N, L), 0.0);
	subsurface += BBMOD_CheapSubsurface(m.Subsurface, V, N, L, color);
	color *= (1.0 - shadow) * NdotL * att;
	diffuse += color;
	specular += color * BBMOD_SpecularGGX(m, N, V, L);
}
/// @desc Accumulates spot light contribution to diffuse, specular, and
/// subsurface outputs.
/// @param position World-space light position.
/// @param range Light attenuation range.
/// @param color Light color (linear, pre-multiplied by intensity).
/// @param shadow Shadow factor in [0, 1]; 1 = fully in shadow.
/// @param direction World-space spot light direction (normalized).
/// @param dcosInner Cosine of the inner cone half-angle.
/// @param dcosOuter Cosine of the outer cone half-angle.
/// @param vertex World-space vertex position.
/// @param N Surface normal (normalized).
/// @param V View direction (normalized, pointing toward camera).
/// @param m Material properties.
/// @param diffuse Accumulated diffuse light (inout).
/// @param specular Accumulated specular light (inout).
/// @param subsurface Accumulated subsurface light (inout).
void BBMOD_DoSpotLightPS(
	vec3 position,
	float range,
	vec3 color,
	float shadow,
	vec3 direction,
	float dcosInner,
	float dcosOuter,
	vec3 vertex,
	vec3 N,
	vec3 V,
	BBMOD_Material m,
	inout vec3 diffuse,
	inout vec3 specular
	,
	inout vec3 subsurface
	)
{
	vec3 L = position - vertex;
	float dist = length(L);
	L = normalize(L);
	float att = clamp(1.0 - (dist / range), 0.0, 1.0);
	float theta = dot(L, normalize(-direction));
	float epsilon = dcosInner - dcosOuter;
	float intensity = clamp((theta - dcosOuter) / epsilon, 0.0, 1.0);
	subsurface += BBMOD_CheapSubsurface(m.Subsurface, V, N, L, color);
	color *= (1.0 - shadow) * intensity * att * max(dot(N, L), 0.0);
	diffuse += color;
	specular += color * BBMOD_SpecularGGX(m, N, V, L);
}
/// @desc Applies camera exposure to a color.
/// @param color The input color.
/// @return Color with exposure applied.
/// @note Requires uniform: bbmod_Exposure.
vec3 BBMOD_Exposure(vec3 color)
{
	return color * bbmod_Exposure * bbmod_Exposure;
}
/// @desc Applies Reinhard tonemapping to a color.
/// @param color The input color in HDR.
/// @return Tonemapped color in LDR.
vec3 BBMOD_TonemapReinhard(vec3 color)
{
	return color / (vec3(1.0) + color);
}
/// @desc Applies fog effect to a color based on depth.
/// @param color The input color to apply fog to.
/// @param depth The depth value (typically from v_vPosition.z).
/// @return Color with fog applied.
/// @note Requires uniforms: bbmod_FogColor, bbmod_FogIntensity, bbmod_FogStart, bbmod_FogRcpRange,
///       bbmod_LightAmbientUp, bbmod_LightAmbientDown, bbmod_LightDirectionalColor.
vec3 BBMOD_Fog(vec3 color, float depth)
{
	vec3 ambientUp = BBMOD_GammaToLinear(bbmod_LightAmbientUp.rgb) * bbmod_LightAmbientUp.a;
	vec3 ambientDown = BBMOD_GammaToLinear(bbmod_LightAmbientDown.rgb) * bbmod_LightAmbientDown.a;
	vec3 directionalLightColor = BBMOD_GammaToLinear(bbmod_LightDirectionalColor.rgb) * bbmod_LightDirectionalColor.a;
	vec3 fogColor = BBMOD_GammaToLinear(bbmod_FogColor.rgb) * (ambientUp + ambientDown + directionalLightColor);
	float fogStrength = clamp((depth - bbmod_FogStart) * bbmod_FogRcpRange, 0.0, 1.0) * bbmod_FogColor.a;
	return mix(color, fogColor, fogStrength * bbmod_FogIntensity);
}
/// @desc Converts linear space color to gamma space.
/// @param rgb Color in linear space.
/// @return Color in gamma space.
vec3 BBMOD_LinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / 2.2));
}

/// @desc Converts a linear-space color to gamma space (gamma correction).
/// @param color Input color in linear space.
/// @return Color in gamma space.
vec3 BBMOD_GammaCorrect(vec3 color)
{
	return BBMOD_LinearToGamma(color);
}
/// @desc Converts a world-space direction vector to UV coordinates on an
/// octahedron map.
/// @param dir Sampling direction vector in world-space.
/// @return UV coordinates on the octahedron map.
/// @source https://gamedev.stackexchange.com/questions/169508/octahedral-impostors-octahedral-mapping
vec2 BBMOD_Vec3ToOctahedronUV(vec3 dir)
{
	vec3 octant = sign(dir);
	float sum = dot(dir, octant);
	vec3 octahedron = dir / sum;
	if (octahedron.z < 0.0)
	{
		vec3 absolute = abs(octahedron);
		octahedron.xy = octant.xy * vec2(1.0 - absolute.y, 1.0 - absolute.x);
	}
	return octahedron.xy * 0.5 + 0.5;
}

/// @desc Samples the diffuse (irradiance) contribution from a prefiltered
/// octahedral IBL map.
/// @param ibl Prefiltered IBL texture (8 octahedral levels stacked horizontally;
///            level 0 = diffuse irradiance, levels 1-7 = specular roughness).
/// @param texel Texel size of one octahedron face (vec2(1.0/(8*w), 1.0/h)).
/// @param N Surface normal.
/// @return Diffuse IBL radiance in linear space.
vec3 BBMOD_DiffuseIBL(sampler2D ibl, vec2 texel, vec3 N)
{
	const float s = 1.0 / 8.0;
	const float r2 = 7.0;
	vec2 uv0 = BBMOD_Vec3ToOctahedronUV(N);
	uv0.x = (r2 + mix(texel.x, 1.0 - texel.x, uv0.x)) * s;
	uv0.y = mix(texel.y, 1.0 - texel.y, uv0.y);
	return BBMOD_GammaToLinear(BBMOD_DecodeRGBM(texture2D(ibl, uv0)));
}
/// @desc Approximates the environment BRDF look-up for PBR specular lighting.
/// @param roughness Material roughness.
/// @param NdotV Dot product of the surface normal and view direction.
/// @return Approximated BRDF coefficients: x=scale, y=bias applied to f0.
/// @source https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
vec2 BBMOD_EnvBRDFApprox(float roughness, float NdotV)
{
	const vec4 c0 = vec4(-1.0, -0.0275, -0.572, 0.022);
	const vec4 c1 = vec4(1.0, 0.0425, 1.04, -0.04);
	vec4 r = (roughness * c0) + c1;
	float a004 = (min(r.x * r.x, exp2(-9.28 * NdotV)) * r.x) + r.y;
	return (vec2(-1.04, 1.04) * a004) + r.zw;
}

/// @desc Samples the specular contribution from a prefiltered octahedral IBL
/// map using the UE4 split-sum approximation.
/// @param ibl Prefiltered IBL texture (8 octahedral roughness levels stacked
///            horizontally; level 0 = lowest roughness).
/// @param texel Texel size of one octahedron face (vec2(1.0/(8*w), 1.0/h)).
/// @param f0 Fresnel reflectance at normal incidence (specular color).
/// @param roughness Material roughness.
/// @param N Surface normal.
/// @param V View direction (normalized, pointing toward camera).
/// @return Specular IBL radiance in linear space.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 BBMOD_SpecularIBL(
	sampler2D ibl, vec2 texel, vec3 f0, float roughness, vec3 N, vec3 V)
{
	float NdotV = clamp(dot(N, V), 0.0, 1.0);
	vec3 R = 2.0 * dot(V, N) * N - V;
	vec2 envBRDF = BBMOD_EnvBRDFApprox(roughness, NdotV);
	const float s = 1.0 / 8.0;
	float r = roughness * 7.0;
	float r2 = floor(r);
	float rDiff = r - r2;
	vec2 uv0 = BBMOD_Vec3ToOctahedronUV(R);
	uv0.x = (r2 + mix(texel.x, 1.0 - texel.x, uv0.x)) * s;
	uv0.y = mix(texel.y, 1.0 - texel.y, uv0.y);
	vec2 uv1 = uv0;
	uv1.x += s;
	vec3 specular = f0 * envBRDF.x + envBRDF.y;
	vec3 col0 = BBMOD_GammaToLinear(BBMOD_DecodeRGBM(texture2D(ibl, uv0))) * specular;
	vec3 col1 = BBMOD_GammaToLinear(BBMOD_DecodeRGBM(texture2D(ibl, uv1))) * specular;
	return mix(col0, col1, rDiff);
}
/// @desc Decodes a linearized depth value from RGB channels.
/// @param c Encoded depth as RGB.
/// @return Decoded linearized depth (0..1 range).
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float BBMOD_DecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}
/// @desc Computes interleaved gradient noise for shadow map filtering.
/// @param positionScreen Screen-space position (e.g. gl_FragCoord.xy).
/// @return Noise value in [0, 1).
/// @source https://www.gamedev.net/tutorials/programming/graphics/contact-hardening-soft-shadows-made-fast-r4906/
float BBMOD_InterleavedGradientNoise(vec2 positionScreen)
{
	vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
	return fract(magic.z * fract(dot(positionScreen, magic.xy)));
}
/// @desc Computes a sample point on a Vogel disk for shadow filtering.
/// @param sampleIndex Index of the current sample.
/// @param samplesCount Total number of samples.
/// @param phi Rotation angle offset (noise).
/// @return 2D disk sample position.
vec2 BBMOD_VogelDiskSample(int sampleIndex, int samplesCount, float phi)
{
	const float GoldenAngle = 2.4;
	float r = sqrt(float(sampleIndex) + 0.5) / sqrt(float(samplesCount));
	float theta = float(sampleIndex) * GoldenAngle + phi;
	return vec2(r * cos(theta), r * sin(theta));
}

/// @desc Samples a shadow map and returns the shadow factor.
/// Requires uniform: bbmod_ShadowmapBias, bbmod_ShadowmapArea.
/// Requires define: SHADOWMAP_SAMPLE_COUNT (e.g. 12).
/// @param shadowMap Shadow map texture.
/// @param texel Shadow map texel size (vec2(1/w, 1/h)).
/// @param uv Shadow map UV coordinates.
/// @param compareZ Normalized depth to compare against (0..1).
/// @return Shadow factor in [0, 1]; 1 = fully in shadow.
float BBMOD_ShadowMap(sampler2D shadowMap, vec2 texel, vec2 uv, float compareZ)
{
	if (clamp(uv.xy, vec2(0.0), vec2(1.0)) != uv.xy)
	{
		return 0.0;
	}
	float shadow = 0.0;
	float noise = 6.28318530718
		* BBMOD_InterleavedGradientNoise(gl_FragCoord.xy);
	float bias = bbmod_ShadowmapBias / bbmod_ShadowmapArea;
	for (int i = 0; i < SHADOWMAP_SAMPLE_COUNT; ++i)
	{
		vec2 uv2 = uv
			+ BBMOD_VogelDiskSample(i, SHADOWMAP_SAMPLE_COUNT, noise)
			* texel * 4.0;
		float depth = BBMOD_DecodeDepth(texture2D(shadowMap, uv2).rgb);
		if (bias != 0.0)
		{
			shadow += clamp((compareZ - depth) / bias, 0.0, 1.0);
		}
		else
		{
			shadow += step(depth, compareZ);
		}
	}
	return (shadow / float(SHADOWMAP_SAMPLE_COUNT));
}
/// @desc Gets screen-space UV coordinates for a clip-space point.
/// @param p A point in clip space (transformed by projection matrix, not
///          normalized).
/// @return UV coordinates on the screen.
vec2 BBMOD_Unproject(vec4 p)
{
	vec2 uv = p.xy / p.w;
	uv = uv * 0.5 + 0.5;
#if defined(_YY_HLSL11_) || defined(_YY_PSSL_)
	uv.y = 1.0 - uv.y;
#endif
	return uv;
}

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
	vec3 V = (v_vEye.w == 1.0)
		? v_vEye.xyz
		: normalize(bbmod_CamPos - v_vVertex);
	vec3 lightDiffuse = vec3(0.0);
	vec3 lightSpecular = vec3(0.0);

	vec3 lightSubsurface = vec3(0.0);

	vec3 ambientUp = BBMOD_GammaToLinear(bbmod_LightAmbientUp.rgb)
		* bbmod_LightAmbientUp.a;
	vec3 ambientDown = BBMOD_GammaToLinear(bbmod_LightAmbientDown.rgb)
		* bbmod_LightAmbientDown.a;
	lightDiffuse += mix(ambientDown, ambientUp,
		dot(N, bbmod_LightAmbientDirUp) * 0.5 + 0.5);

	float shadow = 0.0;
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
		, lightSubsurface
		);

	float ssao = texture2D(bbmod_SSAO, BBMOD_Unproject(v_vPosition)).r;
	lightDiffuse *= ssao;
	lightSpecular *= ssao;

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
				, lightSubsurface
				);
		}
		else
		{
			BBMOD_DoPointLightPS(
				positionRange.xyz, positionRange.w, color,
				(bbmod_ShadowCasterIndex == float(i)) ? shadow : 0.0,
				v_vVertex, N, V, material,
				lightDiffuse, lightSpecular
				, lightSubsurface
				);
		}
	}

	gl_FragColor.rgb = material.Base * lightDiffuse;
	gl_FragColor.rgb += lightSpecular;
	gl_FragColor.rgb *= material.AO;

	gl_FragColor.rgb += lightSubsurface;

	gl_FragColor.a = material.Opacity;

	gl_FragColor.rgb = BBMOD_Fog(gl_FragColor.rgb, depth);

	if (bbmod_HDR == 0.0)
	{
		gl_FragColor.rgb = BBMOD_Exposure(gl_FragColor.rgb);
		gl_FragColor.rgb = BBMOD_TonemapReinhard(gl_FragColor.rgb);
		gl_FragColor.rgb = BBMOD_GammaCorrect(gl_FragColor.rgb);
	}
}
/// @desc Computes a per-fragment dither noise value for distance-based fading.
/// @param positionScreen Screen-space position (e.g. gl_FragCoord.xy).
/// @param seed Per-instance seed value to vary the pattern.
/// @return Noise threshold value in [0, 1).
float BBMOD_DistanceDitherNoise(vec2 positionScreen, float seed)
{
	vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
	return fract(magic.z * fract(
		dot(positionScreen + vec2(seed * 13.13, seed * 7.31), magic.xy)));
}

/// @desc Discards the fragment based on distance-dither fade settings.
/// Requires uniforms: bbmod_DitherEnable, bbmod_DitherDistance.
/// @param seed Per-instance seed value (used by BBMOD_DistanceDitherNoise).
/// @param fadeMultiplier Fade multiplier in [0, 1]; 0 = fully faded out.
void BBMOD_ApplyDistanceDither(float seed, float fadeMultiplier)
{
	if (bbmod_DitherEnable <= 0.0)
	{
		return;
	}
	float fade = clamp(fadeMultiplier, 0.0, 1.0);
	if (fade <= 0.0)
	{
		discard;
	}
	float threshold = BBMOD_DistanceDitherNoise(gl_FragCoord.xy, seed);
	if (threshold > fade)
	{
		discard;
	}
}

////////////////////////////////////////////////////////////////////////////////
//
// Main
//

void main()
{
	////////////////////////////////////////////////////////////////////////////
	// Non-terrain

	BBMOD_Material material = BBMOD_UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_IsRoughness,
		bbmod_NormalW,
		bbmod_IsMetallic,
		bbmod_Material,
		bbmod_Subsurface,

		v_mTBN,
		v_vTexCoord);

	material.Base    *= BBMOD_GammaToLinear(bbmod_BaseOpacityMultiplier.rgb);
	material.Opacity *= bbmod_BaseOpacityMultiplier.a;

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}

	BBMOD_ApplyDistanceDither(v_fDitherSeed, v_fDitherFadeMultiplier);

	BBMOD_PBRShader(material, v_vPosition.z);

}
// @endinclude
