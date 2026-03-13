// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform float uStrength;
uniform vec3 uColor;

void main()
{
	vec2 vec = 0.5 - vTexCoord;
	float vecLen = length(vec);
	gl_FragColor.rgb = mix(
		texture2D(gm_BaseTexture, vTexCoord).rgb,
		uColor,
		vecLen * vecLen * uStrength);
	gl_FragColor.a = 1.0;
}
