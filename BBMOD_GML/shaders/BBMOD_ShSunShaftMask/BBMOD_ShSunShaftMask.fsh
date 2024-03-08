varying vec2 v_vTexCoord;

uniform vec2 u_vLightPos;
uniform vec2 u_vAspect;
uniform float u_fRadius;
uniform vec4 u_vColor;

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
	gl_FragColor = vec4(vec3(xDecodeDepth(texture2D(gm_BaseTexture, v_vTexCoord).rgb)), 1.0);
	gl_FragColor.rgb *= 1.0 - clamp(length((v_vTexCoord - u_vLightPos) * u_vAspect) / u_fRadius, 0.0, 1.0);
	gl_FragColor.rgb *= u_vColor.rgb * u_vColor.a;
}
