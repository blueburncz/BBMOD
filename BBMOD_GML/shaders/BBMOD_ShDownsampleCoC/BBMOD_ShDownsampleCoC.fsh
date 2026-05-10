varying vec2 v_vTexCoord;

uniform vec2 u_vTexel;

void main()
{
	vec2 coc00 = texture2D(gm_BaseTexture, v_vTexCoord + vec2(-0.5, -0.5) * u_vTexel).rg;
	vec2 coc10 = texture2D(gm_BaseTexture, v_vTexCoord + vec2( 0.5, -0.5) * u_vTexel).rg;
	vec2 coc11 = texture2D(gm_BaseTexture, v_vTexCoord + vec2( 0.5,  0.5) * u_vTexel).rg;
	vec2 coc01 = texture2D(gm_BaseTexture, v_vTexCoord + vec2(-0.5,  0.5) * u_vTexel).rg;
	gl_FragColor = vec4(
		max(max(max(coc00.r, coc10.r), coc11.r), coc01.r),
		max(max(max(coc00.g, coc10.g), coc11.g), coc01.g),
		0.0,
		1.0);
}
