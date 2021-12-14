////////////////////////////////////////////////////////////////////////////////
// Varyings
varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;

#if !OUTPUT_DEPTH && !PBR
varying vec3 v_vLight;
#endif

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

#if PBR
// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture

// RGB: Tangent space normal, A: Roughness
uniform sampler2D bbmod_NormalRoughness;

// R: Metallic, G: Ambient occlusion
uniform sampler2D bbmod_MetallicAO;

// RGB: Subsurface color, A: Intensity
uniform sampler2D bbmod_Subsurface;

// RGBM encoded emissive color
uniform sampler2D bbmod_Emissive;

// Prefiltered octahedron env. map
uniform sampler2D bbmod_IBL;

// Texel size of one octahedron.
uniform vec2 bbmod_IBLTexel;
#else
// The color of the fog.
uniform vec4 bbmod_FogColor;

// Maximum fog intensity.
uniform float bbmod_FogIntensity;

// Distance at which the fog starts.
uniform float bbmod_FogStart;

// 1.0 / (fogEnd - fogStart)
uniform float bbmod_FogRcpRange;
#endif

#if !PBR
// RGBM encoded ambient light color on the upper hemisphere.
uniform vec4 bbmod_LightAmbientUp;

/// RGBM encoded ambient light color on the lower hemisphere.
uniform vec4 bbmod_LightAmbientDown;

// Direction of the directional light
uniform vec3 bbmod_LightDirectionalDir;

// RGBM encoded color of the directional light
uniform vec4 bbmod_LightDirectionalColor;

// Shadowmap texture
uniform Texture2D bbmod_Shadowmap;

// WORLD_VIEW_PROJECTION matrix used when rendering shadowmap
uniform Mat4 bbmod_ShadowmapMatrix;

// (1.0/shadowmapWidth, 1.0/shadowmapHeight)
uniform Vec2 bbmod_ShadowmapTexel;

// The area that the shadowmap captures.
uniform float bbmod_ShadowmapArea;

// Offsets vertex position by its normal scaled by this value.
uniform float bbmod_ShadowmapNormalOffset;
#endif

////////////////////////////////////////////////////////////////////////////////
// Includes
#pragma include("Color.xsh", "glsl")

#pragma include("RGBM.xsh", "glsl")

#if !PBR
#pragma include("DepthEncoding.xsh")
#endif

#if PBR
#pragma include("BRDF.xsh", "glsl")

#pragma include("OctahedronMapping.xsh", "glsl")

#pragma include("IBL.xsh")

#pragma include("CheapSubsurface.xsh", "glsl")

#pragma include("Material.xsh", "glsl")
#endif

#if !OUTPUT_DEPTH && !PBR
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
#endif

////////////////////////////////////////////////////////////////////////////////
// Main
void main()
{
#if OUTPUT_DEPTH
	Vec4 baseOpacity = Sample(gm_BaseTexture, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor.rgb = xEncodeDepth(v_fDepth / bbmod_ZFar);
	gl_FragColor.a = 1.0;
#else
#if PBR
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_NormalRoughness,
		bbmod_MetallicAO,
		bbmod_Subsurface,
		bbmod_Emissive,
		v_mTBN,
		v_vTexCoord);

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor.a = material.Opacity;

	vec3 N = material.Normal;
	vec3 V = normalize(bbmod_CamPos - v_vVertex);
	vec3 lightColor = xDiffuseIBL(bbmod_IBL, bbmod_IBLTexel, N);

	// Diffuse
	gl_FragColor.rgb = material.Base * lightColor;
	// Specular
	gl_FragColor.rgb += xSpecularIBL(bbmod_IBL, bbmod_IBLTexel, material.Specular, material.Roughness, N, V);
	// Ambient occlusion
	gl_FragColor.rgb *= material.AO;
	// Emissive
	gl_FragColor.rgb += material.Emissive;
	// Subsurface scattering
	gl_FragColor.rgb += xCheapSubsurface(material.Subsurface, -V, N, N, lightColor);
#else
	Vec4 baseOpacity = Sample(gm_BaseTexture, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor.a = baseOpacity.a;

	vec3 N = normalize(v_mTBN[2]);
	vec3 lightDiffuse = v_vLight;

	// Ambient light
	Vec3 ambientUp = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientUp));
	Vec3 ambientDown = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientDown));
	lightDiffuse += mix(ambientDown, ambientUp, N.z * 0.5 + 0.5);
	// Shadow mapping
	Vec3 posShadowMap = (bbmod_ShadowmapMatrix * vec4(v_vVertex + N * bbmod_ShadowmapNormalOffset, 1.0)).xyz;
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
#endif
	// Exposure
	gl_FragColor.rgb = vec3(1.0) - exp(-gl_FragColor.rgb * bbmod_Exposure);
	// Gamma correction
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
#endif
}
