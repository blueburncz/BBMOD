varying vec2 v_vTexCoord;

uniform float bbmod_Exposure;

#define X_GAMMA 2.2

/// @desc Converts linear space color to gamma space.
vec3 xLinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / X_GAMMA));
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

void main()
{
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexCoord);
	Exposure();
	TonemapReinhard();
	GammaCorrect();
}
