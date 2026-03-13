// FIXME: Temporary fix!
precision highp float;

varying vec3 vWorldPos;

// Camera's exposure value
uniform float bbmod_Exposure;

// HDR mode toggle
uniform float bbmod_HDR;

// Sun direction (normalized)
uniform vec3 bbmod_SunDirection;

// Atmospheric turbidity (1.0 = very clear, 10.0 = very hazy)
uniform float bbmod_Turbidity;

// Sun intensity multiplier
uniform float bbmod_SunIntensity;

// Precomputed transmittance LUT (256x64, rgba16float).
// UV encoding:
//   U = cos(zenith angle) * 0.5 + 0.5
//   V = sqrt(altitude / H_atm)
uniform sampler2D bbmod_TransmittanceLUT;

////////////////////////////////////////////////////////////////////////////////
//
// Night sky
//

// Night sky horizon-to-zenith gradient colours (linear light).
uniform vec3  bbmod_NightSkyHorizonColor;
uniform vec3  bbmod_NightSkyZenithColor;

// View.z at which the zenith colour is fully reached. Typical range: 0.2 - 0.8.
uniform float bbmod_NightZenithShift;

// Master night-sky blend factor [0, 1].
// 0 = pure day sky, 1 = full night elements visible.
// Drive from sun altitude: smoothstep(0.1, -0.1, sunDir.z) on the GML side.
uniform float bbmod_NightIntensity;

// Star field
uniform float bbmod_StarIntensity; // brightness multiplier
uniform float bbmod_StarDensity;   // fraction of grid cells containing a star [0,1]
uniform float bbmod_StarTime;      // monotonically increasing time for scintillation

// Astronomical star rotation.
// bbmod_StarLST: Local Sidereal Time in degrees -- drives Earth-rotation of stars.
// bbmod_StarPole: celestial north pole direction in world space (Z-up, North=+Y).
//   For latitude phi: pole = (0, cos(phi), sin(phi)).
uniform float bbmod_StarLST;
uniform vec3  bbmod_StarPole;

// Moon -- analytic disc, no texture required.
// Phase (crescent / gibbous / full) is computed from the sun direction.
uniform vec3  bbmod_MoonDirection;     // normalised direction toward the moon
uniform float bbmod_MoonAngularRadius; // disc radius in radians (e.g. 0.0087 ~= 0.5 deg)
uniform vec3  bbmod_MoonColor;         // surface tint (linear light)
uniform vec4  bbmod_MoonInnerCorona;   // xyz = colour, w = falloff scale
uniform vec4  bbmod_MoonOuterCorona;   // xyz = colour, w = falloff scale

////////////////////////////////////////////////////////////////////////////////
//
// Clouds (2D layered, not volumetric)
//

// Camera world-space XYZ (for plane intersection).
uniform vec3 bbmod_CloudCamPos;

// World Z of the lowest cloud layer.
uniform float bbmod_CloudAltitude;

// Vertical separation between layers (world units).
uniform float bbmod_CloudLayerSep;

// Number of active cloud layers: 1, 2, or 3.
uniform float bbmod_CloudLayerCount;

// Tileable 2D noise texture (FBM or Perlin, single-channel or RGBA -- .r used).
// If bbmod_CloudUseNoiseTexture < 0.5 the sampler is ignored and procedural
// hash noise is used instead (works without any texture asset).
uniform sampler2D bbmod_CloudNoise;
uniform float bbmod_CloudUseNoiseTexture;

// Per-layer accumulated wind displacement (XY world units).
uniform vec2 bbmod_CloudWindOffset0;
uniform vec2 bbmod_CloudWindOffset1;
uniform vec2 bbmod_CloudWindOffset2;

// Per-layer noise frequency (larger = smaller/more frequent clouds).
uniform float bbmod_CloudScale0;
uniform float bbmod_CloudScale1;
uniform float bbmod_CloudScale2;

// Per-layer sky coverage [0, 1]. 0 = clear, 1 = fully overcast.
uniform float bbmod_CloudCoverage0;
uniform float bbmod_CloudCoverage1;
uniform float bbmod_CloudCoverage2;

// Per-layer opacity at full coverage [0, 1].
uniform float bbmod_CloudDensity0;
uniform float bbmod_CloudDensity1;
uniform float bbmod_CloudDensity2;

