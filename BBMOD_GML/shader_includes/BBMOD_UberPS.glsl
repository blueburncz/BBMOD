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

// @if defined(BBMOD_ID) && !defined(BBMOD_BATCHED)
////////////////////////////////////////////////////////////////////////////////
// Instance IDs

// The ID of the instance that draws the mesh.
uniform vec4 bbmod_InstanceID;
// @endif

////////////////////////////////////////////////////////////////////////////////
// Material

// @if !defined(BBMOD_TERRAIN)
// RGB: Base color, A: Opacity.
#define bbmod_BaseOpacity gm_BaseTexture

// @if !defined(BBMOD_OUTPUT_DEPTH) && !defined(BBMOD_ID)
// RGBA multiplier applied to base color and opacity.
uniform vec4 bbmod_BaseOpacityMultiplier;
// 1.0 if the material uses roughness workflow.
uniform float bbmod_IsRoughness;
// RGB: Tangent-space normal, A: Smoothness or roughness.
uniform sampler2D bbmod_NormalW;
// 1.0 if the material uses metallic workflow.
uniform float bbmod_IsMetallic;
// Metallic: R=metallic, G=AO. Specular: RGB=specular color.
uniform sampler2D bbmod_Material;

// @if defined(BBMOD_SUBSURFACE) && !defined(BBMOD_LIGHTMAP) && !defined(BBMOD_OUTPUT_GBUFFER)
// RGB: Subsurface color, A: Intensity.
uniform sampler2D bbmod_Subsurface;
// @endif

// @if defined(BBMOD_EMISSIVE)
// RGBA: RGBM encoded emissive color.
uniform sampler2D bbmod_Emissive;
// @endif

// @if defined(BBMOD_LIGHTMAP)
// RGBA: RGBM encoded lightmap.
uniform sampler2D bbmod_Lightmap;
// @endif

// @if defined(BBMOD_2D)
// UVs of the BaseOpacity texture.
uniform vec4 bbmod_BaseOpacityUV;
// UVs of the NormalW texture.
uniform vec4 bbmod_NormalWUV;
// UVs of the Material texture.
uniform vec4 bbmod_MaterialUV;
// @if defined(BBMOD_SUBSURFACE) && !defined(BBMOD_OUTPUT_GBUFFER)
// UVs of the Subsurface texture.
uniform vec4 bbmod_SubsurfaceUV;
// @endif

// @if defined(BBMOD_EMISSIVE)
// UVs of the Emissive texture.
uniform vec4 bbmod_EmissiveUV;
// @endif
// @endif

// 1.0 to flip the normal before shading backfaces.
uniform float bbmod_TwoSided;
// @endif // !defined(BBMOD_OUTPUT_DEPTH) && !defined(BBMOD_ID)
// @endif // !defined(BBMOD_TERRAIN)

// Pixels with alpha below this value are discarded.
uniform float bbmod_AlphaTest;

////////////////////////////////////////////////////////////////////////////////
// Camera

// @if !defined(BBMOD_2D)
// Camera position in world space.
uniform vec3 bbmod_CamPos;
// @endif

// Distance to the far clipping plane.
uniform float bbmod_ZFar;
// Camera exposure value.
uniform float bbmod_Exposure;

// @if !defined(BBMOD_OUTPUT_DEPTH) && !defined(BBMOD_OUTPUT_GBUFFER)
// @if defined(BBMOD_PARTICLES)
////////////////////////////////////////////////////////////////////////////////
// Soft particles

// G-buffer depth surface.
uniform sampler2D bbmod_GBuffer;
// Distance over which particles fade out near geometry.
uniform float bbmod_SoftDistance;
// @endif

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

// @if defined(BBMOD_PBR)
////////////////////////////////////////////////////////////////////////////////
// SSAO

// SSAO texture.
uniform sampler2D bbmod_SSAO;

////////////////////////////////////////////////////////////////////////////////
// Image based lighting

// 1.0 to enable IBL.
uniform float bbmod_IBLEnable;
// Prefiltered octahedron env. map.
uniform sampler2D bbmod_IBL;
// Texel size of one octahedron face.
uniform vec2 bbmod_IBLTexel;
// @endif

// @if defined(BBMOD_PBR) && !defined(BBMOD_OUTPUT_GBUFFER)
////////////////////////////////////////////////////////////////////////////////
// Shadow mapping

