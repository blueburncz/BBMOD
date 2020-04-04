/// @func bbmod_animation_create_transition(bbmod, anim_from, time_from, anim_to, time_to, duration)
/// @desc Creates a new animation transition between two specified animations.
/// @param {array} bbmod
/// @param {array} anim_from
/// @param {real} time_from
/// @param {array} anim_to
/// @param {real} time_to
/// @param {real} duration
/// @return {array} The created animation transition.
var _bbmod = argument0;
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
_transition[@ BBMOD_EAnimation.Bones] = array_create(_bbmod[BBMOD_EModel.BoneCount], undefined);

ds_stack_push(_anim_stack, _bbmod[BBMOD_EModel.Skeleton]);

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
			var _position_interpolated_from;
			var _rotation_interpolated_from;
			var _position_interpolated_to;
			var _rotation_interpolated_to;

			#region From key
			// TODO: Make a script from this?
			var _positions = _bone_data_from[BBMOD_EAnimationBone.PositionKeys];
			var k = bbmod_find_animation_key(_positions, _time_from);
			var _position_key = bbmod_get_animation_key(_positions, k);
			var _position_key_next = bbmod_get_animation_key(_positions, k + 1);
			var _factor = bbmod_get_animation_key_interpolation_factor(
				_position_key, _position_key_next, _time_from);
			_position_interpolated_from = bbmod_position_key_interpolate(
				_position_key, _position_key_next, _factor);

			var _rotations = _bone_data_from[BBMOD_EAnimationBone.RotationKeys];
			var k = bbmod_find_animation_key(_rotations, _time_from);
			var _rotation_key = bbmod_get_animation_key(_rotations, k);
			var _rotation_key_next = bbmod_get_animation_key(_rotations, k + 1);
			var _factor = bbmod_get_animation_key_interpolation_factor(
				_rotation_key, _rotation_key_next, _time_from);
			_rotation_interpolated_from = bbmod_rotation_key_interpolate(
				_rotation_key, _rotation_key_next, _factor);
			#endregion From key

			#region To key
			var _positions = _bone_data_to[BBMOD_EAnimationBone.PositionKeys];
			var k = bbmod_find_animation_key(_positions, _time_to);
			var _position_key = bbmod_get_animation_key(_positions, k);
			var _position_key_next = bbmod_get_animation_key(_positions, k + 1);
			var _factor = bbmod_get_animation_key_interpolation_factor(
				_position_key, _position_key_next, _time_to);
			_position_interpolated_to = bbmod_position_key_interpolate(
				_position_key, _position_key_next, _factor);

			var _rotations = _bone_data_to[BBMOD_EAnimationBone.RotationKeys];
			var k = bbmod_find_animation_key(_rotations, _time_to);
			var _rotation_key = bbmod_get_animation_key(_rotations, k);
			var _rotation_key_next = bbmod_get_animation_key(_rotations, k + 1);
			var _factor = bbmod_get_animation_key_interpolation_factor(
				_rotation_key, _rotation_key_next, _time_to);
			_rotation_interpolated_to = bbmod_rotation_key_interpolate(
				_rotation_key, _rotation_key_next, _factor);
			#endregion To key

			_position_interpolated_from[@ BBMOD_EPositionKey.Time] = 0;
			_rotation_interpolated_from[@ BBMOD_ERotationKey.Time] = 0;

			_position_interpolated_to[@ BBMOD_EPositionKey.Time] = _duration;
			_rotation_interpolated_to[@ BBMOD_ERotationKey.Time] = _duration;

			var _anim_bone = array_create(BBMOD_EAnimationBone.SIZE, 0);
			_anim_bone[@ BBMOD_EAnimationBone.BoneIndex] = _bone_index;
			_anim_bone[@ BBMOD_EAnimationBone.PositionKeys] = [
				_position_interpolated_from,
				_position_interpolated_to,
			];
			_anim_bone[@ BBMOD_EAnimationBone.RotationKeys] = [
				_rotation_interpolated_from,
				_rotation_interpolated_to,
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