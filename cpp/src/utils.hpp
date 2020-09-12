#pragma once

#define FILE_WRITE_DATA(f, d) \
	(f).write(reinterpret_cast<const char*>(&(d)), sizeof(d))

#define FILE_WRITE_VEC2(f, v) \
	do \
	{ \
		FILE_WRITE_DATA(f, (v).x); \
		FILE_WRITE_DATA(f, (v).y); \
	} \
	while (false)

#define FILE_WRITE_VEC3(f, v) \
	do \
	{ \
		FILE_WRITE_VEC2(f, v); \
		FILE_WRITE_DATA(f, (v).z); \
	} \
	while (false)

#define FILE_WRITE_VEC4(f, v) \
	do \
	{ \
		FILE_WRITE_VEC3(f, v); \
		FILE_WRITE_DATA(f, (v).w); \
	} \
	while (false)

#define FILE_WRITE_QUAT(f, q) \
	FILE_WRITE_VEC4(f, q)

#define FILE_WRITE_MATRIX(f, m) \
	do \
	{ \
		FILE_WRITE_DATA(f, (m).a1); FILE_WRITE_DATA(f, (m).b1); FILE_WRITE_DATA(f, (m).c1); FILE_WRITE_DATA(f, (m).d1); \
		FILE_WRITE_DATA(f, (m).a2); FILE_WRITE_DATA(f, (m).b2); FILE_WRITE_DATA(f, (m).c2); FILE_WRITE_DATA(f, (m).d2); \
		FILE_WRITE_DATA(f, (m).a3); FILE_WRITE_DATA(f, (m).b3); FILE_WRITE_DATA(f, (m).c3); FILE_WRITE_DATA(f, (m).d3); \
		FILE_WRITE_DATA(f, (m).a4); FILE_WRITE_DATA(f, (m).b4); FILE_WRITE_DATA(f, (m).c4); FILE_WRITE_DATA(f, (m).d4); \
	} \
	while (false)
