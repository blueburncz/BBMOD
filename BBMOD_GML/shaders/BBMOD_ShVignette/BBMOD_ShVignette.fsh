// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform float u_fVignette;     // The strength of the vignette effect
uniform vec3 u_vVignetteColor; // The color of the vignette effect

void main()
{
	vec2 vec = 0.5 - v_vTexCoord;
	float vecLen = length(vec);
	gl_FragColor.rgb = mix(
		texture2D(gm_BaseTexture, v_vTexCoord).rgb,
		u_vVignetteColor,
		vecLen * vecLen * u_fVignette);
	gl_FragColor.a = 1.0;
}
