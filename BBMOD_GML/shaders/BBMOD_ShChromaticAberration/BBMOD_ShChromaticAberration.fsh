// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform vec2 u_vTexel;       // 1/ScreenWidth, 1/ScreenHeight
uniform vec3 u_vOffset;      // Chromatic aberration offset for each channel
uniform float u_fDistortion; // The strength of the chromatic aberration effect

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
		texture2D(tex, uv + direction * distortion.r).r
			+ texture2D(tex, uv + direction * distortion.r * (1.0 / 4.0)).r
			+ texture2D(tex, uv + direction * distortion.r * (2.0 / 4.0)).r
			+ texture2D(tex, uv + direction * distortion.r * (3.0 / 4.0)).r,
		texture2D(tex, uv + direction * distortion.g).g
			+ texture2D(tex, uv + direction * distortion.g * (1.0 / 4.0)).g
			+ texture2D(tex, uv + direction * distortion.g * (2.0 / 4.0)).g
			+ texture2D(tex, uv + direction * distortion.g * (3.0 / 4.0)).g,
		texture2D(tex, uv + direction * distortion.b).b
			+ texture2D(tex, uv + direction * distortion.b * (1.0 / 4.0)).b
			+ texture2D(tex, uv + direction * distortion.b * (2.0 / 4.0)).b
			+ texture2D(tex, uv + direction * distortion.b * (3.0 / 4.0)).b
	) / 4.0;
}

void main()
{
	vec2 vec = 0.5 - v_vTexCoord;
	float vecLen = length(vec);
	vec3 distortion = u_vOffset * u_vTexel.x * u_fDistortion * min(vecLen / 0.5, 1.0);
	gl_FragColor.rgb = xChromaticAberration(gm_BaseTexture, v_vTexCoord, normalize(vec), distortion);
	gl_FragColor.a = 1.0;
}
