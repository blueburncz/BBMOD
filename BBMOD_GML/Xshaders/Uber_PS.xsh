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

// Maximum number of punctual lights
#define BBMOD_MAX_PUNCTUAL_LIGHTS 8
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

#if !defined(X_TERRAIN)
// Material index
// uniform float bbmod_MaterialIndex;

// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture

#if !defined(X_OUTPUT_DEPTH) && !defined(X_ID)
// RGBA
uniform vec4 bbmod_BaseOpacityMultiplier;

// If 1.0 then the material uses roughness
uniform float bbmod_IsRoughness;
// RGB: Tangent-space normal, A: Smoothness or roughness
uniform sampler2D bbmod_NormalW;
// If 1.0 then the material uses metallic workflow
uniform float bbmod_IsMetallic;
// RGB: specular color / R: Metallic, G: ambient occlusion
uniform sampler2D bbmod_Material;

#if !defined(X_LIGHTMAP)
// RGB: Subsurface color, A: Intensity
uniform sampler2D bbmod_Subsurface;
#endif
// RGBA: RGBM encoded emissive color
uniform sampler2D bbmod_Emissive;

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

#endif // !X_TERRAIN
#endif // !defined(X_OUTPUT_DEPTH) && !defined(X_ID)

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

#if !defined(X_OUTPUT_DEPTH) && !defined(X_OUTPUT_GBUFFER)
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
uniform vec4 bbmod_LightPunctualDataA[2 * BBMOD_MAX_PUNCTUAL_LIGHTS];
// [(isSpotLight, dcosInner, dcosOuter), (dX, dY, dZ), ...]
uniform vec3 bbmod_LightPunctualDataB[2 * BBMOD_MAX_PUNCTUAL_LIGHTS];
#endif // X_PBR

#if defined(X_PBR) && !defined(X_OUTPUT_GBUFFER)
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
#endif // defined(X_PBR) && !defined(X_OUTPUT_GBUFFER)
#endif // !defined(X_OUTPUT_DEPTH) && !defined(X_OUTPUT_GBUFFER)

#if defined(X_TERRAIN)
////////////////////////////////////////////////////////////////////////////////
// Terrain

// RGB: Base color, A: Opacity
#define bbmod_TerrainBaseOpacity0 gm_BaseTexture
// If 1.0 then the material uses roughness
uniform float bbmod_TerrainIsRoughness0;
// RGB: Tangent-space normal, A: Smoothness or roughness
uniform sampler2D bbmod_TerrainNormalW0;
// Splatmap texture
uniform sampler2D bbmod_Splatmap;
// Splatmap channel to read. Use -1 for none.
uniform int bbmod_SplatmapIndex0;
// Colormap texture
uniform sampler2D bbmod_Colormap;

#if (!defined(X_PBR) || defined(X_OUTPUT_GBUFFER)) && !(defined(X_OUTPUT_DEPTH) || defined(X_ID))
uniform sampler2D bbmod_TerrainBaseOpacity1;
uniform float bbmod_TerrainIsRoughness1;
uniform sampler2D bbmod_TerrainNormalW1;
uniform int bbmod_SplatmapIndex1;

uniform sampler2D bbmod_TerrainBaseOpacity2;
uniform float bbmod_TerrainIsRoughness2;
uniform sampler2D bbmod_TerrainNormalW2;
uniform int bbmod_SplatmapIndex2;
#endif

#endif // X_TERRAIN

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
#if defined(X_ID)
#elif defined(X_OUTPUT_DEPTH) || defined(X_OUTPUT_GBUFFER)
#    pragma include("DepthShader.xsh")
#    if defined(X_PBR)
#        pragma include("MetallicMaterial.xsh")
#    endif
#elif defined(X_PBR)
#    pragma include("PBRShader.xsh")
#else
#    pragma include("UnlitShader.xsh")
#endif

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
#if defined(X_OUTPUT_DEPTH) || defined(X_ID)
	float opacity = texture2D(gm_BaseTexture, v_vTexCoord).a;

#if defined(X_ZOMBIE)
	// Dissolve
	float noise = Noise(v_vTexCoord * u_vDissolveScale);
	if (noise < u_fDissolveThreshold)
	{
		discard;
	}
