/// @enum An enumeration of members of an AnimationInstance structure.
enum BBMOD_EAnimationInstance
{
	/// @member The animation to be played.
	Animation,
	/// @member True if the animation should be looped.
	Loop,
	/// @member Time when the animation started playing (in seconds).
	AnimationStart,
	/// @member The current animation time.
	AnimationTime,
	/// @member Animation time in last frame. Used to reset members in
	/// looping animations or when switching between animations.
	AnimationTimeLast,
	/// @member An index of a position key which was used last frame.
	/// Used to optimize search of position keys in following frames.
	PositionKeyLast,
	/// @member An index of a rotation key which was used last frame.
	/// Used to optimize search of rotation keys in following frames.
	RotationKeyLast,
	/// @member An array of individual bone transformation matrices,
	/// without offsets. Useful for attachments.
	BoneTransform,
	/// @member An array containing transformation matrices of all bones.
	/// Used to pass current model pose as a uniform to a vertex shader.
	TransformArray,
	/// @member The size of an AnimationInstance structure.
	SIZE
};

/// @func bbmod_animation_instance_create(_animation)
/// @desc Creates a new AnimationInstance structure.
/// @param {array} _animation An Animation structure.
/// @return {array} The created structure.
function bbmod_animation_instance_create(_animation)
{
	var _anim_inst = array_create(BBMOD_EAnimationInstance.SIZE, 0);
	_anim_inst[@ BBMOD_EAnimationInstance.Animation] = _animation;
	_anim_inst[@ BBMOD_EAnimationInstance.Loop] = false;
	_anim_inst[@ BBMOD_EAnimationInstance.AnimationStart] = undefined;
	_anim_inst[@ BBMOD_EAnimationInstance.AnimationTime] = 0;
	_anim_inst[@ BBMOD_EAnimationInstance.AnimationTimeLast] = 0;
	_anim_inst[@ BBMOD_EAnimationInstance.PositionKeyLast] = 0;
	_anim_inst[@ BBMOD_EAnimationInstance.RotationKeyLast] = 0;
	_anim_inst[@ BBMOD_EAnimationInstance.BoneTransform] = undefined;
	_anim_inst[@ BBMOD_EAnimationInstance.TransformArray] = undefined;
	return _anim_inst;
}