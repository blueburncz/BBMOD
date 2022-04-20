#pragma include("SpecularMaterial.xsh")
#pragma include("Fog.xsh")
#pragma include("Exposure.xsh")
#pragma include("GammaCorrect.xsh")

void UnlitShader(Material material, float depth)
{
	gl_FragColor.rgb = material.Base;
	gl_FragColor.a = material.Opacity;
	Fog(depth);
	Exposure();
	GammaCorrect();
}
