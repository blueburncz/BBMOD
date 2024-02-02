// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

void TonemapReinhard()
{
	gl_FragColor.rgb = gl_FragColor.rgb / (vec3(1.0) + gl_FragColor.rgb);
}

void main()
{
	gl_FragColor.rgb = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	TonemapReinhard();
	gl_FragColor.a = 1.0;
}
