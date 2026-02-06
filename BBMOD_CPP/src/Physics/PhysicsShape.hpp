#pragma once

#include <BBMOD/buffer.hpp>

#define BT_USE_DOUBLE_PRECISION
#include <btBulletDynamicsCommon.h>

#include <cassert>

enum class BBMOD_EPhysicsShapeType : int8_t
{
	Invalid = -1,
	Box,
	Capsule,
	Compound,
	Cone,
	ConvexHull,
	Cylinder,
	Plane,
	Sphere,
	StaticMesh,
};

enum class BBMOD_EAxis : uint8_t
{
	X,
	Y,
	Z,
};

struct BBMOD_PhysicsShapeInfo
{
	BBMOD_PhysicsShapeInfo() = default;

	BBMOD_PhysicsShapeInfo(char*& buffer)
	{
	}

	virtual ~BBMOD_PhysicsShapeInfo() = default;

	virtual void FromBuffer(char*& buffer)
	{
		auto type = static_cast<BBMOD_EPhysicsShapeType>(BBMOD_ReadBuffer<int8_t>(buffer));
		m_margin = BBMOD_ReadBuffer<btScalar>(buffer);
	}

	btScalar m_margin = 0.04;
};

struct BBMOD_BoxPhysicsShapeInfo : public BBMOD_PhysicsShapeInfo
{
	BBMOD_BoxPhysicsShapeInfo() = default;

	BBMOD_BoxPhysicsShapeInfo(char*& buffer) : BBMOD_PhysicsShapeInfo(buffer)
	{
		FromBuffer(buffer);
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsShapeInfo::FromBuffer(buffer);

		btScalar sizeX, sizeY, sizeZ;
		sizeX = BBMOD_ReadBuffer<btScalar>(buffer);
		sizeY = BBMOD_ReadBuffer<btScalar>(buffer);
		sizeZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_size = btVector3(sizeX, sizeY, sizeZ);
	}

	btVector3 m_size { 1.0, 1.0, 1.0 };
};

struct BBMOD_CapsulePhysicsShapeInfo : public BBMOD_PhysicsShapeInfo
{
	BBMOD_CapsulePhysicsShapeInfo() = default;

	BBMOD_CapsulePhysicsShapeInfo(char*& buffer) : BBMOD_PhysicsShapeInfo(buffer)
	{
		FromBuffer(buffer);
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsShapeInfo::FromBuffer(buffer);
		m_upAxis = static_cast<BBMOD_EAxis>(BBMOD_ReadBuffer<uint8_t>(buffer));
		m_radius = BBMOD_ReadBuffer<btScalar>(buffer);
		m_height = BBMOD_ReadBuffer<btScalar>(buffer);
	}

	BBMOD_EAxis m_upAxis = BBMOD_EAxis::Z;
	btScalar m_radius = 0.5;
	btScalar m_height = 1.0;
};

struct BBMOD_CompoundPhysicsShapeInfo : public BBMOD_PhysicsShapeInfo
{
	BBMOD_CompoundPhysicsShapeInfo() = default;

	BBMOD_CompoundPhysicsShapeInfo(char*& buffer) : BBMOD_PhysicsShapeInfo(buffer)
	{
		FromBuffer(buffer);
	}
};

struct BBMOD_ConePhysicsShapeInfo : public BBMOD_PhysicsShapeInfo
{
	BBMOD_ConePhysicsShapeInfo() = default;

	BBMOD_ConePhysicsShapeInfo(char*& buffer) : BBMOD_PhysicsShapeInfo(buffer)
	{
		FromBuffer(buffer);
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsShapeInfo::FromBuffer(buffer);
		m_upAxis = static_cast<BBMOD_EAxis>(BBMOD_ReadBuffer<uint8_t>(buffer));
		m_radius = BBMOD_ReadBuffer<btScalar>(buffer);
		m_height = BBMOD_ReadBuffer<btScalar>(buffer);
	}

