varying vec4 vColor;
varying vec2 vTexCoord;

void main()
{
	vec4 color = vColor * texture2D(gm_BaseTexture, vTexCoord);
	gl_FragColor = vec4(pow(color.rgb, vec3(2.2)), color.a);
}
