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

GM_EXPORT gmreal_t bbmod_dll_get_disable_normal()
{
	 return (gmreal_t)gConfig.disableNormals;
}

GM_EXPORT gmreal_t bbmod_dll_set_disable_normal(gmreal_t disable)
{
	gConfig.disableNormals = (bool)disable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_flip_normal()
{
	return (gmreal_t)gConfig.flipNormals;
}

GM_EXPORT gmreal_t bbmod_dll_set_flip_normal(gmreal_t flip)
{
	gConfig.flipNormals = (bool)flip;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_gen_normal()
{
	return (gmreal_t)gConfig.genNormals;
}

GM_EXPORT gmreal_t bbmod_dll_set_gen_normal(gmreal_t generate)
{
	gConfig.genNormals = generate;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_disable_uv()
{
	return (gmreal_t)gConfig.disableTextureCoords;
}

GM_EXPORT gmreal_t bbmod_dll_set_disable_uv(gmreal_t disable)
{
	gConfig.disableTextureCoords = (bool)disable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_flip_uv_horizontally()
{
	return (gmreal_t)gConfig.flipTextureHorizontally;
}

GM_EXPORT gmreal_t bbmod_dll_set_flip_uv_horizontally(gmreal_t flip)
{
	gConfig.flipTextureHorizontally = (bool)flip;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_flip_uv_vertically()
{
	return (gmreal_t)gConfig.flipTextureVertically;
}

GM_EXPORT gmreal_t bbmod_dll_set_flip_uv_vertically(gmreal_t flip)
{
	gConfig.flipTextureVertically = (bool)flip;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_disable_color()
{
	return (gmreal_t)gConfig.disableVertexColors;
}

GM_EXPORT gmreal_t bbmod_dll_set_disable_color(gmreal_t disable)
{
	gConfig.disableVertexColors = (bool)disable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_disable_tangent()
{
	return (gmreal_t)gConfig.disableTangentW;
}

GM_EXPORT gmreal_t bbmod_dll_set_disable_tangent(gmreal_t disable)
{
	gConfig.disableTangentW = (bool)disable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_disable_bone()
{
	return (gmreal_t)gConfig.disableBones;
}

GM_EXPORT gmreal_t bbmod_dll_set_disable_bone(gmreal_t disable)
{
	gConfig.disableBones = (bool)disable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_convert(gmstring_t fin, gmstring_t fout)
{
	return ConvertToBBMOD(fin, fout, gConfig);
}

#endif // _WINDLL