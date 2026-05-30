/// @desc Transforms a hemisphere sample to align with a given normal.
/// @param phi Azimuthal angle (radians).
/// @param cosTheta Cosine of the polar angle.
/// @param sinTheta Sine of the polar angle.
/// @param N Surface normal (hemisphere axis).
/// @return Importance sampled world-space direction.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 BBMOD_ImportanceSample(float phi, float cosTheta, float sinTheta, vec3 N)
{
	vec3 H = vec3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);
	vec3 upVector = abs(N.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
	vec3 tangentX = normalize(cross(upVector, N));
	vec3 tangentY = cross(N, tangentX);
	return normalize(tangentX * H.x + tangentY * H.y + N * H.z);
}
