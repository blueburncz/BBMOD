attribute vec4 in_Position;
attribute vec2 in_TextureCoord;

varying vec4 vColor;

uniform sampler2D uTest;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	vColor = texture2DLod(uTest, in_TextureCoord, 0.0);
}
