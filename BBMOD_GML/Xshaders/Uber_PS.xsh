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

#pragma include("Varyings.xsh")

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

#if defined(X_ID)
////////////////////////////////////////////////////////////////////////////////
//
uniform vec4 bbmod_InstanceID;
#endif

////////////////////////////////////////////////////////////////////////////////
// Material

// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture
#if !defined(X_OUTPUT_DEPTH) && !defined(X_ID)
// RGBA
uniform vec4 bbmod_BaseOpacityMultiplier;
#endif
#if defined(X_PBR)
// RGB: Tangent space normal, A: Roughness
uniform sampler2D bbmod_NormalRoughness;
// R: Metallic, G: Ambient occlusion
uniform sampler2D bbmod_MetallicAO;
// RGB: Subsurface color, A: Intensity
uniform sampler2D bbmod_Subsurface;
// RGBA: RGBM encoded emissive color
uniform sampler2D bbmod_Emissive;
#else // X_PBR
#if defined(X_2D)
// UVs of the BaseOpacity texture
uniform vec4 bbmod_BaseOpacityUV;
// UVs of the NormalSmoothness texture
uniform vec4 bbmod_NormalSmoothnessUV;
// UVs of the SpecularColor texture
uniform vec4 bbmod_SpecularColorUV;
#endif // X_2D
// RGB: Tangent space normal, A: Smoothness
uniform sampler2D bbmod_NormalSmoothness;
// RGB: Specular color
uniform sampler2D bbmod_SpecularColor;
#endif // !X_PBR
// Pixels with alpha less than this value will be discarded
uniform float bbmod_AlphaTest;

////////////////////////////////////////////////////////////////////////////////
// Camera

#if !defined(X_2D)
// Camera's position in world space
uniform vec3 bbmod_CamPos;
#endif
// Distance to the far clipping plane
uniform float bbmod_ZFar;
// Camera's exposure value
uniform float bbmod_Exposure;

#if defined(X_PBR)
////////////////////////////////////////////////////////////////////////////////
// Image based lighting

// Prefiltered octahedron env. map
uniform sampler2D bbmod_IBL;
// Texel size of one octahedron
uniform vec2 bbmod_IBLTexel;
#endif

#if !defined(X_PBR) && !defined(X_OUTPUT_DEPTH)
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

// RGBM encoded ambient light color on the upper hemisphere.
uniform vec4 bbmod_LightAmbientUp;
// RGBM encoded ambient light color on the lower hemisphere.
uniform vec4 bbmod_LightAmbientDown;

////////////////////////////////////////////////////////////////////////////////
// Directional light

// Direction of the directional light
uniform vec3 bbmod_LightDirectionalDir;
// RGBM encoded color of the directional light
uniform vec4 bbmod_LightDirectionalColor;

#if defined(X_2D)
////////////////////////////////////////////////////////////////////////////////
// Point lights

// [(x, y, z, range), (r, g, b, m), ...]
uniform vec4 bbmod_LightPointData[2 * MAX_POINT_LIGHTS];
#endif

////////////////////////////////////////////////////////////////////////////////
// Terrain
#if defined(X_TERRAIN)
// Splatmap texture
uniform sampler2D bbmod_Splatmap;
// Splatmap channel to read. Use -1 for none.
uniform int bbmod_SplatmapIndex;
#endif

////////////////////////////////////////////////////////////////////////////////
// Shadow mapping

// 1.0 to enable shadows
uniform float bbmod_ShadowmapEnablePS;
// Shadowmap texture
uniform sampler2D bbmod_Shadowmap;
// (1.0/shadowmapWidth, 1.0/shadowmapHeight)
uniform vec2 bbmod_ShadowmapTexel;
// The area that the shadowmap captures
uniform float bbmod_ShadowmapAreaPS;
// TODO: Docs
uniform float bbmod_ShadowmapBias;
#endif

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
#if defined(X_PBR)
#pragma include("MetallicMaterial.xsh")
#else
#pragma include("SpecularMaterial.xsh")
#endif

#if !defined(X_ID)
#if defined(X_OUTPUT_DEPTH)
#pragma include("DepthShader.xsh")
#else // X_OUTPUT_DEPTH
#if defined(X_PBR)
#pragma include("PBRShader.xsh")
#else // X_PBR
#if defined(X_UNLIT)
#pragma include("UnlitShader.xsh")
#else // X_UNLIT
#pragma include("DefaultShader.xsh")
#endif // !X_UNLIT
#endif // !X_PBR
#endif // !X_OUTPUT_DEPTH
#endif // !X_ID

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
#if defined(X_PBR)
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_NormalRoughness,
		bbmod_MetallicAO,
		bbmod_Subsurface,
		bbmod_Emissive,
		v_mTBN,
		v_vTexCoord);
#else
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_NormalSmoothness,
		bbmod_SpecularColor,
		v_mTBN,
		v_vTexCoord);
#endif

#if defined(X_2D) || defined(X_PARTICLES)
	material.Base *= v_vColor.rgb;
	material.Opacity *= v_vColor.a;
#endif

#if defined(X_TERRAIN)
	// Splatmap
	vec4 splatmap = texture2D(bbmod_Splatmap, v_vSplatmapCoord);
	if (bbmod_SplatmapIndex >= 0)
	{
		// splatmap[bbmod_SplatmapIndex] does not work in HTML5
		material.Opacity *= ((bbmod_SplatmapIndex == 0) ? splatmap.r
			: ((bbmod_SplatmapIndex == 1) ? splatmap.g
			: ((bbmod_SplatmapIndex == 2) ? splatmap.b
			: splatmap.a)));
	}
#endif

#if !defined(X_OUTPUT_DEPTH) && !defined(X_ID)
	material.Base *= bbmod_BaseOpacityMultiplier.rgb;
	material.Opacity *= bbmod_BaseOpacityMultiplier.a;
#endif

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}

#if defined(X_ID)
	gl_FragColor = bbmod_InstanceID;
#elif defined(X_OUTPUT_DEPTH)
	DepthShader(v_fDepth);
#else // X_OUTPUT_DEPTH
#if defined(X_PBR)
	PBRShader(material);
#else // X_PBR
#if defined(X_UNLIT)
	UnlitShader(material, v_fDepth);
#else // X_UNLIT
	DefaultShader(material, v_fDepth);
#endif // !X_UNLIT
#endif // !X_PBR
#endif // !X_OUTPUT_DEPTH
}
