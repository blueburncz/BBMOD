/// @desc Retrieves batch transform data and instance ID.
/// @param posScale Variable to hold position (xyz) and scale (w).
/// @param rot Variable to hold rotation quaternion.
/// @param instanceID Variable to hold instance ID.
void BBMOD_GetBatchTransformID(out vec4 posScale, out vec4 rot, out vec4 instanceID)
{
	int idx = int(in_Id + 0.5) * 3;
	posScale = bbmod_BatchData[idx];
	rot = bbmod_BatchData[idx + 1];
	instanceID = bbmod_BatchData[idx + 2];
}