	BBMOD_EAxis m_upAxis = BBMOD_EAxis::Z;
	btScalar m_radius = 0.5;
	btScalar m_height = 1.0;
};

struct BBMOD_ConvexHullPhysicsShapeInfo : public BBMOD_PhysicsShapeInfo
{
	BBMOD_ConvexHullPhysicsShapeInfo() = default;

	BBMOD_ConvexHullPhysicsShapeInfo(char*& buffer) : BBMOD_PhysicsShapeInfo(buffer)
	{
		FromBuffer(buffer);
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsShapeInfo::FromBuffer(buffer);
		m_vertexCount = BBMOD_ReadBuffer<uint32_t>(buffer);
		m_vertexStride = BBMOD_ReadBuffer<uint32_t>(buffer);
		m_buffer = buffer;
	}

	char* m_buffer = nullptr;
	uint32_t m_vertexCount = 0;
	uint32_t m_vertexStride = 0;
};

struct BBMOD_CylinderPhysicsShapeInfo : public BBMOD_PhysicsShapeInfo
{
	BBMOD_CylinderPhysicsShapeInfo() = default;

	BBMOD_CylinderPhysicsShapeInfo(char*& buffer) : BBMOD_PhysicsShapeInfo(buffer)
	{
		FromBuffer(buffer);
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsShapeInfo::FromBuffer(buffer);
		m_upAxis = static_cast<BBMOD_EAxis>(BBMOD_ReadBuffer<uint8_t>(buffer));
		m_radius = BBMOD_ReadBuffer<btScalar>(buffer);
		m_height = BBMOD_ReadBuffer<btScalar>(buffer);
	}

	BBMOD_EAxis m_upAxis = BBMOD_EAxis::Z;
	btScalar m_radius = 0.5;
	btScalar m_height = 1.0;
};

struct BBMOD_PlanePhysicsShapeInfo : public BBMOD_PhysicsShapeInfo
{
	BBMOD_PlanePhysicsShapeInfo() = default;

	BBMOD_PlanePhysicsShapeInfo(char*& buffer) : BBMOD_PhysicsShapeInfo(buffer)
	{
		FromBuffer(buffer);
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsShapeInfo::FromBuffer(buffer);

		btScalar normalX, normalY, normalZ;
		normalX = BBMOD_ReadBuffer<btScalar>(buffer);
		normalY = BBMOD_ReadBuffer<btScalar>(buffer);
		normalZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_normal = btVector3(normalX, normalY, normalZ);

		m_distance = BBMOD_ReadBuffer<btScalar>(buffer);
	}

	btVector3 m_normal { 0.0, 0.0, 1.0 };
	btScalar m_distance = 0.0;
};

struct BBMOD_SpherePhysicsShapeInfo : public BBMOD_PhysicsShapeInfo
{
	BBMOD_SpherePhysicsShapeInfo() = default;

	BBMOD_SpherePhysicsShapeInfo(char*& buffer) : BBMOD_PhysicsShapeInfo(buffer)
	{
		FromBuffer(buffer);
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsShapeInfo::FromBuffer(buffer);
		m_radius = BBMOD_ReadBuffer<btScalar>(buffer);
	}

	btScalar m_radius = 0.5;
};

struct BBMOD_StaticMeshPhysicsShapeInfo : public BBMOD_PhysicsShapeInfo
{
	BBMOD_StaticMeshPhysicsShapeInfo() = default;

	BBMOD_StaticMeshPhysicsShapeInfo(char*& buffer) : BBMOD_PhysicsShapeInfo(buffer)
	{
		FromBuffer(buffer);
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsShapeInfo::FromBuffer(buffer);
		m_vertexCount = BBMOD_ReadBuffer<uint32_t>(buffer);
		m_vertexStride = BBMOD_ReadBuffer<uint32_t>(buffer);
		m_buffer = buffer;
	}

	char* m_buffer = nullptr;
	uint32_t m_vertexCount = 0;
	uint32_t m_vertexStride = 0;
};
