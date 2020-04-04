/// @func bbmod_animate(animation_player, animation_instance, anim_time)
/// @desc Animates a Model.
/// @param {array} animation_player An AnimationPlayer structure.
/// @param {array} animation_instance An AnimationInstance structure.
/// @param {real} anim_time The current animation time.
/// [bbmod_create_transform_array](./bbmod_create_transform_array.html).
var _anim_player = argument0;
var _model = _anim_player[BBMOD_EAnimationPlayer.Model];
var _anim_inst = argument1
var _animation = _anim_inst[BBMOD_EAnimationInstance.Animation];
var _animation_time = argument2;
var _anim_stack = global.__bbmod_anim_stack;
var _inverse_transform = _model[BBMOD_EModel.InverseTransformMatrix];
var _position_key_last = _anim_inst[BBMOD_EAnimationInstance.PositionKeyLast];
var _rotation_key_last = _anim_inst[BBMOD_EAnimationInstance.RotationKeyLast];
var _transform_array = _anim_inst[BBMOD_EAnimationInstance.TransformArray];
var _anim_bones = _animation[BBMOD_EAnimation.Bones];

ds_stack_push(_anim_stack, _model[BBMOD_EModel.Skeleton], matrix_build_identity());

while (!ds_stack_empty(_anim_stack))
{
	var _matrix = ds_stack_pop(_anim_stack);
	var _bone = ds_stack_pop(_anim_stack);

	var _transform = _bone[BBMOD_EBone.TransformMatrix];
	var _bone_index = _bone[BBMOD_EBone.Index];

	if (_bone_index >= 0)
	{
		var _bone_data = array_get(_anim_bones, _bone_index);

		if (!is_undefined(_bone_data))
		{
			// Position
			var _positions = _bone_data[BBMOD_EAnimationBone.PositionKeys];
			var k = bbmod_find_animation_key(_positions, _animation_time, _position_key_last[_bone_index]);
			var _position_key = bbmod_get_animation_key(_positions, k);
			var _position_key_next = bbmod_get_animation_key(_positions, k + 1);
			var _factor = bbmod_get_animation_key_interpolation_factor(
				_position_key, _position_key_next, _animation_time);
			var _position_interpolated = bbmod_position_key_interpolate(
				_position_key, _position_key_next, _factor);
			var _mat_position = bbmod_position_key_to_matrix(_position_interpolated);
			_position_key_last[@ _bone_index] = k;

			// Rotation
			var _rotations = _bone_data[BBMOD_EAnimationBone.RotationKeys];
			var k = bbmod_find_animation_key(_rotations, _animation_time, _rotation_key_last[_bone_index]);
			var _rotation_key = bbmod_get_animation_key(_rotations, k);
			var _rotation_key_next = bbmod_get_animation_key(_rotations, k + 1);
			var _factor = bbmod_get_animation_key_interpolation_factor(
				_rotation_key, _rotation_key_next, _animation_time);
			var _rotation_interpolated = bbmod_rotation_key_interpolate(
				_rotation_key, _rotation_key_next, _factor);
			var _mat_rotation = bbmod_rotation_key_to_matrix(_rotation_interpolated);
			_rotation_key_last[@ _bone_index] = k;

			// Multiply transformation matrices
			_transform = matrix_multiply(_mat_rotation, _mat_position);
		}

		// Apply offset
		var _final_transform = _bone[BBMOD_EBone.OffsetMatrix];
		_final_transform = matrix_multiply(_final_transform, matrix_multiply(_transform, _matrix));
		_final_transform = matrix_multiply(_final_transform, _inverse_transform);
		array_copy(_transform_array, _bone_index * 16, _final_transform, 0, 16);
	}

	var _matrix_new = matrix_multiply(_transform, _matrix);

	var _children = _bone[BBMOD_EBone.Children];
	var _child_count = array_length_1d(_children);

	for (var i/*:int*/= 0; i < _child_count; ++i)
	{
		ds_stack_push(_anim_stack, _children[i], _matrix_new);
	}
}