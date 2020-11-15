#pragma once

#include <BBMOD/Matrix.hpp>

#define FILE_WRITE_DATA(f, d) \
	(f).write(reinterpret_cast<const char*>(&(d)), sizeof(d))

#define FILE_READ_DATA(f, d) \
	(f).read(reinterpret_cast<char*>(&(d)), sizeof(d))

#define FILE_WRITE_VEC2(f, v) \
	do \
	{ \
		FILE_WRITE_DATA(f, (v)[0]); \
		FILE_WRITE_DATA(f, (v)[1]); \
	} \
	while (false)

#define FILE_READ_VEC2(f, v) \
	do \
	{ \
		FILE_READ_DATA(f, (v)[0]); \
		FILE_READ_DATA(f, (v)[1]); \
	} \
	while (false)

#define FILE_WRITE_VEC3(f, v) \
	do \
	{ \
		FILE_WRITE_VEC2(f, v); \
		FILE_WRITE_DATA(f, (v)[2]); \
	} \
	while (false)

#define FILE_READ_VEC3(f, v) \
	do \
	{ \
		FILE_READ_VEC2(f, v); \
		FILE_READ_DATA(f, (v)[2]); \
	} \
	while (false)

#define FILE_WRITE_VEC4(f, v) \
	do \
	{ \
		FILE_WRITE_VEC3(f, v); \
		FILE_WRITE_DATA(f, (v)[3]); \
	} \
	while (false)

#define FILE_READ_VEC4(f, v) \
	do \
	{ \
		FILE_READ_VEC3(f, v); \
		FILE_READ_DATA(f, (v)[3]); \
	} \
	while (false)

#define FILE_WRITE_QUAT(f, q) \
	FILE_WRITE_VEC4(f, q)

#define FILE_READ_QUAT(f, q) \
	FILE_READ_VEC4(f, q)

#define FILE_WRITE_MATRIX(f, m) \
	do \
	{ \
		for (size_t i = 0; i < 16; ++i) \
		{ \
			FILE_WRITE_DATA(f, (m)[i]); \
		} \
	} \
	while (false)

#define FILE_READ_MATRIX(f, m) \
	do \
	{ \
		for (size_t i = 0; i < 16; ++i) \
		{ \
			FILE_READ_DATA(f, (m)[i]); \
		} \
	} \
	while (false)
