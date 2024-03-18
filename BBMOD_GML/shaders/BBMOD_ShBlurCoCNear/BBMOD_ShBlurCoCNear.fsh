varying vec2 v_vTexCoord;

uniform vec2 u_vTexel;

void main()
{
	vec2 farNear = texture2D(gm_BaseTexture, v_vTexCoord).rg;
	float nearBlurred = 0.0;
	for (float i = -1.0; i <= 1.0; i += 2.0 / 8.0)
	{
		nearBlurred += texture2D(gm_BaseTexture, v_vTexCoord + u_vTexel * i).b;
	}
	gl_FragColor = vec4(farNear.xy, nearBlurred / 8.0, 1.0);
}
