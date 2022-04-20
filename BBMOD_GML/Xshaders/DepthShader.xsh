#pragma include("DepthEncoding.xsh")

void DepthShader(float depth)
{
	gl_FragColor.rgb = xEncodeDepth(depth / bbmod_ZFar);
	gl_FragColor.a = 1.0;
}
