//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying float v_vShade;
varying vec4 v_vPos;

uniform vec4 u_color;

#extension GL_EXT_frag_depth : enable
		
void main()
{
    gl_FragColor = u_color * texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor.rgb *= v_vShade;
	
	#ifdef GL_EXT_frag_depth
		gl_FragDepthEXT = v_vPos.z / v_vPos.w - .00001;
	#endif
}