// 1.0 to enable shadows.
uniform float bbmod_ShadowmapEnablePS;
// Shadowmap texture.
uniform sampler2D bbmod_Shadowmap;
// (1.0/shadowmapWidth, 1.0/shadowmapHeight).
uniform vec2 bbmod_ShadowmapTexel;
// The area that the shadowmap captures.
uniform float bbmod_ShadowmapArea;
// The range over which meshes smoothly transition into shadow.
uniform float bbmod_ShadowmapBias;
// Index of the light that casts shadows. Use -1 for directional light.
uniform float bbmod_ShadowCasterIndex;
// Offsets vertex position by its normal scaled by this value.
uniform float bbmod_ShadowmapNormalOffsetPS;
// @endif
// @endif // !defined(BBMOD_OUTPUT_DEPTH) && !defined(BBMOD_OUTPUT_GBUFFER)

// @if defined(BBMOD_TERRAIN)
////////////////////////////////////////////////////////////////////////////////
// Terrain

// First layer: RGB=base color, A=opacity.
#define bbmod_TerrainBaseOpacity0 gm_BaseTexture
// 1.0 if the first layer uses roughness workflow.
uniform float bbmod_TerrainIsRoughness0;
// First layer: RGB=tangent-space normal, A=smoothness or roughness.
uniform sampler2D bbmod_TerrainNormalW0;
// Splatmap channel for the first layer. Use -1 for none.
uniform int bbmod_SplatmapIndex0;

// Splatmap texture.
uniform sampler2D bbmod_Splatmap;
// Colormap texture.
uniform sampler2D bbmod_Colormap;

// @if (!defined(BBMOD_PBR) || defined(BBMOD_OUTPUT_GBUFFER)) && !defined(BBMOD_OUTPUT_DEPTH) && !defined(BBMOD_ID)
// Second layer: RGB=base color, A=opacity.
uniform sampler2D bbmod_TerrainBaseOpacity1;
// 1.0 if the second layer uses roughness workflow.
uniform float bbmod_TerrainIsRoughness1;
// Second layer: RGB=tangent-space normal, A=smoothness or roughness.
uniform sampler2D bbmod_TerrainNormalW1;
// Splatmap channel for the second layer. Use -1 for none.
uniform int bbmod_SplatmapIndex1;

// Third layer: RGB=base color, A=opacity.
uniform sampler2D bbmod_TerrainBaseOpacity2;
// 1.0 if the third layer uses roughness workflow.
uniform float bbmod_TerrainIsRoughness2;
// Third layer: RGB=tangent-space normal, A=smoothness or roughness.
uniform sampler2D bbmod_TerrainNormalW2;
// Splatmap channel for the third layer. Use -1 for none.
uniform int bbmod_SplatmapIndex2;
// @endif
// @endif // BBMOD_TERRAIN

// @if defined(BBMOD_OUTPUT_DEPTH)
////////////////////////////////////////////////////////////////////////////////
// Depth output

// 0.0 = write linear depth, 1.0 = write distance from camera.
uniform float u_fOutputDistance;
// @endif

// @if defined(BBMOD_OUTPUT_GBUFFER) && !defined(BBMOD_TERRAIN)
////////////////////////////////////////////////////////////////////////////////
// G-Buffer

// Lookup texture for best-fit normal encoding.
uniform sampler2D u_texBestFitNormalLUT;
// @endif

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

// @include BBMOD_Varyings
// @if defined(BBMOD_OUTPUT_DEPTH)
// @include BBMOD_DepthShader
// @elif defined(BBMOD_OUTPUT_GBUFFER)
// @include BBMOD_GammaToLinear
// @include BBMOD_LinearToGamma
// @include BBMOD_EncodeDepth
// @include BBMOD_BestFitNormal
// @if defined(BBMOD_PBR)
// @include BBMOD_UnpackMaterial
// @endif
// @elif defined(BBMOD_PBR)
// @include BBMOD_UnpackMaterial
// @include BBMOD_PBRShader
// @elif !defined(BBMOD_ID)
// @include BBMOD_UnpackMaterial
// @include BBMOD_UnlitShader
// @endif
// @include BBMOD_ApplyDistanceDither

////////////////////////////////////////////////////////////////////////////////
//
// Main
//

