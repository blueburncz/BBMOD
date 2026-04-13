// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform float uThreshold;
uniform float uKnee;
uniform vec2 uTexelSize;

// @include BBMOD_KarisAverage

/// @desc Performs a 4-sample Karis average downsample to reduce bloom fireflies.
/// Uses a weighted average based on brightness to prevent single bright pixels
/// from dominating the result during downsampling.
/// @param {sampler2D} tex The texture to sample from.
/// @param {vec2} texCoord The texture coordinate for sampling.
/// @param {vec2} texelSize The size of one texel (vec2(1.0/width, 1.0/height)).
/// @return {vec3} The averaged color with firefly reduction.
/// @source Brian Karis, "Next Generation Post Processing in Call of Duty Advanced Warfare"
vec3 BBMOD_KarisAverage(sampler2D tex, vec2 texCoord, vec2 texelSize)
{
	// Sample a 2x2 quad
	vec3 c0 = texture2D(tex, texCoord + vec2(-1.0, -1.0) * texelSize).rgb;
	vec3 c1 = texture2D(tex, texCoord + vec2( 1.0, -1.0) * texelSize).rgb;
	vec3 c2 = texture2D(tex, texCoord + vec2(-1.0,  1.0) * texelSize).rgb;
	vec3 c3 = texture2D(tex, texCoord + vec2( 1.0,  1.0) * texelSize).rgb;

	// Compute luminance-based weights (prevents fireflies)
	float w0 = 1.0 / (1.0 + dot(c0, vec3(0.299, 0.587, 0.114)));
	float w1 = 1.0 / (1.0 + dot(c1, vec3(0.299, 0.587, 0.114)));
	float w2 = 1.0 / (1.0 + dot(c2, vec3(0.299, 0.587, 0.114)));
	float w3 = 1.0 / (1.0 + dot(c3, vec3(0.299, 0.587, 0.114)));

	// Weighted average
	vec3 result = c0 * w0 + c1 * w1 + c2 * w2 + c3 * w3;
	result /= (w0 + w1 + w2 + w3);

	return result;
}
// @endinclude
// @include BBMOD_SoftThreshold

/// @desc Applies soft threshold to a color value with smooth knee.
/// Uses a quadratic curve in the knee region for smooth transitions.
/// @param {vec3} color The input HDR color.
/// @param {float} threshold The brightness threshold value.
/// @param {float} knee The soft knee width (0 = hard threshold, higher = smoother).
/// @return {vec3} Color with soft threshold applied.
/// @source Call of Duty: Advanced Warfare, Siggraph 2014
vec3 BBMOD_SoftThreshold(vec3 color, float threshold, float knee)
{
	// Calculate brightness
	float brightness = max(color.r, max(color.g, color.b));

	// Soft threshold with knee
	float softness = clamp(brightness - threshold + knee, 0.0, 2.0 * knee);
	softness = (softness * softness) / (4.0 * knee + 0.00001);

	// Calculate contribution
	float contribution = max(softness, brightness - threshold);
	contribution = max(0.0, contribution);

	// Apply to color, preserving color ratios
	return color * max(contribution / max(brightness, 0.00001), 0.0);
}
// @endinclude

void main()
{
	vec3 color = BBMOD_KarisAverage(gm_BaseTexture, vTexCoord, uTexelSize);
	gl_FragColor.rgb = BBMOD_SoftThreshold(color, uThreshold, uKnee);
	gl_FragColor.a = 1.0;
}
