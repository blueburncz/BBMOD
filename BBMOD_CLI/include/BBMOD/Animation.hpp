#pragma once

#include <BBMOD/common.hpp>
#include <BBMOD/Model.hpp>
#include <BBMOD/Vector3.hpp>
#include <BBMOD/Quaternion.hpp>
#include <BBMOD/DualQuaternion.hpp>

#include <vector>
#include <string>
#include <fstream>

struct SAnimationKey
{
	virtual bool Save(std::ofstream& file);

	double Time = 0.0;
};

struct SPositionKey : public SAnimationKey
{
	SPositionKey()
		: Position VEC3_ZERO
		, SAnimationKey()
	{
	}

	bool Save(std::ofstream& file);

	static SPositionKey* Load(std::ifstream& file);

	vec3_t Position;
};

struct SRotationKey : public SAnimationKey
{
	SRotationKey()
		: Rotation QUATERNION_IDENTITY
		, SAnimationKey()
	{
	}

	bool Save(std::ofstream& file);

	static SRotationKey* Load(std::ifstream& file);

	quat_t Rotation;
};

struct SDualQuatKey : public SAnimationKey
{
	SDualQuatKey()
		: DualQuat DUAL_QUATERNION_IDENTITY
		, SAnimationKey()
	{
	}

	bool Save(std::ofstream& file);

	static SDualQuatKey* Load(std::ifstream& file);

	dual_quat_t DualQuat;
};

struct SAnimationNode
{
	bool Save(std::ofstream& file);

	static SAnimationNode* Load(std::ifstream& file);

	float Index = 0.0f;

	std::vector<SDualQuatKey*> DualQuatKeys;
};

struct SAnimation
{
	static SAnimation* FromAssimp(struct aiAnimation* animation, SModel* model, const struct SConfig& config);

	bool Save(std::string path, const struct SConfig& config);

	static SAnimation* Load(std::string path);

	uint8_t Version = BBMOD_VERSION;

	std::string Name;

	double Duration = 0.0;

	double TicsPerSecond = 20.0;

	std::vector<SAnimationNode*> AnimationNodes;

	SModel* Model = nullptr;

	uint32_t ModelNodeCount = 0;
};
