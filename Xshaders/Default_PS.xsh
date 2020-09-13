varying vec3 v_vVertex;
//varying vec4 v_vColor;
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

// Prefiltered octahedron env. map
uniform sampler2D u_texIBL;

// Texel size of one octahedron.
uniform vec2 u_vIBLTexel;

// Preintegrated env. BRDF
uniform sampler2D u_texBRDF;

// Pixels with alpha less than this value will be discarded.
uniform float u_fAlphaTest;

// Camera's position in world space
uniform vec3 u_vCamPos;

// Camera's exposure value
uniform float u_fExposure;

#pragma include("BRDF.xsh", "glsl")

#pragma include("OctahedronMapping.xsh", "glsl")

#pragma include("RGBM.xsh", "glsl")

#pragma include("IBL.xsh")

#pragma include("Color.xsh", "glsl")

#pragma include("CheapSubsurface.xsh", "glsl")

#pragma include("Material.xsh", "glsl")

void main()
{
	Material material = UnpackMaterial(
		u_texBaseOpacity,
		u_texNormalRoughness,
		u_texMetallicAO,
		u_texSubsurface,
		u_texEmissive,
		v_mTBN,
		v_vTexCoord);

	if (material.Opacity < u_fAlphaTest)
	{
		discard;
	}
	gl_FragColor.a = material.Opacity;

	vec3 N = material.Normal;
	vec3 V = normalize(u_vCamPos - v_vVertex);
	vec3 lightColor = xDiffuseIBL(u_texIBL, u_vIBLTexel, N);

	// Diffuse
	gl_FragColor.rgb = material.Base * lightColor;
	// Specular
	gl_FragColor.rgb += xSpecularIBL(u_texIBL, u_vIBLTexel, u_texBRDF, material.Specular, material.Roughness, N, V);
	// Ambient occlusion
	gl_FragColor.rgb *= material.AO;
	// Emissive
	gl_FragColor.rgb += material.Emissive;
	// Subsurface scattering
	gl_FragColor.rgb += xCheapSubsurface(material.Subsurface, -V, N, N, lightColor);
	// Exposure
	gl_FragColor.rgb = vec3(1.0) - exp(-gl_FragColor.rgb * u_fExposure);
	// Gamma correction
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
}
