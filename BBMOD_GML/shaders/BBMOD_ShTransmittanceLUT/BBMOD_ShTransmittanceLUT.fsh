// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

// Must match constants in BBMOD_ShSky_Physical.fsh
const float betaScale      = 1.0e6;
const vec3  betaR          = vec3(5.802e-6, 13.558e-6, 33.1e-6) * betaScale;
const vec3  betaM          = vec3(3.996e-6) * betaScale;
const float atmosphereRadius = 6.420;
const float earthRadius      = 6.360;
const float Hr = 0.007994;
const float Hm = 0.001200;

// LUT encoding (256x64, surface_rgba16float):
//   U (x): cos(zenith angle from up), linear [-1..1] -> [0..1]
//   V (y): altitude above surface, sqrt-mapped so denser near ground
//           encode: v = sqrt(h / H_atm)
//           decode: h = v^2 * H_atm
// RGB: per-channel transmittance T = exp(-tau_R - tau_M)

bool raySphereIntersect(vec3 orig, vec3 dir, float radius, out float t0, out float t1)
{
	vec3  L    = orig;
	float b    = 2.0 * dot(dir, L);
	float c    = dot(L, L) - radius * radius;
	float disc = b * b - 4.0 * c;
	if (disc < 0.0) { t0 = 0.0; t1 = 0.0; return false; }
	float sqrtD = sqrt(disc);
	t0 = (-b - sqrtD) * 0.5;
	t1 = (-b + sqrtD) * 0.5;
	if (t0 > t1) { float tmp = t0; t0 = t1; t1 = tmp; }
	return true;
}

void main()
{
	float H_atm    = atmosphereRadius - earthRadius;
	float cosTheta = vTexCoord.x * 2.0 - 1.0;           // [-1, 1]
	float h        = vTexCoord.y * vTexCoord.y * H_atm;  // sqrt-mapped altitude

	vec3  pos      = vec3(0.0, 0.0, earthRadius + h);
	float sinTheta = sqrt(max(1.0 - cosTheta * cosTheta, 0.0));
	vec3  dir      = vec3(sinTheta, 0.0, cosTheta);

	// Exit point from atmosphere
	float t0, t1;
	if (!raySphereIntersect(pos, dir, atmosphereRadius, t0, t1) || t1 <= 0.0)
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
		return;
	}

	// If the ray hits Earth before exiting the atmosphere, no light gets through
	float tG0, tG1;
	if (raySphereIntersect(pos, dir, earthRadius, tG0, tG1) && tG1 > 0.0 && tG0 > 0.0)
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
		return;
	}

	float tStart   = max(t0, 0.0);
	float tEnd     = t1;
	const int numSteps = 40;
	float segLen   = (tEnd - tStart) / float(numSteps);
	float tCurrent = tStart;

	float optDepthR = 0.0;
	float optDepthM = 0.0;

	for (int i = 0; i < numSteps; ++i)
	{
		vec3  p        = pos + dir * (tCurrent + segLen * 0.5);
		float altitude = length(p) - earthRadius;
		if (altitude < 0.0) break;
		optDepthR  += exp(-altitude / Hr) * segLen;
		optDepthM  += exp(-altitude / Hm) * segLen;
		tCurrent   += segLen;
	}

	vec3 tau          = betaR * optDepthR + betaM * 1.1 * optDepthM;
	vec3 transmittance = exp(-tau);

	gl_FragColor = vec4(transmittance, 1.0);
}
