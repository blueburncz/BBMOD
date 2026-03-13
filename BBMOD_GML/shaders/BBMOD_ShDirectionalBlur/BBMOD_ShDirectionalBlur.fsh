// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform vec2 uVector; // With texel size baked in!
uniform float uStep;  // In range (0; 1]

void main()
{
	vec3 color = texture2D(gm_BaseTexture, vTexCoord).rgb;
	float weightSum = 1.0;
	float stepSum = uStep;

	for (float i = 0.01; i < 0.5; i += 0.01)
	{
		color += texture2D(gm_BaseTexture, vTexCoord - uVector * stepSum).rgb;
		color += texture2D(gm_BaseTexture, vTexCoord + uVector * stepSum).rgb;
		weightSum += 2.0;
		stepSum += uStep;
		if (stepSum >= 0.5)
		{
			break;
		}
	}

	gl_FragColor.rgb = color / weightSum;
	gl_FragColor.a = 1.0;
}
