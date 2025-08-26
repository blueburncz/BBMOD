// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform vec3 u_vBias;
uniform vec3 u_vScale;

void main()
{
	vec3 color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	gl_FragColor.rgb = any(greaterThan(color + u_vBias, vec3(0.0))) ? (color * u_vScale) : vec3(0.0);
	gl_FragColor.a = 1.0;
}
