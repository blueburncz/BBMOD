/// @desc Retrieves batch transform data (position/scale and rotation).
/// @param posScale Variable to hold position (xyz) and scale (w).
/// @param rot Variable to hold rotation quaternion.
void BBMOD_GetBatchTransform(out vec4 posScale, out vec4 rot)
{
	int idx = int(in_Id + 0.5) * 3;
	posScale = bbmod_BatchData[idx];
	rot = bbmod_BatchData[idx + 1];
}
