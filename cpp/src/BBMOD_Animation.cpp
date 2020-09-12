#include "BBMOD_Animation.hpp"

BBMOD_Animation* BBMOD_Animation::FromAssimp(aiAnimation* aiAnimation, BBMOD_Model* model)
{
	BBMOD_Animation* animation = new BBMOD_Animation();

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
			aiVectorKey& key = channel->mPositionKeys[i];
			BBMOD_PositionKey* positionKey = new BBMOD_PositionKey();
			positionKey->Time = key.mTime;
			positionKey->Position = key.mValue;
			animationNode->PositionKeys.push_back(positionKey);
		}

		for (size_t j = 0; j < channel->mNumRotationKeys; ++j)
		{
			aiQuatKey& key = channel->mRotationKeys[i];
			BBMOD_RotationKey* rotationKey = new BBMOD_RotationKey();
			rotationKey->Time = key.mTime;
			rotationKey->Rotation = key.mValue;
			animationNode->RotationKeys.push_back(rotationKey);
		}

		animation->AnimationNodes.push_back(animationNode);
	}

	return animation;
}
