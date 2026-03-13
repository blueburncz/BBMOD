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

varying vec4 v_vColor;

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying vec4 v_vPosition;

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
// Dithered transparency

// Distance at which dithered fade starts (0 = disabled)
uniform float bbmod_DitherFadeStart;
// Distance at which dithered fade ends (fully transparent)
uniform float bbmod_DitherFadeEnd;

////////////////////////////////////////////////////////////////////////////////
// Camera

// Camera's position in world space
#define BBMOD_CAMPOS_DECLARED
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

////////////////////////////////////////////////////////////////////////////////
//
// Dithering
//

/// @desc Generate 4x4 Bayer matrix threshold value for screen-space dithering
/// @param screenPos Fragment position in screen space (gl_FragCoord.xy)
/// @return Threshold value in range [0, 1]
float BayerDither4x4(vec2 screenPos)
{
	// Use modulo to get position within 4x4 tile
	vec2 pos = mod(screenPos, 4.0);
	int x = int(pos.x);
	int y = int(pos.y);

	// 4x4 Bayer matrix values (compatible across all GLSL versions)
	// Using if-else chain instead of array indexing for maximum compatibility
	float value = 0.0;

	if (y == 0)
	{
		if (x == 0)      value = 0.0;
		else if (x == 1) value = 8.0;
		else if (x == 2) value = 2.0;
		else             value = 10.0;
	}
	else if (y == 1)
	{
		if (x == 0)      value = 12.0;
		else if (x == 1) value = 4.0;
		else if (x == 2) value = 14.0;
		else             value = 6.0;
	}
	else if (y == 2)
	{
		if (x == 0)      value = 3.0;
		else if (x == 1) value = 11.0;
		else if (x == 2) value = 1.0;
		else             value = 9.0;
	}
	else // y == 3
	{
		if (x == 0)      value = 15.0;
		else if (x == 1) value = 7.0;
		else if (x == 2) value = 13.0;
		else             value = 5.0;
	}

	return value / 16.0;
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

	DepthShader((u_fOutputDistance == 1.0) ? length(v_vPosition.xyz) : v_vPosition.z);

}
