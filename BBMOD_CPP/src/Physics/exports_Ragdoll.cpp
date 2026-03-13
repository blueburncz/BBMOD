#include "Ragdoll.hpp"
#include "PhysicsWorld.hpp"
#include "PhysicsShape.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

#include <BulletCollision/CollisionShapes/btBoxShape.h>
#include <BulletCollision/CollisionShapes/btSphereShape.h>
#include <BulletCollision/CollisionShapes/btCapsuleShape.h>
#include <BulletCollision/CollisionShapes/btConeShape.h>
#include <BulletCollision/CollisionShapes/btCylinderShape.h>
#include <BulletCollision/CollisionShapes/btCompoundShape.h>

#include <functional>

////////////////////////////////////////////////////////////////////////////////
//
// Dual Quaternion Helper Functions
//

static DualQuat ReadDualQuat(char*& buffer)
{
	DualQuat dq;
	dq.m_real.setX(BBMOD_ReadBuffer<double>(buffer));
	dq.m_real.setY(BBMOD_ReadBuffer<double>(buffer));
	dq.m_real.setZ(BBMOD_ReadBuffer<double>(buffer));
	dq.m_real.setW(BBMOD_ReadBuffer<double>(buffer));
	dq.m_dual.setX(BBMOD_ReadBuffer<double>(buffer));
	dq.m_dual.setY(BBMOD_ReadBuffer<double>(buffer));
	dq.m_dual.setZ(BBMOD_ReadBuffer<double>(buffer));
	dq.m_dual.setW(BBMOD_ReadBuffer<double>(buffer));
	return dq;
}

static void WriteDualQuat(char*& buffer, const DualQuat& dq)
{
	BBMOD_WriteBuffer(buffer, dq.m_real.getX());
	BBMOD_WriteBuffer(buffer, dq.m_real.getY());
	BBMOD_WriteBuffer(buffer, dq.m_real.getZ());
	BBMOD_WriteBuffer(buffer, dq.m_real.getW());
	BBMOD_WriteBuffer(buffer, dq.m_dual.getX());
	BBMOD_WriteBuffer(buffer, dq.m_dual.getY());
	BBMOD_WriteBuffer(buffer, dq.m_dual.getZ());
	BBMOD_WriteBuffer(buffer, dq.m_dual.getW());
}

static DualQuat DualQuatMul(const DualQuat& a, const DualQuat& b)
{
	DualQuat result;
	result.m_real = a.m_real * b.m_real;
	result.m_dual = (a.m_real * b.m_dual) + (a.m_dual * b.m_real);
	return result;
}

static DualQuat DualQuatInverse(const DualQuat& dq)
{
	DualQuat result;
	// Conjugate of real part (inverse rotation)
	btQuaternion realConj = dq.m_real.inverse();
	result.m_real = realConj;
	// Inverse dual: -conj(r) * d * conj(r)
	result.m_dual = -(realConj * dq.m_dual * realConj);
	return result;
}

static btTransform DualQuatToTransform(const DualQuat& dq)
{
	btQuaternion real = dq.m_real;
	btQuaternion dual = dq.m_dual;

	btQuaternion transQuat = dual * real.inverse() * btScalar(2.0);
	btVector3 translation(transQuat.x(), transQuat.y(), transQuat.z());

	btTransform transform;
	transform.setRotation(real);
	transform.setOrigin(translation);

	return transform;
}

////////////////////////////////////////////////////////////////////////////////
//
// Ragdoll Destructor
//

