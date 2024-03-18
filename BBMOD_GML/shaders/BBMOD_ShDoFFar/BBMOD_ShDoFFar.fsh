varying vec2 v_vTexCoord;

uniform sampler2D u_texDepth;
uniform float u_fDepthFocus; // Divided by ZFar!
uniform float u_fCoCScale;
uniform vec2 u_vTexel;

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}

float GetCoC(float depth, float depthFocus, float scale)
{
	return scale * clamp(1.0 - (depthFocus / depth), -1.0, 1.0);
	//return scale * (1.0 - (depthFocus / depth));
	//return scale * abs(1.0 - (depthFocus / depth));
}

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

void main()
{
	float depth = xDecodeDepth(texture2D(u_texDepth, v_vTexCoord).rgb);
	float coc = GetCoC(depth, u_fDepthFocus, u_fCoCScale);
	vec4 color = texture2D(gm_BaseTexture, v_vTexCoord);
	float weight = 1.0;
	for (float i = -1.0; i <= 1.0; i += 2.0/8.0)
	{
		for (float j = -1.0; j <= 1.0; j += 2.0/8.0)
		{
			vec2 sampleOffset = coc * SquareToPolygonMapping(vec2(i, j), 5.0, 0.0) * u_vTexel;
			vec2 sampleUV = v_vTexCoord + sampleOffset;
			float sampleDepth = xDecodeDepth(texture2D(u_texDepth, sampleUV).rgb);
			float sampleCoC = GetCoC(sampleDepth, u_fDepthFocus, u_fCoCScale);
			vec4 sampleColor = texture2D(gm_BaseTexture, sampleUV);
			float sampleWeight = 1.0;//abs(min(coc, sampleCoC)) / u_fCoCScale;
			if (length(sampleOffset / u_vTexel) - abs(coc) - abs(sampleCoC) > 0.0)
			{
				sampleWeight = 0.0;
			}
			color += sampleColor * sampleWeight;
			weight += sampleWeight;
		}
	}
	gl_FragColor = color / max(weight, EPSILON);
	gl_FragColor.a *= (coc > 0.0) ? 1.0 : 0.0;
}
