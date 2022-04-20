void GammaCorrect()
{
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
}
