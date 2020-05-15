varying vec3 v_vVertex;
//varying vec4 v_vColour;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;

// RGB: Base color, A: Opacity
#define u_texBaseOpacity gm_BaseTexture

// RGB: Tangent space normal, A: Roughness
uniform sampler2D u_texNormalRoughness;

// R: Metallic, G: Ambient occlusion
uniform sampler2D u_texMetallicAO;

// RGB: Subsurface color, A: Intensity
uniform sampler2D u_texSubsurface;

// RGBM encoded emissive color
uniform sampler2D u_texEmissive;

// Prefiltered diffuse octahedron env. map
uniform sampler2D u_texDiffuseIBL;

// Prefiltered specular octahedron env. map
uniform sampler2D u_texSpecularIBL;

// Texel size of one octahedron.
uniform vec2 u_vSpecularIBLTexel;

// Preintegrated env. BRDF
uniform sampler2D u_texBRDF;

// Camera's position in world space
uniform vec3 u_vCamPos;

// Camera's exposure value
uniform float u_fExposure;

#pragma include("BRDF.xsh", "glsl")

#pragma include("OctahedronMapping.xsh", "glsl")

#pragma include("RGBM.xsh", "glsl")

#pragma include("IBL.xsh")

#pragma include("Color.xsh", "glsl")

#pragma include("Math.xsh", "glsl")

#pragma include("CheapSubsurface.xsh", "glsl")

void main()
{
	////////////////////////////////////////////////////////////////////////////
	// Unpack material properties
	vec4 baseOpacity = texture2D(u_texBaseOpacity, v_vTexCoord);
	vec3 baseColor = xGammaToLinear(baseOpacity.rgb);
	float opacity = baseOpacity.a;

	vec4 normalRoughness = texture2D(u_texNormalRoughness, v_vTexCoord);
	//normalRoughness.g = 1.0 - normalRoughness.g; // TODO: Comment out!
	vec3 N = normalize(v_mTBN * (normalRoughness.rgb * 2.0 - 1.0));
	float roughness = normalRoughness.a;

	vec4 metallicAO = texture2D(u_texMetallicAO, v_vTexCoord);
	float metallic = metallicAO.r;
	float AO = metallicAO.g;

	vec4 subsurface = texture2D(u_texSubsurface, v_vTexCoord);
	vec3 subsurfaceColor = xGammaToLinear(subsurface.rgb);
	float subsurfaceIntensity = subsurface.a;

	vec3 emissive = xGammaToLinear(xDecodeRGBM(texture2D(u_texEmissive, v_vTexCoord)));

	vec3 specularColor = mix(X_F0_DEFAULT, baseColor, metallic);
	baseColor *= (1.0 - metallic);
	////////////////////////////////////////////////////////////////////////////

	vec3 V = normalize(u_vCamPos - v_vVertex);
	vec3 lightColor = xDiffuseIBL(u_texDiffuseIBL, N) / X_PI;

	gl_FragColor.rgb = (
		baseColor * lightColor
		+ xSpecularIBL(u_texSpecularIBL, u_vSpecularIBLTexel, u_texBRDF, specularColor, roughness, N, V)
		) * AO
		+ emissive
		+ xCheapSubsurface(subsurfaceColor, subsurfaceIntensity, -V, N, N, lightColor)
		;

	gl_FragColor.rgb = vec3(1.0) - exp(-gl_FragColor.rgb * u_fExposure);
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
	gl_FragColor.a = opacity;
}
