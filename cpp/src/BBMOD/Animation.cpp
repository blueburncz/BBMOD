#include <BBMOD/Animation.hpp>
#include <BBMOD/Config.hpp>
#include <BBMOD/Model.hpp>
#include <BBMOD/Math.hpp>
#include <BBMOD/Matrix.hpp>

#include <assimp/anim.h>
#include <assimp/vector3.h>
#include <assimp/quaternion.h>

#include <utils.hpp>
#include <iostream>
#include <stack>
#include <cmath>

bool SAnimationKey::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Time);
	return true;
}

bool SPositionKey::Save(std::ofstream& file)
{
	if (!SAnimationKey::Save(file))
	{
		return false;
	}
	FILE_WRITE_VEC3(file, Position);
	return true;
}

SPositionKey* SPositionKey::Load(std::ifstream& file)
{
	SPositionKey* positionKey = new SPositionKey();
	FILE_READ_DATA(file, positionKey->Time);
	FILE_READ_VEC3(file, positionKey->Position);
	return positionKey;
}

bool SRotationKey::Save(std::ofstream& file)
{
	if (!SAnimationKey::Save(file))
	{
		return false;
	}
	FILE_WRITE_QUAT(file, Rotation);
	return true;
}

SRotationKey* SRotationKey::Load(std::ifstream& file)
{
	SRotationKey* rotationKey = new SRotationKey();
	FILE_READ_DATA(file, rotationKey->Time);
	FILE_READ_QUAT(file, rotationKey->Rotation);
	return rotationKey;
}

bool SAnimationNode::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Index);

	size_t positionKeyCount = PositionKeys.size();
	FILE_WRITE_DATA(file, positionKeyCount);

	for (SPositionKey* key : PositionKeys)
	{
		if (!key->Save(file))
		{
			return false;
		}
	}

	size_t rotationKeyCount = RotationKeys.size();
	FILE_WRITE_DATA(file, rotationKeyCount);

	for (SRotationKey* key : RotationKeys)
	{
		if (!key->Save(file))
		{
			return false;
		}
	}

	return true;
}

SAnimationNode* SAnimationNode::Load(std::ifstream& file)
{
	SAnimationNode* animationNode = new SAnimationNode();
	FILE_READ_DATA(file, animationNode->Index);

	size_t positionKeyCount;
	FILE_READ_DATA(file, positionKeyCount);

	for (size_t i = 0; i < positionKeyCount; ++i)
	{
		SPositionKey* positionKey = SPositionKey::Load(file);
		animationNode->PositionKeys.push_back(positionKey);
	}

	size_t rotationKeyCount;
	FILE_READ_DATA(file, rotationKeyCount);

	for (size_t i = 0; i < rotationKeyCount; ++i)
	{
		SRotationKey* rotationKey = SRotationKey::Load(file);
		animationNode->RotationKeys.push_back(rotationKey);
	}

	return animationNode;
}

SAnimation* SAnimation::FromAssimp(aiAnimation* aiAnimation, SModel* model, const SConfig& config)
{
	SAnimation* animation = new SAnimation();

	animation->Model = model;
	animation->Name = aiAnimation->mName.C_Str();
	animation->Duration = aiAnimation->mDuration;
	animation->TicsPerSecond = aiAnimation->mTicksPerSecond;

	for (size_t i = 0; i < aiAnimation->mNumChannels; ++i)
	{
		aiNodeAnim* channel = aiAnimation->mChannels[i];

		SAnimationNode* animationNode = new SAnimationNode();
		SNode* node = model->FindNodeByName(channel->mNodeName.C_Str(), model->RootNode);
		if (!node)
		{
			return nullptr;
		}
		animationNode->Index = node->Index;

		for (size_t j = 0; j < channel->mNumPositionKeys; ++j)
		{
			aiVectorKey& key = channel->mPositionKeys[j];
			SPositionKey* positionKey = new SPositionKey();
			positionKey->Time = key.mTime;
			positionKey->Position[0] = key.mValue.x;
			positionKey->Position[1] = key.mValue.y;
			positionKey->Position[2] = key.mValue.z;
			animationNode->PositionKeys.push_back(positionKey);
		}

		for (size_t j = 0; j < channel->mNumRotationKeys; ++j)
		{
			aiQuatKey& key = channel->mRotationKeys[j];
			SRotationKey* rotationKey = new SRotationKey();
			rotationKey->Time = key.mTime;
			rotationKey->Rotation[0] = key.mValue.x;
			rotationKey->Rotation[1] = key.mValue.y;
			rotationKey->Rotation[2] = key.mValue.z;
			rotationKey->Rotation[3] = key.mValue.w;
			animationNode->RotationKeys.push_back(rotationKey);
		}

		animation->AnimationNodes.push_back(animationNode);
	}

	return animation;
}

bool SAnimation::Save(std::string path)
{
	std::ofstream file(path, std::ios::out | std::ios::binary);

	if (!file.is_open())
	{
		return false;
	}

	file.write("bbanim", sizeof(char) * 7);
	FILE_WRITE_DATA(file, Version);
	FILE_WRITE_DATA(file, Duration);
	FILE_WRITE_DATA(file, TicsPerSecond);

	size_t modelNodeCount = Model->NodeCount;
	FILE_WRITE_DATA(file, modelNodeCount);

	size_t affectedNodeCount = AnimationNodes.size();
	FILE_WRITE_DATA(file, affectedNodeCount);

	for (SAnimationNode* animationNode : AnimationNodes)
	{
		if (!animationNode->Save(file))
		{
			return true;
		}
	}

	file.flush();
	file.close();

	return true;
}

SAnimation* SAnimation::Load(std::string path)
{
	std::ifstream file(path, std::ios::in | std::ios::binary);

	if (!file.is_open())
	{
		return nullptr;
	}

	char header[7];
	file.read(header, 7);
	const char* headerExpected = "bbanim";

	if (std::strcmp(header, headerExpected) != 0)
	{
		file.close();
		return nullptr;
	}

	uint8_t version;
	FILE_READ_DATA(file, version);

	if (version != BBMOD_VERSION)
	{
		file.close();
		return nullptr;
	}

	SAnimation* animation = new SAnimation();
	FILE_READ_DATA(file, animation->Duration);
	FILE_READ_DATA(file, animation->TicsPerSecond);

	size_t modelNodeCount;
	FILE_READ_DATA(file, modelNodeCount);

	animation->ModelNodeCount = modelNodeCount;

	for (size_t i = 0; i < modelNodeCount; ++i)
	{
		animation->AnimationNodes.push_back(nullptr);
	}

	size_t affectedNodeCount;
	FILE_READ_DATA(file, affectedNodeCount);

	for (size_t i = 0; i < affectedNodeCount; ++i)
	{
		SAnimationNode* animationNode = SAnimationNode::Load(file);
		animation->AnimationNodes[(size_t)animationNode->Index] = animationNode;
	}

	file.close();

	return animation;
}
