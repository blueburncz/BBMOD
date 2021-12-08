////////////////////////////////////////////////////////////////////////////////
//
// Camera
//

/// @var {real[]} The current `[x,y,z]` position of the camera. This should be
/// updated every frame before rendering models.
/// @see bbmod_set_camera_position
global.bbmod_camera_position = new BBMOD_Vec3();

/// @var {real} The current camera exposure.
global.bbmod_camera_exposure = 1.0;

/// @func bbmod_set_camera_position(_x, _y, _z)
/// @desc Changes camera position to given coordinates.
/// @param {real} _x The x position of the camera.
/// @param {real} _y The y position of the camera.
/// @param {real} _z The z position of the camera.
/// @see global.bbmod_camera_position
function bbmod_set_camera_position(_x, _y, _z)
{
	gml_pragma("forceinline");
	var _position = global.bbmod_camera_position;
	_position.X = _x;
	_position.Y = _y;
	_position.Z = _z;
}