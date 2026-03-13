varying vec2 vTexCoord;

uniform vec2 uTexel;

void main()
{
	vec2 coc00 = texture2D(gm_BaseTexture, vTexCoord + vec2(-0.5, -0.5) * uTexel).rg;
	vec2 coc10 = texture2D(gm_BaseTexture, vTexCoord + vec2( 0.5, -0.5) * uTexel).rg;
	vec2 coc11 = texture2D(gm_BaseTexture, vTexCoord + vec2( 0.5,  0.5) * uTexel).rg;
	vec2 coc01 = texture2D(gm_BaseTexture, vTexCoord + vec2(-0.5,  0.5) * uTexel).rg;
	gl_FragColor = vec4(
		max(max(max(coc00.r, coc10.r), coc11.r), coc01.r),
		max(max(max(coc00.g, coc10.g), coc11.g), coc01.g),
		0.0,
		1.0);
}
