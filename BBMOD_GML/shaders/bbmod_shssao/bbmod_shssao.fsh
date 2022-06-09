// Reference: https://de45xmedrsdbp.cloudfront.net/Resources/files/The_Technology_Behind_the_Elemental_Demo_16x9-1248544805.pdf
// Reference: http://frederikaalund.com/wp-content/uploads/2013/05/A-Comparative-Study-of-Screen-Space-Ambient-Occlusion-Methods.pdf

// Must be the same values as in the xSsaoInit script!
#define BBMOD_SSAO_KERNEL_SIZE 8

varying vec2 v_vTexCoord;

// Texture of random rotations.
uniform sampler2D u_texNoise;

// (1 / screenWidth, 1 / screenHeight)
uniform vec2 u_vTexel;

// (dtan(fov / 2) * (screenWidth / screenHeight), -dtan(fov / 2))
uniform vec2 u_vTanAspect;

// Distance to the far clipping plane.
uniform float u_fClipFar;

// Kernel of random vectors.
uniform vec2 u_vSampleKernel[BBMOD_SSAO_KERNEL_SIZE];

// (screenWidth, screenHeight) / noiseTextureSize
uniform vec2 u_vNoiseScale;

// Strength of the occlusion effect.
uniform float u_fPower;

// Screen-space radius of the occlusion effect.
uniform float u_fRadius;

// Angle bias of the occlusion effect (in radians).
uniform float u_fAngleBias;

// Maximum depth difference of samples taken into account.
uniform float u_fDepthRange;

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

#pragma include("Projecting.xsh", "glsl")
/// @param tanAspect (tanFovY*(screenWidth/screenHeight),-tanFovY), where
///                  tanFovY = dtan(fov*0.5)
/// @param texCoord  Sceen-space UV.
/// @param depth     Scene depth at texCoord.
/// @return Point projected to view-space.
vec3 xProject(vec2 tanAspect, vec2 texCoord, float depth)
{
	return vec3(tanAspect * (texCoord * 2.0 - 1.0) * depth, depth);
}

/// @param p A point in clip space (transformed by projection matrix, but not
///          normalized).
/// @return P's UV coordinates on the screen.
vec2 xUnproject(vec4 p)
{
	vec2 uv = p.xy / p.w;
	uv = uv * 0.5 + 0.5;
	uv.y = 1.0 - uv.y;
	return uv;
}
// include("Projecting.xsh")

#pragma include("Math.xsh", "glsl")
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
// include("Math.xsh")

// Source: http://stackoverflow.com/a/3380723/554283
float AcosApprox(float x)
{
	return (-0.69813170079773212 * x * x - 0.87266462599716477) * x + 1.5707963267948966;
}

float GetSampleAngle(vec3 origin, vec2 uv, inout float pairWeight)
{
	float sampleDepth = xDecodeDepth(texture2D(gm_BaseTexture, uv).rgb) * u_fClipFar;
	vec3 samplePos = xProject(u_vTanAspect, uv, sampleDepth);
	vec3 s = normalize(samplePos - origin);
	vec3 v = normalize(-origin);
	float cosAngle = dot(v, s);
	float depthDifference = (origin.z - samplePos.z);
	if (depthDifference >= u_fDepthRange)
	{
		pairWeight -= 0.5;
		cosAngle = max(dot(v, -s), 0.0);
	}
	else if (abs(depthDifference) <= 0.01)
	{
		cosAngle = 0.0;
	}
	return max(AcosApprox(cosAngle - u_fAngleBias), 0.0);
}

void main()
{
	// Origin
	float depth = xDecodeDepth(texture2D(gm_BaseTexture, v_vTexCoord).rgb);

	if (depth == 0.0 || depth == 1.0)
	{
		gl_FragColor = vec4(1.0);
		return;
	}

	depth *= u_fClipFar;
	vec3 origin = xProject(u_vTanAspect, v_vTexCoord, depth);

	vec2 noise = texture2D(u_texNoise, v_vTexCoord * u_vNoiseScale).xy * 2.0 - 1.0;

	mat2 rot = mat2(
		noise.x, -noise.y,
		noise.y, noise.x
	);

	// Occlusion
	float weightSum = 0.0001;
	float occlusion = 0.0;

	for (int i = 0; i < BBMOD_SSAO_KERNEL_SIZE; ++i)
	{
		float pairWeight = 1.0;
		vec2 dir = (rot * u_vSampleKernel[i].xy) * u_fRadius;
		vec2 sampleLeftUV = v_vTexCoord + dir * u_vTexel;
		vec2 sampleRightUV = v_vTexCoord - dir * u_vTexel;
		float angle = GetSampleAngle(origin, sampleLeftUV, pairWeight)
			+ GetSampleAngle(origin, sampleRightUV, pairWeight);
		occlusion += angle * pairWeight;
		weightSum += pairWeight;
	}

	occlusion /= weightSum * X_PI;
	occlusion = pow(occlusion, u_fPower);

	// Output
	gl_FragColor.rgb = vec3(occlusion);
	gl_FragColor.a   = 1.0;
}
