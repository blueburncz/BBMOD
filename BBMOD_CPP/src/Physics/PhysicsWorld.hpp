#pragma once

#include "DebugDraw.hpp"

#include <BBMOD/buffer.hpp>

#define BT_USE_DOUBLE_PRECISION
#include <btBulletDynamicsCommon.h>
	
struct BBMOD_PhysicsWorldInfo
{
	BBMOD_PhysicsWorldInfo() = default;

	BBMOD_PhysicsWorldInfo(char*& buffer)
	{
		FromBuffer(buffer);
	}

	void FromBuffer(char*& buffer)
	{
		m_gravityX = BBMOD_ReadBuffer<double>(buffer);
		m_gravityY = BBMOD_ReadBuffer<double>(buffer);
		m_gravityZ = BBMOD_ReadBuffer<double>(buffer);
		m_debugMode = BBMOD_ReadBuffer<uint64_t>(buffer);
	}

	double m_gravityX = 0.0f;
	double m_gravityY = 0.0f;
	double m_gravityZ = -9.8f;
	int m_solverIterations = 30;
	uint64_t m_debugMode = 0;
};

struct BBMOD_PhysicsWorld
{
	BBMOD_PhysicsWorld(BBMOD_PhysicsWorldInfo* info = nullptr)
	{
		m_collisionConfiguration = new btDefaultCollisionConfiguration();
		m_dispatcher = new btCollisionDispatcher(m_collisionConfiguration);
		m_overlappingPairCache = new btDbvtBroadphase();
		m_solver = new btSequentialImpulseConstraintSolver();
		m_dynamicsWorld = new btDiscreteDynamicsWorld(m_dispatcher, m_overlappingPairCache, m_solver, m_collisionConfiguration);

		m_debugDraw = new btDebugDrawInMemory();
		m_dynamicsWorld->setDebugDrawer(m_debugDraw);

		if (info)
		{
			m_dynamicsWorld->setGravity(btVector3(info->m_gravityX, info->m_gravityY, info->m_gravityZ));
			m_dynamicsWorld->getSolverInfo().m_numIterations = info->m_solverIterations;
			m_dynamicsWorld->getSolverInfo().m_splitImpulse = 1;
			m_debugDraw->setDebugMode(info->m_debugMode);
		}
	}

	~BBMOD_PhysicsWorld()
	{
		delete m_dynamicsWorld;
		delete m_solver;
		delete m_overlappingPairCache;
		delete m_dispatcher;
		delete m_collisionConfiguration;

		delete m_debugDraw;
	}

	btDefaultCollisionConfiguration* m_collisionConfiguration;
	btCollisionDispatcher* m_dispatcher;
	btBroadphaseInterface* m_overlappingPairCache;
	btSequentialImpulseConstraintSolver* m_solver;
	btDiscreteDynamicsWorld* m_dynamicsWorld;

	btDebugDrawInMemory* m_debugDraw;
};
