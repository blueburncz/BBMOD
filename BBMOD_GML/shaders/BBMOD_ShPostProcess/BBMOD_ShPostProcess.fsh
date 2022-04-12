// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform sampler2D u_texLut;    // Color grading LUT
uniform vec2 u_vTexel;         // 1/ScreenWidth, 1/ScreenHeight
uniform float u_fDistortion;   // The strength of the chromatic aberration effect
uniform float u_fGrayscale;    // The strength of the grayscale effect
uniform float u_fVignette;     // The strength of the vignette effect
uniform vec3 u_vVignetteColor; // The color of the vignette effect

/// @param color The original RGB color.
/// @param lut Texture of color-grading lookup table (256x16).
/// Needs to have interpolation enabled!
vec3 ColorGrade(vec3 color, sampler2D lut)
{
	// This fixes color grading on HTML5. May be precision issues?
	color = clamp(color, vec3(0.06), vec3(1.0 - 0.06));

	// Fixes selecting wrong mips on HTML5.
	const float bias = -5.0;

	float z = color.b * 15.0;
	vec2 uv1 = vec2((color.r + floor(z)) / 16.0, color.g);
	vec2 uv2 = vec2((color.r + ceil(z)) / 16.0, color.g);
	return mix(
		texture2D(lut, uv1, bias).rgb,
		texture2D(lut, uv2, bias).rgb,
		fract(z));
}

float Luminance(vec3 color)
{
	const vec3 weights = vec3(0.2125, 0.7154, 0.0721);
	return dot(color, weights);
}

#pragma include("ChromaticAberration.xsh", "glsl")
/// @param direction  Direction of distortion.
/// @param distortion Per-channel distortion factor.
/// @source http://john-chapman-graphics.blogspot.cz/2013/02/pseudo-lens-flare.html
vec3 xChromaticAberration(
	sampler2D tex,
	vec2 uv,
	vec2 direction,
	vec3 distortion)
{
	return vec3(
		texture2D(tex, uv + direction * distortion.r).r,
		texture2D(tex, uv + direction * distortion.g).g,
		texture2D(tex, uv + direction * distortion.b).b);
}

// include("ChromaticAberration.xsh")

void main()
{
	vec2 vec = 0.5 - v_vTexCoord;
	float vecLen = length(vec);
	vec3 color;

	// Chromatic aberration
	if (u_fDistortion != 0.0)
	{
		vec3 distortion = vec3(-u_vTexel.x, 0.0, u_vTexel.x) * u_fDistortion * min(vecLen / 0.5, 1.0);
		color = xChromaticAberration(gm_BaseTexture, v_vTexCoord, normalize(vec), distortion);
	}
	else
	{
		color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	}

	// Color grading
	color = ColorGrade(color, u_texLut);

	// Grayscale
	if (u_fGrayscale != 0.0)
	{
		color = mix(color, vec3(Luminance(color)), u_fGrayscale);
	}

	// Vignette
	if (u_fVignette != 0.0)
	{
		color = mix(color, u_vVignetteColor, vecLen * vecLen * u_fVignette);
	}

	gl_FragColor.rgb = color;
	gl_FragColor.a = 1.0;
}