#pragma once

#include <cstring>

typedef float vec2_t[2];

#define VEC2_ZERO \
	{ 0.0f, 0.0f }

static inline void vec2_copy(const vec2_t from, vec2_t to)
{
	std::memcpy(to, from, sizeof(float) * 2);
}
