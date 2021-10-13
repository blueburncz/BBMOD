#pragma include("Uber_PS.xsh", "glsl")
varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;


// Pixels with alpha less than this value will be discarded.
uniform float bbmod_AlphaTest;


void main()
{
	vec4 baseOpacity = texture2D(gm_BaseTexture, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		baseOpacity.a = 0.;
	}
	gl_FragColor = baseOpacity;
}
// include("Uber_PS.xsh")
