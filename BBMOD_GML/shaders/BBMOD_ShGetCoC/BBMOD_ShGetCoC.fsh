varying vec2 v_vTexCoord;

uniform float u_fFocusDepth; // Divided by ZFar!

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
	float depth = xDecodeDepth(texture2D(gm_BaseTexture, v_vTexCoord).rgb);
	float coc = clamp(1.0 - u_fFocusDepth / depth, -1.0, 1.0);
	gl_FragColor = vec4(max(coc, 0.0), max(-coc, 0.0), 0.0, 1.0);
}