#endif // X_ZOMBIE

	if (opacity < bbmod_AlphaTest)
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
#endif

#else
#if defined(X_TERRAIN)
#if defined(X_PBR) && !defined(X_OUTPUT_GBUFFER)
	Material material = UnpackMaterial(
		bbmod_TerrainBaseOpacity0,
		bbmod_TerrainIsRoughness0,
		bbmod_TerrainNormalW0,
		v_mTBN,
		v_vTexCoord);

	// Splatmap
	vec4 splatmap = texture2D(bbmod_Splatmap, v_vSplatmapCoord);
	if (bbmod_SplatmapIndex0 >= 0)
	{
		// splatmap[index] does not work in HTML5
		material.Opacity *= ((bbmod_SplatmapIndex0 == 0) ? splatmap.r
			: ((bbmod_SplatmapIndex0 == 1) ? splatmap.g
			: ((bbmod_SplatmapIndex0 == 2) ? splatmap.b
			: splatmap.a)));
	}

	// Colormap
	material.Base *= xGammaToLinear(texture2D(bbmod_Colormap, v_vSplatmapCoord).xyz);
#else // X_PBR
	Material material = UnpackMaterial(
		bbmod_TerrainBaseOpacity0,
		bbmod_TerrainIsRoughness0,
		bbmod_TerrainNormalW0,
		v_mTBN,
		v_vTexCoord);

	Material material1 = UnpackMaterial(
		bbmod_TerrainBaseOpacity1,
		bbmod_TerrainIsRoughness1,
		bbmod_TerrainNormalW1,
		v_mTBN,
		v_vTexCoord);

	Material material2 = UnpackMaterial(
		bbmod_TerrainBaseOpacity2,
		bbmod_TerrainIsRoughness2,
		bbmod_TerrainNormalW2,
		v_mTBN,
		v_vTexCoord);

	// Splatmap
	vec4 splatmap = texture2D(bbmod_Splatmap, v_vSplatmapCoord);

	// Blend layers
	if (bbmod_SplatmapIndex0 >= 0)
	{
		// splatmap[index] does not work in HTML5
		float layerStrength = ((bbmod_SplatmapIndex0 == 0) ? splatmap.r
			: ((bbmod_SplatmapIndex0 == 1) ? splatmap.g
			: ((bbmod_SplatmapIndex0 == 2) ? splatmap.b
			: splatmap.a)));

		material.Opacity *= layerStrength;
	}

	if (bbmod_SplatmapIndex1 >= 0)
	{
		// splatmap[index] does not work in HTML5
		float layerStrength = ((bbmod_SplatmapIndex1 == 0) ? splatmap.r
			: ((bbmod_SplatmapIndex1 == 1) ? splatmap.g
			: ((bbmod_SplatmapIndex1 == 2) ? splatmap.b
			: splatmap.a)));
		float layerStrengthInv = 1.0 - layerStrength;

		material.Base    *= layerStrengthInv;
		material.Opacity *= layerStrengthInv;

		material.Base    += layerStrength * material1.Base;
		material.Opacity += layerStrength * material1.Opacity;

		#if defined(X_PBR)
		material.Normal        *= layerStrengthInv;
		material.Metallic      *= layerStrengthInv;
		material.Roughness     *= layerStrengthInv;
		material.Specular      *= layerStrengthInv;
		material.Smoothness    *= layerStrengthInv;
		material.SpecularPower *= layerStrengthInv;
		material.AO            *= layerStrengthInv;
		material.Emissive      *= layerStrengthInv;
		material.Subsurface    *= layerStrengthInv;
		material.Lightmap      *= layerStrengthInv;

		material.Normal        += layerStrength * material1.Normal;
		material.Metallic      += layerStrength * material1.Metallic;
		material.Roughness     += layerStrength * material1.Roughness;
		material.Specular      += layerStrength * material1.Specular;
		material.Smoothness    += layerStrength * material1.Smoothness;
		material.SpecularPower += layerStrength * material1.SpecularPower;
		material.AO            += layerStrength * material1.AO;
		material.Emissive      += layerStrength * material1.Emissive;
		material.Subsurface    += layerStrength * material1.Subsurface;
		material.Lightmap      += layerStrength * material1.Lightmap;
		#endif
	}

	if (bbmod_SplatmapIndex2 >= 0)
	{
		// splatmap[index] does not work in HTML5
		float layerStrength= ((bbmod_SplatmapIndex2 == 0) ? splatmap.r
			: ((bbmod_SplatmapIndex2 == 1) ? splatmap.g
			: ((bbmod_SplatmapIndex2 == 2) ? splatmap.b
			: splatmap.a)));
		float layerStrengthInv = 1.0 - layerStrength;

		material.Base    *= layerStrengthInv;
		material.Opacity *= layerStrengthInv;

		material.Base    += layerStrength * material2.Base;
		material.Opacity += layerStrength * material2.Opacity;

		#if defined(X_PBR)
		material.Normal        *= layerStrengthInv;
		material.Metallic      *= layerStrengthInv;
		material.Roughness     *= layerStrengthInv;
		material.Specular      *= layerStrengthInv;
		material.Smoothness    *= layerStrengthInv;
		material.SpecularPower *= layerStrengthInv;
		material.AO            *= layerStrengthInv;
		material.Emissive      *= layerStrengthInv;
		material.Subsurface    *= layerStrengthInv;
		material.Lightmap      *= layerStrengthInv;

		material.Normal        += layerStrength * material2.Normal;
		material.Metallic      += layerStrength * material2.Metallic;
		material.Roughness     += layerStrength * material2.Roughness;
		material.Specular      += layerStrength * material2.Specular;
		material.Smoothness    += layerStrength * material2.Smoothness;
		material.SpecularPower += layerStrength * material2.SpecularPower;
		material.AO            += layerStrength * material2.AO;
		material.Emissive      += layerStrength * material2.Emissive;
		material.Subsurface    += layerStrength * material2.Subsurface;
		material.Lightmap      += layerStrength * material2.Lightmap;
		#endif
	}

	// Colormap
	material.Base *= xGammaToLinear(texture2D(bbmod_Colormap, v_vSplatmapCoord).xyz);
