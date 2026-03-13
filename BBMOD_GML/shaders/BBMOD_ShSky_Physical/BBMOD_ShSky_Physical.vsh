attribute vec3 in_Position;

varying vec3 vWorldPos;

void main()
{
	vec3 pos = in_Position * 6.420;
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(pos, 1.0);
	// Transform position to world space to account for sky sphere rotation
	vWorldPos = (gm_Matrices[MATRIX_WORLD] * vec4(pos, 0.0)).xyz;
}
