#pragma once

#include "bbmod.hpp"
#include "BBMOD_Model.hpp"
#include <assimp/vector3.h>
#include <assimp/quaternion.h>
#include <assimp/anim.h>
#include <vector>
#include <string>

struct BBMOD_AnimationKey
{
	double Time = 0;
};

struct BBMOD_PositionKey : public BBMOD_AnimationKey
{
	BBMOD_PositionKey()
		: Position(aiVector3D())
		, BBMOD_AnimationKey()
	{
	}

	aiVector3D Position;
};

struct BBMOD_RotationKey : public BBMOD_AnimationKey
{
	BBMOD_RotationKey()
		: Rotation(aiQuaternion())
		, BBMOD_AnimationKey()
	{
	}

	aiQuaternion Rotation;
};

struct BBMOD_AnimationNode
{
	int Index = 0;

	std::vector<BBMOD_PositionKey*> PositionKeys;

	std::vector<BBMOD_RotationKey*> RotationKeys;
};

struct BBMOD_Animation
{
	static BBMOD_Animation* FromAssimp(aiAnimation* animation, BBMOD_Model* Model);

	size_t Version = BBMOD_VERSION;

	std::string Name;

	double Duration = 0;

	double TicsPerSecond = 20;

	std::vector<BBMOD_AnimationNode*> AnimationNodes;
};
