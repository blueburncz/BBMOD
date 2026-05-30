/// @desc Punctual light position/range/color data.
/// Layout: [(x,y,z,range), (r,g,b,intensity), ...]
uniform vec4 bbmod_LightPunctualDataA[(BBMOD_MAX_PUNCTUAL_LIGHTS + BBMOD_MAX_PUNCTUAL_LIGHTS)];

/// @desc Punctual light spot-cone and direction data.
/// Layout: [(isSpot,dcosInner,dcosOuter), (dX,dY,dZ), ...]
uniform vec3 bbmod_LightPunctualDataB[(BBMOD_MAX_PUNCTUAL_LIGHTS + BBMOD_MAX_PUNCTUAL_LIGHTS)];

/// @desc Gets an entry from the punctual light position/range/color array.
/// @param index Array index.
/// @return vec4 data entry at that index.
vec4 BBMOD_GetPunctualLightDataA(int index)
{
#if defined(_YY_GLSL_) || defined(_YY_HLSL11_) || defined(_YY_PSSL_)
	return bbmod_LightPunctualDataA[index];
#else
	if (index == 0)       return bbmod_LightPunctualDataA[0];
	else if (index == 1)  return bbmod_LightPunctualDataA[1];
	else if (index == 2)  return bbmod_LightPunctualDataA[2];
	else if (index == 3)  return bbmod_LightPunctualDataA[3];
	else if (index == 4)  return bbmod_LightPunctualDataA[4];
	else if (index == 5)  return bbmod_LightPunctualDataA[5];
	else if (index == 6)  return bbmod_LightPunctualDataA[6];
	else if (index == 7)  return bbmod_LightPunctualDataA[7];
	else if (index == 8)  return bbmod_LightPunctualDataA[8];
	else if (index == 9)  return bbmod_LightPunctualDataA[9];
	else if (index == 10) return bbmod_LightPunctualDataA[10];
	else if (index == 11) return bbmod_LightPunctualDataA[11];
	else if (index == 12) return bbmod_LightPunctualDataA[12];
	else if (index == 13) return bbmod_LightPunctualDataA[13];
	else if (index == 14) return bbmod_LightPunctualDataA[14];
	else if (index == 15) return bbmod_LightPunctualDataA[15];
	else                  return vec4(0.0);
#endif
}

/// @desc Gets an entry from the punctual light spot-cone/direction array.
/// @param index Array index.
/// @return vec3 data entry at that index.
vec3 BBMOD_GetPunctualLightDataB(int index)
{
#if defined(_YY_GLSL_) || defined(_YY_HLSL11_) || defined(_YY_PSSL_)
	return bbmod_LightPunctualDataB[index];
#else
	if (index == 0)       return bbmod_LightPunctualDataB[0];
	else if (index == 1)  return bbmod_LightPunctualDataB[1];
	else if (index == 2)  return bbmod_LightPunctualDataB[2];
	else if (index == 3)  return bbmod_LightPunctualDataB[3];
	else if (index == 4)  return bbmod_LightPunctualDataB[4];
	else if (index == 5)  return bbmod_LightPunctualDataB[5];
	else if (index == 6)  return bbmod_LightPunctualDataB[6];
	else if (index == 7)  return bbmod_LightPunctualDataB[7];
	else if (index == 8)  return bbmod_LightPunctualDataB[8];
	else if (index == 9)  return bbmod_LightPunctualDataB[9];
	else if (index == 10) return bbmod_LightPunctualDataB[10];
	else if (index == 11) return bbmod_LightPunctualDataB[11];
	else if (index == 12) return bbmod_LightPunctualDataB[12];
	else if (index == 13) return bbmod_LightPunctualDataB[13];
	else if (index == 14) return bbmod_LightPunctualDataB[14];
	else if (index == 15) return bbmod_LightPunctualDataB[15];
	else                  return vec3(0.0);
#endif
}
