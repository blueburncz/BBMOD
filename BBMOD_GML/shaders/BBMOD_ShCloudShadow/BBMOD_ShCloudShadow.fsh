// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

// Shadow map world-space footprint.
// xy = centre of shadow map in world XY, z unused.
uniform vec3 bbmod_CloudShadowPos;
// Total world-space size (width and height) of the shadow footprint.
uniform float bbmod_CloudShadowSize;

// Sun direction (normalized). Shadow is disabled when sun is below horizon.
uniform vec3 bbmod_SunDirection;

////////////////////////////////////////////////////////////////////////////////
// Cloud layer 0 parameters (shadow is cast by the primary layer only).

uniform float bbmod_CloudAltitude;
uniform float bbmod_CloudCoverage;
uniform float bbmod_CloudDensity;
uniform float bbmod_CloudScale;
uniform vec2 bbmod_CloudWindOffset;

// Noise texture / procedural toggle (mirrors the sky shader).
uniform sampler2D bbmod_CloudNoise;
uniform float bbmod_CloudUseNoiseTexture;

////////////////////////////////////////////////////////////////////////////////
//
// Procedural 2D noise (fallback when no texture is provided).
//

float BBMOD_Hash(vec2 p)
{
	p = fract(p * vec2(0.1031, 0.1030));
	p += dot(p, p.yx + 19.19);
	return fract((p.x + p.y) * p.x);
}

float BBMOD_ValueNoise2D(vec2 p)
{
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(BBMOD_Hash(i),                BBMOD_Hash(i + vec2(1.0, 0.0)), f.x),
		mix(BBMOD_Hash(i + vec2(0.0, 1.0)), BBMOD_Hash(i + vec2(1.0, 1.0)), f.x),
		f.y);
}

float BBMOD_FBM4(vec2 p)
{
	return BBMOD_ValueNoise2D(p)             * 0.500
		+ BBMOD_ValueNoise2D(p * 2.03 + 1.7) * 0.250
		+ BBMOD_ValueNoise2D(p * 4.07 + 3.2) * 0.125
		+ BBMOD_ValueNoise2D(p * 8.11 + 5.1) * 0.063;
}

// Returns cloud density [0, 1] at a world-space XY position.
float BBMOD_CloudDensity2D(vec2 worldXY)
{
	vec2  p = (worldXY + bbmod_CloudWindOffset) * bbmod_CloudScale;
	float n;

	if (bbmod_CloudUseNoiseTexture >= 0.5)
	{
		vec2 uv0 = p;
		vec2 uv1 = p * 2.03 + vec2(1.7, 3.1);
		n = texture2D(bbmod_CloudNoise, uv0).r * 0.70
			+ texture2D(bbmod_CloudNoise, uv1).r * 0.30;
	}
	else
	{
		n = BBMOD_FBM4(p) / 0.875;
	}

	return clamp((n - (1.0 - bbmod_CloudCoverage)) / max(bbmod_CloudCoverage, 0.001), 0.0, 1.0);
}

////////////////////////////////////////////////////////////////////////////////
//
// Main
//

void main()
{
	vec3 sunDir = normalize(bbmod_SunDirection);

	// No shadow when sun is below horizon.
	if (sunDir.z < 0.001)
	{
		gl_FragColor = vec4(1.0);
		return;
	}

	// World-space XY position of this shadow texel.
	vec2 worldXY = bbmod_CloudShadowPos.xy + (vTexCoord - 0.5) * bbmod_CloudShadowSize;

	// For a flat 2D cloud layer the shadow is simply the cloud opacity projected
	// downward -- no ray-marching needed.
	float density = BBMOD_CloudDensity2D(worldXY) * bbmod_CloudDensity;
	float transmittance = exp(-density * 8.0);

	gl_FragColor = vec4(vec3(transmittance), 1.0);
}
