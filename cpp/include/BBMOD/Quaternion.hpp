#pragma once

#include <BBMOD/Math.hpp>
#include <cstring>
#include <cmath>

typedef float quat_t[4];

#define QUATERNION_IDENTITY \
	{ 0.0f, 0.0f, 0.0f, 1.0f }

static inline void quaternion_copy(const quat_t from, quat_t to)
{
	std::memcpy(to, from, sizeof(float) * 4);
}

static inline void quaternion_conjugate(quat_t q)
{
	q[0] = -q[0];
	q[1] = -q[1];
	q[2] = -q[2];
}

static inline float quaternion_dot(const quat_t q1, const quat_t q2)
{
	return (q1[0] * q2[0]
		+ q1[1] * q2[1]
		+ q1[2] * q2[2]
		+ q1[3] * q2[3]);
}

static inline float quaternion_lengthsqr(const quat_t q)
{
	return quaternion_dot(q, q);
}


static inline float quaternion_length(const quat_t q)
{
	return sqrtf(quaternion_lengthsqr(q));
}

static inline void quaternion_scale(quat_t q, float s)
{
	q[0] *= s;
	q[1] *= s;
	q[2] *= s;
	q[3] *= s;
}

static inline float quaternion_inverse(quat_t q)
{
	quaternion_conjugate(q);
	float s = 1.0f / quaternion_length(q);
	quaternion_scale(q, s);
}

static inline void quaternion_normalize(quat_t q)
{
	float lengthSqr = quaternion_lengthsqr(q);
	if (lengthSqr <= 0.0f)
	{
		return;
	}
	float s = 1.0f / sqrtf(lengthSqr);
	quaternion_scale(q, s);
}

static inline void quaternion_slerp(quat_t q1, const quat_t q2, float f)
{
	static quat_t _q1;
	static quat_t _q2;

	quaternion_copy(q1, _q1);
	quaternion_copy(q2, _q2);

	quaternion_normalize(_q1);
	quaternion_normalize(_q2);

	float dot = quaternion_dot(_q1, _q2);

	if (dot < 0.0f)
	{
		dot = -dot;
		quaternion_scale(_q2, -1.0f);
	}

	if (dot > 0.9995f)
	{
		q1[0] = LERP(_q1[0], _q2[0], f);
		q1[1] = LERP(_q1[1], _q2[1], f);
		q1[2] = LERP(_q1[2], _q2[2], f);
		q1[3] = LERP(_q1[3], _q2[3], f);
		quaternion_normalize(q1);
	}
	else
	{
		float theta0 = acosf(dot);
		float theta = theta0 * f;
		float sinTheta = sinf(theta);
		float sinTheta0 = sinf(theta0);
		float f2 = sinTheta / sinTheta0;
		float f1 = cosf(theta) - (dot * f2);

		q1[0] = (_q1[0] * f1) + (_q2[0] * f2);
		q1[1] = (_q1[1] * f1) + (_q2[1] * f2);
		q1[2] = (_q1[2] * f1) + (_q2[2] * f2);
		q1[3] = (_q1[3] * f1) + (_q2[3] * f2);
	}
}

static inline void quaternion_to_matrix(const quat_t q, float m[16])
{
	float q0sqr = q[0] * q[0];
	float q1sqr = q[1] * q[1];
	float q2sqr = q[2] * q[2];
	float q0q1 = q[0] * q[1];
	float q0q2 = q[0] * q[2];
	float q3q2 = q[3] * q[2];
	float q1q2 = q[1] * q[2];
	float q3q0 = q[3] * q[0];
	float q3q1 = q[3] * q[1];
	
	m[0] = 1.0f - 2.0f * (q1sqr + q2sqr);
	m[1] = 2.0f * (q0q1 + q3q2);
	m[2] = 2.0f * (q0q2 - q3q1);

	m[4] = 2.0f * (q0q1 - q3q2);
	m[5] = 1.0f - 2.0f * (q0sqr + q2sqr);
	m[6] = 2.0f * (q1q2 + q3q0);

	m[8] = 2.0f * (q0q2 + q3q1);
	m[9] = 2.0f * (q1q2 - q3q0);
	m[10] = 1.0f - 2.0f * (q0sqr + q1sqr);
}
