#pragma once

#include <cstring>

typedef float vec4_t[4];

#define VEC4_ZERO \
	{ 0.0f, 0.0f, 0.0f, 0.0f }

static inline void vec4_copy(const vec4_t from, vec4_t to)
{
	std::memcpy(to, from, sizeof(float) * 4);
}
