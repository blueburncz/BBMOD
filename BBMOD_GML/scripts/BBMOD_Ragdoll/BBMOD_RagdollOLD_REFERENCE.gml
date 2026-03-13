// OLD GML REFERENCE - How GetTransformArray worked
// This is JUST for reference, not actual code

GetTransformArray_OLD = function (_dest)
{
	var _numParts = array_length(Ragdoll);
	var _numBones = array_length(bones);
	var _worldDqs = array_create(_numBones, undefined);

	// Step 1: Get world DQs from ragdoll rigid bodies
	for (var i = 0; i < _numParts; ++i)
	{
		var _part = Ragdoll[i];
		if (_part.RigidBody != undefined)
		{
			_worldDqs[@ _part.Bone.Index] = _part.RigidBody.get_dual_quaternion();
		}
	}

	// Step 2: Fill in missing DQs by walking parent chain
	for (var i = 0; i < _numBones; ++i)
	{
		if (_worldDqs[i] == undefined)
		{
			var _bone = bones[i];
			var _dualQuat = _bone.Transform; // Local transform
			var _current = _bone.Parent;

			// Walk up until we find a ragdoll bone or reach root
			while (_current != undefined)
			{
				if (_current.IsBone && _worldDqs[_current.Index] != undefined)
				{
					// Found ragdoll parent - multiply local with parent world
					_dualQuat = _dualQuat.Mul(_worldDqs[_current.Index]);
					break;
				}
				// Accumulate local transforms
				_dualQuat = _dualQuat.Mul(_current.Transform);
				_current = _current.Parent;
			}
			_worldDqs[@ i] = _dualQuat;
		}
	}

	// Step 3: Apply bone offsets for skinning
	for (var i = 0; i < _numBones; ++i)
	{
		var _dq = _worldDqs[i];
		var _offset = new BBMOD_DualQuaternion().FromArray(model.__offsetArray, i * 8);
		_dq = _offset.Mul(_dq);
		_dq.ToArray(_dest, i * 8);
	}
};
