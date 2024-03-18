varying vec2 v_vTexCoord;

uniform float u_fDepthFocus; // Divided by ZFar!

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}

float GetCoC(float depth, float depthFocus, float scale)
{
	return scale * clamp(1.0 - (depthFocus / depth), -1.0, 1.0);
	//return scale * (1.0 - (depthFocus / depth));
	//return scale * abs(1.0 - (depthFocus / depth));
}

void main()
{
	float depth = xDecodeDepth(texture2D(gm_BaseTexture, v_vTexCoord).rgb);
	float coc = GetCoC(depth, u_fDepthFocus, 1.0);
	gl_FragColor = vec4(max(coc, 0.0), max(-coc, 0.0), max(-coc, 0.0), 1.0);
}
