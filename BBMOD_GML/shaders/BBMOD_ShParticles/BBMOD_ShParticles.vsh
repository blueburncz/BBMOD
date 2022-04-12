//#pragma include("Uber_VS.xsh", "glsl")
// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Defines
//

// Maximum number of vec4 uniforms for dynamic batch data
#define MAX_BATCH_DATA_SIZE 64

// Maximum number of point lights
#define MAX_POINT_LIGHTS 8

////////////////////////////////////////////////////////////////////////////////
//
// Attributes
//
attribute vec4 in_Position;
attribute vec2 in_TextureCoord0;
attribute vec2 in_Id;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

uniform vec4 bbmod_BatchData[3 * MAX_BATCH_DATA_SIZE];

// [(x, y, z, range), (r, g, b, m), ...]
uniform vec4 bbmod_LightPointData[2 * MAX_POINT_LIGHTS];

// 1.0 to enable shadows
uniform float bbmod_ShadowmapEnableVS;
// WORLD_VIEW_PROJECTION matrix used when rendering shadowmap
uniform mat4 bbmod_ShadowmapMatrix;
// The area that the shadowmap captures
uniform float bbmod_ShadowmapArea;
// Offsets vertex position by its normal scaled by this value
uniform float bbmod_ShadowmapNormalOffset;

////////////////////////////////////////////////////////////////////////////////
//
// Varyings
//
varying vec3 v_vVertex;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;
varying vec3 v_vLight;
varying vec3 v_vPosShadowmap;
varying mat4 v_mView;

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
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


////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
	vec3 batchPosition = bbmod_BatchData[int(in_Id) * 3 + 0].xyz;
	vec3 batchScale = bbmod_BatchData[int(in_Id) * 3 + 1].xyz;
	vec3 batchColor = xDecodeRGBM(bbmod_BatchData[int(in_Id) * 3 + 2]);

	vec4 position = in_Position;
	position.x *= length(gm_Matrices[MATRIX_WORLD][0].xyz);
	position.y *= length(gm_Matrices[MATRIX_WORLD][1].xyz);
	position.z *= length(gm_Matrices[MATRIX_WORLD][2].xyz);
	position.xyz *= batchScale;

	v_mView = gm_Matrices[MATRIX_VIEW];

	mat4 matrixWorld = gm_Matrices[MATRIX_WORLD];
	matrixWorld[3].xyz += batchPosition;

	mat4 matrixWorldView = gm_Matrices[MATRIX_VIEW] * matrixWorld;

	//if (u_fBillboard != BILLBOARD_NONE)
	//{
		matrixWorldView[0].xyz = vec3(1.0, 0.0, 0.0);
		//if (u_fBillboard == BILLBOARD_CYLINDRICAL)
		//{
		//	matrixWorldView[1].xyz = -matrixWorldView[2].xyz;
		//}
		//else
		//{
			matrixWorldView[1].xyz = vec3(0.0, -1.0, 0.0);
		//}
		matrixWorldView[2].xyz = vec3(0.0, 0.0, 1.0);
	//}

	gl_Position = gm_Matrices[MATRIX_PROJECTION] * (matrixWorldView * position);
	v_fDepth = (gm_Matrices[MATRIX_PROJECTION] * (matrixWorldView * position)).z;
	v_vVertex = (matrixWorldView * position).xyz;
	v_vTexCoord = in_TextureCoord0;

	vec3 N = (matrixWorldView * vec4(0.0, 0.0, -1.0, 0.0)).xyz;
	vec3 T = (matrixWorldView * vec4(1.0, 0.0, 0.0, 0.0)).xyz;
	vec3 B = (matrixWorldView * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	v_mTBN = mat3(T, B, N);

	// Splatmap coords

	////////////////////////////////////////////////////////////////////////////
	// Point lights
	N = normalize(N);
	v_vLight = vec3(0.0);

	for (int i = 0; i < MAX_POINT_LIGHTS; ++i)
	{
		vec4 positionRange = bbmod_LightPointData[i * 2];
		vec3 L = (v_mView * vec4(positionRange.xyz, 1.0)).xyz - v_vVertex;
		float dist = length(L);
		float att = clamp(1.0 - (dist / positionRange.w), 0.0, 1.0);
		float NdotL = max(dot(N, normalize(L)), 0.0);
		v_vLight += xGammaToLinear(xDecodeRGBM(bbmod_LightPointData[(i * 2) + 1])) * NdotL * att;
	}

	////////////////////////////////////////////////////////////////////////////
	// Vertex position in shadowmap
	if (bbmod_ShadowmapEnableVS == 1.0)
	{
		v_vPosShadowmap = (bbmod_ShadowmapMatrix * vec4(v_vVertex + N * bbmod_ShadowmapNormalOffset, 1.0)).xyz;
		v_vPosShadowmap.xy = v_vPosShadowmap.xy * 0.5 + 0.5;
	#if defined(_YY_HLSL11_) || defined(_YY_PSSL_)
		v_vPosShadowmap.y = 1.0 - v_vPosShadowmap.y;
	#endif
		v_vPosShadowmap.z /= bbmod_ShadowmapArea;
	}
}
// include("Uber_VS.xsh")
