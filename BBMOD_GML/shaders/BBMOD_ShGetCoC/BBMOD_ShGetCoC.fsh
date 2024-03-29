varying vec2 v_vTexCoord;

// Note: These are divided by ZFar!
uniform float u_fFocusStart;
uniform float u_fFocusEnd;
uniform float u_fBlurRangeNear;
uniform float u_fBlurRangeFar;

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
	float cocFar = clamp((depth - u_fFocusEnd) / u_fBlurRangeFar, 0.0, 1.0);
	float cocNear = clamp(-(depth - u_fFocusStart) / u_fBlurRangeNear, 0.0, 1.0);
	gl_FragColor = vec4(cocFar, cocNear, 0.0, 1.0);
}
