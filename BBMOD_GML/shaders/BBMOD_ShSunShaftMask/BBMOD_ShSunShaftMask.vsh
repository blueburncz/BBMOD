attribute vec3 in_Position;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexCoord;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.xyz, 1.0);
	v_vTexCoord = in_TextureCoord;
}
