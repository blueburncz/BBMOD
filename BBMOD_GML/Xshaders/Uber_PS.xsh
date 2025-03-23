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

#pragma include("Varyings.xsh")

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

#if defined(X_ID) && !defined(X_BATCHED)
////////////////////////////////////////////////////////////////////////////////
// Instance IDs

// The ID of the instance that draws the mesh.
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

#if !defined(X_LIGHTMAP) && !defined(X_OUTPUT_GBUFFER)
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
#if !defined(X_OUTPUT_GBUFFER)
// UVs of the Subsurface texture
uniform vec4 bbmod_SubsurfaceUV;
#endif
// UVs of the Emissive texture
uniform vec4 bbmod_EmissiveUV;
#endif // X_2D

// If 1.0 then normal is flipped before shading of backfaces
uniform float bbmod_TwoSided;

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

// Distance over which the particle smoothly disappears when getting closer to
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
uniform vec4 bbmod_LightPunctualDataA[(BBMOD_MAX_PUNCTUAL_LIGHTS + BBMOD_MAX_PUNCTUAL_LIGHTS)];
// [(isSpotLight, dcosInner, dcosOuter), (dX, dY, dZ), ...]
uniform vec3 bbmod_LightPunctualDataB[(BBMOD_MAX_PUNCTUAL_LIGHTS + BBMOD_MAX_PUNCTUAL_LIGHTS)];

vec4 BBMOD_GetPunctualLightDataA(int index)
{
#if defined(_YY_GLSL_) || defined(_YY_HLSL11_) || defined(_YY_PSSL_)
	return bbmod_LightPunctualDataA[index];
#else
	if (index == 0)       return bbmod_LightPunctualDataA[0];
	else if (index == 1)  return bbmod_LightPunctualDataA[1];
	else if (index == 2)  return bbmod_LightPunctualDataA[2];
	else if (index == 3)  return bbmod_LightPunctualDataA[3];
	else if (index == 4)  return bbmod_LightPunctualDataA[4];
	else if (index == 5)  return bbmod_LightPunctualDataA[5];
	else if (index == 6)  return bbmod_LightPunctualDataA[6];
	else if (index == 7)  return bbmod_LightPunctualDataA[7];
	else if (index == 8)  return bbmod_LightPunctualDataA[8];
	else if (index == 9)  return bbmod_LightPunctualDataA[9];
	else if (index == 10) return bbmod_LightPunctualDataA[10];
	else if (index == 11) return bbmod_LightPunctualDataA[11];
	else if (index == 12) return bbmod_LightPunctualDataA[12];
	else if (index == 13) return bbmod_LightPunctualDataA[13];
	else if (index == 14) return bbmod_LightPunctualDataA[14];
	else if (index == 15) return bbmod_LightPunctualDataA[15];
	else                  return vec4(0.0);
#endif
}

vec3 BBMOD_GetPunctualLightDataB(int index)
{
#if defined(_YY_GLSL_) || defined(_YY_HLSL11_) || defined(_YY_PSSL_)
	return bbmod_LightPunctualDataB[index];
#else
	if (index == 0)       return bbmod_LightPunctualDataB[0];
	else if (index == 1)  return bbmod_LightPunctualDataB[1];
	else if (index == 2)  return bbmod_LightPunctualDataB[2];
	else if (index == 3)  return bbmod_LightPunctualDataB[3];
	else if (index == 4)  return bbmod_LightPunctualDataB[4];
	else if (index == 5)  return bbmod_LightPunctualDataB[5];
	else if (index == 6)  return bbmod_LightPunctualDataB[6];
	else if (index == 7)  return bbmod_LightPunctualDataB[7];
	else if (index == 8)  return bbmod_LightPunctualDataB[8];
	else if (index == 9)  return bbmod_LightPunctualDataB[9];
	else if (index == 10) return bbmod_LightPunctualDataB[10];
	else if (index == 11) return bbmod_LightPunctualDataB[11];
	else if (index == 12) return bbmod_LightPunctualDataB[12];
	else if (index == 13) return bbmod_LightPunctualDataB[13];
	else if (index == 14) return bbmod_LightPunctualDataB[14];
	else if (index == 15) return bbmod_LightPunctualDataB[15];
	else                  return vec3(0.0);
#endif
}

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
// Offsets vertex position by its normal scaled by this value
uniform float bbmod_ShadowmapNormalOffsetPS;
#endif // defined(X_PBR) && !defined(X_OUTPUT_GBUFFER)
#endif // !defined(X_OUTPUT_DEPTH) && !defined(X_OUTPUT_GBUFFER)

