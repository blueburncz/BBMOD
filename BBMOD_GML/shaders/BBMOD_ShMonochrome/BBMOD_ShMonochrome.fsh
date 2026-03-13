// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform float uStrength;
uniform vec3 uColor;

float Luminance(vec3 color)
{
	const vec3 weights = vec3(0.2125, 0.7154, 0.0721);
	return dot(color, weights);
}

void main()
{
	vec3 color = texture2D(gm_BaseTexture, vTexCoord).rgb;
	gl_FragColor.rgb = mix(color, uColor * Luminance(color), uStrength);
	gl_FragColor.a = 1.0;
}