// Aerial perspective / horizon fade coefficient.
// Clouds fade out at large distances (low view angles) via exp(-t * coeff).
// Typical range: 0.00001 (subtle) -- 0.0001 (aggressive).
uniform float bbmod_CloudHorizonFade;

// Optional artist-painted coverage mask.
// Bright pixels = more cloud, dark = less cloud.
// Set bbmod_CloudCoverageMapEnable = 1.0 to activate.
// bbmod_CloudCoverageMapScale: 1.0 / world_units_covered_by_map.
// At camera position (0,0), the map is centred (UV = 0.5).
uniform sampler2D bbmod_CloudCoverageMap;
uniform float     bbmod_CloudCoverageMapEnable;
uniform float     bbmod_CloudCoverageMapScale;

////////////////////////////////////////////////////////////////////////////////
//
// Helper macros
//

#define X_GAMMA 2.2

////////////////////////////////////////////////////////////////////////////////
//
// Utility functions
//

/// @return x^2
float xPow2(float x) { return (x * x); }

/// @return x^3
float xPow3(float x) { return (x * x * x); }

/// @return x^4
float xPow4(float x) { return (x * x * x * x); }

/// @return x^5
float xPow5(float x) { return (x * x * x * x * x); }

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

/// @desc Gets color's luminance.
float xLuminance(vec3 rgb)
{
	return (0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b);
}

////////////////////////////////////////////////////////////////////////////////
//
// Atmosphere
//

const float PI = 3.141592653589793;

// Physical constants
const float betaScale        = 1.0e6;
const vec3  betaR            = vec3(5.802e-6, 13.558e-6, 33.1e-6) * betaScale;
const vec3  betaM            = vec3(3.996e-6) * betaScale;
const float atmosphereRadius = 6.420;
const float earthRadius      = 6.360;
const float Hr               = 0.007994;
const float Hm               = 0.001200;

bool raySphereIntersect(vec3 orig, vec3 dir, float radius, out float t0, out float t1)
{
	vec3  L            = orig;
	float b            = 2.0 * dot(dir, L);
	float c            = dot(L, L) - radius * radius;
	float discriminant = b * b - 4.0 * c;

	if (discriminant < 0.0)
	{
		t0 = 0.0;
		t1 = 0.0;
		return false;
	}

	float sqrtD = sqrt(discriminant);
	float inv2  = 0.5;
	float tA    = (-b - sqrtD) * inv2;
	float tB    = (-b + sqrtD) * inv2;

	if (tA < tB)
	{
		t0 = tA;
		t1 = tB;
	}
	else
	{
		t0 = tB;
		t1 = tA;
	}

	return true;
}

vec2 transmittanceLUTUV(float altitude, float cosZenith)
{
	float H_atm = atmosphereRadius - earthRadius;
	return vec2(
		cosZenith * 0.5 + 0.5,
		sqrt(clamp(altitude / H_atm, 0.0, 1.0)));
}

vec3 computeIncidentLight(vec3 orig, vec3 dir, float tmin, float tmax,
	vec3 sunDir, float sunIntensity)
{
	float t0;
	float t1;

	if (!raySphereIntersect(orig, dir, atmosphereRadius, t0, t1) || t1 < 0.0)
	{
		return vec3(0.0);
	}

	if (t0 > tmin && t0 > 0.0)
	{
		tmin = t0;
	}
	if (t1 < tmax)
	{
		tmax = t1;
	}

	const int numSamples  = 16;
	float segmentLength   = (tmax - tmin) / float(numSamples);
	float tCurrent        = tmin;
	vec3  sumR            = vec3(0.0);
	vec3  sumM            = vec3(0.0);
	float opticalDepthR   = 0.0;
	float opticalDepthM   = 0.0;
	float mu              = dot(dir, sunDir);
	float phaseR          = 3.0 / (16.0 * PI) * (1.0 + mu * mu);
	float g               = 0.76;
	float tmpDen          = pow(1.0 + g * g - 2.0 * g * mu, 1.5);
	float phaseM          = 3.0 / (8.0 * PI)
		* ((1.0 - g * g) * (1.0 + mu * mu))
		/ ((2.0 + g * g) * tmpDen);

	for (int i = 0; i < numSamples; ++i)
	{
		vec3  samplePosition = orig + dir * (tCurrent + segmentLength * 0.5);
		float height         = length(samplePosition) - earthRadius;
		float hr             = exp(-height / Hr) * segmentLength;
		float hm             = exp(-height / Hm) * segmentLength;
		opticalDepthR += hr;
		opticalDepthM += hm;

		vec3 tau_view = betaR * opticalDepthR + betaM * 1.1 * opticalDepthM;
		vec3 T_view   = exp(-tau_view);

		float cosZenithLight = dot(normalize(samplePosition), sunDir);
		vec3  T_sun  = texture2D(bbmod_TransmittanceLUT,
			transmittanceLUTUV(height, cosZenithLight)).rgb;

		vec3 attenuation = T_view * T_sun;
		sumR += attenuation * hr;
		sumM += attenuation * hm;

		tCurrent += segmentLength;
	}

	return (sumR * betaR * phaseR + sumM * betaM * phaseM) * sunIntensity;
}

