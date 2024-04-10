varying vec2 v_vTexCoord;

uniform vec3 u_vLightPos;
uniform vec4 u_vColor;
uniform vec2 u_vInvRes;
uniform float u_fFadeOut;
uniform sampler2D u_texDepth;
uniform float u_fClipFar;
uniform float u_fDepthThreshold;

uniform sampler2D u_texStarburst;
uniform vec4 u_vStarburstUVs;
uniform float u_fStarburstStrength;

uniform sampler2D u_texLensDirt;
uniform vec4 u_vLensDirtUVs;
uniform float u_fLensDirtStrength;

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}

void main()
{
	vec2 lightUV = u_vLightPos.xy * u_vInvRes;
	if (lightUV.x >= 0.0 && lightUV.x < 1.0
		&& lightUV.y >= 0.0 && lightUV.y < 1.0)
	{
		float depth = xDecodeDepth(texture2D(u_texDepth, lightUV).rgb) * u_fClipFar;
		if (depth < u_vLightPos.z - u_fDepthThreshold)
		{
			gl_FragColor = vec4(0.0);
			return;
		}
	}

	gl_FragColor = texture2D(gm_BaseTexture, v_vTexCoord) * u_vColor;

	vec2 lensDirtUV = mix(u_vLensDirtUVs.xy, u_vLensDirtUVs.zw, gl_FragCoord.xy * u_vInvRes);
	gl_FragColor.rgb += texture2D(u_texLensDirt, lensDirtUV).rgb * gl_FragColor.rgb * u_fLensDirtStrength;

	if (u_fStarburstStrength > 0.0)
	{
		vec2 starburstUV = mix(u_vStarburstUVs.xy, u_vStarburstUVs.zw, gl_FragCoord.xy * u_vInvRes);
		gl_FragColor.a *= mix(1.0, texture2D(u_texStarburst, starburstUV).r, u_fStarburstStrength);
	}

	if (u_fFadeOut == 1.0)
	{
		vec2 dist = vec2(0.5) - (gl_FragCoord.xy * u_vInvRes);
		float len = length(dist) * 2.0;
		gl_FragColor.a *= 1.0 - clamp(len, 0.0, 1.0);
	}
}
