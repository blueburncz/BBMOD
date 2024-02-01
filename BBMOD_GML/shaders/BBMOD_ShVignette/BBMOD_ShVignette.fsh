// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform float u_fStrength;
uniform vec3 u_vColor;

void main()
{
	vec2 vec = 0.5 - v_vTexCoord;
	float vecLen = length(vec);
	gl_FragColor.rgb = mix(
		texture2D(gm_BaseTexture, v_vTexCoord).rgb,
		u_vColor,
		vecLen * vecLen * u_fStrength);
	gl_FragColor.a = 1.0;
}
