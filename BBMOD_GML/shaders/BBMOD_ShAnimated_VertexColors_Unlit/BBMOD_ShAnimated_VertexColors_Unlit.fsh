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

varying vec3 v_vVertex;

varying vec4 v_vColor;

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying vec4 v_vPosition;

varying vec4 v_vPosShadowmap;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

////////////////////////////////////////////////////////////////////////////////
// Material

// Material index
// uniform float bbmod_MaterialIndex;

// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture

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

// RGB: Subsurface color, A: Intensity
uniform sampler2D bbmod_Subsurface;
// RGBA: RGBM encoded emissive color
uniform sampler2D bbmod_Emissive;

// If 1.0 then normal is flipped before shading of backfaces
uniform float bbmod_TwoSided;

// Pixels with alpha less than this value will be discarded
uniform float bbmod_AlphaTest;

////////////////////////////////////////////////////////////////////////////////
// Dithered transparency

// Distance at which dithered fade starts (0 = disabled)
uniform float bbmod_DitherFadeStart;
// Distance at which dithered fade ends (fully transparent)
uniform float bbmod_DitherFadeEnd;

////////////////////////////////////////////////////////////////////////////////
// Camera

// Camera's position in world space
#define BBMOD_CAMPOS_DECLARED
uniform vec3 bbmod_CamPos;
// Distance to the far clipping plane
uniform float bbmod_ZFar;
// Camera's exposure value
uniform float bbmod_Exposure;

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
// Sun/moon disk angular size in radians (diameter). 0 = point light.
uniform float bbmod_LightDirectionalDiskSize;

// Cloud shadow: world-space XY centre and size of the cloud shadow map.
// The shadow transmittance is packed into bbmod_Shadowmap.a, sampled at
// a cloud-shadow UV independent of the depth UV stored in .rgb.
uniform vec2  bbmod_CloudShadowPos;
uniform float bbmod_CloudShadowSize;

////////////////////////////////////////////////////////////////////////////////
// HDR rendering

// 0.0 = apply exposure, tonemap and gamma correct, 1.0 = output raw values
uniform float bbmod_HDR;

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

// Exponential height fog density at the fog base height.
uniform float bbmod_FogDensity;
// Exponential height falloff (0 = uniform fog at all altitudes).
uniform float bbmod_FogFalloff;
// World Z of the fog baseline. Fog density is full at or below this height.
uniform float bbmod_FogHeight;
// Aerial perspective: how brightly the sun tints forward-scattered fog.
uniform float bbmod_FogAerialIntensity;
// Camera world-space position (declared here only for shaders that don't
// include Uber_PS.xsh, e.g. BBMOD_ShSprite_Forward).
#ifndef BBMOD_CAMPOS_DECLARED
#define BBMOD_CAMPOS_DECLARED
uniform vec3 bbmod_CamPos;
#endif