vec3 computeSunDisk(vec3 viewDir, vec3 sunDir, float sunIntensity)
{
	float cosTheta       = dot(viewDir, sunDir);
	float sunAngularRadius = 0.00465;
	float sunEdgeSoftness  = 0.0005;
	float angle          = acos(clamp(cosTheta, -1.0, 1.0));
	float sunMask        = 1.0 - smoothstep(
		sunAngularRadius - sunEdgeSoftness,
		sunAngularRadius + sunEdgeSoftness,
		angle);

	if (sunMask <= 0.0)
	{
		return vec3(0.0);
	}

	vec3 transmittance = texture2D(bbmod_TransmittanceLUT,
		transmittanceLUTUV(0.0, sunDir.z)).rgb;

	return transmittance * sunIntensity * sunMask;
}

////////////////////////////////////////////////////////////////////////////////
//
// Night sky
//

float hash13(vec3 p)
{
	p = fract(p * vec3(127.1, 311.7, 74.7));
	p += dot(p, p.yxz + 19.19);
	return fract((p.x + p.y) * p.z);
}

vec3 hash33(vec3 p)
{
	vec3 q = vec3(
		dot(p, vec3(127.1, 311.7,  74.7)),
		dot(p, vec3(269.5, 183.3,  42.1)),
		dot(p, vec3( 74.7, 127.1, 311.7)));
	return fract(sin(q) * 43758.5453);
}

vec3 computeNightGradient(vec3 viewDir)
{
	const float minGradient = -0.1;
	float denom = max(bbmod_NightZenithShift - minGradient, 0.001);
	float gr    = clamp((viewDir.z - minGradient) / denom, 0.0, 1.0);
	gr *= 2.0 - gr;
	return mix(bbmod_NightSkyHorizonColor, bbmod_NightSkyZenithColor, gr);
}

vec3 computeStars(vec3 viewDir)
{
	const float SCALE  = 200.0;
	const float SIGMA2 = 0.01;

	float theta  = -bbmod_StarLST * 0.017453293;
	float c      = cos(theta);
	float s      = sin(theta);
	vec3  pole   = normalize(bbmod_StarPole);
	vec3  rotDir = viewDir * c
		+ cross(pole, viewDir) * s
		+ pole * dot(pole, viewDir) * (1.0 - c);

	vec3  p  = rotDir * SCALE;
	vec3  id = floor(p);
	vec3  fr = fract(p);

	float h0     = hash13(id);
	float inCell = step(h0, bbmod_StarDensity);

	vec3  starPos  = hash33(id + 17.3);
	vec3  diff     = fr - starPos;
	float dist2    = dot(diff, diff);
	float gaussian = exp(-dist2 / SIGMA2);

	float magnitude = 1.0 - h0 / max(bbmod_StarDensity, 0.0001);

	float flicker = 0.75
		+ 0.15 * sin(bbmod_StarTime * 7.0 + h0 * 47.3)
		+ 0.10 * sin(bbmod_StarTime * 3.0 + h0 * 23.7 + 1.2);

	float hc  = hash13(id + 31.7);
	vec3  col = mix(vec3(0.75, 0.85, 1.0), vec3(1.0, 0.95, 0.8), hc);

	float core = gaussian * gaussian;
	core = core * core * core;
	col += vec3(hc * core * 5.0);

	return col * gaussian * magnitude * flicker * bbmod_StarIntensity * inCell;
}

