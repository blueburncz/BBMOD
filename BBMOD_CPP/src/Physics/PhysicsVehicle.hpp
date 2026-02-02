#pragma once

#define BT_USE_DOUBLE_PRECISION
#include <btBulletDynamicsCommon.h>

using btVehicleTuning = btRaycastVehicle::btVehicleTuning;
using btVehicleRaycasterResult = btVehicleRaycaster::btVehicleRaycasterResult;

struct BBMOD_PhysicsVehicle
{
	btDynamicsWorld* m_world;
	btVehicleTuning m_tuning;
	btVehicleRaycaster* m_raycaster;
	btRaycastVehicle* m_vehicle;

	~BBMOD_PhysicsVehicle()
	{
		m_world->removeVehicle(m_vehicle);
		delete m_vehicle;
		delete m_raycaster;
	}
};
