// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform vec2 uTexel;
uniform float uOffset;

// Source: https://blog.en.uwa4d.com/2022/09/01/screen-post-processing-effects-chapter-4-kawase-blur-and-its-implementation/
vec4 KawaseBlur(sampler2D texture, vec2 uv, vec2 texel, float offset)
{
	return (
		  texture2D(texture, uv + vec2( offset + 0.5,  offset + 0.5) * texel)
		+ texture2D(texture, uv + vec2(-offset - 0.5,  offset + 0.5) * texel)
		+ texture2D(texture, uv + vec2(-offset - 0.5, -offset - 0.5) * texel)
		+ texture2D(texture, uv + vec2( offset + 0.5, -offset - 0.5) * texel)
	) * 0.25;
}

void main()
{
	gl_FragColor = KawaseBlur(gm_BaseTexture, vTexCoord, uTexel, uOffset);
}
