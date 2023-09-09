varying vec2 v_vTexCoord;

// Source: https://gamedev.stackexchange.com/questions/169508/octahedral-impostors-octahedral-mapping

/// @param dir Sampling dir vector in world-space.
/// @return UV coordinates on an octahedron map.
vec2 xVec3ToOctahedronUv(vec3 dir)
{
	vec3 octant = sign(dir);
	float sum = dot(dir, octant);
	vec3 octahedron = dir / sum;
	if (octahedron.z < 0.0)
	{
		vec3 absolute = abs(octahedron);
		octahedron.xy = octant.xy * vec2(1.0 - absolute.y, 1.0 - absolute.x);
	}
	return octahedron.xy * 0.5 + 0.5;
}

/// @desc Converts octahedron UV into a world-space vector.
vec3 xOctahedronUvToVec3Normalized(vec2 uv)
{
	vec3 position = vec3(2.0 * (uv - 0.5), 0);
	vec2 absolute = abs(position.xy);
	position.z = 1.0 - absolute.x - absolute.y;
	if (position.z < 0.0)
	{
		position.xy = sign(position.xy) * vec2(1.0 - absolute.y, 1.0 - absolute.x);
	}
	return position;
}

/// @source https://learnopengl.com/PBR/IBL/Specular-IBL
float xVanDerCorpus(int n, int base)
{
	float invBase = 1.0 / float(base);
	float denom = 1.0;
	float result = 0.0;
	for (int i = 0; i < 32; ++i)
	{
		if (n > 0)
		{
			denom = mod(float(n), 2.0);
			result += denom * invBase;
			invBase = invBase / 2.0;
			n = int(float(n) / 2.0);
		}
	}
	return result;
}

/// @desc Gets i-th point from sequence of uniformly distributed points on a unit square.
/// @param i The point index in sequence.
/// @param n The total size of the sequence.
/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
vec2 xHammersley2D(int i, int n)
{
	return vec2(float(i) / float(n), xVanDerCorpus(i, 2));
}

#define X_PI   3.14159265359
#define X_2_PI 6.28318530718

/// @return x^2
#define xPow2(x) ((x) * (x))

/// @return x^3
#define xPow3(x) ((x) * (x) * (x))

/// @return x^4
#define xPow4(x) ((x) * (x) * (x) * (x))

/// @return x^5
#define xPow5(x) ((x) * (x) * (x) * (x) * (x))

/// @return arctan2(x,y)
#define xAtan2(x, y) atan(y, x)

/// @return Direction from point `from` to point `to` in degrees (0-360 range).
float xPointDirection(vec2 from, vec2 to)
{
	float x = xAtan2(from.x - to.x, from.y - to.y);
	return ((x > 0.0) ? x : (2.0 * X_PI + x)) * 180.0 / X_PI;
}

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 xImportanceSample(float phi, float cosTheta, float sinTheta, vec3 N)
{
	vec3 H = vec3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);
	vec3 upVector = abs(N.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
	vec3 tangentX = normalize(cross(upVector, N));
	vec3 tangentY = cross(N, tangentX);
	return normalize(tangentX * H.x + tangentY * H.y + N * H.z);
}

/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
vec3 xImportanceSample_Lambert(vec2 Xi, vec3 N)
{
	float phi = 2.0 * X_PI * Xi.y;
	float cosTheta = sqrt(1.0 - Xi.x);
	float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
	return xImportanceSample(phi, cosTheta, sinTheta, N);
}

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 xImportanceSample_GGX(vec2 Xi, vec3 N, float roughness)
{
	float a = roughness * roughness;
	float phi = 2.0 * X_PI * Xi.x;
	float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a * a - 1.0) * Xi.y));
	float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
	return xImportanceSample(phi, cosTheta, sinTheta, N);
}

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 xPrefilterIBL_Lambert(sampler2D octahderon, vec3 N)
{
	vec3 prefilteredColor = vec3(0.0, 0.0, 0.0);
	float totalWeight = 0.0;
	const int numSamples = 1024;
	for (int i = 0; i < numSamples; ++i)
	{
		vec2 Xi = xHammersley2D(i, numSamples);
		vec3 L = xImportanceSample_Lambert(Xi, N);
		prefilteredColor += texture2D(octahderon, xVec3ToOctahedronUv(L)).rgb;
	}
	return prefilteredColor / float(numSamples);
}

/// @note Input color should be in gamma space.
/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
vec4 xEncodeRGBM(vec3 color)
{
	vec4 rgbm;
	color *= 1.0 / 6.0;
	rgbm.a = clamp(max(max(color.r, color.g), max(color.b, 0.000001)), 0.0, 1.0);
	rgbm.a = ceil(rgbm.a * 255.0) / 255.0;
	rgbm.rgb = color / rgbm.a;
	return rgbm;
}

/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
vec3 xDecodeRGBM(vec4 rgbm)
{
	return 6.0 * rgbm.rgb * rgbm.a;
}

void main()
{
	vec3 dir = xOctahedronUvToVec3Normalized(v_vTexCoord);
	gl_FragColor = xEncodeRGBM(xPrefilterIBL_Lambert(gm_BaseTexture, dir));
}
