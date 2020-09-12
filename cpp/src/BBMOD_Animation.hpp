#pragma once

#include "bbmod.hpp"
#include "BBMOD_Model.hpp"
#include <assimp/vector3.h>
#include <assimp/quaternion.h>
#include <assimp/anim.h>
#include <vector>
#include <string>
#include <fstream>

struct BBMOD_AnimationKey
{
	double Time = 0.0;

	virtual bool Save(std::ofstream& file);
};

struct BBMOD_PositionKey : public BBMOD_AnimationKey
{
	BBMOD_PositionKey()
		: Position(aiVector3D())
		, BBMOD_AnimationKey()
	{
	}

	bool Save(std::ofstream& file);

	aiVector3D Position;
};

struct BBMOD_RotationKey : public BBMOD_AnimationKey
{
	BBMOD_RotationKey()
		: Rotation(aiQuaternion())
		, BBMOD_AnimationKey()
	{
	}

	bool Save(std::ofstream& file);

	aiQuaternion Rotation;
};

struct BBMOD_AnimationNode
{
	bool Save(std::ofstream& file);

	float Index = 0.0f;

	std::vector<BBMOD_PositionKey*> PositionKeys;

	std::vector<BBMOD_RotationKey*> RotationKeys;
};

struct BBMOD_Animation
{
	static BBMOD_Animation* FromAssimp(aiAnimation* animation, BBMOD_Model* model);

	bool Save(std::string path);

	unsigned char Version = BBMOD_VERSION;

	std::string Name;

	double Duration = 0.0;

	double TicsPerSecond = 20.0;

	std::vector<BBMOD_AnimationNode*> AnimationNodes;

	BBMOD_Model* Model = nullptr;
};
