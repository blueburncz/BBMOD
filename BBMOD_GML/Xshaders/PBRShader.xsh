#pragma include("MetallicMaterial.xsh")
#pragma include("IBL.xsh")
#pragma include("CheapSubsurface.xsh")
#pragma include("Exposure.xsh")
#pragma include("GammaCorrect.xsh")

void PBRShader(Material material)
{
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
	// Opacity
	gl_FragColor.a = material.Opacity;

	Exposure();
	GammaCorrect();
}
