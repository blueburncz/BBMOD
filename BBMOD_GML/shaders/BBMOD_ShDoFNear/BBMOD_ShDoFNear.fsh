varying vec2 v_vTexCoord;

uniform sampler2D u_texCoC;
uniform float u_fCoCScale;
uniform vec2 u_vTexel;

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

float SampleCoC(sampler2D texCoC, vec2 uv, float scale)
{
	vec3 coc = texture2D(texCoC, uv).rgb;
	float cocFar = coc.r;
	float cocNear = -coc.b;
	return scale * ((abs(cocNear) > cocFar) ? cocNear : cocFar);
}

void main()
{
	float coc = SampleCoC(u_texCoC, v_vTexCoord, u_fCoCScale);
	vec4 colorCenter = texture2D(gm_BaseTexture, v_vTexCoord);
	vec4 color = colorCenter;
	float weight = 1.0;
	for (float i = -1.0; i <= 1.0; i += 2.0/8.0)
	{
		for (float j = -1.0; j <= 1.0; j += 2.0/8.0)
		{
			vec2 sampleOffset = coc * SquareToPolygonMapping(vec2(i, j), 5.0, 0.0) * u_vTexel;
			vec2 sampleUV = v_vTexCoord + sampleOffset;
			float sampleCoC = SampleCoC(u_texCoC, sampleUV, u_fCoCScale);
			vec4 sampleColor = texture2D(gm_BaseTexture, sampleUV);
			float sampleWeight = 1.0;
			if (coc > sampleCoC) sampleWeight = abs(min(coc, sampleCoC)) / u_fCoCScale;
			color += mix(colorCenter, sampleColor, sampleWeight);
			weight += 1.0;
		}
	}
	gl_FragColor = color / max(weight, EPSILON);
}
