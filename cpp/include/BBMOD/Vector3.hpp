#pragma once

#include <cstring>

typedef float vec3_t[3];

#define VEC3_ZERO \
	{ 0.0f, 0.0f, 0.0f }

static inline void vec3_copy(const vec3_t from, vec3_t to)
{
	std::memcpy(to, from, sizeof(float) * 3);
}