#if defined(X_TERRAIN)
////////////////////////////////////////////////////////////////////////////////
// Terrain

// First layer:
// RGB: Base color, A: Opacity
#define bbmod_TerrainBaseOpacity0 gm_BaseTexture
// If 1.0 then the material uses roughness
uniform float bbmod_TerrainIsRoughness0;
// RGB: Tangent-space normal, A: Smoothness or roughness
uniform sampler2D bbmod_TerrainNormalW0;
// Splatmap channel to read. Use -1 for none.
uniform int bbmod_SplatmapIndex0;

// Splatmap texture
uniform sampler2D bbmod_Splatmap;
// Colormap texture
uniform sampler2D bbmod_Colormap;

#if (!defined(X_PBR) || defined(X_OUTPUT_GBUFFER)) && !(defined(X_OUTPUT_DEPTH) || defined(X_ID))
// Second layer:
// RGB: Base color, A: Opacity
uniform sampler2D bbmod_TerrainBaseOpacity1;
// If 1.0 then the material uses roughness
uniform float bbmod_TerrainIsRoughness1;
// RGB: Tangent-space normal, A: Smoothness or roughness
uniform sampler2D bbmod_TerrainNormalW1;
// Splatmap channel to read. Use -1 for none.
uniform int bbmod_SplatmapIndex1;

// Third layer:
// RGB: Base color, A: Opacity
uniform sampler2D bbmod_TerrainBaseOpacity2;
// If 1.0 then the material uses roughness
uniform float bbmod_TerrainIsRoughness2;
// RGB: Tangent-space normal, A: Smoothness or roughness
uniform sampler2D bbmod_TerrainNormalW2;
// Splatmap channel to read. Use -1 for none.
uniform int bbmod_SplatmapIndex2;
#endif

#endif // X_TERRAIN

#if defined(X_OUTPUT_DEPTH)
////////////////////////////////////////////////////////////////////////////////
// Writing shadow maps

// 0.0 = output depth, 1.0 = output distance from camera
uniform float u_fOutputDistance;
#endif

#if defined(X_OUTPUT_GBUFFER) && !defined(X_TERRAIN)
////////////////////////////////////////////////////////////////////////////////
// G-Buffer

// Lookup texture for best fit normal encoding
uniform sampler2D u_texBestFitNormalLUT;
#endif

////////////////////////////////////////////////////////////////////////////////
// HDR rendering

// 0.0 = apply exposure, tonemap and gamma correct, 1.0 = output raw values
uniform float bbmod_HDR;

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
#if defined(X_ID)
#elif defined(X_OUTPUT_DEPTH)
#    pragma include("DepthShader.xsh")
#elif defined(X_OUTPUT_GBUFFER)
#    pragma include("DepthEncoding.xsh")
#    pragma include("BestFitNormals.xsh")
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
	DepthShader((u_fOutputDistance == 1.0) ? length(v_vPosition.xyz) : v_vPosition.z);
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
#if !defined(X_LIGHTMAP) && !defined(X_PARTICLES) && !defined(X_OUTPUT_GBUFFER)
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

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}

#if defined(X_OUTPUT_GBUFFER)
	gl_FragData[0] = vec4(xLinearToGamma(mix(material.Base, material.Specular, material.Metallic)), material.AO);
#if defined(X_TERRAIN)
	gl_FragData[1] = vec4(material.Normal * 0.5 + 0.5, material.Roughness);
#else
	gl_FragData[1] = vec4(xBestFitNormal(material.Normal, u_texBestFitNormalLUT) * 0.5 + 0.5, material.Roughness);
#endif
	gl_FragData[2] = vec4(xEncodeDepth(v_vPosition.z / bbmod_ZFar), material.Metallic);
	gl_FragData[3] = vec4(material.Emissive, 1.0);
	if (bbmod_HDR == 0.0)
	{
		gl_FragData[3].rgb = xLinearToGamma(gl_FragData[3].rgb);
	}
#elif defined(X_PBR)
	PBRShader(material, v_vPosition.z);
#else
	UnlitShader(material, v_vPosition.z);
#endif
#endif
}
