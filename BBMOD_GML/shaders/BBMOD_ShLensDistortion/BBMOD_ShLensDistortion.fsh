// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform float uStrength;
uniform float uScale;

vec2 DistortLens(vec2 uv, float strength, float scale)
{
	vec2 st = (uv - vec2(0.5)) * scale;
	float theta = atan(st.x, st.y);
	float radius = sqrt(dot(st, st));
	radius *= 1.0 + strength * (radius * radius);
	return vec2(0.5) + radius * vec2(sin(theta), cos(theta));
}

void main()
{
	vec2 uv = DistortLens(vTexCoord, uStrength, uScale);
	gl_FragColor.rgb = (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
		? vec3(0.0) : texture2D(gm_BaseTexture, uv).rgb;
	gl_FragColor.a = 1.0;
}
