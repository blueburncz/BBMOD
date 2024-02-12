varying vec2 v_vTexCoord;

uniform vec3 u_vLightPos;
uniform vec4 u_vColor;
uniform vec2 u_vInvRes;
uniform float u_fFadeOut;
uniform float u_fFlareRays;
uniform sampler2D u_texFlareRays;

void main()
{
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexCoord) * u_vColor;

	if (u_fFlareRays == 1.0)
	{
		vec2 centerVec = (u_vLightPos.xy - gl_FragCoord.xy) * u_vInvRes;
		float d = length(centerVec);
		float radial = acos(centerVec.x / d);
		float mask = texture2D(u_texFlareRays, vec2(radial, 0.0)).r;
		mask = clamp(mask + (1.0 - smoothstep(0.0, 0.3, d)), 0.0, 1.0);
		gl_FragColor.a *= mask;
	}

	if (u_fFadeOut == 1.0)
	{
		vec2 dist = vec2(0.5) - (gl_FragCoord.xy * u_vInvRes);
		float len = length(dist) * 2.0;
		gl_FragColor.a *= 1.0 - clamp(len, 0.0, 1.0);
	}
}
