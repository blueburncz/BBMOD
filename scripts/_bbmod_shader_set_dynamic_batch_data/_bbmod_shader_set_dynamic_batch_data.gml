/// @func _bbmod_shader_set_dynamic_batch_data(shader, data)
/// @param {real} shader
/// @param {array} data
gml_pragma("forceinline");
shader_set_uniform_f_array(shader_get_uniform(argument0, "u_vData"), argument1);