varying vec2 vTexCoord;

uniform sampler2D uNormal;
uniform vec4 uNormalUVs;
uniform float uStrength;
uniform vec2 uTexel;

void main()
{
	vec2 textureUVs = mix(uNormalUVs.xy, uNormalUVs.zw, vTexCoord);
	vec3 N = normalize(texture2D(uNormal, textureUVs).rgb * 2.0 - 1.0);
	gl_FragColor = texture2D(gm_BaseTexture, vTexCoord + (N.xy / N.z) * uTexel * uStrength);
}
