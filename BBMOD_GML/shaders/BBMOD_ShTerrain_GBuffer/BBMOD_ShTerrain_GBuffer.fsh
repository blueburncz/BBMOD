// @define BBMOD_OUTPUT_GBUFFER
// @define BBMOD_PBR
// @define BBMOD_TERRAIN
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
// Material

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

varying vec2 v_vSplatmapCoord;

varying vec4 v_vEye;
/// @desc Converts gamma space color to linear space.
/// @param rgb Color in gamma space.
/// @return Color in linear space.
vec3 BBMOD_GammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(2.2));
}
/// @desc Converts linear space color to gamma space.
/// @param rgb Color in linear space.
/// @return Color in gamma space.
vec3 BBMOD_LinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / 2.2));
}
/// @desc Encodes a linearized depth value into RGB channels.
/// @param d Linearized depth to encode (0..1 range).
/// @return Encoded depth as RGB.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
vec3 BBMOD_EncodeDepth(float d)
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
/// @desc Encodes a normal using best-fit encoding for improved precision in
/// G-buffer storage.
/// @param normal The normal vector to encode.
/// @param tex Best-fit normal lookup texture.
/// @return Scaled normal vector suitable for G-buffer storage.
/// @source http://advances.realtimerendering.com/s2010/Kaplanyan-CryEngine3(SIGGRAPH%202010%20Advanced%20RealTime%20Rendering%20Course).pdf
vec3 BBMOD_BestFitNormal(vec3 normal, sampler2D tex)
{
	normal = normalize(normal);
	vec3 normalUns = abs(normal);
	float maxNAbs = max(max(normalUns.x, normalUns.y), normalUns.z);
	vec2 texCoord = normalUns.z < maxNAbs
		? (normalUns.y < maxNAbs ? normalUns.yz : normalUns.xz)
		: normalUns.xy;
	texCoord = texCoord.x < texCoord.y ? texCoord.yx : texCoord.xy;
	texCoord.y /= texCoord.x;
	normal /= maxNAbs;
	float fittingScale = texture2D(tex, texCoord).r;
	return normal * fittingScale;
}
/// @desc PBR material properties.
struct BBMOD_Material
{
	vec3 Base;
	float Opacity;
	vec3 Normal;
	float Metallic;
	float Roughness;
	vec3 Specular;
	float Smoothness;
	float SpecularPower;
	float AO;

	vec3 Lightmap;
};

/// @desc Creates a default BBMOD_Material with sensible initial values.
/// @return Default material.
BBMOD_Material BBMOD_CreateMaterial()
{
	BBMOD_Material m;
	m.Base = vec3(1.0);
	m.Opacity = 1.0;
	m.Normal = vec3(0.0, 0.0, 1.0);
	m.Metallic = 0.0;
	m.Roughness = 1.0;
	m.Specular = vec3(0.0);
	m.Smoothness = 0.0;
	m.SpecularPower = 1.0;
	m.AO = 1.0;

	m.Lightmap = vec3(0.0);
	return m;
}
/// @macro {vec3} Default Fresnel reflectance at normal incidence for
/// dielectric (non-metallic) materials.
#define BBMOD_F0_DEFAULT vec3(0.04)
/// @desc Decodes RGBM encoded HDR color.
/// @param rgbm RGBM encoded color (RGB in rgb channels, multiplier in alpha).
/// @return Decoded HDR color.
/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
vec3 BBMOD_DecodeRGBM(vec4 rgbm)
{
	return 6.0 * rgbm.rgb * rgbm.a;
}

