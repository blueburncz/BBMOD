var _physicsEngine, _physicsWorld, _terrain;
with(OMain)
{
	_physicsEngine = physicsEngine;
	_physicsWorld = physicsWorld;
	_terrain = terrain;
}

// Create convex hull from jeep model
var _hullBuilder = new BBMOD_ConvexHullBuilder(_physicsEngine);
var _hullShape = _hullBuilder.from_model(jeep);

// Use compound shape to apply the transform from the Draw event
// Hull already has node transforms baked in, just need to match matrix_build(jeepX, jeepY, jeepZ, 0, 0, 90, jeepScale, jeepScale, jeepScale)
collisionShape = _physicsEngine.create_physics_shape(new BBMOD_CompoundPhysicsShapeInfo());
var _hullTransform = new BBMOD_Matrix()
	.ScaleSelf(jeepScale, jeepScale, jeepScale)
	.RotateZSelf(90)
	.TranslateSelf(jeepX, jeepY, jeepZ);
collisionShape.add_child_shape(_hullShape, _hullTransform);

var _rigidBodyInfo = new BBMOD_RigidBodyInfo();
_rigidBodyInfo.PhysicsShape = collisionShape;
_rigidBodyInfo.Mass = 1200;
_rigidBodyInfo.Transform.TranslateSelf(
	0, 0, (_terrain.get_height(x, y) ?? 0) + 2.0
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

// Freeze the jeep model after we have created convex hull collider for it
jeep.freeze();
