// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform vec2 u_vTexel;

/// @param image The image to blur.
/// @param uv The current texture coordinates.
/// @param texel `(1 / imageWidth, 1 / imageHeight) * direction`, where `direction`
/// is `(1.0, 0.0)` for horizontal or `(0.0, 1.0)` for vertical blur.
/// @source http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
vec4 xGaussianBlur(sampler2D image, vec2 uv, vec2 texel)
{
	vec4 color = texture2D(image, uv) * 0.2270270270;
	vec2 offset1 = texel * 1.3846153846;
	vec2 offset2 = texel * 3.2307692308;
	color += texture2D(image, uv + offset1) * 0.3162162162;
	color += texture2D(image, uv - offset1) * 0.3162162162;
	color += texture2D(image, uv + offset2) * 0.0702702703;
	color += texture2D(image, uv - offset2) * 0.0702702703;
	return color;
}

void main()
{
	gl_FragColor = xGaussianBlur(gm_BaseTexture, v_vTexCoord, u_vTexel);
}
