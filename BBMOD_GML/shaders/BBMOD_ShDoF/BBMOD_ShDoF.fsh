varying vec2 vTexCoord;

uniform sampler2D uCoCNear;
uniform sampler2D uCoCFar;
uniform float uCoCScaleNear;
uniform float uCoCScaleFar;
uniform vec2 uTexel;
uniform float uBokehShape;
uniform float uStep;

// Source: https://www.adriancourreges.com/blog/2018/12/02/ue4-optimized-post-effects/
#define PI 3.14159265359
#define PI_OVER_2 1.5707963
#define PI_OVER_4 0.785398
#define EPSILON 0.000001

// Maps a unit square in [-1, 1] to a unit disk in [-1, 1]. Shirley 97 "A Low Distortion Map Between Disk and Square"
// Inputs: cartesian coordinates
// Return: new circle-mapped polar coordinates (radius, angle)
vec2 UnitSquareToUnitDiskPolar(vec2 uv)
{
	float a = uv.x;
	float b = uv.y;
	float radius, angle;
	if (abs(a) > abs(b))
	{
		// First region (left and right quadrants of the disk)
		radius = a;
		angle = b / (a + EPSILON) * PI_OVER_4;
	}
	else
	{
		// Second region (top and botom quadrants of the disk)
		radius = b;
		angle = PI_OVER_2 - (a / (b + EPSILON) * PI_OVER_4);
	}
	if (radius < 0.0)
	{
		// Always keep radius positive
		radius *= -1.0;
		angle += PI;
	}
	return vec2(radius, angle);
}

// Maps a unit square in [-1, 1] to a unit disk in [-1, 1]
// Inputs: cartesian coordinates
// Return: new circle-mapped cartesian coordinates
vec2 SquareToDiskMapping(vec2 uv)
{
	vec2 PolarCoord = UnitSquareToUnitDiskPolar(uv);
	return vec2(PolarCoord.x * cos(PolarCoord.y), PolarCoord.x * sin(PolarCoord.y));
}

// Remap a unit square in [0, 1] to a polygon in [-1, 1] with <edgeCount> edges rotated by <shapeRotation> radians
// Inputs: cartesian coordinates
// Return: new polygon-mapped cartesian coordinates
vec2 SquareToPolygonMapping(vec2 uv, float edgeCount, float shapeRotation)
{
	vec2 PolarCoord = UnitSquareToUnitDiskPolar(uv); // (radius, angle)

	// Re-scale radius to match a polygon shape
	PolarCoord.x *=                                      cos(PI / edgeCount)
	                / //----------------------------------------------------------------------------------------------
	                cos(PolarCoord.y - (2.0 * PI / edgeCount) * floor((edgeCount*PolarCoord.y + PI) / 2.0 / PI ));

	// Apply a rotation to the polygon shape
	PolarCoord.y += shapeRotation;

	return vec2(PolarCoord.x * cos(PolarCoord.y), PolarCoord.x * sin(PolarCoord.y));
}

float SampleCoC(sampler2D texCoCNear, sampler2D texCoCFar, vec2 uv, float scaleNear, float scaleFar)
{
	float cocNear = texture2D(texCoCNear, uv).g * scaleNear;
	float cocFar = texture2D(texCoCNear, uv).r * scaleFar;
	// Source: https://developer.nvidia.com/gpugems/gpugems3/part-iv-image-effects/chapter-28-practical-post-process-depth-field
	return (2.0 * max(cocFar, cocNear)) - cocFar;
}

void main()
{
	float coc = SampleCoC(uCoCNear, uCoCFar, vTexCoord, uCoCScaleNear, uCoCScaleFar);
	if (coc <= 0.0)
	{
		discard;
	}
	vec4 color = vec4(0.0);
	float weight = 0.0;
	float stepSumI = -1.0;
	for (float i = -1.0; i <= 1.0; i += 0.01)
	{
		float stepSumJ = -1.0;
		for (float j = -1.0; j <= 1.0; j += 0.01)
		{
			vec2 sampleOffset = coc
				* ((uBokehShape >= 3.0)
					? SquareToPolygonMapping(vec2(stepSumI, stepSumJ), uBokehShape, 0.0)
					: SquareToDiskMapping(vec2(stepSumI, stepSumJ)))
				* uTexel;
			color += texture2D(gm_BaseTexture, vTexCoord + sampleOffset);
			weight += 1.0;
			stepSumJ += uStep;
			if (stepSumJ > 1.0)
			{
				break;
			}
		}
		stepSumI += uStep;
		if (stepSumI > 1.0)
		{
			break;
		}
	}
	gl_FragColor = color / max(weight, EPSILON);
}
