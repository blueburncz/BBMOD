/// @func bbmod_set_camera_position(x, y, z)
/// @desc Changes camera position to given coordinates.
/// @param {real} x The x position of the camera.
/// @param {real} y The y position of the camera.
/// @param {real} z The z position of the camera.
/// @note This should be called each frame before rendering, since it is required
/// for proper functioning of PBR shaders!
gml_pragma("forceinline");
var _position = global.bbmod_camera_position;
_position[@ 0] = argument0;
_position[@ 1] = argument1;
_position[@ 2] = argument2;