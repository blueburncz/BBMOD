// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform float u_fGamma;

void main()
{
	vec3 color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	gl_FragColor.rgb = pow(color, vec3(1.0 / u_fGamma));
	gl_FragColor.a = 1.0;
}