void Fog(float depth)
{
	vec3 ambientUp   = xGammaToLinear(bbmod_LightAmbientUp.rgb)   * bbmod_LightAmbientUp.a;
	vec3 ambientDown = xGammaToLinear(bbmod_LightAmbientDown.rgb) * bbmod_LightAmbientDown.a;
	vec3 sunColor    = xGammaToLinear(bbmod_LightDirectionalColor.rgb) * bbmod_LightDirectionalColor.a;
	vec3 fogBase     = xGammaToLinear(bbmod_FogColor.rgb) * (ambientUp + ambientDown + sunColor);

	// Aerial perspective: forward-scattered sun glow in the fog.
	vec3  viewDir  = normalize(v_vVertex - bbmod_CamPos);
	float cosTheta = dot(viewDir, -normalize(bbmod_LightDirectionalDir));
	float sunGlow  = max(0.0, cosTheta);
	sunGlow = sunGlow * sunGlow * sunGlow * sunGlow;
	vec3 fogColor  = fogBase + sunColor * sunGlow * bbmod_FogAerialIntensity;

	// Analytical exponential height fog.
	float camH  = max(bbmod_CamPos.z - bbmod_FogHeight, 0.0);
	float fragH = max(v_vVertex.z    - bbmod_FogHeight, 0.0);
	float e0 = exp(-bbmod_FogFalloff * camH);
	float e1 = exp(-bbmod_FogFalloff * fragH);
	float dh = v_vVertex.z - bbmod_CamPos.z;

	float integral;
	if (abs(dh) > 0.01 && bbmod_FogFalloff > 0.0001)
	{
		integral = bbmod_FogDensity * depth * abs(e0 - e1) / (bbmod_FogFalloff * abs(dh));
	}
	else
	{
		integral = bbmod_FogDensity * (bbmod_FogFalloff > 0.0001 ? e0 : 1.0) * depth;
	}

	integral *= clamp((depth - bbmod_FogStart) * bbmod_FogRcpRange, 0.0, 1.0);

	float fogAmount = clamp(1.0 - exp(-integral), 0.0, 1.0) * bbmod_FogColor.a * bbmod_FogIntensity;
	gl_FragColor.rgb = mix(gl_FragColor.rgb, fogColor, fogAmount);
}
void Exposure()
{
	gl_FragColor.rgb *= bbmod_Exposure * bbmod_Exposure;
}
void TonemapReinhard()
{
	gl_FragColor.rgb = gl_FragColor.rgb / (vec3(1.0) + gl_FragColor.rgb);
}

void GammaCorrect()
{
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
}
struct Material
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
	vec3 Emissive;
	vec4 Subsurface;
	vec3 Lightmap;
};

Material CreateMaterial()
{
	Material m;
	m.Base = vec3(1.0);
	m.Opacity = 1.0;
	m.Normal = vec3(0.0, 0.0, 1.0);
	m.Metallic = 0.0;
	m.Roughness = 1.0;
	m.Specular = vec3(0.0);
	m.Smoothness = 0.0;
	m.SpecularPower = 1.0;
	m.AO = 1.0;
	m.Emissive = vec3(0.0);
	m.Subsurface = vec4(0.0);
	m.Lightmap = vec3(0.0);
	return m;
}
#define F0_DEFAULT vec3(0.04)
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

/// @desc Unpacks material from textures.
/// @param texBaseOpacity RGB: base color, A: opacity
/// @param isRoughness
/// @param texNormalW
/// @param isMetallic
/// @param texMaterial
/// @param texSubsurface  RGB: subsurface color, A: intensity
/// @param texEmissive    RGBA: RGBM encoded emissive color
/// @param texLightmap    RGBA: RGBM encoded lightmap
/// @param uvLightmap     Lightmap texture coordinates
/// @param TBN            Tangent-bitangent-normal matrix
/// @param uv             Texture coordinates
Material UnpackMaterial(
	sampler2D texBaseOpacity,
	float isRoughness,
	sampler2D texNormalW,
	float isMetallic,
	sampler2D texMaterial,
	sampler2D texSubsurface,
	sampler2D texEmissive,
	mat3 TBN,
	vec2 uv)
{
	Material m = CreateMaterial();

	// Base color and opacity
	vec4 baseOpacity = texture2D(texBaseOpacity, uv);
	m.Base = xGammaToLinear(baseOpacity.rgb);
	m.Opacity = baseOpacity.a;

	// Normal vector and smoothness/roughness
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

	// Toksvig specular anti-aliasing
	float variance = 1.0 - normalLength;
	m.Roughness = sqrt(m.Roughness * m.Roughness + variance * variance);
	m.Smoothness = 1.0 - m.Roughness;

	// Material properties
	vec4 materialProps = texture2D(texMaterial,
		uv
		);

	if (isMetallic == 1.0)
	{
		m.Metallic = materialProps.r;
		m.AO = materialProps.g;
		m.Specular = mix(F0_DEFAULT, m.Base, m.Metallic);
		m.Base *= (1.0 - m.Metallic);
	}
	else
	{
		m.Specular = materialProps.rgb;
		m.SpecularPower = exp2(1.0 + (m.Smoothness * 10.0));
	}

	// Subsurface (color and intensity)
	vec4 subsurface = texture2D(texSubsurface,
		uv
	);
	m.Subsurface = vec4(xGammaToLinear(subsurface.rgb).rgb, subsurface.a);

	// Emissive color
	m.Emissive = xGammaToLinear(xDecodeRGBM(texture2D(texEmissive,
		uv
	)));

	return m;
}

