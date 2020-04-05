/// @func bbmod_animate(model, animation_instance, anim_time)
/// @desc Animates a Model.
/// @param {array} model A Model structure.
/// @param {array} animation_instance An AnimationInstance structure.
/// @param {real} anim_time The current animation time.
/// [bbmod_create_transform_array](./bbmod_create_transform_array.html).
var _model = argument0;
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
			var _position = bbmod_get_interpolated_position_key(
				_positions, _animation_time, _position_key_last[_bone_index]);
			var _mat_position = bbmod_position_key_to_matrix(_position);
			_position_key_last[@ _bone_index] = BBMOD_KEY_INDEX_LAST;

			// Rotation
			var _rotations = _bone_data[BBMOD_EAnimationBone.RotationKeys];
			var _rotation = bbmod_get_interpolated_rotation_key(
				_rotations, _animation_time, _rotation_key_last[_bone_index]);
			var _mat_rotation = bbmod_rotation_key_to_matrix(_rotation);
			_rotation_key_last[@ _bone_index] = BBMOD_KEY_INDEX_LAST;

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