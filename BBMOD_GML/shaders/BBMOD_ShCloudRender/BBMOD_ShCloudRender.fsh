// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

////////////////////////////////////////////////////////////////////////////////
//
// Camera
//
uniform vec3  bbmod_CloudCamPos;      // camera world-space position
uniform vec3  bbmod_CloudCamRight;    // normalized camera right vector
uniform vec3  bbmod_CloudCamUp;       // normalized camera up vector
uniform vec3  bbmod_CloudCamForward;  // normalized camera forward vector
uniform float bbmod_CloudTanHalfFovY; // tan(vertical FOV / 2)
uniform float bbmod_CloudAspect;      // render width / height

////////////////////////////////////////////////////////////////////////////////
//
// Sun / sky lighting
//
uniform vec3 bbmod_SunDirection;      // normalized direction TO sun (already global)
uniform vec3 bbmod_CloudSunColor;     // tinted sun color (transmittance * intensity)
uniform vec3 bbmod_CloudAmbientColor; // ambient sky color (for cloud interiors)

////////////////////////////////////////////////////////////////////////////////
//
// Cloud layer geometry
//
uniform float bbmod_CloudAltitude;    // world Z of cloud layer bottom
uniform float bbmod_CloudThickness;   // cloud layer vertical depth

////////////////////////////////////////////////////////////////////////////////
//
// Shape / density
//

// Coverage: 0 = clear sky, 1 = fully overcast.
// Density:  extinction coefficient σ_e (try 0.02-0.06).
// BaseScale: world-space frequency of the coarse cloud shape.
// DetailScale: frequency of the erosion detail.
uniform float bbmod_CloudCoverage;
uniform float bbmod_CloudDensity;
uniform float bbmod_CloudBaseScale;
uniform float bbmod_CloudDetailScale;

////////////////////////////////////////////////////////////////////////////////
//
// Wind
//

// Accumulated horizontal displacement from wind, in world units.
// Computed on the GML side: windOffset += windDir * windStrength * dt.
uniform vec2 bbmod_CloudWindOffset;

////////////////////////////////////////////////////////////////////////////////
//
// Phase function
//

// Dual-lobe Henyey-Greenstein. Typical values:
//   ScatterFwd  = 0.85  (strong forward scatter → silver lining)
//   ScatterBwd  = -0.1  (slight back-scatter → dark cloud backs)
//   ScatterBlend = 0.2  (mostly forward lobe)
uniform float bbmod_CloudScatterFwd;
uniform float bbmod_CloudScatterBwd;
uniform float bbmod_CloudScatterBlend;

// Powder (dark-edge) effect strength. Higher → darker cloud edges.
// Typical: 0.5 - 1.5
uniform float bbmod_CloudPowder;

////////////////////////////////////////////////////////////////////////////////
//
// Ray-march budget
//

// Increasing MaxSteps improves quality; halving them halves cost.
// Good defaults: MaxSteps=32, ShadowSteps=6, ShadowLen=800.
uniform float bbmod_CloudMaxSteps;    // compile-time bound = 32
uniform float bbmod_CloudShadowSteps; // compile-time bound = 6
uniform float bbmod_CloudShadowLen;   // world units of shadow ray

////////////////////////////////////////////////////////////////////////////////
//
// Temporal jitter
//`
uniform float bbmod_CloudFrameCount;

////////////////////////////////////////////////////////////////////////////////
//
// Constants
//
const float PI = 3.14159265;

// =============================================================================
// Procedural 3D value noise (no texture required).
// hash1: returns a pseudo-random float in [0,1) for a vec3 cell coordinate.
// =============================================================================
float hash1(vec3 p)
{
	p = fract(p * vec3(0.1031, 0.1030, 0.0973));
	p += dot(p, p.yxz + 19.19);
	return fract((p.x + p.y) * p.z);
}

float vnoise(vec3 p)
{
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f); // Hermite smoothstep
	return mix(
		mix(mix(hash1(i),              hash1(i + vec3(1.0, 0.0, 0.0)), f.x),
		    mix(hash1(i + vec3(0.0, 1.0, 0.0)), hash1(i + vec3(1.0, 1.0, 0.0)), f.x), f.y),
		mix(mix(hash1(i + vec3(0.0, 0.0, 1.0)), hash1(i + vec3(1.0, 0.0, 1.0)), f.x),
		    mix(hash1(i + vec3(0.0, 1.0, 1.0)), hash1(i + vec3(1.0, 1.0, 1.0)), f.x), f.y),
		f.z);
}

// 4-octave FBM for base cloud shape. Rotated per-octave to reduce directional bias.
float fbm4(vec3 p)
{
	return vnoise(p)         * 0.500
	     + vnoise(p * 2.03 + 1.7) * 0.250
	     + vnoise(p * 4.07 + 3.2) * 0.125
	     + vnoise(p * 8.11 + 5.1) * 0.063;
}

