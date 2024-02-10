// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform sampler2D u_texLUT;

/// @param color The original RGB color.
/// @param lut Texture of color-grading lookup table (256x16).
/// Needs to have interpolation enabled!
vec3 ColorGrade(vec3 color, sampler2D lut)
{
	// Fixes selecting wrong mips on HTML5.
	const float bias = -5.0;

	const vec2 texel = 1.0 / vec2(256.0, 16.0);

	float x1 = floor(color.r * 15.0);
	float y1 = floor(color.g * 15.0);
	float z1 = floor(color.b * 15.0) * 16.0;

	float x2 = ceil(color.r * 15.0);
	float y2 = ceil(color.g * 15.0);
	float z2 = ceil(color.b * 15.0) * 16.0;

	vec2 uv1 = vec2(z1 + x1, y1) * texel;
	vec2 uv2 = vec2(z2 + x2, y2) * texel;

	uv1 += 0.5 * texel;
	uv2 += 0.5 * texel;

	vec3 color1 = texture2D(lut, uv1, bias).rgb;
	vec3 color2 = texture2D(lut, uv2, bias).rgb;

	return vec3(
		mix(color1.r, color2.r, fract(color.r * 15.0)),
		mix(color1.g, color2.g, fract(color.g * 15.0)),
		mix(color1.b, color2.b, fract(color.b * 15.0)));
}

void main()
{
	vec3 color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;

//#ifndef _YY_GLSLES_
//	color = ColorGrade(color, u_texLUT);
//#endif

	gl_FragColor.rgb = color;
	gl_FragColor.a = 1.0;
}
