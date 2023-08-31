varying vec2 v_vTexCoord;

uniform sampler2D bbmod_Splatmap;
uniform int bbmod_SplatmapIndex0;

void main()
{
	vec4 splatmap = texture2D(bbmod_Splatmap, v_vTexCoord);
	// splatmap[index] does not work in HTML5
	gl_FragColor.rgb = vec3((bbmod_SplatmapIndex0 == 0) ? splatmap.r
		: ((bbmod_SplatmapIndex0 == 1) ? splatmap.g
		: ((bbmod_SplatmapIndex0 == 2) ? splatmap.b
		: splatmap.a)));
	gl_FragColor.a = 1.0;
}
