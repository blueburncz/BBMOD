varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying mat3 v_mTBN;

uniform sampler2D u_texNormal; // Tangent-space normal map

void main()
{
	vec4 diffuse = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	vec3 N = normalize(v_mTBN * (texture2D(u_texNormal, v_vTexcoord).xyz * 2.0 - 1.0));
	vec3 L = normalize(vec3(1.0, 1.0, 1.0));
	float NoL = max(dot(N, L), 0.0);
	diffuse.rgb *= max(NoL, 0.25);
	gl_FragColor = diffuse;
}