vec4 computeMoon(vec3 viewDir, vec3 sunDir)
{
	vec3  moonDir   = normalize(bbmod_MoonDirection);
	float cosToMoon = dot(viewDir, moonDir);
	float m         = 1.0 - cosToMoon;

	vec3 moon = bbmod_MoonInnerCorona.rgb / (1.05 + m * bbmod_MoonInnerCorona.w)
		+ bbmod_MoonOuterCorona.rgb / (1.05 + m * bbmod_MoonOuterCorona.w);

	float cosR = cos(bbmod_MoonAngularRadius);
	float disc = smoothstep(cosR - 0.0002, cosR + 0.0002, cosToMoon);

	if (disc > 0.0)
	{
		vec3 ref       = (abs(moonDir.z) < 0.9)
			? vec3(0.0, 0.0, 1.0)
			: vec3(1.0, 0.0, 0.0);
		vec3 moonRight = normalize(cross(moonDir, ref));
		vec3 moonUp    = cross(moonRight, moonDir);

		float sinR  = sin(bbmod_MoonAngularRadius);
		vec3  plane = viewDir - cosToMoon * moonDir;
		float u     = dot(plane, moonRight) / sinR;
		float v     = dot(plane, moonUp)    / sinR;
		float r2    = u * u + v * v;
		float depth  = sqrt(max(0.0, 1.0 - r2));
		vec3  normal = normalize(u * moonRight + v * moonUp - depth * moonDir);
		float NdotL  = max(0.0, dot(normal, sunDir));
		float limb   = sqrt(depth);

		moon += bbmod_MoonColor * NdotL * limb * disc;
	}

	return vec4(moon, disc);
}

////////////////////////////////////////////////////////////////////////////////
//
// Clouds (2D layered)
//

// Procedural 2D value noise (fallback when no noise texture is provided).

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

// 4-octave FBM using BBMOD_ValueNoise2D.
float BBMOD_FBM4(vec2 p)
{
	return BBMOD_ValueNoise2D(p)              * 0.500
		+ BBMOD_ValueNoise2D(p * 2.03 + 1.7)  * 0.250
		+ BBMOD_ValueNoise2D(p * 4.07 + 3.2)  * 0.125
		+ BBMOD_ValueNoise2D(p * 8.11 + 5.1)  * 0.063;
}

// Intersect a view ray with a horizontal plane at world Z = altitude.
// Returns the ray distance t > 0, or -1.0 if the ray misses or looks away.
float BBMOD_CloudPlaneIntersect(vec3 camPos, vec3 viewDir, float altitude)
{
	if (viewDir.z < 0.0001)
	{
		return -1.0;
	}
	float t = (altitude - camPos.z) / viewDir.z;
	if (t <= 0.0)
	{
		return -1.0;
	}
	return t;
}

// Sample one cloud layer at a world-space XY hit position.
// Returns a density value in [0, 1] after applying the coverage threshold.
// Uses a 2D noise texture when bbmod_CloudUseNoiseTexture >= 0.5,
// otherwise falls back to procedural FBM (works with no texture asset).
float BBMOD_CloudSampleLayer(vec2 worldXY, vec2 windOffset, float scale, float coverage)
{
	vec2  p = (worldXY + windOffset) * scale;
	float n;

	if (bbmod_CloudUseNoiseTexture >= 0.5)
	{
		// Texture path: two samples at different scales to break tiling.
		vec2 uv0 = p;
		vec2 uv1 = p * 2.03 + vec2(1.7, 3.1);
		n = texture2D(bbmod_CloudNoise, uv0).r * 0.70
			+ texture2D(bbmod_CloudNoise, uv1).r * 0.30;
	}
	else
	{
		// Procedural path: 4-octave FBM, no texture required.
		n = BBMOD_FBM4(p) / 0.875; // normalize roughly to [0,1]
	}

	// Coverage threshold: remap so lower-coverage values cut off first.
	return clamp((n - (1.0 - coverage)) / max(coverage, 0.001), 0.0, 1.0);
}

