// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform vec2 uTexel;

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

void main()
{
	vec3 color = BBMOD_KarisAverage(gm_BaseTexture, vTexCoord, uTexel);
	gl_FragColor = vec4(color, 1.0);
}
