// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform float u_fStrength;
uniform float u_fTime;

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
	vec3 color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	float noise = Random(vec2(Random(v_vTexCoord), u_fTime)) * 2.0 - 1.0;
	float strength = (1.0 - Luminance(color)) * u_fStrength;
	gl_FragColor.rgb = color + color * noise * strength;
	gl_FragColor.a = 1.0;
}
