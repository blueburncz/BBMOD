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

varying vec4 v_vPosShadowmap;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

////////////////////////////////////////////////////////////////////////////////
// Instance IDs

// The id of the instance that draws the mesh.
uniform vec4 bbmod_InstanceID;

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
// Fog

// The color of the fog
uniform vec4 bbmod_FogColor;
// Maximum fog intensity
uniform float bbmod_FogIntensity;
// Distance at which the fog starts
uniform float bbmod_FogStart;
// 1.0 / (fogEnd - fogStart)
uniform float bbmod_FogRcpRange;

////////////////////////////////////////////////////////////////////////////////
// Ambient light

// Ambient light's up vector.
uniform vec3 bbmod_LightAmbientDirUp;
// Ambient light color on the upper hemisphere.
uniform vec4 bbmod_LightAmbientUp;
// Ambient light color on the lower hemisphere.
uniform vec4 bbmod_LightAmbientDown;

////////////////////////////////////////////////////////////////////////////////
// Directional light

// Direction of the directional light
uniform vec3 bbmod_LightDirectionalDir;
// Color of the directional light
uniform vec4 bbmod_LightDirectionalColor;

////////////////////////////////////////////////////////////////////////////////
// HDR rendering

// 0.0 = apply exposure, tonemap and gamma correct, 1.0 = output raw values
uniform float bbmod_HDR;

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//

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

		gl_FragColor = bbmod_InstanceID;

}
