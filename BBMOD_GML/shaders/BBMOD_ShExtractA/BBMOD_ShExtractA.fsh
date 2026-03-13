varying vec2 vTexCoord;

void main()
{
	vec4 gb = texture2D(gm_BaseTexture, vTexCoord);
	gl_FragColor = vec4(vec3(gb.a), 1.0);
}
