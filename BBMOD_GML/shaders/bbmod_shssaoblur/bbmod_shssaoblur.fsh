varying vec2 v_vTexCoord;

uniform sampler2D u_texDepth;
uniform vec2 u_vTexel; // (1/screenWidth,0) for horizontal blur, (0,1/screenHeight) for vertical
uniform float u_fClipFar;

#pragma include("DepthEncoding.xsh", "glsl")
/// @param d Linearized depth to encode.
/// @return Encoded depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
vec3 xEncodeDepth(float d)
{
	const float inv255 = 1.0 / 255.0;
	vec3 enc;
	enc.x = d;
	enc.y = d * 255.0;
	enc.z = enc.y * 255.0;
	enc = fract(enc);
	float temp = enc.z * inv255;
	enc.x -= enc.y * inv255;
	enc.y -= temp;
	enc.z -= temp;
	return enc;
}

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}
// include("DepthEncoding.xsh")

void main()
{
	float depth = xDecodeDepth(texture2D(u_texDepth, v_vTexCoord).rgb) * u_fClipFar;
	float sampleDepth;
	vec4 color = texture2D(gm_BaseTexture, v_vTexCoord) * 0.2270270270;
	float weightSum = 0.2270270270;
	float weight;
	vec2 offset1 = u_vTexel * 1.3846153846;
	vec2 offset2 = u_vTexel * 3.2307692308;

	sampleDepth = xDecodeDepth(texture2D(u_texDepth, v_vTexCoord + offset1).rgb) * u_fClipFar;
	weight = 0.3162162162 * step(depth, sampleDepth);
	color += texture2D(gm_BaseTexture, v_vTexCoord + offset1) * weight;
	weightSum += weight;

	sampleDepth = xDecodeDepth(texture2D(u_texDepth, v_vTexCoord - offset1).rgb) * u_fClipFar;
	weight = 0.3162162162 * step(depth, sampleDepth);
	color += texture2D(gm_BaseTexture, v_vTexCoord - offset1) * weight;
	weightSum += weight;

	sampleDepth = xDecodeDepth(texture2D(u_texDepth, v_vTexCoord + offset2).rgb) * u_fClipFar;
	weight = 0.0702702703 * step(depth, sampleDepth);
	color += texture2D(gm_BaseTexture, v_vTexCoord + offset2) * weight;
	weightSum += weight;

	sampleDepth = xDecodeDepth(texture2D(u_texDepth, v_vTexCoord - offset2).rgb) * u_fClipFar;
	weight = 0.0702702703 * step(depth, sampleDepth);
	color += texture2D(gm_BaseTexture, v_vTexCoord - offset2) * weight;
	weightSum += weight;

	gl_FragColor = color / weightSum;
}
