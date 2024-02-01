// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform vec2 u_vVector; // With texel size baked in!
uniform float u_fStep;  // In range (0; 1]

void main()
{
	vec2 uv = v_vTexCoord;
	vec3 color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	float weightSum = 1.0;

	for (float i = u_fStep; i < 0.5; i += u_fStep)
	{
		color += texture2D(gm_BaseTexture, v_vTexCoord - u_vVector * i).rgb;
		color += texture2D(gm_BaseTexture, v_vTexCoord + u_vVector * i).rgb;
		weightSum += 2.0;
	}

	gl_FragColor.rgb = color / weightSum;
	gl_FragColor.a = 1.0;
}
