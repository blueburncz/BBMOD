#pragma once

#include <BBMOD/Matrix.hpp>
#include <terminal.hpp>

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

#define FILE_WRITE_DUAL_QUAT(f, dq) \
	do \
	{ \
		FILE_WRITE_DATA(f, (dq)[0]); \
		FILE_WRITE_DATA(f, (dq)[1]); \
		FILE_WRITE_DATA(f, (dq)[2]); \
		FILE_WRITE_DATA(f, (dq)[3]); \
		FILE_WRITE_DATA(f, (dq)[4]); \
		FILE_WRITE_DATA(f, (dq)[5]); \
		FILE_WRITE_DATA(f, (dq)[6]); \
		FILE_WRITE_DATA(f, (dq)[7]); \
	} \
	while (false)

#define FILE_READ_DUAL_QUAT(f, dq) \
	do \
	{ \
		FILE_READ_DATA(f, (dq)[0]); \
		FILE_READ_DATA(f, (dq)[1]); \
		FILE_READ_DATA(f, (dq)[2]); \
		FILE_READ_DATA(f, (dq)[3]); \
		FILE_READ_DATA(f, (dq)[4]); \
		FILE_READ_DATA(f, (dq)[5]); \
		FILE_READ_DATA(f, (dq)[6]); \
		FILE_READ_DATA(f, (dq)[7]); \
	} \
	while (false)
