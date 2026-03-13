// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform float uStrength;
uniform float uTime;

float Random(vec2 co)
{
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float Luminance(vec3 color)
{
	const vec3 weights = vec3(0.2125, 0.7154, 0.0721);
	return dot(color, weights);
}

void main()
{
	vec3 color = texture2D(gm_BaseTexture, vTexCoord).rgb;
	float noise = Random(vec2(Random(vTexCoord), uTime)) * 2.0 - 1.0;
	float strength = (1.0 - Luminance(color)) * uStrength;
	gl_FragColor.rgb = color + color * noise * strength;
	gl_FragColor.a = 1.0;
}
