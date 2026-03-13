/// @module Physics

/// @func BBMOD_RagdollInfo(_model)
///
/// @desc A struct containing the full definition of a ragdoll, including all
/// body parts and their constraints. This is used to create a ragdoll through
/// the physics world's factory method.
///
/// @param {Struct.BBMOD_Model} _model The model this ragdoll is for. The model
/// must not be frozen (frozen models don't have bone data available).
///
/// @example
/// ```gml
/// var ragdollInfo = new BBMOD_RagdollInfo(characterModel);
///
/// var pelvis = new BBMOD_RagdollPartInfo();
/// pelvis.Bone = characterModel.find_node_by_name("mixamorig:Hips");
/// pelvis.Type = BBMOD_EPhysicsShapeType.Box;
/// pelvis.Size.Set(0.375, 0.282, 0.252);
/// pelvis.Mass = 12.5;
/// ragdollInfo.add_part(pelvis);
///
/// var ragdoll = physicsWorld.create_ragdoll(
///     ragdollInfo,
///     new BBMOD_Matrix().TranslateSelf(x, y, z)
/// );
/// ```
///
/// @see BBMOD_RagdollPartInfo
/// @see BBMOD_Ragdoll
/// @see BBMOD_PhysicsWorld.create_ragdoll
function BBMOD_RagdollInfo(_model) constructor
{
	/// @var {Struct.BBMOD_Model} The model this ragdoll is for.
	Model = _model;

	/// @var {Array<Struct.BBMOD_RagdollPartInfo>} Array of ragdoll parts
	/// defining the collision shapes and constraints.
	Parts = [];

	/// @func add_part(_partInfo)
	///
	/// @desc Adds a part to the ragdoll definition. Parts should be added in
	/// hierarchical order (parent bones before children) for best results.
	///
	/// @param {Struct.BBMOD_RagdollPartInfo} _partInfo The part information
	/// to add.
	///
	/// @return {Struct.BBMOD_RagdollInfo} Returns `self` for method chaining.
	///
	/// @example
	/// ```gml
	/// ragdollInfo
	///     .add_part(pelvisInfo)
	///     .add_part(leftHipInfo)
	///     .add_part(rightHipInfo);
	/// ```
	static add_part = function (_partInfo)
	{
		array_push(Parts, _partInfo);
		return self;
	};

	/// @func __get_node_world_transform(_node)
	///
	/// @desc Computes the world transform of a node by accumulating parent
	/// transforms.
	///
	/// @param {Struct.BBMOD_Node} _node The node to get the world transform for.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The world transform.
	///
	/// @private
	static __get_node_world_transform = function (_node)
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

	/// @func to_buffer(_buffer, _worldTransform)
	///
	/// @desc Serializes the ragdoll info to a buffer for passing to C++.
	/// This is used internally when creating the ragdoll.
	///
	/// @param {Id.Buffer} _buffer The buffer to write to.
	/// @param {Struct.BBMOD_Matrix} _worldTransform The world transform for
	/// the ragdoll's initial placement.
	///
	/// @return {Struct.BBMOD_RagdollInfo} Returns `self`.
	///
	/// @private
	static to_buffer = function (_buffer, _worldTransform)
	{
		// Write bone count
		buffer_write(_buffer, buffer_u32, Model.BoneCount);

		// Write model offset array (for skinning)
		for (var i = 0; i < Model.BoneCount * 8; ++i)
		{
			buffer_write(_buffer, buffer_f64, Model.__offsetArray[i]);
		}

		// Write world transform matrix
		for (var i = 0; i < 16; ++i)
		{
			buffer_write(_buffer, buffer_f64, _worldTransform.Raw[i]);
		}

		// Write part count
		buffer_write(_buffer, buffer_u32, array_length(Parts));

		// Write each part
		for (var i = 0; i < array_length(Parts); ++i)
		{
			var _part = Parts[i];

			// Bone index
			buffer_write(_buffer, buffer_u32, _part.Bone != undefined ? _part.Bone.Index : 0xFFFFFFFF);

			// Bone transform (dual quaternion - 8 doubles)
			var _boneDQ = _part.Bone != undefined ? _part.Bone.Transform : new BBMOD_DualQuaternion();
			_boneDQ.ToBuffer(_buffer, buffer_f64);

			// Parent chain transforms (accumulate from parent nodes)
			var _parentDQ = new BBMOD_DualQuaternion();
			if (_part.Bone != undefined)
			{
				var _current = _part.Bone.Parent;
				while (_current != undefined)
				{
					_parentDQ = _parentDQ.Mul(_current.Transform);
					_current = _current.Parent;
				}
			}
			_parentDQ.ToBuffer(_buffer, buffer_f64);

			// Shape info
			buffer_write(_buffer, buffer_u8, _part.Type);
			buffer_write(_buffer, buffer_u8, _part.Direction);
			_part.Offset.ToBuffer(_buffer, buffer_f64);
			_part.Size.ToBuffer(_buffer, buffer_f64);

			// Mass
			buffer_write(_buffer, buffer_f64, _part.Mass);

			// Connected bone index
			buffer_write(_buffer, buffer_u32, _part.ConnectedToBone != undefined ? _part.ConnectedToBone.Index : 0xFFFFFFFF);

			// Angular limits
			_part.LowerLimit.ToBuffer(_buffer, buffer_f32);
			_part.UpperLimit.ToBuffer(_buffer, buffer_f32);
		}

		// Write bone hierarchy data for fast C++ transform extraction
		var _nodes = Model.get_node_array();
		var _bones = array_create(Model.BoneCount, undefined);
		for (var i = 0; i < array_length(_nodes); ++i)
		{
			if (_nodes[i].IsBone)
			{
				_bones[@ _nodes[i].Index] = _nodes[i];
			}
		}

		// For each bone, write: parent bone index, accumulated transform to parent bone
		for (var i = 0; i < Model.BoneCount; ++i)
		{
			var _bone = _bones[i];
			if (_bone == undefined)
			{
				// Not a bone - write -1 parent and identity transform
				buffer_write(_buffer, buffer_s32, -1);
				var _identity = new BBMOD_DualQuaternion();
				_identity.ToBuffer(_buffer, buffer_f64);
			}
			else
			{
				// Accumulate transform from bone to parent bone
				// This matches the old GML hierarchy walk logic
				var _dualQuat = _bone.Transform;
				var _parentBoneIndex = -1;
				var _current = _bone.Parent;

				while (_current != undefined)
				{
					if (_current.IsBone)
					{
						_parentBoneIndex = _current.Index;
						break;
					}
					// Accumulate intermediate non-bone node transforms
					_dualQuat = _dualQuat.Mul(_current.Transform);
					_current = _current.Parent;
				}

				buffer_write(_buffer, buffer_s32, _parentBoneIndex);
				_dualQuat.ToBuffer(_buffer, buffer_f64);
			}
		}

		return self;
	};
}
