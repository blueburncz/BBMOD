// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Defines
//

// Maximum number of punctual lights
#define BBMOD_MAX_PUNCTUAL_LIGHTS 8
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
varying float v_fDitherSeed;
varying float v_fDitherFadeMultiplier;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

////////////////////////////////////////////////////////////////////////////////
// Material

// Material index
// uniform float bbmod_MaterialIndex;

// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture

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
// Writing shadow maps

// 0.0 = output depth, 1.0 = output distance from camera
uniform float u_fOutputDistance;

////////////////////////////////////////////////////////////////////////////////
// HDR rendering

// 0.0 = apply exposure, tonemap and gamma correct, 1.0 = output raw values
uniform float bbmod_HDR;

////////////////////////////////////////////////////////////////////////////////
// Distance dithering

// 0.0 = disabled, > 0.0 = enabled
uniform float bbmod_DitherEnable;
// (fadeInStart, fadeInEnd, fadeOutStart, fadeOutEnd)
uniform vec4 bbmod_DitherDistance;

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
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

float xDistanceDitherNoise(vec2 positionScreen, float seed)
{
	vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
	return fract(magic.z * fract(dot(positionScreen + vec2(seed * 13.13, seed * 7.31), magic.xy)));
}

void xApplyDistanceDither(float seed, float fadeMultiplier)
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

	float threshold = xDistanceDitherNoise(gl_FragCoord.xy, seed);
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
	float opacity = texture2D(gm_BaseTexture, v_vTexCoord).a;

	if (opacity < bbmod_AlphaTest)
	{
		discard;
	}

	xApplyDistanceDither(v_fDitherSeed, v_fDitherFadeMultiplier);

	DepthShader((u_fOutputDistance == 1.0) ? length(v_vPosition.xyz) : v_vPosition.z);

}
