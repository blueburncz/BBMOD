#pragma once

#ifdef _WIN32
#	define GM_EXPORT extern "C" __declspec(dllexport)
#else
#	define GM_EXPORT extern "C"
#endif
