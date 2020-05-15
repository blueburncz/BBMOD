varying vec3 v_vVertex;
//varying vec4 v_vColour;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;

// RGB: Base color, A: Opacity
#define u_texBaseOpacity gm_BaseTexture

// RGB: Tangent space normal, A: Roughness
uniform sampler2D u_texNormalRoughness;

// R: Metallic, G: Ambient occlusion
uniform sampler2D u_texMetallicAO;

// RGB: Subsurface color, A: Intensity
uniform sampler2D u_texSubsurface;

// RGBM encoded emissive color
uniform sampler2D u_texEmissive;

// Prefiltered diffuse octahedron env. map
uniform sampler2D u_texDiffuseIBL;

// Prefiltered specular octahedron env. map
uniform sampler2D u_texSpecularIBL;

// Texel size of one octahedron.
uniform vec2 u_vSpecularIBLTexel;

// Preintegrated env. BRDF
uniform sampler2D u_texBRDF;

// Camera's position in world space
uniform vec3 u_vCamPos;

// Camera's exposure value
uniform float u_fExposure;

#pragma include("BRDF.xsh", "glsl")
#define X_PI   3.14159265359
#define X_2_PI 6.28318530718

/// @return x^2
float xPow2(float x) { return (x * x); }

/// @return x^3
float xPow3(float x) { return (x * x * x); }

/// @return x^4
float xPow4(float x) { return (x * x * x * x); }

/// @return x^5
float xPow5(float x) { return (x * x * x * x * x); }

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
// include("BRDF.xsh")

#pragma include("OctahedronMapping.xsh", "glsl")
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
// include("OctahedronMapping.xsh")

#pragma include("RGBM.xsh", "glsl")
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
// include("RGBM.xsh")

#pragma include("IBL.xsh")
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

#define X_ROUGHNESS_MIP_COUNT 8

vec3 xDiffuseIBL(sampler2D octahedron, vec3 N)
{
	return xGammaToLinear(xDecodeRGBM(texture2D(octahedron, xVec3ToOctahedronUv(N))));
}

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 xSpecularIBL(sampler2D octahedron, vec2 texel, sampler2D brdf, vec3 f0, float roughness, vec3 N, vec3 V)
{
	float NdotV = clamp(dot(N, V), 0.0, 1.0);
	vec3 R = 2.0 * dot(V, N) * N - V;
	vec2 envBRDF = texture2D(brdf, vec2(roughness, NdotV)).xy;

	float s = 1.0 / float(X_ROUGHNESS_MIP_COUNT);
	float r = roughness * float(X_ROUGHNESS_MIP_COUNT);
	float r2 = floor(r);
	float rDiff = r - r2;

	vec2 uv0 = xVec3ToOctahedronUv(R);
	uv0.x = (r2 + mix(texel.x, 1.0 - texel.x, uv0.x)) * s;
	uv0.y = mix(texel.y, 1.0 - texel.y, uv0.y);

	vec2 uv1 = uv0;
	uv1.x = uv1.x + s;

	vec3 specular = f0 * envBRDF.x + envBRDF.y;

	vec3 col0 = xGammaToLinear(xDecodeRGBM(texture2D(octahedron, uv0))) * specular;
	vec3 col1 = xGammaToLinear(xDecodeRGBM(texture2D(octahedron, uv1))) * specular;

	return mix(col0, col1, rDiff);
}
// include("IBL.xsh")

#pragma include("Color.xsh", "glsl")

#pragma include("Math.xsh", "glsl")

#pragma include("CheapSubsurface.xsh", "glsl")
/// @source https://colinbarrebrisebois.com/2011/03/07/gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurface-scattering-look/
vec3 xCheapSubsurface(vec3 subsurfaceColor, float subsurfaceIntensity, vec3 eye, vec3 normal, vec3 light, vec3 lightColor)
{
	const float fLTPower = 1.0;
	const float fLTScale = 1.0;
	vec3 vLTLight = light + normal;
	float fLTDot = pow(clamp(dot(eye, -vLTLight), 0.0, 1.0), fLTPower) * fLTScale;
	float fLT = fLTDot * subsurfaceIntensity;
	return subsurfaceColor * lightColor * fLT;
}
// include("CheapSubsurface.xsh")

void main()
{
	////////////////////////////////////////////////////////////////////////////
	// Unpack material properties
	vec4 baseOpacity = texture2D(u_texBaseOpacity, v_vTexCoord);
	vec3 baseColor = xGammaToLinear(baseOpacity.rgb);
	float opacity = baseOpacity.a;

	vec4 normalRoughness = texture2D(u_texNormalRoughness, v_vTexCoord);
	normalRoughness.g = 1.0 - normalRoughness.g; // TODO: Comment out!
	vec3 N = normalize(v_mTBN * (normalRoughness.rgb * 2.0 - 1.0));
	float roughness = normalRoughness.a;

	vec4 metallicAO = texture2D(u_texMetallicAO, v_vTexCoord);
	float metallic = metallicAO.r;
	float AO = metallicAO.g;

	vec4 subsurface = texture2D(u_texSubsurface, v_vTexCoord);
	vec3 subsurfaceColor = xGammaToLinear(subsurface.rgb);
	float subsurfaceIntensity = subsurface.a;

	vec3 emissive = xGammaToLinear(xDecodeRGBM(texture2D(u_texEmissive, v_vTexCoord)));

	vec3 specularColor = mix(X_F0_DEFAULT, baseColor, metallic);
	baseColor *= (1.0 - metallic);
	////////////////////////////////////////////////////////////////////////////

	vec3 V = normalize(u_vCamPos - v_vVertex);
	vec3 lightColor = xDiffuseIBL(u_texDiffuseIBL, N) / X_PI;

	gl_FragColor.rgb = (
		baseColor * lightColor
		+ xSpecularIBL(u_texSpecularIBL, u_vSpecularIBLTexel, u_texBRDF, specularColor, roughness, N, V)
		) * AO
		+ emissive
		+ xCheapSubsurface(subsurfaceColor, subsurfaceIntensity, -V, N, N, lightColor)
		;

	gl_FragColor.rgb = vec3(1.0) - exp(-gl_FragColor.rgb * u_fExposure);
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
	gl_FragColor.a = opacity;
}