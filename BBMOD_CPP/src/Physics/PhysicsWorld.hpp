#pragma once

#include "DebugDraw.hpp"

#define BT_USE_DOUBLE_PRECISION
#include <btBulletDynamicsCommon.h>

struct BBMOD_PhysicsWorld
{
	BBMOD_PhysicsWorld()
	{
		m_collisionConfiguration = new btDefaultCollisionConfiguration();
		m_dispatcher = new btCollisionDispatcher(m_collisionConfiguration);
		m_overlappingPairCache = new btDbvtBroadphase();
		m_solver = new btSequentialImpulseConstraintSolver();
		m_dynamicsWorld = new btDiscreteDynamicsWorld(m_dispatcher, m_overlappingPairCache, m_solver, m_collisionConfiguration);

		m_dynamicsWorld->getSolverInfo().m_numIterations = 30; // default ~10
		m_dynamicsWorld->getSolverInfo().m_splitImpulse = 1;   // prevents slight sinking

		m_debugDraw = new btDebugDrawInMemory();
		m_dynamicsWorld->setDebugDrawer(m_debugDraw);
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
