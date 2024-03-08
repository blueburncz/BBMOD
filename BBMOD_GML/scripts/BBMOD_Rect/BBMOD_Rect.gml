/// @module Core

/// @func BBMOD_Rect([_x[, _y[, _width[, _height]]]])
///
/// @desc A rectangle structure.
///
/// @param {Real} [_x] The X position of the rectangle's to left corner.
/// Defaults to 0.
/// @param {Real} [_y] The Y position of the rectangle's to left corner.
/// Defaults to 0.
/// @param {Real} [_width] The width of the rectangle. Defaults to 0.
/// @param {Real} [_height] The height of the rectangle. Defaults to 0.
function BBMOD_Rect(_x=0, _y=0, _width=0, _height=0) constructor
{
	/// @var {Real} The X position of the rectangle's to left corner.
	X = _x;

	/// @var {Real} The Y position of the rectangle's to left corner.
	Y = _y;

	/// @var {Real} The width of the rectangle.
	Width = _width;

	/// @var {Real} The height of the rectangle.
	Height = _height;
}
