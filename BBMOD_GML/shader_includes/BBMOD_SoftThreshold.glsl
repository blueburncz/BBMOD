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
