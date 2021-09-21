#pragma once

#include <BBMOD/Math.hpp>
#include <BBMOD/Quaternion.hpp>
#include <BBMOD/Vector3.hpp>
#include <cstring>

typedef float dual_quat_t[8];

#define DUAL_QUATERNION_IDENTITY \
	{ 0.0f, 0.0f, 0.0f, 1.0f, \
	  0.0f, 0.0f, 0.0f, 0.0f }

static inline float* dual_quaternion_create()
{
	float* dq = new float[8];
	std::memset(dq, 0, sizeof(float) * 8);
	dq[3] = 1.0;
	return dq;
}

static inline void dual_quaternion_copy(const dual_quat_t from, dual_quat_t to)
{
	std::memcpy(to, from, sizeof(float) * 8);
}

static inline void dual_quaternion_from_translation_rotation(dual_quat_t q, const vec3_t t, const quat_t r)
{
	float* p = q;
	float* real = p;
	float* dual = p + 4;

	quaternion_copy(r, real);
	quaternion_normalize(real);

	dual[0] = t[0];
	dual[1] = t[1];
	dual[2] = t[2];
	dual[3] = 0.0f;
	quaternion_multiply(dual, real);
	quaternion_scale(dual, 0.5f);
}

static inline void dual_quaternion_multiply(dual_quat_t _dq1, dual_quat_t _dq2, dual_quat_t _out, size_t _outIndex)
{
	float _dq1r0 = _dq1[0];
	float _dq1r1 = _dq1[1];
	float _dq1r2 = _dq1[2];
	float _dq1r3 = _dq1[3];

	float _dq1d0 = _dq1[4];
	float _dq1d1 = _dq1[5];
	float _dq1d2 = _dq1[6];
	float _dq1d3 = _dq1[7];

	float _dq2r0 = _dq2[0];
	float _dq2r1 = _dq2[1];
	float _dq2r2 = _dq2[2];
	float _dq2r3 = _dq2[3];

	float _dq2d0 = _dq2[4];
	float _dq2d1 = _dq2[5];
	float _dq2d2 = _dq2[6];
	float _dq2d3 = _dq2[7];

	_out[_outIndex + 0] = (_dq2r3 * _dq1r0 + _dq2r0 * _dq1r3 + _dq2r1 * _dq1r2 - _dq2r2 * _dq1r1);
	_out[_outIndex + 1] = (_dq2r3 * _dq1r1 + _dq2r1 * _dq1r3 + _dq2r2 * _dq1r0 - _dq2r0 * _dq1r2);
	_out[_outIndex + 2] = (_dq2r3 * _dq1r2 + _dq2r2 * _dq1r3 + _dq2r0 * _dq1r1 - _dq2r1 * _dq1r0);
	_out[_outIndex + 3] = (_dq2r3 * _dq1r3 - _dq2r0 * _dq1r0 - _dq2r1 * _dq1r1 - _dq2r2 * _dq1r2);

	_out[_outIndex + 4] = (_dq2d3 * _dq1r0 + _dq2d0 * _dq1r3 + _dq2d1 * _dq1r2 - _dq2d2 * _dq1r1)
		+ (_dq2r3 * _dq1d0 + _dq2r0 * _dq1d3 + _dq2r1 * _dq1d2 - _dq2r2 * _dq1d1);
	_out[_outIndex + 5] = (_dq2d3 * _dq1r1 + _dq2d1 * _dq1r3 + _dq2d2 * _dq1r0 - _dq2d0 * _dq1r2)
		+ (_dq2r3 * _dq1d1 + _dq2r1 * _dq1d3 + _dq2r2 * _dq1d0 - _dq2r0 * _dq1d2);
	_out[_outIndex + 6] = (_dq2d3 * _dq1r2 + _dq2d2 * _dq1r3 + _dq2d0 * _dq1r1 - _dq2d1 * _dq1r0)
		+ (_dq2r3 * _dq1d2 + _dq2r2 * _dq1d3 + _dq2r0 * _dq1d1 - _dq2r1 * _dq1d0);
	_out[_outIndex + 7] = (_dq2d3 * _dq1r3 - _dq2d0 * _dq1r0 - _dq2d1 * _dq1r1 - _dq2d2 * _dq1r2)
		+ (_dq2r3 * _dq1d3 - _dq2r0 * _dq1d0 - _dq2r1 * _dq1d1 - _dq2r2 * _dq1d2);
}