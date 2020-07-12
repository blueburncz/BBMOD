/// @func bbmod_animation_create_transition(model, anim_from, time_from, anim_to, time_to, duration)
/// @desc Creates a new animation transition between two specified Animation
/// structures.
/// @param {array} model A Model structure.
/// @param {array} anim_from The first Animation structure.
/// @param {real} time_from Animation time of the first animation.
/// @param {array} anim_to The second Animation structure.
/// @param {real} time_to Animation time of the second animation.
/// @param {real} duration The duration of the transition in seconds.
/// @return {array} The created transition Animation structure.
var _model = argument0;
var _anim_from = argument1;
var _time_from = argument2;
var _anim_to = argument3;
var _time_to = argument4;
var _duration = argument5;
var _anim_stack = global.__bbmod_anim_stack;

var _transition = array_create(BBMOD_EAnimation.SIZE, 0);
_transition[@ BBMOD_EAnimation.Version] = _anim_from[BBMOD_EAnimation.Version];
_transition[@ BBMOD_EAnimation.Duration] = _duration;
_transition[@ BBMOD_EAnimation.TicsPerSecond] = 1;
_transition[@ BBMOD_EAnimation.Bones] = array_create(_model[BBMOD_EModel.BoneCount], undefined);

ds_stack_push(_anim_stack, _model[BBMOD_EModel.Skeleton]);

while (!ds_stack_empty(_anim_stack))
{
	var _bone = ds_stack_pop(_anim_stack);
	var _bone_index = _bone[BBMOD_EBone.Index];

	if (_bone_index >= 0)
	{
		var _bone_data_from = array_get(_anim_from[BBMOD_EAnimation.Bones], _bone_index);
		var _bone_data_to = array_get(_anim_to[BBMOD_EAnimation.Bones], _bone_index);

		if (!is_undefined(_bone_data_from)
			&& !is_undefined(_bone_data_to))
		{
			var _positions, _rotations;

			// Keys from
			_positions = _bone_data_from[BBMOD_EAnimationBone.PositionKeys];
			var _position_from = bbmod_get_interpolated_position_key(
				_positions, _time_from);

			_rotations = _bone_data_from[BBMOD_EAnimationBone.RotationKeys];
			var _rotation_from = bbmod_get_interpolated_rotation_key(
				_rotations, _time_from);

			_position_from[@ BBMOD_EPositionKey.Time] = 0;
			_rotation_from[@ BBMOD_ERotationKey.Time] = 0;

			// Keys to
			_positions = _bone_data_to[BBMOD_EAnimationBone.PositionKeys];
			var _position_to = bbmod_get_interpolated_position_key(
				_positions, _time_to);

			_rotations = _bone_data_to[BBMOD_EAnimationBone.RotationKeys];
			var _rotation_to = bbmod_get_interpolated_rotation_key(
				_rotations, _time_to);

			_position_to[@ BBMOD_EPositionKey.Time] = _duration;
			_rotation_to[@ BBMOD_ERotationKey.Time] = _duration;

			// Create a bone with from,to keys
			var _anim_bone = array_create(BBMOD_EAnimationBone.SIZE, 0);
			_anim_bone[@ BBMOD_EAnimationBone.BoneIndex] = _bone_index;
			_anim_bone[@ BBMOD_EAnimationBone.PositionKeys] = [
				_position_from,
				_position_to,
			];
			_anim_bone[@ BBMOD_EAnimationBone.RotationKeys] = [
				_rotation_from,
				_rotation_to,
			];

			array_set(_transition[BBMOD_EAnimation.Bones], _bone_index, _anim_bone);
		}
	}

	var _children = _bone[BBMOD_EBone.Children];
	var _child_count = array_length_1d(_children);

	for (var i/*:int*/= 0; i < _child_count; ++i)
	{
		ds_stack_push(_anim_stack, _children[i]);
	}
}

return _transition;