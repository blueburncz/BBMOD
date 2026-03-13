varying vec2 vTexCoord;

// Note: These are divided by ZFar!
uniform float uFocusStart;
uniform float uFocusEnd;
uniform float uBlurRangeNear;
uniform float uBlurRangeFar;

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
	float depth = xDecodeDepth(texture2D(gm_BaseTexture, vTexCoord).rgb);
	float cocFar = clamp((depth - uFocusEnd) / uBlurRangeFar, 0.0, 1.0);
	float cocNear = clamp(-(depth - uFocusStart) / uBlurRangeNear, 0.0, 1.0);
	gl_FragColor = vec4(cocFar, cocNear, 0.0, 1.0);
}
