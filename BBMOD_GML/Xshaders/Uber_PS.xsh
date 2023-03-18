// FIXME: Temporary fix!
precision highp float;

#if defined(X_ZOMBIE)
// Dissolve effect
uniform vec3 u_vDissolveColor;
uniform float u_fDissolveThreshold;
uniform float u_fDissolveRange;
uniform vec2 u_vDissolveScale;

#if !defined(X_OUTPUT_DEPTH)
// Silhouette effect
uniform vec4 u_vSilhouette;
#endif

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
#define MAX_PUNCTUAL_LIGHTS 8
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

#if defined(X_ID) && !defined(X_BATCHED)
////////////////////////////////////////////////////////////////////////////////
// Instance IDs

// The id of the instance that draws the mesh.
uniform vec4 bbmod_InstanceID;
#endif

////////////////////////////////////////////////////////////////////////////////
// Material

// Material index
// uniform float bbmod_MaterialIndex;

// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture

#if !defined(X_OUTPUT_DEPTH) && !defined(X_ID)
// RGBA
uniform vec4 bbmod_BaseOpacityMultiplier;
#endif

// If 1.0 then the material uses roughness
uniform float bbmod_IsRoughness;
// If 1.0 then the material uses metallic workflow
uniform float bbmod_IsMetallic;
// RGB: Tangent-space normal, A: Smoothness or roughness
uniform sampler2D bbmod_NormalW;
// RGB: specular color / R: Metallic, G: ambient occlusion
uniform sampler2D bbmod_Material;

#if !defined(X_TERRAIN)
#if !defined(X_LIGHTMAP)
// RGB: Subsurface color, A: Intensity
uniform sampler2D bbmod_Subsurface;
#endif
// RGBA: RGBM encoded emissive color
uniform sampler2D bbmod_Emissive;
#endif

#if defined(X_LIGHTMAP)
// RGBA: RGBM encoded lightmap
uniform sampler2D bbmod_Lightmap;
#endif

#if defined(X_2D)
// UVs of the BaseOpacity texture
uniform vec4 bbmod_BaseOpacityUV;
// UVs of the NormalW texture
uniform vec4 bbmod_NormalWUV;
// UVs of the Material texture
uniform vec4 bbmod_MaterialUV;
#endif // X_2D

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

#if defined(X_PBR)
////////////////////////////////////////////////////////////////////////////////
// SSAO

// SSAO texture
uniform sampler2D bbmod_SSAO;

////////////////////////////////////////////////////////////////////////////////
// Image based lighting

// 1.0 to enable IBL
uniform float bbmod_IBLEnable;
// Prefiltered octahedron env. map
uniform sampler2D bbmod_IBL;
// Texel size of one octahedron
uniform vec2 bbmod_IBLTexel;

////////////////////////////////////////////////////////////////////////////////
// Punctual lights

// [(x, y, z, range), (r, g, b, m), ...]
uniform vec4 bbmod_LightPunctualDataA[2 * MAX_PUNCTUAL_LIGHTS];
// [(isSpotLight, dcosInner, dcosOuter), (dX, dY, dZ), ...]
uniform vec3 bbmod_LightPunctualDataB[2 * MAX_PUNCTUAL_LIGHTS];
#endif // X_PBR

#if defined(X_TERRAIN)
////////////////////////////////////////////////////////////////////////////////
// Terrain

// Splatmap texture
uniform sampler2D bbmod_Splatmap;
// Splatmap channel to read. Use -1 for none.
uniform int bbmod_SplatmapIndex;
#endif // X_TERRAIN

#if defined(X_PBR)
////////////////////////////////////////////////////////////////////////////////
// Shadow mapping

// 1.0 to enable shadows
uniform float bbmod_ShadowmapEnablePS;
// Shadowmap texture
uniform sampler2D bbmod_Shadowmap;
// (1.0/shadowmapWidth, 1.0/shadowmapHeight)
uniform vec2 bbmod_ShadowmapTexel;
// The area that the shadowmap captures
uniform float bbmod_ShadowmapArea;
// The range over which meshes smoothly transition into shadow.
uniform float bbmod_ShadowmapBias;
// The index of the light that casts shadows. Use -1 for the directional light.
uniform float bbmod_ShadowCasterIndex;
#endif // X_PBR
#endif // !X_OUTPUT_DEPTH

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
#pragma include("MetallicMaterial.xsh")

#if !defined(X_ID)
#if defined(X_OUTPUT_DEPTH)
#pragma include("DepthShader.xsh")
#else // X_OUTPUT_DEPTH
#if defined(X_PBR)
#pragma include("PBRShader.xsh")
#else // X_PBR
#pragma include("UnlitShader.xsh")
#endif // !X_PBR
#endif // !X_OUTPUT_DEPTH
#endif // !X_ID

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_IsRoughness,
		bbmod_NormalW,
		bbmod_IsMetallic,
		bbmod_Material,
#if !defined(X_TERRAIN)
#if !defined(X_LIGHTMAP)
		bbmod_Subsurface,
#endif
		bbmod_Emissive,
#endif
#if defined(X_LIGHTMAP)
		bbmod_Lightmap,
		v_vTexCoord2,
#endif
		v_mTBN,
		v_vTexCoord);

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
#if defined(X_BATCHED)
	gl_FragColor = v_vInstanceID;
#else
	gl_FragColor = bbmod_InstanceID;
#endif
#elif defined(X_OUTPUT_DEPTH)
	DepthShader(v_vPosition.z);
#else // X_OUTPUT_DEPTH
#if defined(X_PBR)
	PBRShader(material, v_vPosition.z);
#else // X_PBR
	UnlitShader(material, v_vPosition.z);
#endif // !X_PBR
#endif // !X_OUTPUT_DEPTH

#if defined(X_ZOMBIE) && !defined(X_OUTPUT_DEPTH)
	// Dissolve
	gl_FragColor.rgb = mix(
		gl_FragColor.rgb,
		u_vDissolveColor,
		(1.0 - clamp((noise - u_fDissolveThreshold) / u_fDissolveRange, 0.0, 1.0)) * u_fDissolveThreshold);
	// Silhouette
	gl_FragColor.rgb = mix(gl_FragColor.rgb, u_vSilhouette.rgb, u_vSilhouette.a);
#endif
}
