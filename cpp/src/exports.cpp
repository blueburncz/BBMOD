#ifdef _WINDLL

#include <BBMOD/Importer.hpp>

#define GM_EXPORT extern "C" __declspec (dllexport)

#define GM_TRUE 1.0

#define GM_FALSE 0.0

typedef double gmreal_t;

typedef const char* gmstring_t;

typedef void* gmptr_t;

SConfig gConfig;

GM_EXPORT gmreal_t bbmod_dll_get_left_handed()
{
	return (gmreal_t)gConfig.LeftHanded;
}

GM_EXPORT gmreal_t bbmod_dll_set_left_handed(gmreal_t leftHanded)
{
	gConfig.LeftHanded = (bool)leftHanded;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_invert_winding()
{
	return (gmreal_t)gConfig.InvertWinding;
}

GM_EXPORT gmreal_t bbmod_dll_set_invert_winding(gmreal_t invertWinding)
{
	gConfig.InvertWinding = (bool)invertWinding;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_disable_normal()
{
	 return (gmreal_t)gConfig.DisableNormals;
}

GM_EXPORT gmreal_t bbmod_dll_set_disable_normal(gmreal_t disable)
{
	gConfig.DisableNormals = (bool)disable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_flip_normal()
{
	return (gmreal_t)gConfig.FlipNormals;
}

GM_EXPORT gmreal_t bbmod_dll_set_flip_normal(gmreal_t flip)
{
	gConfig.FlipNormals = (bool)flip;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_gen_normal()
{
	return (gmreal_t)gConfig.GenNormals;
}

GM_EXPORT gmreal_t bbmod_dll_set_gen_normal(gmreal_t generate)
{
	gConfig.GenNormals = (size_t)generate;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_disable_uv()
{
	return (gmreal_t)gConfig.DisableTextureCoords;
}

GM_EXPORT gmreal_t bbmod_dll_set_disable_uv(gmreal_t disable)
{
	gConfig.DisableTextureCoords = (bool)disable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_flip_uv_horizontally()
{
	return (gmreal_t)gConfig.FlipTextureHorizontally;
}

GM_EXPORT gmreal_t bbmod_dll_set_flip_uv_horizontally(gmreal_t flip)
{
	gConfig.FlipTextureHorizontally = (bool)flip;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_flip_uv_vertically()
{
	return (gmreal_t)gConfig.FlipTextureVertically;
}

GM_EXPORT gmreal_t bbmod_dll_set_flip_uv_vertically(gmreal_t flip)
{
	gConfig.FlipTextureVertically = (bool)flip;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_disable_color()
{
	return (gmreal_t)gConfig.DisableVertexColors;
}

GM_EXPORT gmreal_t bbmod_dll_set_disable_color(gmreal_t disable)
{
	gConfig.DisableVertexColors = (bool)disable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_disable_tangent()
{
	return (gmreal_t)gConfig.DisableTangentW;
}

GM_EXPORT gmreal_t bbmod_dll_set_disable_tangent(gmreal_t disable)
{
	gConfig.DisableTangentW = (bool)disable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_disable_bone()
{
	return (gmreal_t)gConfig.DisableBones;
}

GM_EXPORT gmreal_t bbmod_dll_set_disable_bone(gmreal_t disable)
{
	gConfig.DisableBones = (bool)disable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_optimize_materials()
{
	return (gmreal_t)gConfig.OptimizeMaterials;
}

GM_EXPORT gmreal_t bbmod_dll_set_optimize_materials(gmreal_t optimize)
{
	gConfig.OptimizeMaterials = (bool)optimize;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_optimize_meshes()
{
	return (gmreal_t)gConfig.OptimizeMeshes;
}

GM_EXPORT gmreal_t bbmod_dll_set_optimize_meshes(gmreal_t optimize)
{
	gConfig.OptimizeMeshes = (bool)optimize;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_optimize_nodes()
{
	return (gmreal_t)gConfig.OptimizeNodes;
}

GM_EXPORT gmreal_t bbmod_dll_set_optimize_nodes(gmreal_t optimize)
{
	gConfig.OptimizeNodes = (bool)optimize;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_convert(gmstring_t fin, gmstring_t fout)
{
	return ConvertToBBMOD(fin, fout, gConfig);
}

#endif // _WINDLL