// 2-octave FBM for shadow rays and detail erosion (cheaper).
float fbm2(vec3 p)
{
	return vnoise(p)         * 0.667
	     + vnoise(p * 2.03 + 1.7) * 0.333;
}

// =============================================================================
// Cloud density at a world-space position.
// Returns extinction density in [0, ∞) — multiply by σ_e for optical depth.
// relH: normalized height within the slab [0=bottom, 1=top].
// =============================================================================
float getDensity(vec3 posWS, float relH)
{
	// Height gradient: zero at base and top, smoothly peaks near 1/3 height.
	// This gives a flat-bottom / domed-top cumulus profile.
	float hBot  = clamp(relH * 5.0, 0.0, 1.0);          // ramps up fast
	float hTop  = clamp((1.0 - relH) * 2.5, 0.0, 1.0);  // ramps down slower
	float hGrad = sqrt(hBot * hTop);

	// Wind-animated base position.
	vec3 basePos = vec3(posWS.xy + bbmod_CloudWindOffset, posWS.z) * bbmod_CloudBaseScale;

	// Base shape (4-octave FBM).
	float base = fbm4(basePos) * 0.5 + 0.5; // remap [~-0.5,0.5] → [0,1]

	// Coverage threshold: subtract (1-coverage) so lower-coverage values cut off first.
	base = clamp(base - (1.0 - bbmod_CloudCoverage), 0.0, 1.0)
	     / max(bbmod_CloudCoverage, 0.001);

	// Detail erosion: billow noise moves slightly faster than the base layer.
	vec3  detailPos = vec3(posWS.xy + bbmod_CloudWindOffset * 1.3, posWS.z) * bbmod_CloudDetailScale;
	float detail    = abs(fbm2(detailPos) * 2.0 - 1.0); // billowy [0,1]
	base -= detail * 0.4 * (1.0 - base);                // only erodes thin regions

	return max(0.0, base) * hGrad;
}

// =============================================================================
// Dual-lobe Henyey-Greenstein phase function.
// Gives the characteristic silver lining (strong forward scatter) and
// dark-cloud silhouette (back scatter) without a LUT.
// =============================================================================
float phaseHG(float cosTheta, float g)
{
	float g2 = g * g;
	float d  = max(1.0 + g2 - 2.0 * g * cosTheta, 1e-5);
	return (1.0 - g2) / (4.0 * PI * pow(d, 1.5));
}

float cloudPhase(float cosTheta)
{
	float p1 = phaseHG(cosTheta,  bbmod_CloudScatterFwd);
	float p2 = phaseHG(cosTheta,  bbmod_CloudScatterBwd);
	return mix(p1, p2, bbmod_CloudScatterBlend);
}

// =============================================================================
// Interleaved gradient noise jitter (temporal anti-aliasing).
// Shifts ray sample positions per-frame, averaging out over time when combined
// with FXAA or any TAA.
// =============================================================================
float getJitter()
{
	vec2  pix   = gl_FragCoord.xy + bbmod_CloudFrameCount * 5.588238;
	vec3  magic = vec3(0.06711056, 0.00583715, 52.9829189);
	return fract(magic.z * fract(dot(pix, magic.xy)));
}

