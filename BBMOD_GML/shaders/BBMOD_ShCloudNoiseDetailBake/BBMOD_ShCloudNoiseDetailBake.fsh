// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

////////////////////////////////////////////////////////////////////////////////
// Atlas layout

// 32x32 tiles, 8 cols x 4 rows = 32 Z slices, 256x128 total.
// R = FBM2 — billow erosion (apply abs(r*2-1) at runtime)
// G = cVNoise — single-octave field for shimmer / edge animation
const float ATLAS_COLS = 8.0;
const float ATLAS_ROWS = 4.0;
const float NUM_SLICES = 32.0;

// 4 noise cells per 32-px tile → 8 px per cell.
const float NOISE_FREQ = 4.0;

float cHashW(vec3 p)
{
	p = mod(p, vec3(NOISE_FREQ, NOISE_FREQ, NUM_SLICES));
	p = fract(p * vec3(0.1031, 0.1030, 0.0973));
	p += dot(p, p.yxz + 19.19);
	return fract((p.x + p.y) * p.z);
}

float cVNoiseW(vec3 p)
{
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(mix(cHashW(i),               cHashW(i + vec3(1,0,0)), f.x),
		    mix(cHashW(i + vec3(0,1,0)), cHashW(i + vec3(1,1,0)), f.x), f.y),
		mix(mix(cHashW(i + vec3(0,0,1)), cHashW(i + vec3(1,0,1)), f.x),
		    mix(cHashW(i + vec3(0,1,1)), cHashW(i + vec3(1,1,1)), f.x), f.y),
		f.z);
}

// Integer lacunarity (1, 2) for seamless FBM2.
float cFBM2W(vec3 p)
{
	return cVNoiseW(p)             * 0.667
	     + cVNoiseW(p * 2.0 + 1.7) * 0.333;
}

void main()
{
	float col   = floor(vTexCoord.x * ATLAS_COLS);
	float row   = floor(vTexCoord.y * ATLAS_ROWS);
	float slice = row * ATLAS_COLS + col;

	vec2 tileUV = fract(vTexCoord * vec2(ATLAS_COLS, ATLAS_ROWS));
	vec3 p      = vec3(tileUV * NOISE_FREQ, slice);

	float fbm2    = cFBM2W(p);
	float shimmer = cVNoiseW(p); // raw; caller maps to [-1,1] via *2-1

	gl_FragColor = vec4(fbm2, shimmer, 0.0, 1.0);
}
