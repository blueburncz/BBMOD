/*
Copyright (c) 2018 Jacob Maximilian Fober

This work is licensed under the Creative Commons
Attribution-ShareAlike 4.0 International License.
To view a copy of this license, visit 
http://creativecommons.org/licenses/by-sa/4.0/.
*/

// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform vec2 uTexel;
uniform float uStrength;
uniform float uClamp;
uniform float uOffset;

// Overlay blending mode
float Overlay(float LayerA, float LayerB)
{
	float MinA = min(LayerA, 0.5) * 2.0;
	float MinB = min(LayerB, 0.5) * 2.0;

	float MaxA = 1.0 - (max(LayerA, 0.5) * 2.0 - 1.0);
	float MaxB = 1.0 - (max(LayerB, 0.5) * 2.0 - 1.0);

	float Result = (MinA * MinB + 1.0 - MaxA * MaxB) * 0.5;
	return Result;
}

// Convert RGB to YUV.luma
float Luma(vec3 Source, vec3 Coefficients)
{
	vec3 Result = Source * Coefficients;
	return Result.r + Result.g + Result.b;
}

void main()
{
	vec2 Pixel = uTexel;

	Pixel *= uOffset;
	// Sample display image
	vec3 Source = texture2D(gm_BaseTexture, vTexCoord).rgb;

	vec2 North = vec2(vTexCoord.x, vTexCoord.y + Pixel.y);
	vec2 South = vec2(vTexCoord.x, vTexCoord.y - Pixel.y);
	vec2 West = vec2(vTexCoord.x + Pixel.x, vTexCoord.y);
	vec2 East = vec2(vTexCoord.x - Pixel.x, vTexCoord.y);

	// Choose luma coefficient
	vec3 LumaCoefficient = vec3(0.2126, 0.7152, 0.0722); // BT.709 Luma

	// Luma high-pass
	float HighPass;
	HighPass  = Luma(texture2D(gm_BaseTexture, North).rgb, LumaCoefficient);
	HighPass += Luma(texture2D(gm_BaseTexture, South).rgb, LumaCoefficient);
	HighPass += Luma(texture2D(gm_BaseTexture, West).rgb, LumaCoefficient);
	HighPass += Luma(texture2D(gm_BaseTexture, East).rgb, LumaCoefficient);
	HighPass *= 0.25;
	HighPass = 1.0 - HighPass;
	HighPass = (HighPass + Luma(Source, LumaCoefficient)) * 0.5;

	// Sharpen strength
	HighPass = mix(0.5, HighPass, uStrength);

	// Clamping sharpen
	HighPass = min(HighPass, uClamp);
	HighPass = max(HighPass, 1.0 - uClamp);

	vec3 Sharpen = vec3(
		Overlay(Source.r, HighPass),
		Overlay(Source.g, HighPass),
		Overlay(Source.b, HighPass));

	gl_FragColor.rgb = Sharpen;
	gl_FragColor.a = 1.0;
}
