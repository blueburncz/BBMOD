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

	/// @var {real[]} An array of indices of position keys which were used last frame.
	/// Used to optimize search of position keys in following frames.
	/// @see BBMOD_EPositionKey
	/// @private
	PositionKeyLast = [];

	/// @var {real[]} An array of indices of rotation keys which were used last frame.
	/// Used to optimize search of rotation keys in following frames.
	/// @see BBMOD_ERotationKey
	/// @private
	RotationKeyLast = [];

	/// @member {array<matrix>} An array of individual node transformation matrices,
	/// without offsets. Useful for attachments.
	/// @see {@link BBMOD_AnimationPlayer.get_node_transform}
	/// @private
	NodeTransform = undefined;

	/// @member {real[]} An array containing transformation matrices of all bones.
	/// Used to pass current model pose as a uniform to a vertex shader.
	/// @see {@link BBMOD_AnimationPlayer.get_transform}
	/// @private
	TransformArray = undefined;
}