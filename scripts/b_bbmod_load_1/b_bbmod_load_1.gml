/// @func b_bbmod_load_1(file[, format[, sha1]])
/// @param {string} file
/// @param {real} [format]
/// @param {string} [sha1]
/// @return {real}
var _file = argument[0];
var _vformat = (argument_count > 1) ? argument[1] : undefined;
var _sha1 = (argument_count > 2) ? argument[2] : undefined;

if (!is_undefined(_sha1))
{
	if (sha1_file(_file) != _sha1)
	{
		return -1;
	}
}

var _buffer = buffer_load(_file);
buffer_seek(_buffer, buffer_seek_start, 0);

var _node = -1;
var _version = buffer_read(_buffer, buffer_u8);

if (_version == 1)
{
	var _has_vertices = buffer_read(_buffer, buffer_bool);
	var _has_normals = buffer_read(_buffer, buffer_bool);
	var _has_uvs = buffer_read(_buffer, buffer_bool);
	var _has_colors = buffer_read(_buffer, buffer_bool);
	var _has_tangentw = buffer_read(_buffer, buffer_bool);
	var _has_bones = buffer_read(_buffer, buffer_bool);

	var _inverse_transform = b_bbmod_load_matrix(_buffer);

	var _mask = (_has_vertices
		| _has_normals << 1
		| _has_uvs << 2
		| _has_colors << 3
		| _has_tangentw << 4
		| _has_bones << 5);

	if (is_undefined(_vformat))
	{
		_vformat = b_bbmod_get_vertex_format(
			_has_vertices,
			_has_normals,
			_has_uvs,
			_has_colors,
			_has_tangentw,
			_has_bones);
	}

	// Global inverse transform
	_node = b_bbmod_node_load(_buffer, _vformat, _mask);
	_node[? "inverse_transform"] = _inverse_transform;

	// Bones
	var _bone_count = buffer_read(_buffer, buffer_u32);
	show_debug_message("Bone count: " + string(_bone_count));
	_node[? "bone_count"] = _bone_count;

	if (_bone_count > 0)
	{
		_node[? "skeleton"] = b_bbmod_bone_load(_buffer);
	}

	// Animations
	var _animations = ds_map_create();
	ds_map_add_map(_node, "animations", _animations);

	var _anim_count = buffer_read(_buffer, buffer_u32);
	show_debug_message("Animation count: " + string(_anim_count));

	repeat (_anim_count)
	{
		var _anim_name = buffer_read(_buffer, buffer_string);
		show_debug_message("Animation: " + _anim_name);

		var _anim_data = ds_map_create();
		ds_map_add_map(_animations, _anim_name, _anim_data);

		var _animation_duration = buffer_read(_buffer, buffer_f64);
		_anim_data[? "duration"] = _animation_duration;
		show_debug_message("Duration: " + string(_animation_duration));

		var _animation_tics_per_sec = buffer_read(_buffer, buffer_f64);
		_anim_data[? "tics_per_sec"] = _animation_tics_per_sec;
		show_debug_message("Tics per sec: " + string(_animation_tics_per_sec));
	   
		var _affected_bone_count = buffer_read(_buffer, buffer_u32);
		show_debug_message("Affected bones: " + string(_affected_bone_count));

		var _animation_bones = ds_map_create();
		ds_map_add_map(_anim_data, "bones", _animation_bones);

		repeat (_affected_bone_count)
		{
			var _bone_id = buffer_read(_buffer, buffer_f32);
			show_debug_message("Bone id: " + string(_bone_id));

			var _bone_data = ds_map_create();
			ds_map_add_map(_animation_bones, _bone_id, _bone_data);

			show_debug_message("Reading positions");

			var _positions = ds_list_create();
			ds_map_add_list(_bone_data, "positions", _positions);

			var _position_keys = buffer_read(_buffer, buffer_u32);
			repeat (_position_keys)
			{
				var _time = buffer_read(_buffer, buffer_f64);
				var _position = array_create(3);
				_position[0] = buffer_read(_buffer, buffer_f32);
				_position[1] = buffer_read(_buffer, buffer_f32);
				_position[2] = buffer_read(_buffer, buffer_f32);
				var _key = array_create(2);
				_key[0] = _time;
				_key[1] = _position;
				show_debug_message(_key);
				ds_list_add(_positions, _key);
			}

			show_debug_message("Reading rotations");

			var _rotations = ds_list_create();
			ds_map_add_list(_bone_data, "rotations", _rotations);

			var _rotation_keys = buffer_read(_buffer, buffer_u32);
			repeat (_rotation_keys)
			{
				var _time = buffer_read(_buffer, buffer_f64);
				var _rotation = array_create(3);
				_rotation[0] = buffer_read(_buffer, buffer_f32);
				_rotation[1] = buffer_read(_buffer, buffer_f32);
				_rotation[2] = buffer_read(_buffer, buffer_f32);
				_rotation[3] = buffer_read(_buffer, buffer_f32);
				var _key = array_create(2);
				_key[0] = _time;
				_key[1] = _rotation;
				show_debug_message(_key);
				ds_list_add(_rotations, _key);
			}
		}
	}
}

buffer_delete(_buffer);
return _node;