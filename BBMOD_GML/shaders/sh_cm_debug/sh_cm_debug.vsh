//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying float v_vShade;
varying vec4 v_vPos;

uniform float u_radius;

void main()
{
    //Find worldspace position
    vec4 worldSpacePos = gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0);
	
	//Create a separate matrix for the normals. This will remove any scaling done on the object. This is useful for simple reusable vertex buffers
	mat3 Nmat = mat3(gm_Matrices[MATRIX_WORLD]);
	Nmat[0] = normalize(Nmat[0]);
	Nmat[1] = normalize(Nmat[1]);
	Nmat[2] = normalize(Nmat[2]);
	vec3 worldNormal = Nmat * in_Normal;
	
	//Displace the worldspace position along the normal. Again, this is used for allowing reusable vertex buffers.
	worldSpacePos.xyz += worldNormal * u_radius;
	
	//Find the viewspace position
	vec4 viewSpacePos = gm_Matrices[MATRIX_VIEW] * worldSpacePos;
	
	//Find the projection space coordinate
    gl_Position = gm_Matrices[MATRIX_PROJECTION] * viewSpacePos;
    
    v_vTexcoord = in_TextureCoord;
	
	v_vShade = .7 - .5 * dot(worldNormal, normalize(vec3(.2, -.3, -.5)));
	
	v_vPos = gl_Position;
}
