// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform float uGamma;

void main()
{
	vec3 color = texture2D(gm_BaseTexture, vTexCoord).rgb;
	gl_FragColor.rgb = pow(color, vec3(1.0 / uGamma));
	gl_FragColor.a = 1.0;
}
