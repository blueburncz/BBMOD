z = (OMain.terrain.get_height(x, y) ?? 0) + 0.125;

model = BBMOD_RESOURCE_MANAGER.load_sync("Data/YBot/YBot.bbmod").freeze();

var _nodes = model.get_node_array();
var _boneCount = model.BoneCount;

bones = array_create(_boneCount, undefined);

for (var i = 0; i < array_length(_nodes); ++i)
{
	if (_nodes[i].IsBone)
	{
		bones[@ _nodes[i].Index] = _nodes[i];
	}
}

transformArray = array_create(_boneCount * 8, 0);

/// @func GetNodeWorldTransform(_node)
GetNodeWorldTransform = function (_node)
{
	var _dualQuat = _node.Transform;
	var _current = _node.Parent;
	while (_current != undefined)
	{
		_dualQuat = _dualQuat.Mul(_current.Transform);
		_current = _current.Parent;
	}
	return _dualQuat;
};

/// @func GetTransformArray(_dest)
GetTransformArray = function (_dest)
{
	var _numParts = array_length(Ragdoll);
	var _numBones = array_length(bones);
	var _worldDqs = array_create(_numBones, undefined);

	// Get world DQs from ragdoll
	for (var i = 0; i < _numParts; ++i)
	{
		var _part = Ragdoll[i];
		if (_part.RigidBody != undefined)
		{
			_worldDqs[@ _part.Bone.Index] = _part.RigidBody.get_dual_quaternion();
		}
	}

	// Fill in missing DQs
	for (var i = 0; i < _numBones; ++i)
	{
		if (_worldDqs[i] == undefined)
		{
			var _bone = bones[i];
			var _dualQuat = _bone.Transform;
			var _current = _bone.Parent;
			while (_current != undefined)
			{
				if (_current.IsBone && _worldDqs[_current.Index] != undefined)
				{
					_dualQuat = _dualQuat.Mul(_worldDqs[_current.Index]);
					break;
				}
				_dualQuat = _dualQuat.Mul(_current.Transform);
				_current = _current.Parent;
			}
			_worldDqs[@ i] = _dualQuat;
		}
	}

	// Mul with bone offsets
	for (var i = 0; i < _numBones; ++i)
	{
		var _dq = _worldDqs[i];
		var _offset = new BBMOD_DualQuaternion().FromArray(model.__offsetArray, i * 8);
		_dq = _offset.Mul(_dq);
		_dq.ToArray(_dest, i * 8);
	}
};

/// @func TryGetBone(_name)
TryGetBone = function (_name)
{
	var _nodes = model.get_node_array();
	for (var i = array_length(_nodes) - 1; i >= 0; --i)
	{
		if (_nodes[i].IsBone && _nodes[i].Name == _name)
		{
			return _nodes[i];
		}
	}
	return undefined;
};

