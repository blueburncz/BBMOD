z = (OMain.terrain.get_height(x, y) ?? 0) + 0.125;

model = BBMOD_RESOURCE_MANAGER.load_sync("Data/YBot/YBot.bbmod");

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
ragdoll = undefined;

// Animation player for smooth transitions
animationPlayer = new BBMOD_AnimationPlayer(model);
idleAnimation = BBMOD_RESOURCE_MANAGER.load_sync("Data/YBot/Idle.bbanim");
animationPlayer.play(idleAnimation, true);

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
	// Destroy old ragdoll
	if (ragdoll != undefined)
	{
		ragdoll.destroy();
		ragdoll = undefined;
	}

	// Update animation player to ensure transforms are ready
	animationPlayer.update(0);

	// Create ragdoll info
	var _ragdollInfo = new BBMOD_RagdollInfo(model);

	// Add all parts to the ragdoll info
	var _num = array_length(Ragdoll);
	for (var i = 0; i < _num; ++i)
	{
		_ragdollInfo.add_part(Ragdoll[i]);
	}

	// Create ragdoll at current object position
	var _worldTransform = new BBMOD_Matrix().TranslateSelf(x, y, z);
	ragdoll = OMain.physicsWorld.create_ragdoll(_ragdollInfo, _worldTransform);

	if (ragdoll != undefined)
	{
		// Start in animation mode
		ragdoll.set_active(false);

		// Sync to current animation pose
		var _worldMat = new BBMOD_Matrix().TranslateSelf(x, y, z);
		ragdoll.sync_to_animation(animationPlayer, _worldMat);
	}
};

UI = new CGUI();
Ragdoll = [];

Pelvis = new BBMOD_RagdollPartInfo();
Pelvis.Name = "Pelvis";
Pelvis.Bone = TryGetBone("mixamorig:Hips");
Pelvis.Expand = true;
Pelvis.Type = BBMOD_EPhysicsShapeType.Box;
Pelvis.Offset.Set(-8.40425491 * power(10, -6), 0.0745585412, -0.0308578461).MulSelf(new BBMOD_Vec3(1, 1, -1));
Pelvis.Size.Set(0.375215948, 0.282260925, 0.25216195);
Pelvis.Mass = 12.5;
array_push(Ragdoll, Pelvis);

LeftHips = new BBMOD_RagdollPartInfo();
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

LeftKnee = new BBMOD_RagdollPartInfo();
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

//LeftFoot = new BBMOD_RagdollPartInfo();
//LeftFoot.Name = "Left Foot";
//LeftFoot.Bone = TryGetBone("mixamorig:LeftFoot");
//array_push(Ragdoll, LeftFoot);

RightHips = new BBMOD_RagdollPartInfo();
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

RightKnee = new BBMOD_RagdollPartInfo();
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

//RightFoot = new BBMOD_RagdollPartInfo();
//RightFoot.Name = "Right Foot";
//RightFoot.Bone = TryGetBone("mixamorig:RightFoot");
//array_push(Ragdoll, RightFoot);

LeftArm = new BBMOD_RagdollPartInfo();
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

LeftElbow = new BBMOD_RagdollPartInfo();
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

RightArm = new BBMOD_RagdollPartInfo();
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

RightElbow = new BBMOD_RagdollPartInfo();
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

MiddleSpine = new BBMOD_RagdollPartInfo();
MiddleSpine.Name = "Middle Spine";
MiddleSpine.Bone = TryGetBone("mixamorig:Spine1");
MiddleSpine.Type = BBMOD_EPhysicsShapeType.Box;
MiddleSpine.Offset.Set(3.7252903 * power(10, -7), 0.112345047, -0.00417891145).MulSelf(new BBMOD_Vec3(1, 1, -1));
MiddleSpine.Size.Set(0.375215948, 0.224690124, 0.254008442);
MiddleSpine.Mass = 12.5;
MiddleSpine.ConnectedToBone = TryGetBone("mixamorig:Hips");
MiddleSpine.LowerLimit.Set(-20.0, -30.0, -30.0);
MiddleSpine.UpperLimit.Set(20.0, 30.0, 30.0);
array_push(Ragdoll, MiddleSpine);

Head = new BBMOD_RagdollPartInfo();
Head.Name = "Head";
Head.Bone = TryGetBone("mixamorig:Head");
Head.Type = BBMOD_EPhysicsShapeType.Sphere;
Head.Offset.Set(0, 0.0938039869, 0).MulSelf(new BBMOD_Vec3(1, 1, -1));
Head.Size.X = 0.09380399;
Head.Mass = 5;
Head.ConnectedToBone = TryGetBone("mixamorig:Spine1");
Head.LowerLimit.Set(-25.0, -35.0, -35.0);
Head.UpperLimit.Set(25.0, 35.0, 35.0);
array_push(Ragdoll, Head);

alarm[0] = 1;
