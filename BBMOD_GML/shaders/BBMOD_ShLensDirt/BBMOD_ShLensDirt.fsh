varying vec4 vColor;
varying vec2 vTexCoord;

uniform sampler2D uLensDirt;
uniform vec4 uLensDirtUVs;
uniform float uLensDirtStrength;

void main()
{
	gl_FragColor = vColor * texture2D(gm_BaseTexture, vTexCoord);
	vec2 lensDirtUV = mix(uLensDirtUVs.xy, uLensDirtUVs.zw, vTexCoord);
	gl_FragColor.rgb += texture2D(uLensDirt, lensDirtUV).rgb * gl_FragColor.rgb * uLensDirtStrength;
	gl_FragColor.rgb = clamp(gl_FragColor.rgb, vec3(0.0), vec3(1.0));
}
