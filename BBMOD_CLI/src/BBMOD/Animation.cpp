#include <BBMOD/Animation.hpp>
#include <BBMOD/Config.hpp>
#include <BBMOD/Model.hpp>
#include <BBMOD/Math.hpp>
#include <BBMOD/Matrix.hpp>
#include <terminal.hpp>

#include <assimp/anim.h>
#include <assimp/vector3.h>
#include <assimp/quaternion.h>

#include <utils.hpp>
#include <iostream>
#include <stack>

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

bool SDualQuatKey::Save(std::ofstream& file)
{
	if (!SAnimationKey::Save(file))
	{
		return false;
	}
	FILE_WRITE_DUAL_QUAT(file, DualQuat);
	return true;
}

SDualQuatKey* SDualQuatKey::Load(std::ifstream& file)
{
	SDualQuatKey* dualQuatKey = new SDualQuatKey();
	FILE_READ_DATA(file, dualQuatKey->Time);
	FILE_READ_DUAL_QUAT(file, dualQuatKey->DualQuat);
	return dualQuatKey;
}

bool SAnimationNode::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Index);

	uint32_t keyCount = (uint32_t)DualQuatKeys.size();
	FILE_WRITE_DATA(file, keyCount);

	for (SDualQuatKey* key : DualQuatKeys)
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

	uint32_t keyCount;
	FILE_READ_DATA(file, keyCount);

	for (uint32_t i = 0; i < keyCount; ++i)
	{
		SDualQuatKey* key = SDualQuatKey::Load(file);
		animationNode->DualQuatKeys.push_back(key);
	}

	return animationNode;
}

SAnimation* SAnimation::FromAssimp(aiAnimation* aiAnimation, SModel* model, const SConfig& config)
{
	SAnimation* animation = new SAnimation();

	double scale = aiAnimation->mTicksPerSecond / config.SamplingRate;

	animation->Model = model;
	animation->Name = aiAnimation->mName.C_Str();
	animation->Duration = ceil(aiAnimation->mDuration / scale);
	if (animation->Duration < 1.0)
	{
		animation->Duration = 1.0;
	}
	animation->TicsPerSecond = config.SamplingRate;

	for (uint32_t i = 0; i < aiAnimation->mNumChannels; ++i)
	{
		aiNodeAnim* channel = aiAnimation->mChannels[i];

		SAnimationNode* animationNode = new SAnimationNode();
		SNode* node = model->FindNodeByName(channel->mNodeName.C_Str(), model->RootNode);
		if (!node)
		{
			return nullptr;
		}
		animationNode->Index = node->Index;

		std::vector<SPositionKey*> positionKeys;
		std::vector<SRotationKey*> rotationKeys;

		// Position keys
		for (uint32_t j = 0; j < channel->mNumPositionKeys; ++j)
		{
			aiVectorKey& key = channel->mPositionKeys[j];
			SPositionKey* positionKey = new SPositionKey();
			positionKey->Time = key.mTime;
			positionKey->Position[0] = key.mValue.x;
			positionKey->Position[1] = key.mValue.y;
			positionKey->Position[2] = key.mValue.z;
			positionKeys.push_back(positionKey);
		}

		// Rotation keys
		for (uint32_t j = 0; j < channel->mNumRotationKeys; ++j)
		{
			aiQuatKey& key = channel->mRotationKeys[j];
			SRotationKey* rotationKey = new SRotationKey();
			rotationKey->Time = key.mTime;
			rotationKey->Rotation[0] = key.mValue.x;
			rotationKey->Rotation[1] = key.mValue.y;
			rotationKey->Rotation[2] = key.mValue.z;
			rotationKey->Rotation[3] = key.mValue.w;
			rotationKeys.push_back(rotationKey);
		}

		// Interpolate missing keys
		for (double at = 0.0; at <= animation->Duration; at += 1.0)
		{
			double animationTime = (at / animation->Duration) * aiAnimation->mDuration;

			vec3_t position;
			quat_t rotation;

			// Interpolate position
			bool added = false;
			for (uint32_t i = 0; i < positionKeys.size() - 1; ++i)
			{
				if (animationTime < positionKeys[i + 1]->Time)
				{
					SPositionKey* previous = positionKeys[i];
					SPositionKey* next = positionKeys[i + 1];
					vec3_copy(previous->Position, position);
					double factor = (animationTime - previous->Time) / (next->Time - previous->Time);
					vec3_lerp(position, next->Position, (float)factor);
					added = true;
					break;
				}
			}

			if (!added)
			{
				SPositionKey* previous = positionKeys[0];
				vec3_copy(previous->Position, position);
			}

			// Interpolate rotation
			added = false;
			for (uint32_t i = 0; i < rotationKeys.size() - 1; ++i)
			{
				if (animationTime < rotationKeys[i + 1]->Time)
				{
					SRotationKey* previous = rotationKeys[i];
					SRotationKey* next = rotationKeys[i + 1];
					quaternion_copy(previous->Rotation, rotation);
					double factor = (animationTime - previous->Time) / (next->Time - previous->Time);
					quaternion_slerp(rotation, next->Rotation, (float)factor);
					added = true;
					break;
				}
			}

			if (!added)
			{
				SRotationKey* previous = rotationKeys[0];
				quaternion_copy(previous->Rotation, rotation);
			}

			// Make dual quat
			SDualQuatKey* key = new SDualQuatKey();
			key->Time = at;

			dual_quaternion_from_translation_rotation(key->DualQuat, position, rotation);

			animationNode->DualQuatKeys.push_back(key);
		}

		animation->AnimationNodes.push_back(animationNode);
	}

	return animation;
}

