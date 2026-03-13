// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

////////////////////////////////////////////////////////////////////////////////
// Atlas layout

// 128x128 tiles, 8 cols x 8 rows = 64 Z slices, 1024x1024 total.
// R = FBM4 Perlin base shape
// G = 3D inverted Worley octave 1 (1x freq)
// B = 3D inverted Worley octave 2 (2x freq)
// A = 3D inverted Worley octave 3 (4x freq)
const float ATLAS_COLS = 8.0;
const float ATLAS_ROWS = 8.0;
const float NUM_SLICES = 64.0;

// NOISE_FREQ: noise cells per tile in X and Y.
// Each tile is 128x128 px → 128/NOISE_FREQ px per noise cell.
// NOISE_FREQ=8 → 16 px/cell.  Must be a positive integer.
// Larger = more unique pattern per tile = less obvious tiling in the world.
// The pattern repeats every (NOISE_FREQ / BaseScale) world units; with
// BaseScale=0.0004 and NOISE_FREQ=8, that's 20 000 world units ≈ 20 km.
const float NOISE_FREQ = 8.0;

////////////////////////////////////////////////////////////////////////////////
// Seamlessly tileable hash

// Wrapping the integer cell index at (NOISE_FREQ, NOISE_FREQ, NUM_SLICES)
// makes the noise field periodic at those exact intervals so that the left
// edge of a tile has the same value as the right edge → no seam.
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

// FBM4 with integer lacunarity (1, 2, 4, 8) so every octave also hits integer
// cell boundaries at the wrap point → all octaves are seamlessly tileable.
float cFBM4W(vec3 p)
{
	return cVNoiseW(p)             * 0.500
	     + cVNoiseW(p * 2.0 + 1.7) * 0.250
	     + cVNoiseW(p * 4.0 + 3.2) * 0.125
	     + cVNoiseW(p * 8.0 + 5.1) * 0.063;
}

////////////////////////////////////////////////////////////////////////////////
// 3D tileable Worley

// Cell IDs are wrapped at the tile period before hashing so cell patterns on
// one side of the tile boundary match the other side.
vec3 cHash33W(vec3 ip) // ip already mod-wrapped by the caller
{
	return vec3(
		cHashW(ip),
		cHashW(ip + vec3(37.0, 0.0, 0.0)),
		cHashW(ip + vec3(0.0,  59.0, 0.0)));
}

float cWorley3DW(vec3 p, float freq)
{
	// Scale so that one tile (NOISE_FREQ units) contains freq Worley cells.
	// Using integer freq values ensures the Worley also tiles seamlessly.
	vec3  id      = floor(p);
	vec3  fr      = fract(p);
	float minDist = 1.0;
	for (int x = -1; x <= 1; x++)
	for (int y = -1; y <= 1; y++)
	for (int z = -1; z <= 1; z++)
	{
		vec3 cell   = vec3(float(x), float(y), float(z));
		// Wrap neighbour cell ID to tile period.
		vec3 wrappedId = mod(id + cell, vec3(NOISE_FREQ * freq, NOISE_FREQ * freq, NUM_SLICES));
		vec3 point     = cell + cHash33W(wrappedId) - fr;
		minDist        = min(minDist, dot(point, point));
	}
	return sqrt(minDist);
}

float cInvWorley(vec3 p, float freq)
{
	return 1.0 - clamp(cWorley3DW(p, freq) / 0.75, 0.0, 1.0);
}

////////////////////////////////////////////////////////////////////////////////
// Main
void main()
{
	float col   = floor(vTexCoord.x * ATLAS_COLS);
	float row   = floor(vTexCoord.y * ATLAS_ROWS);
	float slice = row * ATLAS_COLS + col;

	// Local [0,1] UV within the 128x128 tile.
	vec2 tileUV = fract(vTexCoord * vec2(ATLAS_COLS, ATLAS_ROWS));

	// Map tile UV to noise space: [0, NOISE_FREQ) in X/Y, [0, NUM_SLICES) in Z.
	vec3 p = vec3(tileUV * NOISE_FREQ, slice);

	float perlin = cFBM4W(p);

	// Worley octaves at integer frequencies (1, 2, 4) relative to NOISE_FREQ.
	float w1 = cInvWorley(p, 1.0);
	float w2 = cInvWorley(p, 2.0);
	float w3 = cInvWorley(p, 4.0);

	gl_FragColor = vec4(perlin, w1, w2, w3);
}
