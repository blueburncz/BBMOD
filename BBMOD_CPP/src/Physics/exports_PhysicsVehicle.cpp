#include "PhysicsVehicle.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

GM_EXPORT double BBMOD_PhysicsVehicle_AddWheel(double _id, char* _buffer)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id);

	btVector3 connectionPoint;
	connectionPoint.setX(BBMOD_ReadBuffer<double>(_buffer));
	connectionPoint.setY(BBMOD_ReadBuffer<double>(_buffer));
	connectionPoint.setZ(BBMOD_ReadBuffer<double>(_buffer));

	btVector3 direction;
	direction.setX(BBMOD_ReadBuffer<double>(_buffer));
	direction.setY(BBMOD_ReadBuffer<double>(_buffer));
	direction.setZ(BBMOD_ReadBuffer<double>(_buffer));

	btVector3 axle;
	axle.setX(BBMOD_ReadBuffer<double>(_buffer));
	axle.setY(BBMOD_ReadBuffer<double>(_buffer));
	axle.setZ(BBMOD_ReadBuffer<double>(_buffer));

	double suspensionRestLength = BBMOD_ReadBuffer<double>(_buffer);
	double radius = BBMOD_ReadBuffer<double>(_buffer);
	auto isFrontWheel = BBMOD_ReadBuffer<bool>(_buffer);

	auto& wheelInfo = vehicle->m_vehicle->addWheel(
		connectionPoint,
		direction,
		axle,
		suspensionRestLength,
		radius,
		vehicle->m_tuning,
		isFrontWheel);

	// wheelInfo.m_wheelsDampingCompression = 4.0f;
	// wheelInfo.m_wheelsDampingRelaxation = 6.0f;
	wheelInfo.m_frictionSlip = 5.0f;
	wheelInfo.m_maxSuspensionTravelCm = 10.0f;

	return static_cast<double>(vehicle->m_vehicle->getNumWheels() - 1);
}

GM_EXPORT double BBMOD_PhysicsVehicle_SetBrake(double _id, double _wheelIndex, double _brake)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	vehicle->setBrake(_brake, static_cast<int>(_wheelIndex));
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsVehicle_SetSteering(double _id, double _wheelIndex, double _steering)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	vehicle->setSteeringValue(_steering, static_cast<int>(_wheelIndex));
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsVehicle_ApplyEngineForce(double _id, double _wheelIndex, double _force)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	vehicle->applyEngineForce(_force, static_cast<int>(_wheelIndex));
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsVehicle_UpdateWheelTransform(double _id, double _wheelIndex)
{
	Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle->updateWheelTransform(static_cast<int>(_wheelIndex), true);
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsVehicle_GetWheelTransform(double _id, double _wheelIndex, char* _outBuffer)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	auto transform = vehicle->getWheelTransformWS(static_cast<int>(_wheelIndex));
	btScalar m[16];
	transform.getOpenGLMatrix(m);
	for (int i = 0; i < 16; ++i)
	{
		BBMOD_WriteBuffer(_outBuffer, (double)m[i]);
	}
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsVehicle_GetDeltaRotation(double _id, double _wheelIndex)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	return (vehicle->getWheelInfo(static_cast<int>(_wheelIndex)).m_deltaRotation * 57.2957795131); // Rad -> deg
}

GM_EXPORT double BBMOD_PhysicsVehicle_IsWheelInContact(double _id, double _wheelIndex)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	return (vehicle->getWheelInfo(static_cast<int>(_wheelIndex)).m_raycastInfo.m_isInContact ? 1.0 : 0.0);
}