/// @func CreateRagdoll()
CreateRagdoll = function ()
{
	var _num = array_length(Ragdoll);

	// Destroy old
	for (var i = 0; i < _num; ++i)
	{
		var _ragdollPart = Ragdoll[i];

		if (_ragdollPart.Constraint != undefined)
		{
			BBMOD_PhysicsWorld_DestroyConstraint(OMain.physicsWorld.__id, _ragdollPart.Constraint);
			_ragdollPart.Constraint = undefined;
		}

		if (_ragdollPart.RigidBody != undefined)
		{
			BBMOD_PhysicsWorld_DestroyRigidBody(OMain.physicsWorld.__id, _ragdollPart.RigidBody.__id);
			_ragdollPart.RigidBody = undefined;
		}

		if (_ragdollPart.PhysicsShape != undefined)
		{
			BBMOD_PhysicsEngine_DestroyShape(_ragdollPart.PhysicsShape.__id);
			_ragdollPart.PhysicsShape = undefined;
		}
	}

	// Create new shapes and rigid bodies
	for (var i = 0; i < _num; ++i)
	{
		var _ragdollPart = Ragdoll[i];

		if (_ragdollPart.Bone == undefined)
		{
			continue;
		}

		var _shapeInfo = undefined;
		var _shape = undefined;

		switch (_ragdollPart.Type)
		{
			case EPhysicsShape.Box:
				_shapeInfo = new BBMOD_BoxPhysicsShapeInfo();
				_ragdollPart.Size.Copy(_shapeInfo.Size);
				break;

			case EPhysicsShape.Capsule:
				_shapeInfo = new BBMOD_CapsuleYPhysicsShapeInfo();
				_shapeInfo.Radius = _ragdollPart.Size.X;
				_shapeInfo.Height = max(_ragdollPart.Size.Y - (_shapeInfo.Radius * 2), 0);
				break;

				//case EPhysicsShape.Cone:
				//	break;

				//case EPhysicsShape.Cylinder:
				//	break;

			case EPhysicsShape.Sphere:
				_shapeInfo = new BBMOD_SpherePhysicsShapeInfo();
				_shapeInfo.Radius = _ragdollPart.Size.X;
				break;

			default:
				break;
		}

		if (_shapeInfo != undefined)
		{
			_shapeInfo.Transform.TranslateSelf(_ragdollPart.Offset);

			switch (_ragdollPart.Type)
			{
				case EPhysicsShape.Box:
					_shape = OMain.physicsEngine.create_box_shape(_shapeInfo);
					break;

				case EPhysicsShape.Capsule:
					_shape = OMain.physicsEngine.create_capsule_y_shape(_shapeInfo);
					break;

					//case EPhysicsShape.Cone:
					//	break;

					//case EPhysicsShape.Cylinder:
					//	break;

				case EPhysicsShape.Sphere:
					_shape = OMain.physicsEngine.create_sphere_shape(_shapeInfo);
					break;

				default:
					break;
			}
		}

		if (_shape != undefined)
		{
			_ragdollPart.PhysicsShape = _shape;

			var _bodyInfo = new BBMOD_RigidBodyInfo();
			_bodyInfo.PhysicsShape = _shape;
			_bodyInfo.Mass = _ragdollPart.Mass;
			_bodyInfo.Transform.Raw = matrix_multiply(
				GetNodeWorldTransform(_ragdollPart.Bone).ToMatrix(),
				matrix_build(x, y, z, 0, 0, 0, 1, 1, 1)
			);

			_ragdollPart.RigidBody = OMain.physicsWorld.create_rigid_body(_bodyInfo);
		}
	}

	// Create constraints
	for (var i = 0; i < _num; ++i)
	{
		var _ragdollPart = Ragdoll[i];

		if (_ragdollPart.RigidBody == undefined)
		{
			continue;
		}

		if (_ragdollPart.ConnectedToBone == undefined)
		{
			continue;
		}

		var _ragdollPartConnectedTo = undefined;
		for (var j = 0; j < _num; ++j)
		{
			if (Ragdoll[j].Bone != undefined
				&& Ragdoll[j].Bone == _ragdollPart.ConnectedToBone)
			{
				_ragdollPartConnectedTo = Ragdoll[j];
				break;
			}
		}

		if (_ragdollPartConnectedTo == undefined)
		{
			continue;
		}

		var _scratchBuffer = bbmod_get_scratch_buffer();

		buffer_write(_scratchBuffer, buffer_f64, _ragdollPart.RigidBody.__id);
		buffer_write(_scratchBuffer, buffer_f64, _ragdollPartConnectedTo.RigidBody.__id);
		_ragdollPart.LowerLimit.ToBuffer(_scratchBuffer, buffer_f32);
		_ragdollPart.UpperLimit.ToBuffer(_scratchBuffer, buffer_f32);

		_ragdollPart.Constraint = BBMOD_PhysicsWorld_CreateCharacterJoint(OMain.physicsWorld.__id,
			buffer_get_address(_scratchBuffer));
	}
};

UI = new CGUI();
Ragdoll = [];

Pelvis = new CRagdollPartInfo();
Pelvis.Name = "Pelvis";
Pelvis.Bone = TryGetBone("mixamorig:Hips");
Pelvis.Expand = true;
Pelvis.Type = EPhysicsShape.Box;
Pelvis.Offset.Set(-8.40425491 * power(10, -6), 0.0745585412, -0.0308578461).MulSelf(new BBMOD_Vec3(1, 1, -1));
Pelvis.Size.Set(0.375215948, 0.282260925, 0.25216195);
Pelvis.Mass = 12.5;
array_push(Ragdoll, Pelvis);

