// Comment out if you don't have tangent and bitangent sign in your vertex format.
#define USING_TBN

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
#ifdef USING_TBN
varying mat3 v_mTBN;

uniform sampler2D u_texNormal; // Tangent-space normal map
#endif

void main()
{
	vec4 diffuse = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);

	#ifdef USING_TBN
	vec3 N = normalize(v_mTBN * texture2D(u_texNormal, v_vTexcoord).xyz * 2.0 - 1.0);

	// Your lighting code here...
	// E.g.:
	// vec3 L = vec3(1.0, 0.0, 0.0);
	// float NoL = max(dot(N, L), 0.0);
	// diffuse *= NoL;
	#endif

	gl_FragColor = diffuse;
}