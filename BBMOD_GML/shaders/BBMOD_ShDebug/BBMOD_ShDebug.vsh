attribute vec3 in_Position;
attribute vec4 in_Color;

varying vec4 v_vColor;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.xyz, 1.0);
	gl_Position.z -= 0.001;
	v_vColor = in_Color;
}