LeftHips = new CRagdollPartInfo();
LeftHips.Name = "Left Hips";
LeftHips.Bone = TryGetBone("mixamorig:LeftUpLeg");
LeftHips.Offset.Set(0, 0.21, 0).MulSelf(new BBMOD_Vec3(1, 1, -1));
LeftHips.Size.X = 0.08;
LeftHips.Size.Y = 0.39;
LeftHips.Mass = 7.5;
LeftHips.ConnectedToBone = TryGetBone("mixamorig:Hips");
LeftHips.LowerLimit.Set(-30.0, -70.0, -60.0);
LeftHips.UpperLimit.Set(30.0, 70.0, 60.0);
array_push(Ragdoll, LeftHips);

LeftKnee = new CRagdollPartInfo();
LeftKnee.Name = "Left Knee";
LeftKnee.Bone = TryGetBone("mixamorig:LeftLeg");
LeftKnee.Offset.Set(0, 0.2430662, 0).MulSelf(new BBMOD_Vec3(1, 1, -1));
LeftKnee.Size.X = 0.1215331;
LeftKnee.Size.Y = 0.4861324;
LeftKnee.Mass = 7.5;
LeftKnee.ConnectedToBone = TryGetBone("mixamorig:LeftUpLeg");
LeftKnee.LowerLimit.Set(0.0, 0.0, 0.0);
LeftKnee.UpperLimit.Set(0.0, 85.0, 0.0); // 0.0, 105.0, 0.0
array_push(Ragdoll, LeftKnee);

//LeftFoot = new CRagdollPartInfo();
//LeftFoot.Name = "Left Foot";
//LeftFoot.Bone = TryGetBone("mixamorig:LeftFoot");
//array_push(Ragdoll, LeftFoot);

RightHips = new CRagdollPartInfo();
RightHips.Name = "Right Hips";
RightHips.Bone = TryGetBone("mixamorig:RightUpLeg");
RightHips.Offset.Set(0, 0.21, 0).MulSelf(new BBMOD_Vec3(1, 1, -1));
RightHips.Size.X = 0.08;
RightHips.Size.Y = 0.39;
RightHips.Mass = 7.5;
RightHips.ConnectedToBone = TryGetBone("mixamorig:Hips");
RightHips.LowerLimit.Set(-30.0, -70.0, -60.0);
RightHips.UpperLimit.Set(30.0, 70.0, 60.0);
array_push(Ragdoll, RightHips);

RightKnee = new CRagdollPartInfo();
RightKnee.Name = "Right Knee";
RightKnee.Bone = TryGetBone("mixamorig:RightLeg");
RightKnee.Offset.Set(0, 0.2430652, 0).MulSelf(new BBMOD_Vec3(1, 1, -1));
RightKnee.Size.X = 0.1215326;
RightKnee.Size.Y = 0.4861304;
RightKnee.Mass = 7.5;
RightKnee.ConnectedToBone = TryGetBone("mixamorig:RightUpLeg");
RightKnee.LowerLimit.Set(0.0, 0.0, 0.0);
RightKnee.UpperLimit.Set(0.0, 85.0, 0.0); // 0.0, 105.0, 0.0
array_push(Ragdoll, RightKnee);

//RightFoot = new CRagdollPartInfo();
//RightFoot.Name = "Right Foot";
//RightFoot.Bone = TryGetBone("mixamorig:RightFoot");
//array_push(Ragdoll, RightFoot);

LeftArm = new CRagdollPartInfo();
LeftArm.Name = "Left Arm";
LeftArm.Bone = TryGetBone("mixamorig:LeftArm");
LeftArm.Offset.Set(0, 0.1370234, 0).MulSelf(new BBMOD_Vec3(1, 1, -1));
LeftArm.Size.X = 0.06851171;
LeftArm.Size.Y = 0.2740468;
LeftArm.Mass = 5;
LeftArm.ConnectedToBone = TryGetBone("mixamorig:Spine1");
LeftArm.LowerLimit.Set(-15.0, -85.0, -70.0);
LeftArm.UpperLimit.Set(15.0, 85.0, 70.0);
array_push(Ragdoll, LeftArm);

