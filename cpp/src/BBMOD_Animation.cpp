#include "BBMOD_Animation.hpp"
#include "utils.hpp"

BBMOD_Animation* BBMOD_Animation::FromAssimp(aiAnimation* aiAnimation, BBMOD_Model* model)
{
	BBMOD_Animation* animation = new BBMOD_Animation();

	animation->Model = model;
	animation->Name = aiAnimation->mName.C_Str();
	animation->Duration = aiAnimation->mDuration;
	animation->TicsPerSecond = aiAnimation->mTicksPerSecond;

	for (size_t i = 0; i < aiAnimation->mNumChannels; ++i)
	{
		aiNodeAnim* channel = aiAnimation->mChannels[i];

		BBMOD_AnimationNode* animationNode = new BBMOD_AnimationNode();
		animationNode->Index = model->FindNodeByName(channel->mNodeName.C_Str(), model->RootNode)->Index;
		
		for (size_t j = 0; j < channel->mNumPositionKeys; ++j)
		{
			aiVectorKey& key = channel->mPositionKeys[j];
			BBMOD_PositionKey* positionKey = new BBMOD_PositionKey();
			positionKey->Time = key.mTime;
			positionKey->Position = key.mValue;
			animationNode->PositionKeys.push_back(positionKey);
		}

		for (size_t j = 0; j < channel->mNumRotationKeys; ++j)
		{
			aiQuatKey& key = channel->mRotationKeys[j];
			BBMOD_RotationKey* rotationKey = new BBMOD_RotationKey();
			rotationKey->Time = key.mTime;
			rotationKey->Rotation = key.mValue;
			animationNode->RotationKeys.push_back(rotationKey);
		}

		animation->AnimationNodes.push_back(animationNode);
	}

	return animation;
}

bool BBMOD_AnimationKey::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Time);
	return true;
}

bool BBMOD_PositionKey::Save(std::ofstream& file)
{
	if (!BBMOD_AnimationKey::Save(file))
	{
		return false;
	}
	FILE_WRITE_VEC3(file, Position);
	return true;
}

bool BBMOD_RotationKey::Save(std::ofstream& file)
{
	if (!BBMOD_AnimationKey::Save(file))
	{
		return false;
	}
	FILE_WRITE_QUAT(file, Rotation);
	return true;
}

bool BBMOD_AnimationNode::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Index);

	size_t positionKeyCount = PositionKeys.size();
	FILE_WRITE_DATA(file, positionKeyCount);

	for (BBMOD_PositionKey* key : PositionKeys)
	{
		if (!key->Save(file))
		{
			return false;
		}
	}

	size_t rotationKeyCount = RotationKeys.size();
	FILE_WRITE_DATA(file, rotationKeyCount);

	for (BBMOD_RotationKey* key : RotationKeys)
	{
		if (!key->Save(file))
		{
			return false;
		}
	}

	return true;
}


bool BBMOD_Animation::Save(std::string path)
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

	for (BBMOD_AnimationNode* animationNode : AnimationNodes)
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
