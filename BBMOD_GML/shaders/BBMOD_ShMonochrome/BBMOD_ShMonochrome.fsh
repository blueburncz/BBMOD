// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform float u_fStrength;
uniform vec3 u_vColor;

float Luminance(vec3 color)
{
	const vec3 weights = vec3(0.2125, 0.7154, 0.0721);
	return dot(color, weights);
}

void main()
{
	vec3 color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	gl_FragColor.rgb = mix(color, u_vColor * Luminance(color), u_fStrength);
	gl_FragColor.a = 1.0;
}
