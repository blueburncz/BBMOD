varying vec2 vTexCoord;
varying vec4 vColour;
varying mat3 vTBN;

uniform sampler2D u_texNormal; // Tangent-space normal map

void main()
{
	vec4 diffuse = vColour * texture2D(gm_BaseTexture, vTexCoord);
	vec3 N = normalize(vTBN * (texture2D(u_texNormal, vTexCoord).xyz * 2.0 - 1.0));
	vec3 L = normalize(vec3(1.0, -1.0, 1.0));
	float NoL = max(dot(N, L), 0.0);
	diffuse.rgb *= max(NoL, 0.25);
	gl_FragColor = diffuse;
}