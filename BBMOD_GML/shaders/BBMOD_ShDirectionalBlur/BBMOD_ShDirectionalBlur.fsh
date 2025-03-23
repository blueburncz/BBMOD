// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform vec2 u_vVector; // With texel size baked in!
uniform float u_fStep;  // In range (0; 1]

void main()
{
	vec3 color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	float weightSum = 1.0;
	float stepSum = u_fStep;

	for (float i = 0.01; i < 0.5; i += 0.01)
	{
		color += texture2D(gm_BaseTexture, v_vTexCoord - u_vVector * stepSum).rgb;
		color += texture2D(gm_BaseTexture, v_vTexCoord + u_vVector * stepSum).rgb;
		weightSum += 2.0;
		stepSum += u_fStep;
		if (stepSum >= 0.5)
		{
			break;
		}
	}

	gl_FragColor.rgb = color / weightSum;
	gl_FragColor.a = 1.0;
}