void main()
{
// @if defined(BBMOD_OUTPUT_DEPTH) || defined(BBMOD_ID)
	float opacity = texture2D(gm_BaseTexture, v_vTexCoord).a;

	if (opacity < bbmod_AlphaTest)
	{
		discard;
	}

	BBMOD_ApplyDistanceDither(v_fDitherSeed, v_fDitherFadeMultiplier);

// @if defined(BBMOD_ID)
// @if defined(BBMOD_BATCHED)
	gl_FragColor = v_vInstanceID;
// @else
	gl_FragColor = bbmod_InstanceID;
// @endif
// @elif defined(BBMOD_OUTPUT_DEPTH)
	BBMOD_DepthShader(
		(u_fOutputDistance == 1.0) ? length(v_vPosition.xyz) : v_vPosition.z);
// @endif

// @else
// @if defined(BBMOD_TERRAIN)
// @if defined(BBMOD_PBR) && !defined(BBMOD_OUTPUT_GBUFFER)
	////////////////////////////////////////////////////////////////////////////
	// Single-layer PBR terrain

	BBMOD_Material material = BBMOD_UnpackMaterial(
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
	material.Base *= BBMOD_GammaToLinear(
		texture2D(bbmod_Colormap, v_vSplatmapCoord).xyz);

// @else
	////////////////////////////////////////////////////////////////////////////
	// Multi-layer terrain (G-buffer or unlit)

	BBMOD_Material material = BBMOD_UnpackMaterial(
		bbmod_TerrainBaseOpacity0,
		bbmod_TerrainIsRoughness0,
		bbmod_TerrainNormalW0,
		v_mTBN,
		v_vTexCoord);

	BBMOD_Material material1 = BBMOD_UnpackMaterial(
		bbmod_TerrainBaseOpacity1,
		bbmod_TerrainIsRoughness1,
		bbmod_TerrainNormalW1,
		v_mTBN,
		v_vTexCoord);

	BBMOD_Material material2 = BBMOD_UnpackMaterial(
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

// @if defined(BBMOD_PBR)
		material.Normal        *= layerStrengthInv;
		material.Metallic      *= layerStrengthInv;
		material.Roughness     *= layerStrengthInv;
		material.Specular      *= layerStrengthInv;
		material.Smoothness    *= layerStrengthInv;
		material.SpecularPower *= layerStrengthInv;
		material.AO            *= layerStrengthInv;

// @if defined(BBMOD_EMISSIVE)
		material.Emissive      *= layerStrengthInv;
// @endif

// @if defined(BBMOD_SUBSURFACE)
		material.Subsurface    *= layerStrengthInv;
// @endif

		material.Lightmap      *= layerStrengthInv;

		material.Normal        += layerStrength * material1.Normal;
		material.Metallic      += layerStrength * material1.Metallic;
		material.Roughness     += layerStrength * material1.Roughness;
		material.Specular      += layerStrength * material1.Specular;
		material.Smoothness    += layerStrength * material1.Smoothness;
		material.SpecularPower += layerStrength * material1.SpecularPower;
		material.AO            += layerStrength * material1.AO;

// @if defined(BBMOD_EMISSIVE)
		material.Emissive      += layerStrength * material1.Emissive;
// @endif

// @if defined(BBMOD_SUBSURFACE)
		material.Subsurface    += layerStrength * material1.Subsurface;
// @endif

		material.Lightmap      += layerStrength * material1.Lightmap;
// @endif
	}

	if (bbmod_SplatmapIndex2 >= 0)
	{
		// splatmap[index] does not work in HTML5
		float layerStrength = ((bbmod_SplatmapIndex2 == 0) ? splatmap.r
			: ((bbmod_SplatmapIndex2 == 1) ? splatmap.g
			: ((bbmod_SplatmapIndex2 == 2) ? splatmap.b
			: splatmap.a)));
		float layerStrengthInv = 1.0 - layerStrength;

		material.Base    *= layerStrengthInv;
		material.Opacity *= layerStrengthInv;

		material.Base    += layerStrength * material2.Base;
		material.Opacity += layerStrength * material2.Opacity;

// @if defined(BBMOD_PBR)
		material.Normal        *= layerStrengthInv;
		material.Metallic      *= layerStrengthInv;
		material.Roughness     *= layerStrengthInv;
		material.Specular      *= layerStrengthInv;
		material.Smoothness    *= layerStrengthInv;
		material.SpecularPower *= layerStrengthInv;
		material.AO            *= layerStrengthInv;

// @if defined(BBMOD_EMISSIVE)
		material.Emissive      *= layerStrengthInv;
// @endif

// @if defined(BBMOD_SUBSURFACE)
		material.Subsurface    *= layerStrengthInv;
// @endif

		material.Lightmap      *= layerStrengthInv;

		material.Normal        += layerStrength * material2.Normal;
		material.Metallic      += layerStrength * material2.Metallic;
		material.Roughness     += layerStrength * material2.Roughness;
		material.Specular      += layerStrength * material2.Specular;
		material.Smoothness    += layerStrength * material2.Smoothness;
		material.SpecularPower += layerStrength * material2.SpecularPower;
		material.AO            += layerStrength * material2.AO;

// @if defined(BBMOD_EMISSIVE)
		material.Emissive      += layerStrength * material2.Emissive;
// @endif

// @if defined(BBMOD_SUBSURFACE)
		material.Subsurface    += layerStrength * material2.Subsurface;
// @endif

		material.Lightmap      += layerStrength * material2.Lightmap;
// @endif
	}

	// Colormap
	material.Base *= BBMOD_GammaToLinear(
		texture2D(bbmod_Colormap, v_vSplatmapCoord).xyz);

// @endif // BBMOD_PBR && !BBMOD_OUTPUT_GBUFFER
// @else
	////////////////////////////////////////////////////////////////////////////
	// Non-terrain

	BBMOD_Material material = BBMOD_UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_IsRoughness,
		bbmod_NormalW,
		bbmod_IsMetallic,
		bbmod_Material,
// @if defined(BBMOD_SUBSURFACE) && !defined(BBMOD_LIGHTMAP) && !defined(BBMOD_OUTPUT_GBUFFER)
		bbmod_Subsurface,
// @endif

// @if defined(BBMOD_EMISSIVE)
		bbmod_Emissive,
// @endif

// @if defined(BBMOD_LIGHTMAP)
		bbmod_Lightmap,
		v_vTexCoord2,
// @endif
		v_mTBN,
		v_vTexCoord);

// @endif // BBMOD_TERRAIN

// @if defined(BBMOD_COLOR) || defined(BBMOD_2D) || defined(BBMOD_PARTICLES)
	material.Base    *= v_vColor.rgb;
	material.Opacity *= v_vColor.a;
// @endif

// @if !defined(BBMOD_TERRAIN)
	material.Base    *= BBMOD_GammaToLinear(bbmod_BaseOpacityMultiplier.rgb);
	material.Opacity *= bbmod_BaseOpacityMultiplier.a;
// @endif

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}

	BBMOD_ApplyDistanceDither(v_fDitherSeed, v_fDitherFadeMultiplier);

