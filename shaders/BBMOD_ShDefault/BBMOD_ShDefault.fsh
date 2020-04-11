// This is just an example fragment shader to help you get started creating your
// own materials.

// Comment out if the model doesn't have tangent vectors and bitangent signs.
// Don't forget to do this in the vertex shader as well!
#define HAS_TBN

varying vec3 v_vVertex;
varying vec4 v_vColour;
varying vec2 v_vTexCoord;

#ifdef HAS_TBN
	varying mat3 v_mTBN;
	// Tangent-space normal map
	uniform sampler2D u_texNormal;
#else
	varying vec3 v_vNormal
#endif

void main()
{
	vec4 diffuse = v_vColour * texture2D(gm_BaseTexture, v_vTexCoord);

#ifdef HAS_TBN
	vec3 N = normalize(v_mTBN * (texture2D(u_texNormal, v_vTexCoord).xyz * 2.0 - 1.0));
#else
	vec3 N = normalize(v_vNormal);
#endif

	vec3 L = normalize(-vec3(-1.0, -1.0, -1.0));
	float NoL = max(dot(N, L), 0.0);
	diffuse.rgb *= max(NoL, 0.25);
	gl_FragColor = diffuse;
}