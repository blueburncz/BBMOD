// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Defines
//

#if defined(X_2D)
// Maximum number of point lights
#define MAX_POINT_LIGHTS 8
#endif

#if !defined(X_OUTPUT_DEPTH) && !defined(X_PBR) && !defined(X_2D)
// Number of samples used when computing shadows
#define SHADOWMAP_SAMPLE_COUNT 12
#endif

////////////////////////////////////////////////////////////////////////////////
//
// Varyings
//
varying vec3 v_vVertex;

#if defined(X_2D)
varying vec4 v_vColor;
#endif

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;

#if !defined(X_OUTPUT_DEPTH) && !defined(X_PBR) && !defined(X_2D)
varying vec3 v_vLight;
varying vec3 v_vPosShadowmap;
#if defined(X_TERRAIN)
varying vec2 v_vSplatmapCoord;
#endif
#endif

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

////////////////////////////////////////////////////////////////////////////////
// Material

// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture
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

#if defined(X_PBR)
////////////////////////////////////////////////////////////////////////////////
// Image based lighting

// Prefiltered octahedron env. map
uniform sampler2D bbmod_IBL;
// Texel size of one octahedron
uniform vec2 bbmod_IBLTexel;
#endif

#if !defined(X_PBR) && !defined(X_OUTPUT_DEPTH)
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

#if defined(X_2D)
////////////////////////////////////////////////////////////////////////////////
// Point lights

// [(x, y, z, range), (r, g, b, m), ...]
uniform vec4 bbmod_LightPointData[2 * MAX_POINT_LIGHTS];
#endif

////////////////////////////////////////////////////////////////////////////////
// Terrain
#if defined(X_TERRAIN)
// Splatmap texture
uniform sampler2D bbmod_Splatmap;
// Splatmap channel to read. Use -1 for none.
uniform int bbmod_SplatmapIndex;
#endif

////////////////////////////////////////////////////////////////////////////////
// Shadow mapping

// 1.0 to enable shadows
uniform float bbmod_ShadowmapEnablePS;
// Shadowmap texture
uniform sampler2D bbmod_Shadowmap;
// (1.0/shadowmapWidth, 1.0/shadowmapHeight)
uniform vec2 bbmod_ShadowmapTexel;
#endif

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
#if !defined(X_OUTPUT_DEPTH)
#pragma include("Color.xsh", "glsl")

#pragma include("RGBM.xsh", "glsl")
#endif

#if !defined(X_PBR)
#pragma include("DepthEncoding.xsh")
#endif

#if defined(X_PBR)
#pragma include("BRDF.xsh", "glsl")

#pragma include("OctahedronMapping.xsh", "glsl")

#pragma include("IBL.xsh")

#pragma include("CheapSubsurface.xsh", "glsl")

#pragma include("MetallicRoughnessMaterial.xsh", "glsl")
#endif

#if !defined(X_PBR) && !defined(X_OUTPUT_DEPTH)
#pragma include("SpecularColorSmoothnessMaterial.xsh", "glsl")
#endif

#if !defined(X_OUTPUT_DEPTH) && !defined(X_PBR) && !defined(X_2D)
// Shadowmap filtering source: https://www.gamedev.net/tutorials/programming/graphics/contact-hardening-soft-shadows-made-fast-r4906/
float InterleavedGradientNoise(vec2 positionScreen)
{
	vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
	return fract(magic.z * fract(dot(positionScreen, magic.xy)));
}

vec2 VogelDiskSample(int sampleIndex, int samplesCount, float phi)
{
	float GoldenAngle = 2.4;
	float r = sqrt(float(sampleIndex) + 0.5) / sqrt(float(samplesCount));
	float theta = float(sampleIndex) * GoldenAngle + phi;
	float sine = sin(theta);
	float cosine = cos(theta);
	return vec2(r * cosine, r * sine);
}

float ShadowMap(sampler2D shadowMap, vec2 texel, vec2 uv, float compareZ)
{
	if (clamp(uv.xy, vec2(0.0), vec2(1.0)) != uv.xy)
	{
		return 0.0;
	}
	float shadow = 0.0;
	float noise = 6.28 * InterleavedGradientNoise(gl_FragCoord.xy);
	for (int i = 0; i < SHADOWMAP_SAMPLE_COUNT; ++i)
	{
		vec2 uv2 = uv + VogelDiskSample(i, SHADOWMAP_SAMPLE_COUNT, noise) * texel * 4.0;
		shadow += step(xDecodeDepth(texture2D(shadowMap, uv2).rgb), compareZ);
	}
	return (shadow / float(SHADOWMAP_SAMPLE_COUNT));
}
#endif

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
#if defined(X_OUTPUT_DEPTH)
	Vec4 baseOpacity = texture2D(bbmod_BaseOpacity, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor.rgb = xEncodeDepth(v_fDepth / bbmod_ZFar);
	gl_FragColor.a = 1.0;
#else // X_OUTPUT_DEPTH
#if defined(X_PBR)
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
#else // X_PBR
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_NormalSmoothness,
		bbmod_SpecularColor,
		v_mTBN,
		v_vTexCoord);

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

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor.a = material.Opacity;

	vec3 N = material.Normal;
