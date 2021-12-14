#pragma include("Uber_PS.xsh", "glsl")
////////////////////////////////////////////////////////////////////////////////
// Varyings
varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;


////////////////////////////////////////////////////////////////////////////////
// Uniforms

// Pixels with alpha less than this value will be discarded.
uniform float bbmod_AlphaTest;

// Camera's position in world space
uniform vec3 bbmod_CamPos;

// Distance to the far clipping plane.
uniform float bbmod_ZFar;

// Camera's exposure value
uniform float bbmod_Exposure;

// The color of the fog.
uniform vec4 bbmod_FogColor;

// Maximum fog intensity.
uniform float bbmod_FogIntensity;

// Distance at which the fog starts.
uniform float bbmod_FogStart;

// 1.0 / (fogEnd - fogStart)
uniform float bbmod_FogRcpRange;

// RGBM encoded ambient light color on the upper hemisphere.
uniform vec4 bbmod_LightAmbientUp;

/// RGBM encoded ambient light color on the lower hemisphere.
uniform vec4 bbmod_LightAmbientDown;

// Direction of the directional light
uniform vec3 bbmod_LightDirectionalDir;

// RGBM encoded color of the directional light
uniform vec4 bbmod_LightDirectionalColor;

// Shadowmap texture
uniform sampler2D bbmod_Shadowmap;

// WORLD_VIEW_PROJECTION matrix used when rendering shadowmap
uniform mat4 bbmod_ShadowmapMatrix;

// (1.0/shadowmapWidth, 1.0/shadowmapHeight)
uniform vec2 bbmod_ShadowmapTexel;

// The area that the shadowmap captures.
uniform float bbmod_ShadowmapArea;

// Offsets vertex position by its normal scaled by this value.
uniform float bbmod_ShadowmapNormalOffset;

////////////////////////////////////////////////////////////////////////////////
// Includes
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



////////////////////////////////////////////////////////////////////////////////
// Main
void main()
{
	vec4 baseOpacity = texture2D(gm_BaseTexture, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor.rgb = xEncodeDepth(v_fDepth / bbmod_ZFar);
	gl_FragColor.a = 1.0;
}
// include("Uber_PS.xsh")
