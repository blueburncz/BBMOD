// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform vec2 uTexel;
uniform vec2 uOrigin;
uniform float uRadius;
uniform float uStrength;
uniform float uStep;

void main()
{
	vec3 color = vec3(0.0);
	vec2 dist = vTexCoord - uOrigin;
	float stepSum = 0.0;
	for (float i = 0.0; i < 1.0; i += 0.01)
	{
		float scale = 1.0 - uStrength * (i * uStep) * (clamp(length(dist) / uRadius, 0.0, 1.0));
		color += texture2D(gm_BaseTexture, uOrigin + dist * scale).rgb;
		stepSum += uStep;
		if (stepSum >= 1.0)
		{
			break;
		}
	}
	color *= uStep;
	gl_FragColor.rgb = color;
	gl_FragColor.a = 1.0;
}
