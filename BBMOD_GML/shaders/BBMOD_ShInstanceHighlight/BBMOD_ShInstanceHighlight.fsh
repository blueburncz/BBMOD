varying vec2 v_vTexCoord;

uniform vec2 u_vTexel;
uniform vec4 u_vColor;

uniform float bbmod_HDR;

float IsInstance(vec2 uv)
{
	return (dot(texture2D(gm_BaseTexture, uv), vec4(1.0)) > 0.0) ? 1.0 : 0.0;
}

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

void GammaCorrect()
{
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
}

void main()
{
	float x = IsInstance(v_vTexCoord + vec2(-1.0, 0.0) * u_vTexel)
		- IsInstance(v_vTexCoord + vec2(+1.0, 0.0) * u_vTexel);
	float y = IsInstance(v_vTexCoord + vec2(0.0, -1.0) * u_vTexel)
		- IsInstance(v_vTexCoord + vec2(0.0, +1.0) * u_vTexel);
	gl_FragColor.rgb = xGammaToLinear(u_vColor.rgb);
	gl_FragColor.a = clamp(u_vColor.a * sqrt((x * x) + (y * y)), 0.0, 1.0);

	if (bbmod_HDR == 0.0)
	{
		GammaCorrect();
	}
}
