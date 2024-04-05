varying vec4 v_vColor;
varying vec2 v_vTexCoord;

uniform sampler2D u_texLensDirt;
uniform vec4 u_vLensDirtUVs;
uniform float u_fLensDirtStrength;

void main()
{
	gl_FragColor = v_vColor * texture2D(gm_BaseTexture, v_vTexCoord);
	vec2 lensDirtUV = mix(u_vLensDirtUVs.xy, u_vLensDirtUVs.zw, v_vTexCoord);
	gl_FragColor.rgb += texture2D(u_texLensDirt, lensDirtUV).rgb * gl_FragColor.rgb * u_fLensDirtStrength;
}
