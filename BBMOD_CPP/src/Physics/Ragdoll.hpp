#pragma once

#include "Registry.hpp"
#include "DualQuat.hpp"
#include "PhysicsShape.hpp"

#include <BulletDynamics/Dynamics/btRigidBody.h>
#include <BulletDynamics/ConstraintSolver/btGeneric6DofConstraint.h>

#include <vector>

struct BBMOD_RagdollPart
{
	uint32_t boneIndex;
	btRigidBody* rigidBody;
	btGeneric6DofConstraint* constraint; // nullptr if root
	uint32_t connectedToBoneIndex;

	// Store angular limits for constraint creation in second pass
	btVector3 angularLower;
	btVector3 angularUpper;

	BBMOD_RagdollPart()
		: boneIndex(0)
		, rigidBody(nullptr)
		, constraint(nullptr)
		, connectedToBoneIndex(0xFFFFFFFF) // Invalid index
		, angularLower(0, 0, 0)
		, angularUpper(0, 0, 0)
	{
	}
};

struct BBMOD_Ragdoll
{
	btDynamicsWorld* world;
	std::vector<BBMOD_RagdollPart> parts;
	std::vector<DualQuat> boneOffsets; // From model (for skinning)
	std::vector<int> boneToPartIndex; // Fast lookup: bone index -> part index (-1 if none)
	uint32_t boneCount;
	bool isActive;

	// Bone hierarchy data for transform extraction
	std::vector<int> boneParents; // Parent bone index for each bone (-1 if none)
	std::vector<DualQuat> boneLocalTransforms; // Local transform of each bone
	std::vector<bool> isBone; // Whether each index is a bone

	BBMOD_Ragdoll()
		: world(nullptr)
		, boneCount(0)
		, isActive(true)
	{
	}

	~BBMOD_Ragdoll();
};