#if defined(X_2D)
	vec3 lightDiffuse = vec3(0.0);
#else
	vec3 lightDiffuse = v_vLight;
#endif
	vec3 lightSpecular = vec3(0.0);

	// Ambient light
	vec3 ambientUp = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientUp));
	vec3 ambientDown = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientDown));
	lightDiffuse += mix(ambientDown, ambientUp, N.z * 0.5 + 0.5);
	// Shadow mapping
	float shadow = 0.0;
#if !defined(X_2D)
	if (bbmod_ShadowmapEnablePS == 1.0)
	{
		shadow = ShadowMap(bbmod_Shadowmap, bbmod_ShadowmapTexel, v_vPosShadowmap.xy, v_vPosShadowmap.z);
	}
#endif
	// Directional light
	vec3 L = normalize(-bbmod_LightDirectionalDir);
	float NdotL = max(dot(N, L), 0.0);
	float specularPower = exp2(1.0 + (material.Smoothness * 10.0));
#if defined(X_2D)
	vec3 V = vec3(0.0, 0.0, 1.0);
#else
	vec3 V = normalize(bbmod_CamPos - v_vVertex);
#endif
	vec3 f0 = material.Specular;
	vec3 H = normalize(L + V);
	float NdotH = max(dot(N, H), 0.0);
	float VdotH = max(dot(V, H), 0.0);
	vec3 fresnel = f0 + (1.0 - f0) * pow(1.0 - VdotH, 5.0);
	float visibility = 0.25;
	float A = specularPower / log(2.0);
	float blinnPhong = exp2(A * NdotH - A);
	float blinnNormalization = (specularPower + 8.0) / 8.0;
	float normalDistribution = blinnPhong * blinnNormalization;
	vec3 directionalLightColor = xGammaToLinear(xDecodeRGBM(bbmod_LightDirectionalColor));
	vec3 lightColor = directionalLightColor * NdotL * (1.0 - shadow);
	lightSpecular += lightColor * fresnel * visibility * normalDistribution;
	lightDiffuse += lightColor; // * (1.0 - fresnel);
#if defined(X_2D)
	// Point lights
	for (int i = 0; i < MAX_POINT_LIGHTS; ++i)
	{
		Vec4 positionRange = bbmod_LightPointData[i * 2];
		L = positionRange.xyz - v_vVertex;
		H = normalize(L + V);
		NdotH = max(dot(N, H), 0.0);
		VdotH = max(dot(V, H), 0.0);
		fresnel = f0 + (1.0 - f0) * pow(1.0 - VdotH, 5.0);
		float dist = length(L);
		float att = clamp(1.0 - (dist / positionRange.w), 0.0, 1.0);
		NdotL = max(dot(N, normalize(L)), 0.0);
		lightColor = xGammaToLinear(xDecodeRGBM(bbmod_LightPointData[(i * 2) + 1])) * NdotL * att;
		lightSpecular += lightColor * fresnel * visibility * normalDistribution;
		lightDiffuse += lightColor; // * (1.0 - fresnel);
	}
#endif // X_2D
	// Diffuse
	gl_FragColor.rgb = material.Base * lightDiffuse;
	// Specular
	gl_FragColor.rgb += lightSpecular;
	// Fog
	vec3 fogColor = xGammaToLinear(xDecodeRGBM(bbmod_FogColor))
		* ((ambientUp + ambientDown + directionalLightColor) / 3.0);
	float fogStrength = clamp((v_fDepth - bbmod_FogStart) * bbmod_FogRcpRange, 0.0, 1.0);
	gl_FragColor.rgb = mix(gl_FragColor.rgb, fogColor, fogStrength * bbmod_FogIntensity);
#endif // !X_PBR
	// Exposure
	gl_FragColor.rgb = vec3(1.0) - exp(-gl_FragColor.rgb * bbmod_Exposure);
	// Gamma correction
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
#endif // !X_OUTPUT_DEPTH
}
