var _physicsEngine, _physicsWorld, _terrain;
with(OMain)
{
	_physicsEngine = physicsEngine;
	_physicsWorld = physicsWorld;
	_terrain = terrain;
}

var _boxShapeInfo = new BBMOD_BoxPhysicsShapeInfo();
_boxShapeInfo.Size.Set(4, 1.8, 0.7);
_boxShapeInfo.Margin = 0.1;

var _boxShape = _physicsEngine.create_physics_shape(_boxShapeInfo);

collisionShape = _physicsEngine.create_physics_shape(new BBMOD_CompoundPhysicsShapeInfo());

collisionShape.add_child_shape(_boxShape, new BBMOD_Matrix().TranslateSelf(0, 0, -0.1));

var _rigidBodyInfo = new BBMOD_RigidBodyInfo();
_rigidBodyInfo.PhysicsShape = collisionShape;
_rigidBodyInfo.Mass = 1200;
_rigidBodyInfo.Transform.TranslateSelf(
	0, 0, (_terrain.get_height(x, y) ?? 0) + (_boxShapeInfo.Size.Z * 2)
);

rigidBody = _physicsWorld.create_rigid_body(_rigidBodyInfo);

var _vehicleInfo = new BBMOD_PhysicsVehicleInfo();
_vehicleInfo.MaxSuspensionForce *= scale;
_vehicleInfo.SuspensionStiffness = 100; // * scale;
_vehicleInfo.SuspensionDamping = 2.3; // * scale;
_vehicleInfo.SuspensionCompression = 4.4; // * scale;
_vehicleInfo.RigidBody = rigidBody;

vehicle = _physicsWorld.create_vehicle(_vehicleInfo);

var _wheelInfo = new BBMOD_PhysicsWheelInfo();
//_wheelInfo.Direction.Set(0, 0, -1);
//_wheelInfo.Axle.Set(0, -1, 0);
_wheelInfo.Radius = 0.4;
_wheelInfo.SuspensionRestLength = 0.1; //_wheelInfo.Radius;

_wheelInfo.ConnectionPoint.Set(1.4, -0.9, -0.5);
_wheelInfo.IsFrontWheel = true;
vehicle.add_wheel(_wheelInfo);

_wheelInfo.ConnectionPoint.Set(1.4, 0.9, -0.5);
//_wheelInfo.IsFrontWheel = true;
vehicle.add_wheel(_wheelInfo);

_wheelInfo.ConnectionPoint.Set(-1.1, -0.9, -0.5);
_wheelInfo.IsFrontWheel = false;
vehicle.add_wheel(_wheelInfo);

_wheelInfo.ConnectionPoint.Set(-1.1, 0.9, -0.5);
//_wheelInfo.IsFrontWheel = false;
vehicle.add_wheel(_wheelInfo);

steering = 0;
