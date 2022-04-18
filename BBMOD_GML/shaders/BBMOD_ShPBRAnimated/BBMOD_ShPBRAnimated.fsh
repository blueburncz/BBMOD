#pragma include("Uber_PS.xsh", "glsl")
// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Defines
//

// Maximum number of point lights
#define MAX_POINT_LIGHTS 8
// Number of samples used when computing shadows
#define SHADOWMAP_SAMPLE_COUNT 12

////////////////////////////////////////////////////////////////////////////////
//
// Varyings
//

varying vec3 v_vVertex;


varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;


////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

////////////////////////////////////////////////////////////////////////////////
// Material

// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture
// RGB: Tangent space normal, A: Roughness
uniform sampler2D bbmod_NormalRoughness;
// R: Metallic, G: Ambient occlusion
uniform sampler2D bbmod_MetallicAO;
// RGB: Subsurface color, A: Intensity
uniform sampler2D bbmod_Subsurface;
// RGBA: RGBM encoded emissive color
uniform sampler2D bbmod_Emissive;
// Pixels with alpha less than this value will be discarded
uniform float bbmod_AlphaTest;

////////////////////////////////////////////////////////////////////////////////
// Camera

// Camera's position in world space
uniform vec3 bbmod_CamPos;
// Distance to the far clipping plane
uniform float bbmod_ZFar;
// Camera's exposure value
uniform float bbmod_Exposure;

////////////////////////////////////////////////////////////////////////////////
// Image based lighting

// Prefiltered octahedron env. map
uniform sampler2D bbmod_IBL;
// Texel size of one octahedron
uniform vec2 bbmod_IBLTexel;


////////////////////////////////////////////////////////////////////////////////
//
// Includes
//

struct Material
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
	vec3 Emissive;
	vec4 Subsurface;
};

#define X_GAMMA 2.2

/// @desc Converts gamma space color to linear space.
vec3 xGammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(X_GAMMA));
}

/// @desc Converts linear space color to gamma space.
vec3 xLinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / X_GAMMA));
}

/// @desc Gets color's luminance.
float xLuminance(vec3 rgb)
{
	return (0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b);
}

/// @note Input color should be in gamma space.
/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
vec4 xEncodeRGBM(vec3 color)
{
	vec4 rgbm;
	color *= 1.0 / 6.0;
	rgbm.a = clamp(max(max(color.r, color.g), max(color.b, 0.000001)), 0.0, 1.0);
	rgbm.a = ceil(rgbm.a * 255.0) / 255.0;
	rgbm.rgb = color / rgbm.a;
	return rgbm;
}

/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
vec3 xDecodeRGBM(vec4 rgbm)
{
	return 6.0 * rgbm.rgb * rgbm.a;
}

/// @param d Linearized depth to encode.
/// @return Encoded depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
vec3 xEncodeDepth(float d)
{
	const float inv255 = 1.0 / 255.0;
	vec3 enc;
	enc.x = d;
	enc.y = d * 255.0;
	enc.z = enc.y * 255.0;
	enc = fract(enc);
	float temp = enc.z * inv255;
	enc.x -= enc.y * inv255;
	enc.y -= temp;
	enc.z -= temp;
	return enc;
}

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}



vec3 SpecularBlinnPhong(Material m, vec3 N, vec3 V, vec3 L)
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

void DoDirectionalLightPS(
	vec3 direction,
	vec3 color,
	vec3 vertex,
	vec3 N,
	vec3 V,
	Material m,
	inout vec3 diffuse,
	inout vec3 specular)
{
	vec3 L = normalize(-direction);
	float NdotL = max(dot(N, L), 0.0);
	color *= NdotL;
	diffuse += color;
	specular += color * SpecularBlinnPhong(m, N, V, L);
}

// Shadowmap filtering source: https://www.gamedev.net/tutorials/programming/graphics/contact-hardening-soft-shadows-made-fast-r4906/
float InterleavedGradientNoise(vec2 positionScreen)
{
	vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
	return fract(magic.z * fract(dot(positionScreen, magic.xy)));
}

vec2 VogelDiskSample(int sampleIndex, int samplesCount, float phi)
{
	float GoldenAngle = 2.4;
	float r = sqrt(float(sampleIndex) + 0.5) / sqrt(float(samplesCount));
	float theta = float(sampleIndex) * GoldenAngle + phi;
	float sine = sin(theta);
	float cosine = cos(theta);
	return vec2(r * cosine, r * sine);
}

float ShadowMap(sampler2D shadowMap, vec2 texel, vec2 uv, float compareZ)
{
	if (clamp(uv.xy, vec2(0.0), vec2(1.0)) != uv.xy)
	{
		return 0.0;
	}
	float shadow = 0.0;
	float noise = 6.28 * InterleavedGradientNoise(gl_FragCoord.xy);
	for (int i = 0; i < SHADOWMAP_SAMPLE_COUNT; ++i)
	{
		vec2 uv2 = uv + VogelDiskSample(i, SHADOWMAP_SAMPLE_COUNT, noise) * texel * 4.0;
		shadow += step(xDecodeDepth(texture2D(shadowMap, uv2).rgb), compareZ);
	}
	return (shadow / float(SHADOWMAP_SAMPLE_COUNT));
}



