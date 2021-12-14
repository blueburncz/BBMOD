#pragma include("Uber_PS.xsh", "glsl")
////////////////////////////////////////////////////////////////////////////////
// Varyings
varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;

varying vec3 v_vLight;

////////////////////////////////////////////////////////////////////////////////
// Uniforms

// Pixels with alpha less than this value will be discarded.
uniform float bbmod_AlphaTest;

// Camera's position in world space
uniform vec3 bbmod_CamPos;

// Distance to the far clipping plane.
uniform float bbmod_ZFar;

// Camera's exposure value
uniform float bbmod_Exposure;

// The color of the fog.
uniform vec4 bbmod_FogColor;

// Maximum fog intensity.
uniform float bbmod_FogIntensity;

// Distance at which the fog starts.
uniform float bbmod_FogStart;

// 1.0 / (fogEnd - fogStart)
uniform float bbmod_FogRcpRange;

// RGBM encoded ambient light color on the upper hemisphere.
uniform vec4 bbmod_LightAmbientUp;

/// RGBM encoded ambient light color on the lower hemisphere.
uniform vec4 bbmod_LightAmbientDown;

// Direction of the directional light
uniform vec3 bbmod_LightDirectionalDir;

// RGBM encoded color of the directional light
uniform vec4 bbmod_LightDirectionalColor;

// Shadowmap texture
uniform sampler2D bbmod_Shadowmap;

// WORLD_VIEW_PROJECTION matrix used when rendering shadowmap
uniform mat4 bbmod_ShadowmapMatrix;

// (1.0/shadowmapWidth, 1.0/shadowmapHeight)
uniform vec2 bbmod_ShadowmapTexel;

// The area that the shadowmap captures.
uniform float bbmod_ShadowmapArea;

// Offsets vertex position by its normal scaled by this value.
uniform float bbmod_ShadowmapNormalOffset;

////////////////////////////////////////////////////////////////////////////////
// Includes
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

/// @param d Linearized depth to encode.
/// @return Encoded depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
vec3 xEncodeDepth(float d)
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

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}


/// @source https://iquilezles.org/www/articles/hwinterpolation/hwinterpolation.htm
float xShadowMapCompare(sampler2D shadowMap, vec2 texel, vec2 uv, float compareZ)
{
	if (uv.x < 0.0 || uv.y < 0.0
		|| uv.x > 1.0 || uv.y > 1.0)
	{
		return 0.0;
	}
	vec2 res = 1.0 / texel;
	vec2 st = uv*res - 0.5;
	vec2 iuv = floor(st);
	vec2 fuv = fract(st);
	vec3 s = texture2D(shadowMap, (iuv + vec2(0.5, 0.5)) / res).rgb;
	if (s == vec3(1.0, 0.0, 0.0))
	{
		return 0.0;
	}
	float a = step(xDecodeDepth(s), compareZ);
	float b = step(xDecodeDepth(texture2D(shadowMap, (iuv + vec2(1.5, 0.5)) / res).rgb), compareZ);
	float c = step(xDecodeDepth(texture2D(shadowMap, (iuv + vec2(0.5, 1.5)) / res).rgb), compareZ);
	float d = step(xDecodeDepth(texture2D(shadowMap, (iuv + vec2(1.5, 1.5)) / res).rgb), compareZ);
	return mix(
		mix(a, b, fuv.x),
		mix(c, d, fuv.x),
		fuv.y);
}

/// @source https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping
float xShadowMapPCF(sampler2D shadowMap, vec2 texel, vec2 uv, float compareZ)
{
	const float size = 2.0;
	const float sampleCount = (size * 2.0 + 1.0) * (size * 2.0 + 1.0);
	float shadow = 0.0;
	for (float x = -size; x <= size; x += 1.0)
	{
		for (float y = -size; y <= size; y += 1.0)
		{
			vec2 uv2 = uv + vec2(x, y) * texel;
			shadow += xShadowMapCompare(shadowMap, texel, uv2, compareZ);
		}
	}
	shadow /= sampleCount;
	return shadow;
}

////////////////////////////////////////////////////////////////////////////////
// Main
void main()
{
	vec4 baseOpacity = texture2D(gm_BaseTexture, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor.a = baseOpacity.a;

	vec3 N = normalize(v_mTBN[2]);
	vec3 lightDiffuse = v_vLight;

	// Ambient light
	vec3 ambientUp = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientUp));
	vec3 ambientDown = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientDown));
	lightDiffuse += mix(ambientDown, ambientUp, N.z * 0.5 + 0.5);
	// Shadow mapping
	vec3 posShadowMap = (bbmod_ShadowmapMatrix * vec4(v_vVertex + N * bbmod_ShadowmapNormalOffset, 1.0)).xyz;
	posShadowMap.xy = posShadowMap.xy * 0.5 + 0.5;
	posShadowMap.y = 1.0 - posShadowMap.y;
	posShadowMap.z /= bbmod_ShadowmapArea;
	float shadow = xShadowMapPCF(bbmod_Shadowmap, bbmod_ShadowmapTexel, posShadowMap.xy, posShadowMap.z);
	// Directional light
	vec3 L = normalize(-bbmod_LightDirectionalDir);
	float NdotL = max(dot(N, L), 0.0);
	lightDiffuse += xGammaToLinear(xDecodeRGBM(bbmod_LightDirectionalColor)) * NdotL * (1.0 - shadow);
	// Diffuse
	gl_FragColor.rgb = xGammaToLinear(baseOpacity.rgb) * lightDiffuse;
	// Fog
	vec3 fogColor = xGammaToLinear(xDecodeRGBM(bbmod_FogColor));
	float fogStrength = clamp((v_fDepth - bbmod_FogStart) * bbmod_FogRcpRange, 0.0, 1.0);
	gl_FragColor.rgb = mix(gl_FragColor.rgb, fogColor, fogStrength * bbmod_FogIntensity);
	// Exposure
	gl_FragColor.rgb = vec3(1.0) - exp(-gl_FragColor.rgb * bbmod_Exposure);
	// Gamma correction
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
}
// include("Uber_PS.xsh")
