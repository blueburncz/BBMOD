#pragma once

#include <BBMOD/Math.hpp>
#include <cstring>

typedef float vec3_t[3];

#define VEC3_ZERO \
	{ 0.0f, 0.0f, 0.0f }

static inline void vec3_copy(const vec3_t from, vec3_t to)
{
	std::memcpy(to, from, sizeof(float) * 3);
}

static inline void vec3_lerp(vec3_t a, const vec3_t b, float factor)
{
	a[0] = LERP(a[0], b[0], factor);
	a[1] = LERP(a[1], b[1], factor);
	a[2] = LERP(a[2], b[2], factor);
}

static inline void vec3_normalize(vec3_t v)
{
	float l = v[0] * v[0] + v[1] * v[1] + v[2] * v[2];
	if (l > 0.0f)
	{
		float n = 1.0f / l;
		v[0] *= n;
		v[1] *= n;
		v[2] *= n;
	}
}
