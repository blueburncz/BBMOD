#include <BBMOD/Importer.hpp>

#include <cmath>
#ifdef _WIN32
#	include <d3d11.h>
#endif

#ifdef _WIN32
#	define GM_EXPORT extern "C" __declspec (dllexport)
#else
#	define GM_EXPORT extern "C"
#endif

#define GM_TRUE 1.0

#define GM_FALSE 0.0

typedef double gmreal_t;

typedef const char* gmstring_t;

typedef void* gmptr_t;

SConfig gConfig;

#ifdef _WIN32
ID3D11Device* gDevice;

ID3D11DeviceContext* gContext;
#endif // _WIN32

GM_EXPORT gmreal_t bbmod_d3d11_init(gmptr_t device, gmptr_t context)
{
#ifdef _WIN32
	gDevice = (ID3D11Device*)device;
	gContext = (ID3D11DeviceContext*)context;
	return GM_TRUE;
#else
	return GM_FALSE;
#endif
}

GM_EXPORT gmreal_t bbmod_d3d11_texture_set_stage_vs(gmreal_t index)
{
#ifdef _WIN32
	UINT startSlot = (UINT)index;
	// Note: Max could be D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT, but this
	// is for compatibility with the rest of the platforms.
	if (startSlot < 0 || startSlot >= 8)
	{
		return GM_FALSE;
	}
	ID3D11ShaderResourceView* shaderResourceView;
	gContext->PSGetShaderResources(0, 1, &shaderResourceView);
	gContext->VSSetShaderResources(startSlot, 1, &shaderResourceView);
	return GM_TRUE;
#else
	return GM_FALSE;
#endif
}

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
	gConfig.GenNormals = (uint32_t)generate;
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

GM_EXPORT gmreal_t bbmod_dll_get_disable_uv2()
{
	return (gmreal_t)gConfig.DisableTextureCoords2;
}

GM_EXPORT gmreal_t bbmod_dll_set_disable_uv2(gmreal_t disable)
{
	gConfig.DisableTextureCoords2 = (bool)disable;
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

GM_EXPORT gmreal_t bbmod_dll_get_pre_transform()
{
	return (gmreal_t)gConfig.PreTransform;
}

GM_EXPORT gmreal_t bbmod_dll_set_pre_transform(gmreal_t enable)
{
	gConfig.PreTransform = (bool)enable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_apply_scale()
{
	return (gmreal_t)gConfig.ApplyScale;
}

GM_EXPORT gmreal_t bbmod_dll_set_apply_scale(gmreal_t enable)
{
	gConfig.ApplyScale = (bool)enable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_optimize_animations()
{
	return (gmreal_t)gConfig.AnimationOptimization;
}

GM_EXPORT gmreal_t bbmod_dll_set_optimize_animations(gmreal_t level)
{
	gConfig.AnimationOptimization = (uint32_t)level;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_sampling_rate()
{
	return (gmreal_t)gConfig.SamplingRate;
}

GM_EXPORT gmreal_t bbmod_dll_set_sampling_rate(gmreal_t fps)
{
	double samplingRate = floor((double)fps);
	gConfig.SamplingRate = (samplingRate < 1.0) ? 1.0 : samplingRate;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_export_materials()
{
	return (gmreal_t)gConfig.ExportMaterials;
}

GM_EXPORT gmreal_t bbmod_dll_set_export_materials(gmreal_t enable)
{
	gConfig.ExportMaterials = (bool)enable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_zup()
{
	return (gmreal_t)gConfig.ConvertToZUp;
}

GM_EXPORT gmreal_t bbmod_dll_set_zup(gmreal_t enable)
{
	gConfig.ConvertToZUp = (bool)enable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_get_prefix()
{
	return (gmreal_t)gConfig.Prefix;
}

GM_EXPORT gmreal_t bbmod_dll_set_prefix(gmreal_t enable)
{
	gConfig.Prefix = (bool)enable;
	return BBMOD_SUCCESS;
}

GM_EXPORT gmreal_t bbmod_dll_convert(gmstring_t fin, gmstring_t fout)
{
	return ConvertToBBMOD(fin, fout, gConfig);
}
