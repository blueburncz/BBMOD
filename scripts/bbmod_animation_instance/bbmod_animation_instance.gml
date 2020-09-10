/// @enum An enumeration of members of a legacy animation instance struct.
/// @obsolete This legacy struct is obsolete. Please use
/// {@link BBMOD_AnimationInstance} instead.
enum BBMOD_EAnimationInstance
{
	/// @member {BBMOD_EAnimation} The animation to be played.
	/// @see BBMOD_EAnimation
	/// @readonly
	Animation,
	/// @member {bool} If `true` then the animation should be looped.
	/// @readonly
	Loop,
	/// @member {real} Time when the animation started playing (in seconds).
	/// @readonly
	AnimationStart,
	/// @member {real} The current animation time.
	/// @readonly
	AnimationTime,
	/// @member {real} Animation time in last frame. Used to reset members in
	/// looping animations or when switching between animations.
	/// @readonly
	AnimationTimeLast,
	/// @member {real} An index of a position key which was used last frame.
	/// Used to optimize search of position keys in following frames.
	/// @see BBMOD_EPositionKey
	/// @readonly
	PositionKeyLast,
	/// @member {real} An index of a rotation key which was used last frame.
	/// Used to optimize search of rotation keys in following frames.
	/// @see BBMOD_ERotationKey
	/// @readonly
	RotationKeyLast,
	/// @member {array<matrix>} An array of individual bone transformation matrices,
	/// without offsets. Useful for attachments.
	/// @see bbmod_get_bone_transform
	/// @readonly
	BoneTransform,
	/// @member {real[]} An array containing transformation matrices of all bones.
	/// Used to pass current model pose as a uniform to a vertex shader.
	/// @see bbmod_get_transform
	/// @readonly
	TransformArray,
	/// @member The size of the struct.
	SIZE
};

/// @func BBMOD_AnimationInstance(_animation)
/// @desc An instance of an animation. Used for animation playback.
/// @param {BBMOD_Animation} _animation An animation to create an instance of.
/// @see BBMOD_Animation
function BBMOD_AnimationInstance(_animation) constructor
{
	/// @var {BBMOD_Animation} The animation to be played.
	/// @see BBMOD_Animation
	/// @readonly
	Animation = _animation;

	/// @var {bool} If `true` then the animation should be looped.
	/// @readonly
	Loop = false;

	/// @var {real} Time when the animation started playing (in seconds).
	/// @private
	AnimationStart = undefined;

	/// @var {real} The current animation time.
	/// @private
	AnimationTime = 0;

	/// @var {real} Animation time in last frame. Used to reset members in
	/// looping animations or when switching between animations.
	/// @private
	AnimationTimeLast = 0;

	/// @member {var} An index of a position key which was used last frame.
	/// Used to optimize search of position keys in following frames.
	/// @see BBMOD_EPositionKey
	/// @private
	PositionKeyLast = 0;

	/// @var {real} An index of a rotation key which was used last frame.
	/// Used to optimize search of rotation keys in following frames.
	/// @see BBMOD_ERotationKey
	/// @private
	RotationKeyLast = 0;

	/// @member {array<matrix>} An array of individual bone transformation matrices,
	/// without offsets. Useful for attachments.
	/// @see {@link BBMOD_AnimationPlayer.get_bone_transform}
	/// @private
	BoneTransform = undefined;

	/// @member {real[]} An array containing transformation matrices of all bones.
	/// Used to pass current model pose as a uniform to a vertex shader.
	/// @see {@link BBMOD_AnimationPlayer.get_transform}
	/// @private
	TransformArray = undefined;
}