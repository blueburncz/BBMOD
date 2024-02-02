varying vec2 v_vTexCoord;

uniform float bbmod_Exposure;

#define X_GAMMA 2.2

/// @desc Converts linear space color to gamma space.
vec3 xLinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / X_GAMMA));
}

vec3 Exposure(vec3 color)
{
	return color * bbmod_Exposure * bbmod_Exposure;
}

vec3 TonemapReinhard(vec3 color)
{
	return color.rgb / (vec3(1.0) + color.rgb);
}

vec3 GammaCorrect(vec3 color)
{
	return xLinearToGamma(color.rgb);
}

void main()
{
	vec3 color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	color = Exposure(color);
	color = TonemapReinhard(color);
	color = GammaCorrect(color);
	gl_FragColor.rgb = color.rgb;
	gl_FragColor.a = 1.0;
}