void UnlitShader(Material material, float depth)
{
	gl_FragColor.rgb = material.Base;
	gl_FragColor.rgb += material.Emissive;
	gl_FragColor.a = material.Opacity;
	// Soft particles
	Fog(depth);

	if (bbmod_HDR == 0.0)
	{
		Exposure();
		TonemapReinhard();
		GammaCorrect();
	}
}

////////////////////////////////////////////////////////////////////////////////
//
// Dithering
//

/// @desc Generate 4x4 Bayer matrix threshold value for screen-space dithering
/// @param screenPos Fragment position in screen space (gl_FragCoord.xy)
/// @return Threshold value in range [0, 1]
float BayerDither4x4(vec2 screenPos)
{
	// Use modulo to get position within 4x4 tile
	vec2 pos = mod(screenPos, 4.0);
	int x = int(pos.x);
	int y = int(pos.y);

	// 4x4 Bayer matrix values (compatible across all GLSL versions)
	// Using if-else chain instead of array indexing for maximum compatibility
	float value = 0.0;

	if (y == 0)
	{
		if (x == 0)      value = 0.0;
		else if (x == 1) value = 8.0;
		else if (x == 2) value = 2.0;
		else             value = 10.0;
	}
	else if (y == 1)
	{
		if (x == 0)      value = 12.0;
		else if (x == 1) value = 4.0;
		else if (x == 2) value = 14.0;
		else             value = 6.0;
	}
	else if (y == 2)
	{
		if (x == 0)      value = 3.0;
		else if (x == 1) value = 11.0;
		else if (x == 2) value = 1.0;
		else             value = 9.0;
	}
	else // y == 3
	{
		if (x == 0)      value = 15.0;
		else if (x == 1) value = 7.0;
		else if (x == 2) value = 13.0;
		else             value = 5.0;
	}

	return value / 16.0;
}

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
		bbmod_Subsurface,
		bbmod_Emissive,
		v_mTBN,
		v_vTexCoord);

	material.Base *= v_vColor.rgb;
	material.Opacity *= v_vColor.a;

	material.Base *= xGammaToLinear(bbmod_BaseOpacityMultiplier.rgb);
	material.Opacity *= bbmod_BaseOpacityMultiplier.a;

	// Apply distance-based dithered transparency
	float finalOpacity = material.Opacity;
	if (bbmod_DitherFadeStart >= 0.0 && bbmod_DitherFadeEnd > bbmod_DitherFadeStart)
	{
		// Use view-space depth for distance-based fading
		float distance = v_vPosition.z;

		// Map distance to fade range [0, 1]
		float fadeRange = bbmod_DitherFadeEnd - bbmod_DitherFadeStart;
		float fadeAmount = clamp((distance - bbmod_DitherFadeStart) / fadeRange, 0.0, 1.0);

		// Apply fade to opacity
		finalOpacity *= (1.0 - fadeAmount);

		// Get dither threshold for this pixel
		float ditherThreshold = BayerDither4x4(gl_FragCoord.xy);

		// Discard pixel if opacity is below or equal to dither threshold
		if (finalOpacity <= ditherThreshold)
		{
			discard;
		}
	}

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}

	UnlitShader(material, v_vPosition.z);
}
