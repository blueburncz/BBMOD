/// @func WorldToScreen(_pos, _viewProjMat, _screenWidth, _screenHeight)
/// @desc Computes screen-space position of a point in world-space.
/// @param {BBMOD_Vec2} _pos The world-space position.
/// @param {real[16]} _viewProjMat A `view * projection` matrix.
/// @param {real} _screenWidth The width of the screen.
/// @param {real} _screenHeight The height of the screen.
/// @return {BBMOD_Vec4/undefined} The screen-space position or `undefined` if
/// the point is outside of the screen.
function WorldToScreen(_pos, _viewProjMat, _screenWidth, _screenHeight)
{
	var _screenPos = new BBMOD_Vec4(_pos.X, _pos.Y, _pos.Z, 1.0).Transform(_viewProjMat);
	if (_screenPos.Z < 0.0)
	{
		return undefined;
	}
	_screenPos = _screenPos.Scale(1.0 / _screenPos.W);
	_screenPos.X = (_screenPos.X * 0.5 + 0.5) * _screenWidth;
	_screenPos.Y = (1.0 - (_screenPos.Y * 0.5 + 0.5)) * _screenHeight;
	return _screenPos;
}