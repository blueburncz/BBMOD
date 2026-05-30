// @define BBMOD_ID
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
// Instance IDs

// The ID of the instance that draws the mesh.
uniform vec4 bbmod_InstanceID;

////////////////////////////////////////////////////////////////////////////////
// Material

// RGB: Base color, A: Opacity.
#define bbmod_BaseOpacity gm_BaseTexture

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
	float opacity = texture2D(gm_BaseTexture, v_vTexCoord).a;

	if (opacity < bbmod_AlphaTest)
	{
		discard;
	}

	BBMOD_ApplyDistanceDither(v_fDitherSeed, v_fDitherFadeMultiplier);

	gl_FragColor = bbmod_InstanceID;

}
// @endinclude
