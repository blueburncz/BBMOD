// @define BBMOD_COLOR
// @define BBMOD_BATCHED
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

// RGB: Base color, A: Opacity.
#define bbmod_BaseOpacity gm_BaseTexture

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

// 1.0 to flip the normal before shading backfaces.
uniform float bbmod_TwoSided;

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

varying vec4 v_vColor;

varying vec2 v_vTexCoord;

varying mat3 v_mTBN;
varying vec4 v_vPosition;
varying float v_fDitherSeed;
varying float v_fDitherFadeMultiplier;

varying vec4 v_vPosShadowmap;
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
/// @desc Converts gamma space color to linear space.
/// @param rgb Color in gamma space.
/// @return Color in linear space.
vec3 BBMOD_GammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(2.2));
}
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
/// @param isMetallic 1.0 for metallic workflow, 0.0 for specular workflow.
/// @param texMaterial Metallic: R=metallic, G=AO. Specular: RGB=specular.
/// @param TBN Tangent-bitangent-normal matrix.
/// @param uv Texture coordinates.
/// @return Unpacked material.
BBMOD_Material BBMOD_UnpackMaterial(
	sampler2D texBaseOpacity,
	float isRoughness,
	sampler2D texNormalW,
	float isMetallic,
	sampler2D texMaterial,
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

	if (bbmod_TwoSided == 1.0 && !gl_FrontFacing)
	{
		TBN[2] *= -1.0;
	}

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

	vec4 materialProps = texture2D(texMaterial,
		uv
		);
	if (isMetallic == 1.0)
	{
		m.Metallic = materialProps.r;
		m.AO = materialProps.g;
		m.Specular = mix(BBMOD_F0_DEFAULT, m.Base, m.Metallic);
		m.Base *= (1.0 - m.Metallic);
	}
	else
	{
		m.Specular = materialProps.rgb;
		m.SpecularPower = exp2(1.0 + (m.Smoothness * 10.0));
	}

	return m;
}
/// @desc Applies fog effect to a color based on depth.
/// @param color The input color to apply fog to.
/// @param depth The depth value (typically from v_vPosition.z).
/// @return Color with fog applied.
/// @note Requires uniforms: bbmod_FogColor, bbmod_FogIntensity, bbmod_FogStart, bbmod_FogRcpRange,
///       bbmod_LightAmbientUp, bbmod_LightAmbientDown, bbmod_LightDirectionalColor.
vec3 BBMOD_Fog(vec3 color, float depth)
{
	vec3 ambientUp = BBMOD_GammaToLinear(bbmod_LightAmbientUp.rgb) * bbmod_LightAmbientUp.a;
	vec3 ambientDown = BBMOD_GammaToLinear(bbmod_LightAmbientDown.rgb) * bbmod_LightAmbientDown.a;
	vec3 directionalLightColor = BBMOD_GammaToLinear(bbmod_LightDirectionalColor.rgb) * bbmod_LightDirectionalColor.a;
	vec3 fogColor = BBMOD_GammaToLinear(bbmod_FogColor.rgb) * (ambientUp + ambientDown + directionalLightColor);
	float fogStrength = clamp((depth - bbmod_FogStart) * bbmod_FogRcpRange, 0.0, 1.0) * bbmod_FogColor.a;
	return mix(color, fogColor, fogStrength * bbmod_FogIntensity);
}
/// @desc Applies camera exposure to a color.
/// @param color The input color.
/// @return Color with exposure applied.
/// @note Requires uniform: bbmod_Exposure.
vec3 BBMOD_Exposure(vec3 color)
{
	return color * bbmod_Exposure * bbmod_Exposure;
}
/// @desc Applies Reinhard tonemapping to a color.
/// @param color The input color in HDR.
/// @return Tonemapped color in LDR.
vec3 BBMOD_TonemapReinhard(vec3 color)
{
	return color / (vec3(1.0) + color);
}
/// @desc Converts linear space color to gamma space.
/// @param rgb Color in linear space.
/// @return Color in gamma space.
vec3 BBMOD_LinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / 2.2));
}

/// @desc Converts a linear-space color to gamma space (gamma correction).
/// @param color Input color in linear space.
/// @return Color in gamma space.
vec3 BBMOD_GammaCorrect(vec3 color)
{
	return BBMOD_LinearToGamma(color);
}
/// @desc Decodes a linearized depth value from RGB channels.
/// @param c Encoded depth as RGB.
/// @return Decoded linearized depth (0..1 range).
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float BBMOD_DecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}
/// @desc Gets screen-space UV coordinates for a clip-space point.
/// @param p A point in clip space (transformed by projection matrix, not
///          normalized).
/// @return UV coordinates on the screen.
vec2 BBMOD_Unproject(vec4 p)
{
	vec2 uv = p.xy / p.w;
	uv = uv * 0.5 + 0.5;
#if defined(_YY_HLSL11_) || defined(_YY_PSSL_)
	uv.y = 1.0 - uv.y;
#endif
	return uv;
}

/// @desc Unlit shading pass. Writes the final color to gl_FragColor.
/// Requires uniforms: bbmod_HDR, bbmod_ZFar,
///   bbmod_FogColor, bbmod_FogIntensity, bbmod_FogStart, bbmod_FogRcpRange,
///   bbmod_LightAmbientUp, bbmod_LightAmbientDown, bbmod_LightDirectionalColor.
/// @param material Unpacked material properties.
/// @param depth View-space depth of the fragment.
void BBMOD_UnlitShader(BBMOD_Material material, float depth)
{
	gl_FragColor.rgb = material.Base;

	gl_FragColor.a = material.Opacity;

	gl_FragColor.rgb = BBMOD_Fog(gl_FragColor.rgb, depth);

	if (bbmod_HDR == 0.0)
	{
		gl_FragColor.rgb = BBMOD_Exposure(gl_FragColor.rgb);
		gl_FragColor.rgb = BBMOD_TonemapReinhard(gl_FragColor.rgb);
		gl_FragColor.rgb = BBMOD_GammaCorrect(gl_FragColor.rgb);
	}
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
	// Non-terrain

	BBMOD_Material material = BBMOD_UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_IsRoughness,
		bbmod_NormalW,
		bbmod_IsMetallic,
		bbmod_Material,

		v_mTBN,
		v_vTexCoord);

	material.Base    *= v_vColor.rgb;
	material.Opacity *= v_vColor.a;

	material.Base    *= BBMOD_GammaToLinear(bbmod_BaseOpacityMultiplier.rgb);
	material.Opacity *= bbmod_BaseOpacityMultiplier.a;

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}

	BBMOD_ApplyDistanceDither(v_fDitherSeed, v_fDitherFadeMultiplier);

	BBMOD_UnlitShader(material, v_vPosition.z);

}
// @endinclude
