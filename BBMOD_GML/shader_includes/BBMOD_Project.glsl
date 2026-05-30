/// @desc Projects a screen-space UV to view-space.
/// @param tanAspect (tanFovY*(screenWidth/screenHeight), -tanFovY), where
///                  tanFovY = tan(fov*0.5).
/// @param texCoord Screen-space UV.
/// @param depth Scene depth at texCoord.
/// @return Point projected to view-space.
vec3 BBMOD_Project(vec2 tanAspect, vec2 texCoord, float depth)
{
#if !(defined(_YY_HLSL11_) || defined(_YY_PSSL_))
	tanAspect.y *= -1.0;
#endif
	return vec3(tanAspect * (texCoord * 2.0 - 1.0) * depth, depth);
}
