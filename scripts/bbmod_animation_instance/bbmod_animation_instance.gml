/// @enum An enumeration of members of a legacy animation instance struct.
/// @see BBMOD_EAnimation
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
	/// @member {array<real[]>} An array of individual bone transformation matrices,
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

/// @func bbmod_animation_instance_create(_animation)
/// @desc Creates a new animation instance.
/// @param {BBMOD_EAnimation} _animation An animation to create an instance of.
/// @return {BBMOD_EAnimationInstance} The created animation instance.
/// @private
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