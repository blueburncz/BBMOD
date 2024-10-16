// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform vec2 u_vTexel;
uniform vec2 u_vOrigin;
uniform float u_fRadius;
uniform float u_fStrength;
uniform float u_fStep;

void main()
{
	vec3 color = vec3(0.0);
	vec2 dist = v_vTexCoord - u_vOrigin;
	for (float i = 0.0; i < 1.0; i += u_fStep)
	{
		float scale = 1.0 - u_fStrength * (i * u_fStep) * (clamp(length(dist) / u_fRadius, 0.0, 1.0));
		color += texture2D(gm_BaseTexture, u_vOrigin + dist * scale).rgb;
	}
	color *= u_fStep;
	gl_FragColor.rgb = color;
	gl_FragColor.a = 1.0;
}
