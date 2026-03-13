varying vec2 vTexCoord;

uniform vec3 uLightPos;
uniform vec4 uColor;
uniform vec2 uInvRes;
uniform float uFadeOut;
uniform sampler2D uDepth;
uniform float uClipFar;
uniform float uDepthThreshold;

uniform sampler2D uStarburst;
uniform vec4 uStarburstUVs;
uniform float uStarburstStrength;
uniform float uStarburstRot;

uniform sampler2D uLensDirt;
uniform vec4 uLensDirtUVs;
uniform float uLensDirtStrength;

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
	vec2 lightUV = uLightPos.xy * uInvRes;
	float depth = xDecodeDepth(texture2D(uDepth, lightUV).rgb) * uClipFar;

	gl_FragColor = texture2D(gm_BaseTexture, vTexCoord) * uColor;

	vec2 lensDirtUV = mix(uLensDirtUVs.xy, uLensDirtUVs.zw, gl_FragCoord.xy * uInvRes);
	gl_FragColor.rgb += texture2D(uLensDirt, lensDirtUV).rgb * gl_FragColor.rgb * uLensDirtStrength;

	//if (uStarburstStrength > 0.0)
	//{
		vec2 starburstUV = (gl_FragCoord.xy * uInvRes * 2.0 - 1.0) * 0.7072;
		mat2 matRot = mat2(
			cos(uStarburstRot), -sin(uStarburstRot),
			sin(uStarburstRot), cos(uStarburstRot));
		starburstUV = matRot * starburstUV;
		starburstUV = starburstUV * 0.5 + 0.5;
		starburstUV = mix(uStarburstUVs.xy, uStarburstUVs.zw, starburstUV);
		gl_FragColor.a *= mix(1.0, texture2D(uStarburst, starburstUV).r, uStarburstStrength);
	//}

	if (uFadeOut == 1.0)
	{
		vec2 dist = vec2(0.5) - (gl_FragCoord.xy * uInvRes);
		float len = length(dist) * 2.0;
		gl_FragColor.a *= 1.0 - clamp(len, 0.0, 1.0);
	}

	if (lightUV.x >= 0.0 && lightUV.x < 1.0
		&& lightUV.y >= 0.0 && lightUV.y < 1.0)
	{
		if (depth < uLightPos.z - uDepthThreshold)
		{
			gl_FragColor = vec4(0.0);
		}
	}
}
