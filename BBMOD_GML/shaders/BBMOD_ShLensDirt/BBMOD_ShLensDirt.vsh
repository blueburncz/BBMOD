attribute vec3 in_Position;
attribute vec4 in_Color;
attribute vec2 in_TextureCoord;

varying vec4 v_vColor;
varying vec2 v_vTexCoord;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.xyz, 1.0);
	v_vColor = in_Color;
	v_vTexCoord = in_TextureCoord;
}
