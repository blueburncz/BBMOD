// FIXME: Temporary fix!
precision highp float;

#if defined(X_ZOMBIE)
// Dissolve effect
uniform vec3 u_vDissolveColor;
uniform float u_fDissolveThreshold;
uniform float u_fDissolveRange;
uniform vec2 u_vDissolveScale;

// Silhouette effect
uniform vec4 u_vSilhouette;

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
#endif // X_ZOMBIE

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
// Instance IDs

// The id of the instance that draws the mesh.
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

#if !defined(X_OUTPUT_DEPTH)
#if defined(X_PARTICLES)
////////////////////////////////////////////////////////////////////////////////
// Soft particles

// G-buffer surface.
uniform sampler2D bbmod_GBuffer;

// Distance over which the particle smoothly dissappears when getting closer to
// geometry rendered in the depth buffer.
uniform float bbmod_SoftDistance;
#endif // X_PARTICLES

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

#if !defined(X_UNLIT)
////////////////////////////////////////////////////////////////////////////////
// SSAO

// SSAO texture
uniform sampler2D bbmod_SSAO;

////////////////////////////////////////////////////////////////////////////////
// Image based lighting

// Prefiltered octahedron env. map
uniform sampler2D bbmod_IBL;
// Texel size of one octahedron
uniform vec2 bbmod_IBLTexel;

////////////////////////////////////////////////////////////////////////////////
// Point lights

// [(x, y, z, range), (r, g, b, m), ...]
uniform vec4 bbmod_LightPointData[2 * MAX_POINT_LIGHTS];
#endif // !X_UNLIT

#if defined(X_TERRAIN)
////////////////////////////////////////////////////////////////////////////////
// Terrain

// Splatmap texture
uniform sampler2D bbmod_Splatmap;
// Splatmap channel to read. Use -1 for none.
uniform int bbmod_SplatmapIndex;
#endif // X_TERRAIN

#if !defined(X_UNLIT)
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
// The range over which meshes smoothly transition into shadow.
uniform float bbmod_ShadowmapBias;
#endif // !X_UNLIT
#endif // !X_OUTPUT_DEPTH

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

#if defined(X_ZOMBIE)
	// Dissolve
	float noise = Noise(v_vTexCoord * u_vDissolveScale);
	if (noise < u_fDissolveThreshold)
	{
		discard;
	}
#endif // X_ZOMBIE

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}

#if defined(X_ID)
	gl_FragColor = bbmod_InstanceID;
#elif defined(X_OUTPUT_DEPTH)
	DepthShader(v_vPosition.z);
#else // X_OUTPUT_DEPTH
#if defined(X_PBR)
	PBRShader(material, v_vPosition.z);
#else // X_PBR
#if defined(X_UNLIT)
	UnlitShader(material, v_vPosition.z);
#else // X_UNLIT
	DefaultShader(material, v_vPosition.z);
#endif // !X_UNLIT
#endif // !X_PBR
#endif // !X_OUTPUT_DEPTH

#if defined(X_ZOMBIE)
	// Dissolve
	gl_FragColor.rgb = mix(
		gl_FragColor.rgb,
		u_vDissolveColor,
		(1.0 - clamp((noise - u_fDissolveThreshold) / u_fDissolveRange, 0.0, 1.0)) * u_fDissolveThreshold);
	// Silhouette
	gl_FragColor.rgb = mix(gl_FragColor.rgb, u_vSilhouette.rgb, u_vSilhouette.a);
#endif // X_ZOBMIE
}
