/// @desc Computes a sample point on a Vogel disk for shadow filtering.
/// @param sampleIndex Index of the current sample.
/// @param samplesCount Total number of samples.
/// @param phi Rotation angle offset (noise).
/// @return 2D disk sample position.
vec2 BBMOD_VogelDiskSample(int sampleIndex, int samplesCount, float phi)
{
	const float GoldenAngle = 2.4;
	float r = sqrt(float(sampleIndex) + 0.5) / sqrt(float(samplesCount));
	float theta = float(sampleIndex) * GoldenAngle + phi;
	return vec2(r * cos(theta), r * sin(theta));
}
