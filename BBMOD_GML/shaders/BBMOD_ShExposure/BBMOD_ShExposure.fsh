// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform float u_fExposure;

void main()
{
	vec3 color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	gl_FragColor.rgb = color * u_fExposure * u_fExposure;
	gl_FragColor.a = 1.0;
}
