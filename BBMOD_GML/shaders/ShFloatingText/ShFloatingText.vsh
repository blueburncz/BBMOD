attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
	gl_Position = (gm_Matrices[MATRIX_PROJECTION] * gm_Matrices[MATRIX_VIEW]) * vec4(gm_Matrices[MATRIX_WORLD][3].xyz, 1.0);
	gl_Position /= gl_Position.w;
	gl_Position.xy += (in_Position.xy / vec2(1280.0, 720.0)) * vec2(1.0, -1.0);
	v_vColour = in_Colour;
	v_vTexcoord = in_TextureCoord;
}
