varying vec4 v_vColor;
varying vec2 v_vTexCoord;

void main()
{
	vec4 color = v_vColor * texture2D(gm_BaseTexture, v_vTexCoord);
	gl_FragColor = vec4(pow(color.rgb, vec3(2.2)), color.a);
}
