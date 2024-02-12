varying vec2 v_vTexCoord;

uniform sampler2D u_texLensDirt;
uniform vec4 u_vLensDirtUVs;
uniform float u_fBias;
uniform float u_fScale;

void main()
{
	vec2 lensDirtUV = mix(u_vLensDirtUVs.xy, u_vLensDirtUVs.zw, v_vTexCoord);
	vec3 lensDirt = texture2D(u_texLensDirt, lensDirtUV).rgb;
	vec3 color = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	gl_FragColor.rgb = color;
	color = max(color - vec3(u_fBias), vec3(0.0)) * u_fScale;
	gl_FragColor.rgb += color * lensDirt;
	gl_FragColor.a = 1.0;
}
