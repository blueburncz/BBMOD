varying vec2 vTexCoord;

void main()
{
	gl_FragColor = texture2D(gm_BaseTexture, vTexCoord);
}
