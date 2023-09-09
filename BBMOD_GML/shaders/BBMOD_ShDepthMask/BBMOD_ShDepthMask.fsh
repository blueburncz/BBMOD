varying vec2 v_vTexCoord;

uniform sampler2D u_texDepth;

void main()
{
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexCoord);
	gl_FragColor.a = (dot(texture2D(u_texDepth, v_vTexCoord).rgb, vec3(1.0)) > 0.0) ? 1.0 : 0.0;
}
