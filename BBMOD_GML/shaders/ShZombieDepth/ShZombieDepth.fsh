// FIXME: Temporary fix!
precision highp float;

// Dissolve effect
uniform vec3 u_vDissolveColor;
uniform float u_fDissolveThreshold;
uniform float u_fDissolveRange;
uniform vec2 u_vDissolveScale;

float Random(in vec2 st)
{
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float Noise(in vec2 st)
{
	vec2 i = floor(st);
	vec2 f = fract(st);
	float a = Random(i);
	float b = Random(i + vec2(1.0, 0.0));
	float c = Random(i + vec2(0.0, 1.0));
	float d = Random(i + vec2(1.0, 1.0));
	vec2 u = smoothstep(0.0, 1.0, f);
	return mix(
		mix(a, b, u.x),
		mix(c, d, u.x),
		u.y);
}

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
varying vec4 v_vPosition;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

////////////////////////////////////////////////////////////////////////////////
// Material

// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture
// RGB: Tangent space normal, A: Smoothness
uniform sampler2D bbmod_NormalSmoothness;
// RGB: Specular color
uniform sampler2D bbmod_SpecularColor;
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

Material CreateMaterial(mat3 TBN)
{
	Material m;
	m.Base = vec3(1.0);
	m.Opacity = 1.0;
	m.Normal = normalize(TBN * vec3(0.0, 0.0, 1.0));
	m.Metallic = 0.0;
	m.Roughness = 1.0;
	m.Specular = vec3(0.0);
	m.Smoothness = 0.0;
	m.SpecularPower = 1.0;
	m.AO = 1.0;
	m.Emissive = vec3(0.0);
	m.Subsurface = vec4(0.0);
	return m;
}
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

	// Roughness
	m.Roughness = 1.0 - m.Smoothness;

	// Specular power
	m.SpecularPower = exp2(1.0 + (m.Smoothness * 10.0));

	return m;
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

void DepthShader(float depth)
{
	gl_FragColor.rgb = xEncodeDepth(depth / bbmod_ZFar);
	gl_FragColor.a = 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_NormalSmoothness,
		bbmod_SpecularColor,
		v_mTBN,
		v_vTexCoord);

	// Dissolve
	float noise = Noise(v_vTexCoord * u_vDissolveScale);
	if (noise < u_fDissolveThreshold)
	{
		discard;
	}

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}

	DepthShader(v_vPosition.z);

	// Dissolve
	gl_FragColor.rgb = mix(
		gl_FragColor.rgb,
		u_vDissolveColor,
		(1.0 - clamp((noise - u_fDissolveThreshold) / u_fDissolveRange, 0.0, 1.0)) * u_fDissolveThreshold);
}
