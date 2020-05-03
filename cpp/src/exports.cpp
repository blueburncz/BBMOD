#ifdef _WINDLL

#include "bbmod.hpp"

#define GM_EXPORT extern "C" __declspec (dllexport)

#define GM_TRUE 1.0

#define GM_FALSE 0.0

typedef double gmreal_t;

typedef const char* gmstring_t;

typedef void* gmptr_t;

BBMODConfig gConfig;

GM_EXPORT gmreal_t bbmod_dll_get_left_handed()
{
	return (gmreal_t)gConfig.leftHanded;
}

GM_EXPORT gmreal_t bbmod_dll_set_left_handed(gmreal_t leftHanded)
{
	gConfig.leftHanded = (bool)leftHanded;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_invert_winding()
{
	return (gmreal_t)gConfig.invertWinding;
}

GM_EXPORT gmreal_t bbmod_dll_set_invert_winding(gmreal_t invertWinding)
{
	gConfig.invertWinding = (bool)invertWinding;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_convert(gmstring_t fin, gmstring_t fout)
{
	return ConvertToBBMOD(fin, fout, gConfig);
}

#endif // _WINDLL