// =============================================================================
void main()
{
	////////////////////////////////////////////////////////////////////////////
	// Reconstruct per-pixel view direction from camera frustum params
	vec2  ndc     = vTexCoord * 2.0 - 1.0;
	vec3  viewDir = normalize(
		bbmod_CloudCamForward
		+ bbmod_CloudCamRight * ndc.x * bbmod_CloudTanHalfFovY * bbmod_CloudAspect
		+ bbmod_CloudCamUp    * ndc.y * bbmod_CloudTanHalfFovY);

	////////////////////////////////////////////////////////////////////////////
	// Cloud slab intersection (two horizontal planes)
	float botZ = bbmod_CloudAltitude;
	float topZ = bbmod_CloudAltitude + bbmod_CloudThickness;

	// Rays looking downward (or nearly horizontal) can't hit a cloud layer above.
	if (viewDir.z < 0.001)
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0); // transmittance=1 → fully clear
		return;
	}

	float invDz  = 1.0 / viewDir.z;
	float tStart = max((botZ - bbmod_CloudCamPos.z) * invDz, 0.0);
	float tEnd   = (topZ - bbmod_CloudCamPos.z) * invDz;

	// Camera is above the cloud top — swap: ray hits top first, then bottom.
	if (bbmod_CloudCamPos.z > topZ)
	{
		tStart = max(-(topZ - bbmod_CloudCamPos.z) * invDz, 0.0); // viewDir.z is negative here
		tEnd   = -(botZ  - bbmod_CloudCamPos.z) * invDz;
	}

	// Camera inside the slab: start at 0.
	if (bbmod_CloudCamPos.z >= botZ && bbmod_CloudCamPos.z <= topZ)
	{
		tStart = 0.001;
		tEnd   = (topZ - bbmod_CloudCamPos.z) * invDz;
	}

	if (tStart >= tEnd)
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
		return;
	}

	////////////////////////////////////////////////////////////////////////////
	// Pre-compute lighting constants
	float rayLen   = tEnd - tStart;
	float jitter   = getJitter();
	float cosTheta = dot(viewDir, bbmod_SunDirection);
	float ph       = cloudPhase(cosTheta);

	float shadowStepLen = bbmod_CloudShadowLen / max(bbmod_CloudShadowSteps, 1.0);

	////////////////////////////////////////////////////////////////////////////
	// Ray-march
	vec3  inscatter     = vec3(0.0);
	float transmittance = 1.0;
	float totalOptDepth = 0.0; // accumulated optical depth for powder effect

	for (int i = 0; i < 32; i++)
	{
		if (float(i) >= bbmod_CloudMaxSteps) break;
		if (transmittance < 0.01) break;

		// Uniformly-spaced steps, jittered by one step width to remove banding.
		float fi     = float(i);
		float t      = tStart + (fi + jitter) / bbmod_CloudMaxSteps * rayLen;
		float tNext  = tStart + (fi + 1.0 + jitter) / bbmod_CloudMaxSteps * rayLen;
		float stepSz = tNext - t;

		vec3  posWS = bbmod_CloudCamPos + viewDir * t;
		float relH  = clamp((posWS.z - botZ) / bbmod_CloudThickness, 0.0, 1.0);
		float dens  = getDensity(posWS, relH);

		if (dens <= 0.0) continue;

		////////////////////////////////////////////////////////////////////////
		// Shadow ray toward the sun (Beer's law, coarse steps)
		float optToSun = 0.0;
		for (int si = 0; si < 6; si++)
		{
			if (float(si) >= bbmod_CloudShadowSteps) break;
			vec3  sp     = posWS + bbmod_SunDirection * ((float(si) + 0.5) * shadowStepLen);
			float relHs  = clamp((sp.z - botZ) / bbmod_CloudThickness, 0.0, 1.0);
			optToSun    += getDensity(sp, relHs) * bbmod_CloudDensity * shadowStepLen;
		}

		////////////////////////////////////////////////////////////////////////
		// Multi-scatter approximation (Hillaire 2020)

		// The idea: higher-order scattering events produce a smoother, brighter
		// interior. We approximate this with a second exp term at lower density.
		//   term0: direct single-scatter (bright where shadow is low)
		//   term1: diffuse multi-scatter  (preserves brightness inside thick clouds)
		float term0 = exp(-optToSun);
		float term1 = exp(-optToSun * 0.25) * 0.7;
		float lightEnergy = max(term0, term1);

		////////////////////////////////////////////////////////////////////////
		// Powder (dark-edge) effect

		// Clouds look darker at their edges because forward-scattered light hasn't
		// had a chance to bounce back toward the camera.
		totalOptDepth += dens * bbmod_CloudDensity * stepSz;
		float powder   = 1.0 - exp(-totalOptDepth * bbmod_CloudPowder * 2.0);
		// Powder is strongest when looking toward the sun (forward scatter).
		powder = mix(1.0, powder, clamp(cosTheta * 0.5 + 0.5, 0.0, 1.0));

		////////////////////////////////////////////////////////////////////////
		// Ambient lighting

		// Cloud tops receive more sky light; interiors get a soft constant term.
		float skyGrad = 0.05 + (1.0 - relH) * 0.15;
		vec3  ambient = bbmod_CloudAmbientColor * skyGrad;

		////////////////////////////////////////////////////////////////////////
		// Analytic in-scatter integration within the voxel

		// S = sigmaS * ( sunLight + ambient )
		// Sint = integral of S * exp(-sigmaE * s) ds, solved analytically.
		float sigmaE = dens * bbmod_CloudDensity;
		vec3  sunLight = bbmod_CloudSunColor * ph * lightEnergy * powder;
		vec3  S        = sigmaE * (sunLight + ambient);

		float muE  = max(sigmaE, 1e-7);
		float trns = exp(-muE * stepSz);
		inscatter     += transmittance * (S - S * trns) / muE;
		transmittance *= trns;
	}

	////////////////////////////////////////////////////////////////////////////
	// Output

	// rgb = inscattering radiance.
	// a   = transmittance (1=fully transparent, 0=opaque).
	// Composite on GML side with:  gpu_set_blendmode_ext(bm_one, bm_src_alpha)
	//   result = inscatter + scene * transmittance
	gl_FragColor = vec4(inscatter, transmittance);
}
