varying vec2 v_vTexCoord;

uniform sampler2D u_texLut;
uniform vec2 u_vTexel;
uniform float u_fDistortion;
uniform float u_fGrayscale;
uniform float u_fVignette;

/// @param color The original RGB color.
/// @param lut Texture of color-grading lookup table (256x16).
/// Needs to have interpolation enabled!
vec3 ColorGrade(vec3 color, sampler2D lut)
{
	vec2 uv = vec2(color.x * 0.05859375, color.y);
	float b15 = color.b * 15.0;
	float z0 = floor(b15) * 0.0625;
	float z1 = z0 + 0.0625;
	vec2 uv2 = uv + 0.001953125;
	return mix(
		texture2D(lut, uv2 + vec2(z0, 0.0)).rgb,
		texture2D(lut, uv2 + vec2(z1, 0.0)).rgb,
		fract(b15));
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
	highp vec2 vec = 0.5 - v_vTexCoord;
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
		color *= 1.0 - (vecLen * vecLen * u_fVignette);
	}

	gl_FragColor.rgb = color;
	gl_FragColor.a = 1.0;
}