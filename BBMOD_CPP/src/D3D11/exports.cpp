#include <BBMOD/exports.hpp>

#include <d3d11.h>

#pragma comment(lib, "d3d11.lib")

static bool gInitialized = false;
static ID3D11Device* gDevice = nullptr;
static ID3D11DeviceContext* gContext = nullptr;

GM_EXPORT double bbmod_d3d11_init_impl(char* _device, char* _context)
{
	gInitialized = true;
	gDevice = reinterpret_cast<ID3D11Device*>(_device);
	gContext = reinterpret_cast<ID3D11DeviceContext*>(_context);
	return 1.0;
}

GM_EXPORT double bbmod_d3d11_copy_srv_ps_vs(double _indexSrc, double _indexDest)
{
	if (!gInitialized
		|| _indexSrc < 0.0 || _indexSrc >= 8.0
		|| _indexDest < 0.0 || _indexDest >= D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT)
	{
		return 0.0;
	}
	auto src = static_cast<UINT>(_indexSrc);
	auto dest = static_cast<UINT>(_indexDest);
	ID3D11ShaderResourceView* shaderResourceView = nullptr;
	gContext->PSGetShaderResources(src, 1, &shaderResourceView);
	gContext->VSSetShaderResources(dest, 1, &shaderResourceView);
	return 1.0;
}
