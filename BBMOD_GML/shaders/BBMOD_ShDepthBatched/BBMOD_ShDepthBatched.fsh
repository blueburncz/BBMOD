#pragma include("Uber_PS.xsh", "glsl")
// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
// Defines


////////////////////////////////////////////////////////////////////////////////
// Varyings
varying vec3 v_vVertex;


varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;


////////////////////////////////////////////////////////////////////////////////
// Uniforms
// Material
#define bbmod_BaseOpacity gm_BaseTexture  // RGB: Base color, A: Opacity
uniform sampler2D bbmod_NormalSmoothness; // RGB: Tangent space normal, A: Smoothness
uniform sampler2D bbmod_SpecularColor;    // RGB: Specular color
uniform float bbmod_AlphaTest;            // Pixels with alpha less than this value will be discarded

// Camera
uniform vec3 bbmod_CamPos;    // Camera's position in world space
uniform float bbmod_ZFar;     // Distance to the far clipping plane
uniform float bbmod_Exposure; // Camera's exposure value



////////////////////////////////////////////////////////////////////////////////
// Includes

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
	vec4 baseOpacity = texture2D(bbmod_BaseOpacity, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor.rgb = xEncodeDepth(v_fDepth / bbmod_ZFar);
	gl_FragColor.a = 1.0;
}
// include("Uber_PS.xsh")