#endif // !X_PBR
#else // X_TERRAIN
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_IsRoughness,
		bbmod_NormalW,
		bbmod_IsMetallic,
		bbmod_Material,
#if !defined(X_LIGHTMAP)
		bbmod_Subsurface,
#endif
		bbmod_Emissive,
#if defined(X_LIGHTMAP)
		bbmod_Lightmap,
		v_vTexCoord2,
#endif
		v_mTBN,
		v_vTexCoord);
#endif // !X_TERRAIN

#if defined(X_COLOR) || defined(X_2D) || defined(X_PARTICLES)
	material.Base *= v_vColor.rgb;
	material.Opacity *= v_vColor.a;
#endif

#if !defined(X_TERRAIN)
	material.Base *= xGammaToLinear(bbmod_BaseOpacityMultiplier.rgb);
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

#if defined(X_OUTPUT_GBUFFER)
	gl_FragData[0] = vec4(xLinearToGamma(mix(material.Base, material.Specular, material.Metallic)), material.AO);
	gl_FragData[1] = vec4(material.Normal * 0.5 + 0.5, material.Roughness);
	gl_FragData[2] = vec4(xEncodeDepth(v_vPosition.z / bbmod_ZFar), material.Metallic);
	gl_FragData[3] = vec4(xLinearToGamma(material.Emissive), 1.0);
#elif defined(X_PBR)
	PBRShader(material, v_vPosition.z);
#else
	UnlitShader(material, v_vPosition.z);
#endif

#if defined(X_ZOMBIE)
	// Dissolve
	gl_FragColor.rgb = mix(
		gl_FragColor.rgb,
		u_vDissolveColor,
		(1.0 - clamp((noise - u_fDissolveThreshold) / u_fDissolveRange, 0.0, 1.0)) * u_fDissolveThreshold);
	// Silhouette
	gl_FragColor.rgb = mix(gl_FragColor.rgb, u_vSilhouette.rgb, u_vSilhouette.a);
#endif

#endif
}