LeftElbow = new CRagdollPartInfo();
LeftElbow.Name = "Left Elbow";
LeftElbow.Bone = TryGetBone("mixamorig:LeftForeArm");
LeftElbow.Offset.Set(0, 0.2557196, 0).MulSelf(new BBMOD_Vec3(1, 1, -1));
LeftElbow.Size.X = 0.1022878;
LeftElbow.Size.Y = 0.5114392;
LeftElbow.Mass = 5;
LeftElbow.ConnectedToBone = TryGetBone("mixamorig:LeftArm");
LeftElbow.LowerLimit.Set(-15.0, 0.0, 0.0); // -6.0, 0.0, 0.0
LeftElbow.UpperLimit.Set(15.0, 0.0, -85.0); // 6.0, 0.0, -100.0
array_push(Ragdoll, LeftElbow);

RightArm = new CRagdollPartInfo();
RightArm.Name = "Right Arm";
RightArm.Bone = TryGetBone("mixamorig:RightArm");
RightArm.Offset.Set(0, 0.1370234, 0).MulSelf(new BBMOD_Vec3(1, 1, -1));
RightArm.Size.X = 0.06851171;
RightArm.Size.Y = 0.2740468;
RightArm.Mass = 5;
RightArm.ConnectedToBone = TryGetBone("mixamorig:Spine1");
RightArm.LowerLimit.Set(-15.0, -85.0, -70.0);
RightArm.UpperLimit.Set(15.0, 85.0, 70.0);
array_push(Ragdoll, RightArm);

RightElbow = new CRagdollPartInfo();
RightElbow.Name = "Right Elbow";
RightElbow.Bone = TryGetBone("mixamorig:RightForeArm");
RightElbow.Offset.Set(0, 0.2557195, 0).MulSelf(new BBMOD_Vec3(1, 1, -1));
RightElbow.Size.X = 0.1022878;
RightElbow.Size.Y = 0.511439;
RightElbow.Mass = 5;
RightElbow.ConnectedToBone = TryGetBone("mixamorig:RightArm");
RightElbow.LowerLimit.Set(-15.0, 0.0, 0.0); // -6.0, 0.0, 0.0
RightElbow.UpperLimit.Set(15.0, 0.0, 85.0); // 6.0, 0.0, 100.0
array_push(Ragdoll, RightElbow);

MiddleSpine = new CRagdollPartInfo();
MiddleSpine.Name = "Middle Spine";
MiddleSpine.Bone = TryGetBone("mixamorig:Spine1");
MiddleSpine.Type = EPhysicsShape.Box;
MiddleSpine.Offset.Set(3.7252903 * power(10, -7), 0.112345047, -0.00417891145).MulSelf(new BBMOD_Vec3(1, 1, -1));
MiddleSpine.Size.Set(0.375215948, 0.224690124, 0.254008442);
MiddleSpine.Mass = 12.5;
MiddleSpine.ConnectedToBone = TryGetBone("mixamorig:Hips");
MiddleSpine.LowerLimit.Set(-20.0, -30.0, -30.0);
MiddleSpine.UpperLimit.Set(20.0, 30.0, 30.0);
array_push(Ragdoll, MiddleSpine);

Head = new CRagdollPartInfo();
Head.Name = "Head";
Head.Bone = TryGetBone("mixamorig:Head");
Head.Type = EPhysicsShape.Sphere;
Head.Offset.Set(0, 0.0938039869, 0).MulSelf(new BBMOD_Vec3(1, 1, -1));
Head.Size.X = 0.09380399;
Head.Mass = 5;
Head.ConnectedToBone = TryGetBone("mixamorig:Spine1");
Head.LowerLimit.Set(-25.0, -35.0, -35.0);
Head.UpperLimit.Set(25.0, 35.0, 35.0);
array_push(Ragdoll, Head);

alarm[0] = 1;
