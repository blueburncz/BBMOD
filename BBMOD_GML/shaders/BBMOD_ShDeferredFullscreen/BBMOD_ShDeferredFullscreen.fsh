varying vec2 v_vTexCoord;

#define u_texGB0 gm_BaseTexture
uniform sampler2D u_texGB1;
uniform sampler2D u_texGB2;
uniform vec2 u_vTexel;

// 1.0 to enable IBL
uniform float bbmod_IBLEnable;
// Prefiltered octahedron env. map
uniform sampler2D bbmod_IBL;
// Texel size of one octahedron
uniform vec2 bbmod_IBLTexel;

#define X_GAMMA 2.2

/// @desc Converts gamma space color to linear space.
vec3 xGammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(X_GAMMA));
}

/// @desc Converts linear space color to gamma space.
vec3 xLinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / X_GAMMA));
}

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}

void main()
{
	vec4 GB0 = texture2D(u_texGB0, v_vTexCoord);
	vec4 GB1 = texture2D(u_texGB1, v_vTexCoord);
	vec4 GB2 = texture2D(u_texGB2, v_vTexCoord);

	vec3 baseColor = xGammaToLinear(GB0.rgb);
	float AO = GB0.a;
	vec3 N = normalize(GB1.rgb * 2.0 - 1.0);
	float roughness = GB1.a;
	float depth = xDecodeDepth(GB2.rgb);
	float metallic = GB2.a;

	vec3 L = normalize(-vec3(-1.0));
	float NdotL = max(dot(N, L), 0.0);

	gl_FragColor = vec4((dot(GB1.rgb, vec3(1.0)) != 0.0) ? xLinearToGamma(baseColor * NdotL) : vec3(0.0), 1.0);
}