/// @desc Unpacks a BBMOD_Material from a set of PBR textures.
///
/// The function signature adapts at build time based on active defines:
///   BBMOD_TERRAIN:       terrain variant (no metallic/specular/emissive/
///                        subsurface).
///   BBMOD_EMISSIVE:      adds texEmissive parameter and emissive sampling.
///   BBMOD_SUBSURFACE:    adds texSubsurface parameter and subsurface
///                        sampling when not in lightmap or G-buffer mode.
///   BBMOD_LIGHTMAP:      adds texLightmap and uvLightmap parameters.
///   BBMOD_OUTPUT_GBUFFER: disables subsurface parameter/sampling.
///
/// @param texBaseOpacity RGB: base color, A: opacity.
/// @param isRoughness 1.0 if normal alpha is roughness, 0.0 for smoothness.
/// @param texNormalW RGB: tangent-space normal, A: roughness or smoothness.
/// @param TBN Tangent-bitangent-normal matrix.
/// @param uv Texture coordinates.
/// @return Unpacked material.
BBMOD_Material BBMOD_UnpackMaterial(
	sampler2D texBaseOpacity,
	float isRoughness,
	sampler2D texNormalW,
	mat3 TBN,
	vec2 uv)
{
	BBMOD_Material m = BBMOD_CreateMaterial();

	vec4 baseOpacity = texture2D(texBaseOpacity, uv);
	m.Base = BBMOD_GammaToLinear(baseOpacity.rgb);
	m.Opacity = baseOpacity.a;

	vec4 normalW = texture2D(texNormalW,
		uv
		);

	vec3 normalTS = normalW.rgb * 2.0 - 1.0;
	float normalLength = length(normalTS);
	m.Normal = normalize(TBN * normalTS);

	if (isRoughness == 1.0)
	{
		m.Roughness = mix(0.1, 0.9, normalW.a);
		m.Smoothness = 1.0 - m.Roughness;
	}
	else
	{
		m.Smoothness = mix(0.1, 0.9, normalW.a);
		m.Roughness = 1.0 - m.Smoothness;
	}

	float variance = 1.0 - normalLength;
	m.Roughness = sqrt(m.Roughness * m.Roughness + variance * variance);
	m.Smoothness = 1.0 - m.Roughness;

	m.Metallic = 0.0;
	m.AO = 1.0;
	m.Specular = BBMOD_F0_DEFAULT;

	return m;
}
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

		material.Normal        *= layerStrengthInv;
		material.Metallic      *= layerStrengthInv;
		material.Roughness     *= layerStrengthInv;
		material.Specular      *= layerStrengthInv;
		material.Smoothness    *= layerStrengthInv;
		material.SpecularPower *= layerStrengthInv;
		material.AO            *= layerStrengthInv;

		material.Lightmap      *= layerStrengthInv;

		material.Normal        += layerStrength * material1.Normal;
		material.Metallic      += layerStrength * material1.Metallic;
		material.Roughness     += layerStrength * material1.Roughness;
		material.Specular      += layerStrength * material1.Specular;
		material.Smoothness    += layerStrength * material1.Smoothness;
		material.SpecularPower += layerStrength * material1.SpecularPower;
		material.AO            += layerStrength * material1.AO;

		material.Lightmap      += layerStrength * material1.Lightmap;
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

		material.Normal        *= layerStrengthInv;
		material.Metallic      *= layerStrengthInv;
		material.Roughness     *= layerStrengthInv;
		material.Specular      *= layerStrengthInv;
		material.Smoothness    *= layerStrengthInv;
		material.SpecularPower *= layerStrengthInv;
		material.AO            *= layerStrengthInv;

		material.Lightmap      *= layerStrengthInv;

		material.Normal        += layerStrength * material2.Normal;
		material.Metallic      += layerStrength * material2.Metallic;
		material.Roughness     += layerStrength * material2.Roughness;
		material.Specular      += layerStrength * material2.Specular;
		material.Smoothness    += layerStrength * material2.Smoothness;
		material.SpecularPower += layerStrength * material2.SpecularPower;
		material.AO            += layerStrength * material2.AO;

		material.Lightmap      += layerStrength * material2.Lightmap;
	}

	// Colormap
	material.Base *= BBMOD_GammaToLinear(
		texture2D(bbmod_Colormap, v_vSplatmapCoord).xyz);

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}

	BBMOD_ApplyDistanceDither(v_fDitherSeed, v_fDitherFadeMultiplier);

	gl_FragData[0] = vec4(
		BBMOD_LinearToGamma(mix(material.Base, material.Specular, material.Metallic)),
		material.AO);

	gl_FragData[1] = vec4(material.Normal * 0.5 + 0.5, material.Roughness);

	gl_FragData[2] = vec4(
		BBMOD_EncodeDepth(v_vPosition.z / bbmod_ZFar),
		material.Metallic);

	gl_FragData[3] = vec4(0.0, 0.0, 0.0, 1.0);

}
// @endinclude
