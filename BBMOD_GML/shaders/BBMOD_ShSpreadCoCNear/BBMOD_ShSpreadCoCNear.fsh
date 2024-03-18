varying vec2 v_vTexCoord;

uniform vec2 u_vTexel;
uniform float u_fCoCScale;

void main()
{
	vec2 farNear = texture2D(gm_BaseTexture, v_vTexCoord).rg;
	float nearBlurred = farNear.g;
	float nearWeight = 1.0;
	for (float i = -1.0; i <= 1.0; i += 2.0 / 8.0)
	{
		for (float j = -1.0; j <= 1.0; j += 2.0 / 8.0)
		{
			vec2 sampleUV = v_vTexCoord + u_fCoCScale * u_vTexel * vec2(i, j);
			float coc = texture2D(gm_BaseTexture, sampleUV).b;
			float d = distance(v_vTexCoord / u_vTexel, sampleUV / u_vTexel);
			if (d <= coc * u_fCoCScale)
			{
				float w = 1.0 - min(d / u_fCoCScale, 1.0);
				nearBlurred += coc * w;
				nearWeight += w;
			}
		}
	}
	gl_FragColor = vec4(farNear.rg, nearBlurred / nearWeight, 1.0);
}