// Compute the lit colour for a cloud fragment.
// Combines sun forward-scatter (silver lining), direct sun, ambient sky, and moon.
// Dense clouds darken at the bottom, giving storm clouds their characteristic look.
vec3 BBMOD_CloudLighting(
	float density,
	float cosTheta,
	vec3 sunColor,
	vec3 ambientColor,
	vec3 moonColor)
{
	// Forward scatter: silver-lining highlight at cloud edges toward the sun.
	float scatter = pow(clamp(cosTheta * 0.5 + 0.5, 0.0, 1.0), 6.0);

	// Thickness factor [0=thin bright edge, 1=dense dark interior].
	float thickness = 1.0 - exp(-density * 10.0);

	// Lit edge: sky ambient + some direct sun.
	vec3 litColor = ambientColor * 0.70 + sunColor * 0.25;

	// Dark interior: nearly black, independent of ambient so storm clouds look
	// genuinely dark even at noon. Only a tiny ambient bleed is kept.
	vec3 darkColor = vec3(0.01, 0.012, 0.018) + ambientColor * 0.02;

	// Blend from lit edge to dark interior.
	vec3 dayLight = mix(litColor, darkColor, thickness);

	// Silver lining: additive, but strongly suppressed toward the interior so
	// it does not blow out storm cloud centres in HDR.
	dayLight += sunColor * scatter * 0.20 * (1.0 - thickness * 0.90);

	// Night: faint moon tint at edges, nearly black at thick interior.
	vec3 nightLight = mix(
		ambientColor * 0.10 + moonColor * 0.04,
		ambientColor * 0.01,
		thickness);

	return mix(dayLight, nightLight, bbmod_NightIntensity);
}

// Composite up to 3 2D cloud layers over the sky.
// Returns vec4(rgb inscatter, transmittance).
// transmittance = 1.0 -> fully clear, 0.0 -> fully opaque.
vec4 BBMOD_ComputeClouds(vec3 viewDir, vec3 sunDir)
{
	// Only render clouds for upward-looking rays.
	if (viewDir.z < 0.0001)
	{
		return vec4(0.0, 0.0, 0.0, 1.0);
	}

	float cosTheta = dot(viewDir, sunDir);

	// Sun colour from the transmittance LUT -- matches the sky automatically.
	vec3 sunColor = texture2D(bbmod_TransmittanceLUT,
		transmittanceLUTUV(0.0, sunDir.z)).rgb * bbmod_SunIntensity;

	// Ambient sky approximation: warm-white at midday, dim blue at horizon,
	// nearly black at night.
	float sunElev = clamp(sunDir.z, 0.0, 1.0);
	vec3 ambientDay = mix(vec3(0.25, 0.35, 0.55), vec3(0.85, 0.90, 1.00), sunElev);
	vec3 ambientNight = vec3(0.01, 0.01, 0.02);
	vec3 ambientColor = mix(ambientDay, ambientNight, bbmod_NightIntensity);

	// Optional artist-painted coverage mask (same world-space UV for all layers).
	float coverageMask = 1.0;

	vec3 cloudColor = vec3(0.0);
	float totalAlpha = 0.0;

	////////////////////////////////////////////////////////////////////////////
	// Layer 0
	{
		float t = BBMOD_CloudPlaneIntersect(
			bbmod_CloudCamPos, viewDir, bbmod_CloudAltitude);

		if (t > 0.0)
		{
			vec3 hitPos = bbmod_CloudCamPos + viewDir * t;

			if (bbmod_CloudCoverageMapEnable > 0.5)
			{
				vec2 mapUV   = hitPos.xy * bbmod_CloudCoverageMapScale + 0.5;
				coverageMask = texture2D(bbmod_CloudCoverageMap, mapUV).r;
			}

			float dens  = BBMOD_CloudSampleLayer(
				hitPos.xy,
				bbmod_CloudWindOffset0,
				bbmod_CloudScale0,
				bbmod_CloudCoverage0 * coverageMask)
				* bbmod_CloudDensity0;

			float horizonFade = exp(-t * bbmod_CloudHorizonFade);
			float alpha = clamp(dens, 0.0, 1.0) * horizonFade;
			vec3  lit   = BBMOD_CloudLighting(
				dens, cosTheta, sunColor, ambientColor, bbmod_MoonColor);

			cloudColor  = mix(cloudColor, lit, alpha * (1.0 - totalAlpha));
			totalAlpha += alpha * (1.0 - totalAlpha);
		}
	}

	////////////////////////////////////////////////////////////////////////////
	// Layer 1
	if (bbmod_CloudLayerCount >= 2.0 && totalAlpha < 0.99)
	{
		float t = BBMOD_CloudPlaneIntersect(
			bbmod_CloudCamPos, viewDir,
			bbmod_CloudAltitude + bbmod_CloudLayerSep);

		if (t > 0.0)
		{
			vec3  hitPos = bbmod_CloudCamPos + viewDir * t;
			float dens   = BBMOD_CloudSampleLayer(
				hitPos.xy,
				bbmod_CloudWindOffset1,
				bbmod_CloudScale1,
				bbmod_CloudCoverage1 * coverageMask)
				* bbmod_CloudDensity1;

			float horizonFade = exp(-t * bbmod_CloudHorizonFade);
			float alpha = clamp(dens, 0.0, 1.0) * horizonFade;
			vec3  lit   = BBMOD_CloudLighting(
				dens, cosTheta, sunColor, ambientColor, bbmod_MoonColor);

			cloudColor  = mix(cloudColor, lit, alpha * (1.0 - totalAlpha));
			totalAlpha += alpha * (1.0 - totalAlpha);
		}
	}

	////////////////////////////////////////////////////////////////////////////
	// Layer 2
	if (bbmod_CloudLayerCount >= 3.0 && totalAlpha < 0.99)
	{
		float t = BBMOD_CloudPlaneIntersect(
			bbmod_CloudCamPos, viewDir,
			bbmod_CloudAltitude + 2.0 * bbmod_CloudLayerSep);

		if (t > 0.0)
		{
			vec3  hitPos = bbmod_CloudCamPos + viewDir * t;
			float dens   = BBMOD_CloudSampleLayer(
				hitPos.xy,
				bbmod_CloudWindOffset2,
				bbmod_CloudScale2,
				bbmod_CloudCoverage2 * coverageMask)
				* bbmod_CloudDensity2;

			float horizonFade = exp(-t * bbmod_CloudHorizonFade);
			float alpha = clamp(dens, 0.0, 1.0) * horizonFade;
			vec3  lit   = BBMOD_CloudLighting(
				dens, cosTheta, sunColor, ambientColor, bbmod_MoonColor);

			cloudColor  = mix(cloudColor, lit, alpha * (1.0 - totalAlpha));
			totalAlpha += alpha * (1.0 - totalAlpha);
		}
	}

	return vec4(cloudColor, 1.0 - totalAlpha);
}