// @if defined(BBMOD_OUTPUT_GBUFFER)
	gl_FragData[0] = vec4(
		BBMOD_LinearToGamma(mix(material.Base, material.Specular, material.Metallic)),
		material.AO);

// @if defined(BBMOD_TERRAIN)
	gl_FragData[1] = vec4(material.Normal * 0.5 + 0.5, material.Roughness);
// @else
	gl_FragData[1] = vec4(
		BBMOD_BestFitNormal(material.Normal, u_texBestFitNormalLUT) * 0.5 + 0.5,
		material.Roughness);
// @endif

	gl_FragData[2] = vec4(
		BBMOD_EncodeDepth(v_vPosition.z / bbmod_ZFar),
		material.Metallic);

// @if defined(BBMOD_EMISSIVE)
	gl_FragData[3] = vec4(material.Emissive, 1.0);
	if (bbmod_HDR == 0.0)
	{
		gl_FragData[3].rgb = BBMOD_LinearToGamma(gl_FragData[3].rgb);
	}
// @else
	gl_FragData[3] = vec4(0.0, 0.0, 0.0, 1.0);
// @endif
// @elif defined(BBMOD_PBR)
	BBMOD_PBRShader(material, v_vPosition.z);
// @else
	BBMOD_UnlitShader(material, v_vPosition.z);
// @endif

// @endif // !OUTPUT_DEPTH && !ID
}
