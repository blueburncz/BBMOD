/// @func bbmod_animate(bbmod, animation, out)
/// @param {array} node
/// @param {array} animation
/// @param {array} out
/// @return {array}
var _t = get_timer();

var _bbmod = argument0;
var _animation = argument1;
var _array = argument2;

var _anim_stack = global.__bbmod_anim_stack;
var _inverse_transform = _bbmod[BBMOD_EModel.InverseTransformMatrix];

var _time_in_seconds = current_time * 0.001;
var _animation_time = bbmod_get_animation_time(_animation, _time_in_seconds);

// TODO: Use animation_cache struct!
if (_animation_time < animation_time_last)
{
	position_key_last = array_create(64, 0);
	rotation_key_last = array_create(64, 0);
}
animation_time_last = _animation_time;

ds_stack_push(_anim_stack, _bbmod[BBMOD_EModel.Skeleton], matrix_build_identity());

while (!ds_stack_empty(_anim_stack))
{
	var _matrix = ds_stack_pop(_anim_stack);
	var _bone = ds_stack_pop(_anim_stack);

	var _transform = _bone[@ BBMOD_EBone.TransformMatrix];
	var _bone_index = _bone[@ BBMOD_EBone.Index];

	if (_bone_index >= 0)
	{
		var _bone_data = array_get(_animation[@ BBMOD_EAnimation.Bones], _bone_index);

		if (!is_undefined(_bone_data))
		{
			// Position
			var _positions = _bone_data[@ BBMOD_EAnimationBone.PositionKeys];
			var k = bbmod_find_animation_key(_positions, _animation_time, position_key_last[_bone_index]);
			var _position_key = bbmod_get_animation_key(_positions, k);
			var _position_key_next = bbmod_get_animation_key(_positions, k + 1);
			var _factor = bbmod_get_animation_key_interpolation_factor(
				_position_key, _position_key_next, _animation_time);
			var _position_interpolated = bbmod_position_key_interpolate(
				_position_key, _position_key_next, _factor);
			var _mat_position = bbmod_position_key_to_matrix(_position_interpolated);
			position_key_last[@ _bone_index] = k;

			// Rotation
			var _rotations = _bone_data[@ BBMOD_EAnimationBone.RotationKeys];
			var k = bbmod_find_animation_key(_rotations, _animation_time, rotation_key_last[_bone_index]);
			var _rotation_key = bbmod_get_animation_key(_rotations, k);
			var _rotation_key_next = bbmod_get_animation_key(_rotations, k + 1);
			var _factor = bbmod_get_animation_key_interpolation_factor(
				_rotation_key, _rotation_key_next, _animation_time);
			var _rotation_interpolated = bbmod_rotation_key_interpolate(
				_rotation_key, _rotation_key_next, _factor);
			var _mat_rotation = bbmod_rotation_key_to_matrix(_rotation_interpolated);
			rotation_key_last[@ _bone_index] = k;

			// Multiply transformation matrices
			_transform = matrix_multiply(_mat_rotation, _mat_position);
		}

		// Apply offset
		var _final_transform = _bone[@ BBMOD_EBone.OffsetMatrix];
		_final_transform = matrix_multiply(_final_transform, matrix_multiply(_transform, _matrix));
		_final_transform = matrix_multiply(_final_transform, _inverse_transform);
		array_copy(_array, _bone_index * 16, _final_transform, 0, 16);
	}

	var _matrix_new = matrix_multiply(_transform, _matrix);

	var _children = _bone[@ BBMOD_EBone.Children];
	var _child_count = array_length_1d(_children);

	for (var i/*:int*/= 0; i < _child_count; ++i)
	{
		ds_stack_push(_anim_stack, _children[i], _matrix_new);
	}
}

show_debug_message("Animate: " + string(get_timer() - _t) + "us");