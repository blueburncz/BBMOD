// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform float uExposure;

void main()
{
	vec3 color = texture2D(gm_BaseTexture, vTexCoord).rgb;
	gl_FragColor.rgb = color * uExposure * uExposure;
	gl_FragColor.a = 1.0;
}