void DoPointLightPS(
	vec3 position,
	float range,
	vec3 color,
	vec3 vertex,
	vec3 N,
	vec3 V,
	Material m,
	inout vec3 diffuse,
	inout vec3 specular)
{
	vec3 L = position - vertex;
	float dist = length(L);
	L = normalize(L);
	float att = clamp(1.0 - (dist / range), 0.0, 1.0);
	float NdotL = max(dot(N, L), 0.0);
	color *= NdotL * att;
	diffuse += color;
	specular += color * SpecularBlinnPhong(m, N, V, L);
}

#define X_PI   3.14159265359
#define X_2_PI 6.28318530718

/// @return x^2
#define xPow2(x) ((x) * (x))

/// @return x^3
#define xPow3(x) ((x) * (x) * (x))

/// @return x^4
#define xPow4(x) ((x) * (x) * (x) * (x))

/// @return x^5
#define xPow5(x) ((x) * (x) * (x) * (x) * (x))

/// @return arctan2(x,y)
#define xAtan2(x, y) atan(y, x)

/// @return Direction from point `from` to point `to` in degrees (0-360 range).
float xPointDirection(vec2 from, vec2 to)
{
	float x = xAtan2(from.x - to.x, from.y - to.y);
	return ((x > 0.0) ? x : (2.0 * X_PI + x)) * 180.0 / X_PI;
}

/// @desc Default specular color for dielectrics
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
#define X_F0_DEFAULT vec3(0.04, 0.04, 0.04)

/// @desc Normal distribution function
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularD_GGX(float roughness, float NdotH)
{
	float r = xPow4(roughness);
	float a = NdotH * NdotH * (r - 1.0) + 1.0;
	return r / (X_PI * a * a);
}

/// @source https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
float xSpecularD_Approx(float roughness, float RdotL)
{
	float a = roughness * roughness;
	float a2 = a * a;
	float rcp_a2 = 1.0 / a2;
	// 0.5 / ln(2), 0.275 / ln(2)
	float c = (0.72134752 * rcp_a2) + 0.39674113;
	return (rcp_a2 * exp2((c * RdotL) - c));
}

/// @desc Roughness remapping for analytic lights.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xK_Analytic(float roughness)
{
	return xPow2(roughness + 1.0) * 0.125;
}

/// @desc Roughness remapping for IBL lights.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xK_IBL(float roughness)
{
	return xPow2(roughness) * 0.5;
}

/// @desc Geometric attenuation
/// @param k Use either xK_Analytic for analytic lights or xK_IBL for image based lighting.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularG_Schlick(float k, float NdotL, float NdotV)
{
	return (NdotL / (NdotL * (1.0 - k) + k))
		* (NdotV / (NdotV * (1.0 - k) + k));
}

/// @desc Fresnel
/// @source https://en.wikipedia.org/wiki/Schlick%27s_approximation
vec3 xSpecularF_Schlick(vec3 f0, float VdotH)
{
	return f0 + (1.0 - f0) * xPow5(1.0 - VdotH);
}

/// @desc Cook-Torrance microfacet specular shading
/// @note N = normalize(vertexNormal)
///       L = normalize(light - vertex)
///       V = normalize(camera - vertex)
///       H = normalize(L + V)
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 xBRDF(vec3 f0, float roughness, float NdotL, float NdotV, float NdotH, float VdotH)
{
	vec3 specular = xSpecularD_GGX(roughness, NdotH)
		* xSpecularF_Schlick(f0, VdotH)
		* xSpecularG_Schlick(xK_Analytic(roughness), NdotL, NdotH);
	return specular / max(4.0 * NdotL * NdotV, 0.001);
}

// Source: https://gamedev.stackexchange.com/questions/169508/octahedral-impostors-octahedral-mapping

/// @param dir Sampling dir vector in world-space.
/// @return UV coordinates on an octahedron map.
vec2 xVec3ToOctahedronUv(vec3 dir)
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

/// @desc Converts octahedron UV into a world-space vector.
vec3 xOctahedronUvToVec3Normalized(vec2 uv)
{
	vec3 position = vec3(2.0 * (uv - 0.5), 0);
	vec2 absolute = abs(position.xy);
	position.z = 1.0 - absolute.x - absolute.y;
	if (position.z < 0.0)
	{
		position.xy = sign(position.xy) * vec2(1.0 - absolute.y, 1.0 - absolute.x);
	}
	return position;
}


