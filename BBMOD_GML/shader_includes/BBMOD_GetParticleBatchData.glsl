/// @desc Retrieves particle batch data (position, rotation, scale, color).
/// @param position Variable to hold particle position.
/// @param rotation Variable to hold particle rotation (quaternion).
/// @param scale Variable to hold particle scale.
/// @param colorAlpha Variable to hold particle color and alpha.
void BBMOD_GetParticleBatchData(out vec3 position, out vec4 rotation, out vec3 scale, out vec4 colorAlpha)
{
	int idx = int(in_Id + 0.5) * 4;
	position = bbmod_BatchData[idx + 0].xyz;
	rotation = bbmod_BatchData[idx + 1];
	scale = bbmod_BatchData[idx + 2].xyz;
	colorAlpha = bbmod_BatchData[idx + 3];
}
