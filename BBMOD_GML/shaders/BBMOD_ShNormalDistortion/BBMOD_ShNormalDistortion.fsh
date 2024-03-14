varying vec2 v_vTexCoord;

uniform sampler2D u_texNormal;
uniform vec4 u_vNormalUVs;
uniform float u_fStrength;
uniform vec2 u_vTexel;

void main()
{
	vec2 textureUVs = mix(u_vNormalUVs.xy, u_vNormalUVs.zw, v_vTexCoord);
	vec3 N = normalize(texture2D(u_texNormal, textureUVs).rgb * 2.0 - 1.0);
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexCoord + (N.xy / N.z) * u_vTexel * u_fStrength);
}