vec3 xDiffuseIBL(sampler2D ibl, vec2 texel, vec3 N)
{
	const float s = 1.0 / 8.0;
	const float r2 = 7.0;

	vec2 uv0 = xVec3ToOctahedronUv(N);
	uv0.x = (r2 + mix(texel.x, 1.0 - texel.x, uv0.x)) * s;
	uv0.y = mix(texel.y, 1.0 - texel.y, uv0.y);

	return xGammaToLinear(xDecodeRGBM(texture2D(ibl, uv0)));
}

/// @source https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
vec2 xEnvBRDFApprox(float roughness, float NdotV)
{
	const vec4 c0 = vec4(-1.0, -0.0275, -0.572, 0.022);
	const vec4 c1 = vec4(1.0, 0.0425, 1.04, -0.04);
	vec4 r = (roughness * c0) + c1;
	float a004 = (min(r.x * r.x, exp2(-9.28 * NdotV)) * r.x) + r.y;
	return ((vec2(-1.04, 1.04) * a004) + r.zw);
}

/// @source https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
float xEnvBRDFApproxNonmetal(float roughness, float NdotV)
{
	// Same as EnvBRDFApprox(0.04, Roughness, NdotV)
	const vec2 c0 = vec2(-1.0, -0.0275);
	const vec2 c1 = vec2(1.0, 0.0425);
	vec2 r = (roughness * c0) + c1;
	return (min(r.x * r.x, exp2(-9.28 * NdotV)) * r.x) + r.y;
}

// Fully rough optimization:
// xEnvBRDFApprox(SpecularColor, 1, 1) == SpecularColor * 0.4524 - 0.0024
// DiffuseColor += SpecularColor * 0.45;
// SpecularColor = 0.0;

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 xSpecularIBL(sampler2D ibl, vec2 texel/*, sampler2D brdf*/, vec3 f0, float roughness, vec3 N, vec3 V)
{
	float NdotV = clamp(dot(N, V), 0.0, 1.0);
	vec3 R = 2.0 * dot(V, N) * N - V;
	// vec2 envBRDF = texture2D(brdf, vec2(roughness, NdotV)).xy;
	vec2 envBRDF = xEnvBRDFApprox(roughness, NdotV);

	const float s = 1.0 / 8.0;
	float r = roughness * 7.0;
	float r2 = floor(r);
	float rDiff = r - r2;

	vec2 uv0 = xVec3ToOctahedronUv(R);
	uv0.x = (r2 + mix(texel.x, 1.0 - texel.x, uv0.x)) * s;
	uv0.y = mix(texel.y, 1.0 - texel.y, uv0.y);

	vec2 uv1 = uv0;
	uv1.x = uv1.x + s;

	vec3 specular = f0 * envBRDF.x + envBRDF.y;

	vec3 col0 = xGammaToLinear(xDecodeRGBM(texture2D(ibl, uv0))) * specular;
	vec3 col1 = xGammaToLinear(xDecodeRGBM(texture2D(ibl, uv1))) * specular;

	return mix(col0, col1, rDiff);
}

/// @param subsurface Color in RGB and thickness/intensity in A.
/// @source https://colinbarrebrisebois.com/2011/03/07/gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurface-scattering-look/
vec3 xCheapSubsurface(vec4 subsurface, vec3 eye, vec3 normal, vec3 light, vec3 lightColor)
{
	const float fLTPower = 1.0;
	const float fLTScale = 1.0;
	vec3 vLTLight = light + normal;
	float fLTDot = pow(clamp(dot(eye, -vLTLight), 0.0, 1.0), fLTPower) * fLTScale;
	float fLT = fLTDot * subsurface.a;
	return subsurface.rgb * lightColor * fLT;
}


#define F0_DEFAULT vec3(0.04)



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

void Exposure()
{
	gl_FragColor.rgb = vec3(1.0) - exp(-gl_FragColor.rgb * bbmod_Exposure);
}

void GammaCorrect()
{
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
}

void PBRShader(Material material)
{
	vec3 N = material.Normal;
	vec3 V = normalize(bbmod_CamPos - v_vVertex);
	vec3 lightColor = xDiffuseIBL(bbmod_IBL, bbmod_IBLTexel, N);

	// Diffuse
	gl_FragColor.rgb = material.Base * lightColor;
	// Specular
	gl_FragColor.rgb += xSpecularIBL(bbmod_IBL, bbmod_IBLTexel, material.Specular, material.Roughness, N, V);
	// Ambient occlusion
	gl_FragColor.rgb *= material.AO;
	// Emissive
	gl_FragColor.rgb += material.Emissive;
	// Subsurface scattering
	gl_FragColor.rgb += xCheapSubsurface(material.Subsurface, -V, N, N, lightColor);
	// Opacity
	gl_FragColor.a = material.Opacity;

	Exposure();
	GammaCorrect();
}

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_NormalRoughness,
		bbmod_MetallicAO,
		bbmod_Subsurface,
		bbmod_Emissive,
		v_mTBN,
		v_vTexCoord);



	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}

	PBRShader(material);
}
// include("Uber_PS.xsh")
