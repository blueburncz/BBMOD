// FIXME: Temporary fix!
precision highp float;

varying vec2 v_vTexCoord;

uniform vec3 u_vBias;
uniform vec3 u_vScale;

void main()
{
	gl_FragColor.rgb = (texture2D(gm_BaseTexture, v_vTexCoord).rgb - u_vBias) * u_vScale;
	gl_FragColor.a = 1.0;
}