////////////////////////////////////////////////////////////////////////////////
//
// Main
//

void main()
{
	vec3 viewDir = normalize(vWorldPos);
	vec3 sunDir  = normalize(bbmod_SunDirection);

	vec3 orig     = vec3(0.0, 0.0, earthRadius);
	vec3 skyColor = computeIncidentLight(orig, viewDir, 0.0, 1000.0, sunDir, bbmod_SunIntensity);
	vec3 sunDisk  = computeSunDisk(viewDir, sunDir, bbmod_SunIntensity);

	// Night sky composited additively over daytime scattering.
	vec3 moonDisc = vec3(0.0);
	if (bbmod_NightIntensity > 0.0)
	{
		vec4  moonResult = computeMoon(viewDir, sunDir);
		float moonMask   = moonResult.a;
		skyColor += computeNightGradient(viewDir)             * bbmod_NightIntensity;
		skyColor += computeStars(viewDir) * (1.0 - moonMask) * bbmod_NightIntensity;
		skyColor += moonResult.rgb * (1.0 - moonMask)        * bbmod_NightIntensity;
		moonDisc  = moonResult.rgb * moonMask                * bbmod_NightIntensity;
	}

	// Clouds: inscatter over sky, attenuate sky behind them.
	// Sun and moon discs are point sources -- quadratic attenuation makes them
	// disappear under heavy cloud cover much faster than the diffuse sky.
	vec4  cloudResult = BBMOD_ComputeClouds(viewDir, sunDir);
	float cloudT      = cloudResult.a;
	vec3  color       = cloudResult.rgb
		+ skyColor * cloudT
		+ sunDisk  * (cloudT * cloudT)
		+ moonDisc * (cloudT * cloudT);

	gl_FragColor.rgb = color;
	if (bbmod_HDR < 0.5)
	{
		gl_FragColor.rgb *= bbmod_Exposure * bbmod_Exposure;
		gl_FragColor.rgb  = gl_FragColor.rgb / (vec3(1.0) + gl_FragColor.rgb);
		gl_FragColor.rgb  = xLinearToGamma(gl_FragColor.rgb);
	}
	gl_FragColor.a = 1.0;
}
