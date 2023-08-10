void TonemapReinhard()
{
	gl_FragColor.rgb = gl_FragColor.rgb / (vec3(1.0) + gl_FragColor.rgb);
}
