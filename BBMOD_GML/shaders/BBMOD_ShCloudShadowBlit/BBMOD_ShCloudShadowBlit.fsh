// Reads the cloud shadow transmittance from the red channel of gm_BaseTexture
// (the cloud shadow map) and outputs it to the alpha channel only.
// RGB output is zero; the caller uses gpu_set_blendmode_ext_sepalpha to
// preserve the existing RGB (geometry depth) while writing the new alpha.

// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

void main()
{
	float shadow = texture2D(gm_BaseTexture, vTexCoord).r;
	gl_FragColor  = vec4(0.0, 0.0, 0.0, shadow);
}
