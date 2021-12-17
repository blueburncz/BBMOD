////////////////////////////////////////////////////////////////////////////////
// Varyings
varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;

#if !OUTPUT_DEPTH && !PBR
varying vec3 v_vLight;
varying vec3 v_vPosShadowmap;
#endif

////////////////////////////////////////////////////////////////////////////////
// Uniforms
// Material
#define bbmod_BaseOpacity gm_BaseTexture  // RGB: Base color, A: Opacity
#if PBR
uniform sampler2D bbmod_NormalRoughness;  // RGB: Tangent space normal, A: Roughness
uniform sampler2D bbmod_MetallicAO;       // R: Metallic, G: Ambient occlusion
uniform sampler2D bbmod_Subsurface;       // RGB: Subsurface color, A: Intensity
uniform sampler2D bbmod_Emissive;         // RGBA: RGBM encoded emissive color
#else
uniform sampler2D bbmod_NormalSmoothness; // RGB: Tangent space normal, A: Smoothness
uniform sampler2D bbmod_SpecularColor;    // RGB: Specular color
#endif
uniform float bbmod_AlphaTest;            // Pixels with alpha less than this value will be discarded

// Camera
uniform vec3 bbmod_CamPos;    // Camera's position in world space
uniform float bbmod_ZFar;     // Distance to the far clipping plane
uniform float bbmod_Exposure; // Camera's exposure value

#if PBR
// Image based lighting
uniform sampler2D bbmod_IBL; // Prefiltered octahedron env. map
uniform vec2 bbmod_IBLTexel; // Texel size of one octahedron
#endif

#if !PBR && !OUTPUT_DEPTH
// Fog
uniform vec4 bbmod_FogColor;      // The color of the fog
uniform float bbmod_FogIntensity; // Maximum fog intensity
uniform float bbmod_FogStart;     // Distance at which the fog starts
uniform float bbmod_FogRcpRange;  // 1.0 / (fogEnd - fogStart)

// Ambient light
uniform vec4 bbmod_LightAmbientUp;   // RGBM encoded ambient light color on the upper hemisphere.
uniform vec4 bbmod_LightAmbientDown; // RGBM encoded ambient light color on the lower hemisphere.

// Directional light
uniform vec3 bbmod_LightDirectionalDir;   // Direction of the directional light
uniform vec4 bbmod_LightDirectionalColor; // RGBM encoded color of the directional light

// Shadow mapping
uniform float bbmod_ShadowmapEnablePS; // 1.0 to enable shadows
uniform sampler2D bbmod_Shadowmap;     // Shadowmap texture
uniform vec2 bbmod_ShadowmapTexel;     // (1.0/shadowmapWidth, 1.0/shadowmapHeight)
#endif

////////////////////////////////////////////////////////////////////////////////
// Includes
#if !OUTPUT_DEPTH
#pragma include("Color.xsh", "glsl")

#pragma include("RGBM.xsh", "glsl")
#endif

#if !PBR
#pragma include("DepthEncoding.xsh")
#endif

#if PBR
#pragma include("BRDF.xsh", "glsl")

#pragma include("OctahedronMapping.xsh", "glsl")

#pragma include("IBL.xsh")

#pragma include("CheapSubsurface.xsh", "glsl")

#pragma include("MetallicRoughnessMaterial.xsh", "glsl")
#endif

#if !PBR && !OUTPUT_DEPTH
#pragma include("SpecularColorSmoothnessMaterial.xsh", "glsl")
#endif

#if !OUTPUT_DEPTH && !PBR
// Shadowmap filtering source: https://www.gamedev.net/tutorials/programming/graphics/contact-hardening-soft-shadows-made-fast-r4906/
float InterleavedGradientNoise(vec2 positionScreen)
{
	vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
	return fract(magic.z * fract(dot(positionScreen, magic.xy)));
}

vec2 VogelDiskSample(float sampleIndex, float samplesCount, float phi)
{
	float GoldenAngle = 2.4;
	float r = sqrt(sampleIndex + 0.5) / sqrt(samplesCount);
	float theta = sampleIndex * GoldenAngle + phi;
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
	for (float i = 0.0; i < 6.0; ++i)
	{
		vec2 uv2 = uv + VogelDiskSample(i, 6.0, noise) * texel * 4.0;
		shadow += step(xDecodeDepth(texture2D(shadowMap, uv2).rgb), compareZ);
	}
	return (shadow / 6.0);
}
#endif

////////////////////////////////////////////////////////////////////////////////
// Main
void main()
{
#if OUTPUT_DEPTH
	Vec4 baseOpacity = texture2D(bbmod_BaseOpacity, v_vTexCoord);
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
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_NormalSmoothness,
		bbmod_SpecularColor,
		v_mTBN,
		v_vTexCoord);

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor.a = material.Opacity;

	vec3 N = material.Normal;
	vec3 lightDiffuse = v_vLight;
	vec3 lightSpecular = vec3(0.0);

	// Ambient light
	Vec3 ambientUp = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientUp));
	Vec3 ambientDown = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientDown));
	lightDiffuse += mix(ambientDown, ambientUp, N.z * 0.5 + 0.5);
	// Shadow mapping
	float shadow = 0.0;
	if (bbmod_ShadowmapEnablePS == 1.0)
	{
		shadow = ShadowMap(bbmod_Shadowmap, bbmod_ShadowmapTexel, v_vPosShadowmap.xy, v_vPosShadowmap.z);
	}
	// Directional light
	vec3 L = normalize(-bbmod_LightDirectionalDir);
	float NdotL = max(dot(N, L), 0.0);
	float specularPower = exp2(1.0 + (material.Smoothness * 10.0));
	vec3 V = normalize(bbmod_CamPos - v_vVertex);
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
	vec3 lightColor = xGammaToLinear(xDecodeRGBM(bbmod_LightDirectionalColor)) * NdotL * (1.0 - shadow);
	lightSpecular += lightColor * fresnel * visibility * normalDistribution;
	lightDiffuse += lightColor; // * (1.0 - fresnel);
	// Diffuse
	gl_FragColor.rgb = material.Base * lightDiffuse;
	// Specular
	gl_FragColor.rgb += lightSpecular;
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
