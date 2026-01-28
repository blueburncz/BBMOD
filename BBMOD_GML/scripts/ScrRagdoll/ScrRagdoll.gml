enum EAxis
{
	X = 0,
	Y,
	Z,
	SIZE,
};

global.AxisNames = ["X", "Y", "Z"];
global.AxisValues = [EAxis.X, EAxis.Y, EAxis.Z];

function GetAxisName(_axis)
{
	bbmod_assert(_axis >= 0 && _axis < EAxis.SIZE);
	return global.AxisNames[_axis];
}

function GetAxisValue(_axis)
{
	for (var i = 0; i < array_length(global.AxisNames); ++i)
	{
		if (global.AxisNames[i] == _axis)
		{
			return global.AxisValues[i];
		}
	}
	bbmod_assert(false);
}

enum EPhysicsShape
{
	Box = 0,
	Capsule,
	//Cone,
	//Cylinder,
	Sphere,
	SIZE,
};

global.PhysicsShapeNames = ["Box", "Capsule", "Sphere"];
global.PhysicsShapeValues = [
	EPhysicsShape.Box,
	EPhysicsShape.Capsule,
	//EPhysicsShape.Cone,
	//EPhysicsShape.Cylinder,
	EPhysicsShape.Sphere,
];

function GetPhysicsShapeName(_shape)
{
	bbmod_assert(_shape >= 0 && _shape < EPhysicsShape.SIZE);
	return global.PhysicsShapeNames[_shape];
}

function GetPhysicsShapeValue(_shape)
{
	for (var i = 0; i < array_length(global.PhysicsShapeNames); ++i)
	{
		if (global.PhysicsShapeNames[i] == _shape)
		{
			return global.PhysicsShapeValues[i];
		}
	}
	bbmod_assert(false);
}

function CRagdollPartInfo() constructor
{
	Name = "";
	Expand = false;

	Bone = undefined;

	// Shape
	Type = EPhysicsShape.Capsule;
	Direction = EAxis.X;
	Offset = new BBMOD_Vec3();
	Size = new BBMOD_Vec3(0.1);

	// Rigid body
	Mass = 0;

	// Joint
	ConnectedToBone = undefined;
	LowerLimit = new BBMOD_Vec3();
	UpperLimit = new BBMOD_Vec3();

	PhysicsShape = undefined;
	RigidBody = undefined;
	Constraint = undefined;
}