BBMOD_Ragdoll::~BBMOD_Ragdoll()
{
	// Destroy constraints first
	for (auto& part : parts)
	{
		if (part.constraint)
		{
			world->removeConstraint(part.constraint);
			delete part.constraint;
		}
	}

	// Then destroy rigid bodies
	for (auto& part : parts)
	{
		if (part.rigidBody)
		{
			world->removeRigidBody(part.rigidBody);
			delete part.rigidBody->getMotionState();
			delete part.rigidBody->getCollisionShape();
			delete part.rigidBody;
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
//
// Helper Functions
//

static btCollisionShape* CreateShapeFromInfo(
	BBMOD_EPhysicsShapeType shapeType,
	BBMOD_EAxis upAxis,
	const btVector3& offset,
	const btVector3& size)
{
	btCollisionShape* primitiveShape = nullptr;

	switch (shapeType)
	{
		case BBMOD_EPhysicsShapeType::Box:
			// btBoxShape expects half-extents, size contains full extents
			primitiveShape = new btBoxShape(size * 0.5);
			break;

		case BBMOD_EPhysicsShapeType::Sphere:
			primitiveShape = new btSphereShape(size.x());
			break;

		case BBMOD_EPhysicsShapeType::Capsule:
		{
			btScalar radius = size.x();
			btScalar height = size.y();

			switch (upAxis)
			{
				case BBMOD_EAxis::X:
					primitiveShape = new btCapsuleShapeX(radius, height);
					break;
				case BBMOD_EAxis::Y:
					primitiveShape = new btCapsuleShape(radius, height);
					break;
				case BBMOD_EAxis::Z:
					primitiveShape = new btCapsuleShapeZ(radius, height);
					break;
			}
			break;
		}

		case BBMOD_EPhysicsShapeType::Cone:
		{
			btScalar radius = size.x();
			btScalar height = size.y();

			switch (upAxis)
			{
				case BBMOD_EAxis::X:
					primitiveShape = new btConeShapeX(radius, height);
					break;
				case BBMOD_EAxis::Y:
					primitiveShape = new btConeShape(radius, height);
					break;
				case BBMOD_EAxis::Z:
					primitiveShape = new btConeShapeZ(radius, height);
					break;
			}
			break;
		}

		case BBMOD_EPhysicsShapeType::Cylinder:
		{
			btVector3 halfExtents = size;

			switch (upAxis)
			{
				case BBMOD_EAxis::X:
					primitiveShape = new btCylinderShapeX(halfExtents);
					break;
				case BBMOD_EAxis::Y:
					primitiveShape = new btCylinderShape(halfExtents);
					break;
				case BBMOD_EAxis::Z:
					primitiveShape = new btCylinderShapeZ(halfExtents);
					break;
			}
			break;
		}

		default:
			return nullptr;
	}

	// Wrap in compound shape to apply offset
	auto compoundShape = new btCompoundShape();
	btTransform localTransform;
	localTransform.setIdentity();
	localTransform.setOrigin(offset);
	compoundShape->addChildShape(localTransform, primitiveShape);

	return compoundShape;
}

static btGeneric6DofConstraint* CreateRagdollJoint(
	btRigidBody* parent,
	btRigidBody* child,
	const btVector3& angularLower,
	const btVector3& angularUpper,
	btDiscreteDynamicsWorld* world)
{
	// Joint frame at child's origin, rotated so bone's local Z = constraint's X (twist axis)
	btTransform gizmoWorld = child->getWorldTransform();

	btQuaternion fix = btQuaternion(btVector3(0, 0, -1), -SIMD_HALF_PI);
	btTransform basisFix;
	basisFix.setIdentity();
	basisFix.setRotation(fix);
	gizmoWorld = gizmoWorld * basisFix;

	btTransform frameA = parent->getWorldTransform().inverse() * gizmoWorld;
	btTransform frameB = child->getWorldTransform().inverse() * gizmoWorld;

	auto joint = new btGeneric6DofConstraint(*parent, *child, frameA, frameB, true);

	// Lock linear motion
	joint->setLinearLowerLimit(btVector3(0, 0, 0));
	joint->setLinearUpperLimit(btVector3(0, 0, 0));

	// Set angular limits (already in radians)
	joint->setAngularLowerLimit(angularLower);
	joint->setAngularUpperLimit(angularUpper);

	// Soft constraint parameters
	for (int i = 0; i < 6; ++i)
	{
		joint->setParam(BT_CONSTRAINT_STOP_ERP, 0.1f, i);
		joint->setParam(BT_CONSTRAINT_STOP_CFM, 0.0f, i);
	}

	world->addConstraint(joint, true);
	return joint;
}

////////////////////////////////////////////////////////////////////////////////
//
// Ragdoll Creation
//

GM_EXPORT double BBMOD_PhysicsWorld_CreateRagdoll(double _worldId, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);
	auto world = physicsWorld->m_dynamicsWorld;

	// Read bone count
	uint32_t boneCount = BBMOD_ReadBuffer<uint32_t>(_buffer);

	// Read bone offsets (for skinning)
	std::vector<DualQuat> boneOffsets;
	boneOffsets.reserve(boneCount);
	for (uint32_t i = 0; i < boneCount; ++i)
	{
		boneOffsets.push_back(ReadDualQuat(_buffer));
	}

	// Read world transform matrix
	btScalar worldMat[16];
	for (int i = 0; i < 16; ++i)
	{
		worldMat[i] = BBMOD_ReadBuffer<double>(_buffer);
	}
	btTransform worldTransform;
	worldTransform.setFromOpenGLMatrix(worldMat);

	// Read part count
	uint32_t partCount = BBMOD_ReadBuffer<uint32_t>(_buffer);

	// Create ragdoll struct
	auto ragdoll = new BBMOD_Ragdoll();
	ragdoll->world = world;
	ragdoll->boneCount = boneCount;
	ragdoll->boneOffsets = boneOffsets;
	ragdoll->parts.reserve(partCount);

	// First pass: create all rigid bodies
	for (uint32_t i = 0; i < partCount; ++i)
	{
		BBMOD_RagdollPart part;

		// Read bone index
		part.boneIndex = BBMOD_ReadBuffer<uint32_t>(_buffer);

		// Read bone transform (dual quaternion)
		DualQuat boneDQ = ReadDualQuat(_buffer);

		// Read parent chain transform
		DualQuat parentDQ = ReadDualQuat(_buffer);

		// Compute world transform: worldTransform * parentDQ * boneDQ
		btTransform boneWorld = DualQuatToTransform(
			DualQuatMul(parentDQ, boneDQ)
		);
		boneWorld = worldTransform * boneWorld;

		// Read shape info
		auto shapeType = static_cast<BBMOD_EPhysicsShapeType>(BBMOD_ReadBuffer<uint8_t>(_buffer));
		auto upAxis = static_cast<BBMOD_EAxis>(BBMOD_ReadBuffer<uint8_t>(_buffer));

		btVector3 offset;
		offset.setX(BBMOD_ReadBuffer<double>(_buffer));
		offset.setY(BBMOD_ReadBuffer<double>(_buffer));
		offset.setZ(BBMOD_ReadBuffer<double>(_buffer));

		btVector3 size;
		size.setX(BBMOD_ReadBuffer<double>(_buffer));
		size.setY(BBMOD_ReadBuffer<double>(_buffer));
		size.setZ(BBMOD_ReadBuffer<double>(_buffer));

		// Read mass
		btScalar mass = BBMOD_ReadBuffer<double>(_buffer);

		// Read connected bone index (for constraints later)
		part.connectedToBoneIndex = BBMOD_ReadBuffer<uint32_t>(_buffer);

		// Read angular limits (in degrees, convert to radians)
		btVector3 angularLowerDeg, angularUpperDeg;
		angularLowerDeg.setX(BBMOD_ReadBuffer<float>(_buffer));
		angularLowerDeg.setY(BBMOD_ReadBuffer<float>(_buffer));
		angularLowerDeg.setZ(BBMOD_ReadBuffer<float>(_buffer));
		angularUpperDeg.setX(BBMOD_ReadBuffer<float>(_buffer));
		angularUpperDeg.setY(BBMOD_ReadBuffer<float>(_buffer));
		angularUpperDeg.setZ(BBMOD_ReadBuffer<float>(_buffer));

		// Convert to radians
		auto degToRad = [](btScalar deg) { return deg * SIMD_PI / btScalar(180.0); };
		part.angularLower.setValue(
			degToRad(angularLowerDeg.x()),
			degToRad(angularLowerDeg.y()),
			degToRad(angularLowerDeg.z())
		);
		part.angularUpper.setValue(
			degToRad(angularUpperDeg.x()),
			degToRad(angularUpperDeg.y()),
			degToRad(angularUpperDeg.z())
		);

		// Create collision shape
		auto shape = CreateShapeFromInfo(shapeType, upAxis, offset, size);
		if (!shape)
		{
			part.rigidBody = nullptr;
			part.constraint = nullptr;
			ragdoll->parts.push_back(part);
			continue;
		}

		// Calculate inertia
		btVector3 localInertia(0, 0, 0);
		if (mass > 0.0)
		{
			shape->calculateLocalInertia(mass, localInertia);
		}

		// Create rigid body
		auto motionState = new btDefaultMotionState(boneWorld);
		btRigidBody::btRigidBodyConstructionInfo rbInfo(mass, motionState, shape, localInertia);
		rbInfo.m_restitution = 0.0f;
		rbInfo.m_friction = 0.5f;

		part.rigidBody = new btRigidBody(rbInfo);
		part.rigidBody->setDamping(0.05f, 0.85f);
		part.rigidBody->setSleepingThresholds(0.1f, 0.1f);
		part.rigidBody->setDeactivationTime(1.0f);

		// Add to world
		world->addRigidBody(part.rigidBody);

		part.constraint = nullptr; // Will create in second pass
		ragdoll->parts.push_back(part);
	}

	// Build bone index to part index map for fast lookups (store in ragdoll for reuse)
	ragdoll->boneToPartIndex.resize(boneCount, -1);
	for (size_t i = 0; i < ragdoll->parts.size(); ++i)
	{
		if (ragdoll->parts[i].rigidBody && ragdoll->parts[i].boneIndex < boneCount)
		{
			ragdoll->boneToPartIndex[ragdoll->parts[i].boneIndex] = static_cast<int>(i);
		}
	}

	// Second pass: create constraints between connected parts
	for (size_t i = 0; i < ragdoll->parts.size(); ++i)
	{
		auto& part = ragdoll->parts[i];

		// Skip if no rigid body
		if (!part.rigidBody)
		{
			continue;
		}

		// Skip if not connected to any bone
		if (part.connectedToBoneIndex == 0xFFFFFFFF)
		{
			continue;
		}

		// Find parent part using fast lookup
		int parentIndex = (part.connectedToBoneIndex < boneCount) ? ragdoll->boneToPartIndex[part.connectedToBoneIndex] : -1;
		if (parentIndex < 0)
		{
			continue;
		}

		BBMOD_RagdollPart* parentPart = &ragdoll->parts[parentIndex];

		// Create constraint
		part.constraint = CreateRagdollJoint(
			parentPart->rigidBody,
			part.rigidBody,
			part.angularLower,
			part.angularUpper,
			world
		);
	}

	// Read bone hierarchy data for transform extraction
	ragdoll->boneParents.reserve(boneCount);
	ragdoll->boneLocalTransforms.reserve(boneCount);
	ragdoll->isBone.reserve(boneCount);

	for (uint32_t i = 0; i < boneCount; ++i)
	{
		int32_t parentIndex = BBMOD_ReadBuffer<int32_t>(_buffer);
		DualQuat localTransform = ReadDualQuat(_buffer);

		ragdoll->boneParents.push_back(parentIndex);
		ragdoll->boneLocalTransforms.push_back(localTransform);
		ragdoll->isBone.push_back(parentIndex >= -1); // If parent is valid or -1, it's a bone
	}

	return Registry::Add(ragdoll);
}

////////////////////////////////////////////////////////////////////////////////
//
// Ragdoll Mode Switching
//

GM_EXPORT double BBMOD_Ragdoll_SetActive(double _ragdollId, double _active)
{
	auto ragdoll = Registry::Get<BBMOD_Ragdoll>(_ragdollId);
	ragdoll->isActive = (_active > 0.5);

	// When active, bodies are dynamic
	// When inactive, bodies become kinematic (animation-driven)
	for (auto& part : ragdoll->parts)
	{
		if (part.rigidBody)
		{
			if (ragdoll->isActive)
			{
				// Enable physics
				part.rigidBody->setCollisionFlags(
					part.rigidBody->getCollisionFlags() & ~btCollisionObject::CF_KINEMATIC_OBJECT
				);
				part.rigidBody->forceActivationState(ACTIVE_TAG);
				part.rigidBody->activate();
			}
			else
			{
				// Make kinematic
				part.rigidBody->setCollisionFlags(
					part.rigidBody->getCollisionFlags() | btCollisionObject::CF_KINEMATIC_OBJECT
				);
				part.rigidBody->setActivationState(DISABLE_DEACTIVATION);
			}
		}
	}

	return 1.0;
}

GM_EXPORT double BBMOD_Ragdoll_SyncToAnimation(double _ragdollId, char* _buffer)
{
	auto ragdoll = Registry::Get<BBMOD_Ragdoll>(_ragdollId);

	// Read world transform matrix
	btScalar worldMat[16];
	for (int i = 0; i < 16; ++i)
	{
		worldMat[i] = BBMOD_ReadBuffer<double>(_buffer);
	}
	btTransform worldTransform;
	worldTransform.setFromOpenGLMatrix(worldMat);

	// Read transform count
	uint32_t transformCount = BBMOD_ReadBuffer<uint32_t>(_buffer);

	// Read all transforms (dual quaternions - in model space)
	std::vector<DualQuat> transforms;
	uint32_t numBones = transformCount / 8;
	transforms.reserve(numBones);
	for (uint32_t i = 0; i < numBones; ++i)
	{
		transforms.push_back(ReadDualQuat(_buffer));
	}

	// Update each rigid body to match animation pose
	for (auto& part : ragdoll->parts)
	{
		if (part.rigidBody && part.boneIndex < transforms.size())
		{
			// transforms[] contains skinning transforms (world × boneOffset)
			// We need the actual bone world transform, so undo the bone offset
			DualQuat skinningDQ = transforms[part.boneIndex];
			DualQuat boneOffsetInv = DualQuatInverse(ragdoll->boneOffsets[part.boneIndex]);
			DualQuat boneDQ = DualQuatMul(skinningDQ, boneOffsetInv);

			// Convert to transform and apply world transform
			btTransform boneTransform = DualQuatToTransform(boneDQ);
			btTransform worldBoneTransform = worldTransform * boneTransform;

			// Update rigid body
			part.rigidBody->setWorldTransform(worldBoneTransform);
			part.rigidBody->setLinearVelocity(btVector3(0, 0, 0));
			part.rigidBody->setAngularVelocity(btVector3(0, 0, 0));
		}
	}

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Transform Extraction
//

GM_EXPORT double BBMOD_Ragdoll_GetTransformArray(double _ragdollId, char* _buffer)
{
	auto ragdoll = Registry::Get<BBMOD_Ragdoll>(_ragdollId);

	// Complete transform extraction in C++ for maximum performance
	// This does everything the old GML code did but much faster

	// Step 1: Get world DQs from ragdoll rigid bodies
	std::vector<DualQuat> worldDqs(ragdoll->boneCount);
	std::vector<bool> hasTransform(ragdoll->boneCount, false);

	for (const auto& part : ragdoll->parts)
	{
		if (part.rigidBody && part.boneIndex < ragdoll->boneCount)
		{
			btTransform worldTransform = part.rigidBody->getWorldTransform();
			worldDqs[part.boneIndex].FromTransform(worldTransform);
			hasTransform[part.boneIndex] = true;
		}
	}

	// Step 2: Fill in missing DQs by using accumulated transforms
	// Use a recursive helper to ensure parents are processed before children
	std::function<void(uint32_t)> computeWorldTransform = [&](uint32_t boneIdx) -> void
	{
		if (hasTransform[boneIdx] || !ragdoll->isBone[boneIdx])
		{
			return; // Already computed or not a bone
		}

		// boneLocalTransforms[boneIdx] contains the accumulated transform
		// from the bone to its parent bone (including intermediate non-bone nodes)
		DualQuat dualQuat = ragdoll->boneLocalTransforms[boneIdx];
		int parentBoneIdx = ragdoll->boneParents[boneIdx];

		// Ensure parent is computed first (recursive)
		if (parentBoneIdx >= 0)
		{
			computeWorldTransform(parentBoneIdx);

			// BBMOD's Mul is reversed: a.Mul(b) = b * a
			// So we need: parentWorld * accumulated
			dualQuat = DualQuatMul(worldDqs[parentBoneIdx], dualQuat);
		}

		worldDqs[boneIdx] = dualQuat;
		hasTransform[boneIdx] = true;
	};

	// Compute all missing bone transforms
	for (uint32_t i = 0; i < ragdoll->boneCount; ++i)
	{
		computeWorldTransform(i);
	}

	// Step 3: Apply bone offsets for skinning and write to buffer
	for (uint32_t i = 0; i < ragdoll->boneCount; ++i)
	{
		if (hasTransform[i])
		{
			DualQuat offset = ragdoll->boneOffsets[i];
			// BBMOD's Mul is reversed: offset.Mul(world) = world * offset
			DualQuat finalDQ = DualQuatMul(worldDqs[i], offset);
			WriteDualQuat(_buffer, finalDQ);
		}
		else
		{
			// Fallback to bind pose (bone offset only)
			WriteDualQuat(_buffer, ragdoll->boneOffsets[i]);
		}
	}

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Ragdoll Utilities
//

GM_EXPORT double BBMOD_Ragdoll_GetRootPosition(double _ragdollId, char* _buffer)
{
	auto ragdoll = Registry::Get<BBMOD_Ragdoll>(_ragdollId);

	// Get position of first ragdoll part (typically pelvis/root)
	if (!ragdoll->parts.empty() && ragdoll->parts[0].rigidBody)
	{
		btVector3 pos = ragdoll->parts[0].rigidBody->getWorldTransform().getOrigin();
		BBMOD_WriteBuffer(_buffer, pos.x());
		BBMOD_WriteBuffer(_buffer, pos.y());
		BBMOD_WriteBuffer(_buffer, pos.z());
		return 1.0;
	}

	// No parts or no rigid body - return origin
	BBMOD_WriteBuffer(_buffer, 0.0);
	BBMOD_WriteBuffer(_buffer, 0.0);
	BBMOD_WriteBuffer(_buffer, 0.0);
	return 0.0;
}

GM_EXPORT double BBMOD_Ragdoll_ApplyForce(double _ragdollId, double _partIndex, char* _buffer)
{
	auto ragdoll = Registry::Get<BBMOD_Ragdoll>(_ragdollId);

	if (_partIndex < 0 || _partIndex >= ragdoll->parts.size())
	{
		return -1.0;
	}

	auto& part = ragdoll->parts[static_cast<size_t>(_partIndex)];
	if (!part.rigidBody)
	{
		return -1.0;
	}

	btVector3 force;
	force.setX(BBMOD_ReadBuffer<double>(_buffer));
	force.setY(BBMOD_ReadBuffer<double>(_buffer));
	force.setZ(BBMOD_ReadBuffer<double>(_buffer));

	part.rigidBody->applyCentralForce(force);
	part.rigidBody->activate();

	return 1.0;
}

GM_EXPORT double BBMOD_Ragdoll_Destroy(double _ragdollId)
{
	auto ragdoll = Registry::Get<BBMOD_Ragdoll>(_ragdollId);
	Registry::Remove(_ragdollId);
	delete ragdoll;
	return 1.0;
}
