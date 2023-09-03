attribute vec4 in_Position;
//attribute vec3 in_Normal;
//attribute vec2 in_TextureCoord0;
//attribute vec4 in_TangentW;

varying vec4 v_vVertex;

void main()
{
	v_vVertex = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	gl_Position = v_vVertex;
}