bool SAnimation::Save(std::string path, const SConfig& config)
{
	std::ofstream file(path, std::ios::out | std::ios::binary);

	if (!file.is_open())
	{
		return false;
	}

	file.write("BBANIM", sizeof(char) * 7);
	FILE_WRITE_DATA(file, VersionMajor);
	FILE_WRITE_DATA(file, VersionMinor);
	unsigned char spaces = 0;
	if (config.AnimationOptimization == 0) { spaces = spaces | BBMOD_BONE_SPACE_PARENT; }
	if (config.AnimationOptimization == 1) { spaces = spaces | BBMOD_BONE_SPACE_WORLD; }
	if (config.AnimationOptimization == 2) { spaces = spaces | BBMOD_BONE_SPACE_WORLD | BBMOD_BONE_SPACE_BONE; }
	FILE_WRITE_DATA(file, spaces);
	FILE_WRITE_DATA(file, Duration);
	FILE_WRITE_DATA(file, TicsPerSecond);

	uint32_t modelNodeCount = Model->NodeCount;
	FILE_WRITE_DATA(file, modelNodeCount);

	uint32_t modelBoneCount = Model->BoneCount;
	FILE_WRITE_DATA(file, modelBoneCount);

	uint32_t nodeSize = modelNodeCount * 8;
	uint32_t boneSize = modelBoneCount * 8;
	float* frameParent = new float[nodeSize];
	float* frameWorld = new float[nodeSize];
	float* frameBone = new float[boneSize];

	for (double frame = 0.0; frame < Duration; ++frame)
	{
		std::stack<SNode*> stackNodes;
		std::stack<float*> stackDualQuat;

		stackNodes.push(Model->RootNode);
		
		float* dqIdentity = dual_quaternion_create();
		stackDualQuat.push(dqIdentity);

		while (!stackNodes.empty())
		{
			SNode* node = stackNodes.top();
			stackNodes.pop();

			float* top = stackDualQuat.top();
			stackDualQuat.pop();
			dual_quat_t dq;
			dual_quaternion_copy(top, dq);
			delete top;

			float nodeIndex = node->Index;

			SAnimationNode* nodeData = nullptr;

			for (SAnimationNode* animationNode : AnimationNodes)
			{
				if (animationNode->Index == nodeIndex)
				{
					nodeData = animationNode;
					break;
				}
			}

			dual_quat_t transform;

			if (nodeData != nullptr)
			{
				SDualQuatKey* key = nodeData->DualQuatKeys.at((uint32_t)frame);
				dual_quaternion_copy(key->DualQuat, transform);
			}
			else
			{
				dual_quaternion_copy(node->Transform, transform);
			}

			// Parent space
			memcpy(&frameParent[(uint32_t)nodeIndex * 8], transform, sizeof(float) * 8);

			// World space
			dual_quat_t dqNew;
			dual_quaternion_multiply(transform, dq, dqNew, 0);

			memcpy(&frameWorld[(uint32_t)nodeIndex * 8], dqNew, sizeof(float) * 8);

			// Bone space
			if (node->IsBone)
			{
				dual_quat_t finalTransform;
				dual_quat_t& offset = Model->Skeleton[(uint32_t)nodeIndex]->Offset;
				dual_quaternion_multiply(offset, dqNew, finalTransform, 0);
				memcpy(&frameBone[(uint32_t)nodeIndex * 8], finalTransform, sizeof(float) * 8);
			}

			for (SNode* child : node->Children)
			{
				stackNodes.push(child);
				float* dqChild = dual_quaternion_create();
				dual_quaternion_copy(dqNew, dqChild);
				stackDualQuat.push(dqChild);
			}
		}

		if (spaces & BBMOD_BONE_SPACE_PARENT)
		{
			for (uint32_t f = 0; f < nodeSize; ++f)
			{
				float v = frameParent[f];
				FILE_WRITE_DATA(file, v);
			}
		}

		if (spaces & BBMOD_BONE_SPACE_WORLD)
		{
			for (uint32_t f = 0; f < nodeSize; ++f)
			{
				float v = frameWorld[f];
				FILE_WRITE_DATA(file, v);
			}
		}

		if (spaces & BBMOD_BONE_SPACE_BONE)
		{
			for (uint32_t f = 0; f < boneSize; ++f)
			{
				float v = frameBone[f];
				FILE_WRITE_DATA(file, v);
			}
		}
	}

	delete[] frameParent;
	delete[] frameWorld;
	delete[] frameBone;

	uint32_t eventCount = 0;
	FILE_WRITE_DATA(file, eventCount);

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

	bool hasMinorVersion = false;

	if (std::strcmp(header, "bbanim") == 0)
	{
	}
	else if (std::strcmp(header, "BBANIM") == 0)
	{
		hasMinorVersion = true;
	}
	else
	{
		file.close();
		return nullptr;
	}

	uint8_t versionMajor;
	FILE_READ_DATA(file, versionMajor);

	if (versionMajor != BBMOD_VERSION_MAJOR)
	{
		file.close();
		return nullptr;
	}

	uint8_t versionMinor = 0;
	if (hasMinorVersion)
	{
		FILE_READ_DATA(file, versionMinor);
		if (versionMinor != BBMOD_VERSION_MINOR)
		{
			file.close();
			return nullptr;
		}
	}

	SAnimation* animation = new SAnimation();
	animation->VersionMajor = versionMajor;
	animation->VersionMinor = versionMinor;
	FILE_READ_DATA(file, animation->Duration);
	FILE_READ_DATA(file, animation->TicsPerSecond);

	uint32_t modelNodeCount;
	FILE_READ_DATA(file, modelNodeCount);

	animation->ModelNodeCount = modelNodeCount;

	for (uint32_t i = 0; i < modelNodeCount; ++i)
	{
		animation->AnimationNodes.push_back(nullptr);
	}

	uint32_t affectedNodeCount;
	FILE_READ_DATA(file, affectedNodeCount);

	for (uint32_t i = 0; i < affectedNodeCount; ++i)
	{
		SAnimationNode* animationNode = SAnimationNode::Load(file);
		animation->AnimationNodes[(uint32_t)animationNode->Index] = animationNode;
	}

	file.close();

	return animation;
}
