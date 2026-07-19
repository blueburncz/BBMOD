/// @module Core

/// @func __bbmod_editor_debug_draw_line(_x1, _y1, _z1, _x2, _y2, _z2, _color, _alpha)
///
/// @desc Draws a native BBMOD editor debug line.
///
/// @param {Real} _x1 The line start X coordinate.
/// @param {Real} _y1 The line start Y coordinate.
/// @param {Real} _z1 The line start Z coordinate.
/// @param {Real} _x2 The line end X coordinate.
/// @param {Real} _y2 The line end Y coordinate.
/// @param {Real} _z2 The line end Z coordinate.
/// @param {Constant.Color} _color The line color.
/// @param {Real} _alpha The line alpha.
///
/// @private
function __bbmod_editor_debug_draw_line(_x1, _y1, _z1, _x2, _y2, _z2, _color, _alpha)
{
	gml_pragma("forceinline");
	var _vbuffer = global.__bbmodVBufferDebug;
	vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);
	vertex_position_3d(_vbuffer, _x1, _y1, _z1);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x2, _y2, _z2);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_end(_vbuffer);
	vertex_submit(_vbuffer, pr_linelist, -1);
}

/// @func __bbmod_editor_debug_draw_sphere(_position, _radius, _color, _alpha)
///
/// @desc Draws a native BBMOD editor debug wireframe sphere.
///
/// @param {Struct.BBMOD_Vec3} _position The sphere center.
/// @param {Real} _radius The sphere radius.
/// @param {Constant.Color} _color The wireframe color.
/// @param {Real} _alpha The wireframe alpha.
///
/// @private
function __bbmod_editor_debug_draw_sphere(_position, _radius, _color, _alpha)
{
	var _vbuffer = global.__bbmodVBufferDebug;
	vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

	var _x = _position.X;
	var _y = _position.Y;
	var _z = _position.Z;
	var _steps = 24;
	var _inc = 360.0 / _steps;
	var _angle = 0.0;
	var _ldirx1 = lengthdir_x(_radius, _angle);
	var _ldiry1 = lengthdir_y(_radius, _angle);

	repeat(_steps)
	{
		var _ldirx2 = lengthdir_x(_radius, _angle + _inc);
		var _ldiry2 = lengthdir_y(_radius, _angle + _inc);

		vertex_position_3d(_vbuffer, _x, _y + _ldirx1, _z + _ldiry1);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x, _y + _ldirx2, _z + _ldiry2);
		vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, _x + _ldirx1, _y, _z + _ldiry1);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x + _ldirx2, _y, _z + _ldiry2);
		vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, _x + _ldirx1, _y + _ldiry1, _z);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x + _ldirx2, _y + _ldiry2, _z);
		vertex_color(_vbuffer, _color, _alpha);

		_ldirx1 = _ldirx2;
		_ldiry1 = _ldiry2;
		_angle += _inc;
	}

	vertex_end(_vbuffer);
	vertex_submit(_vbuffer, pr_linelist, -1);
}

/// @func __bbmod_editor_debug_draw_aabb(_center, _halfSize, _color, _alpha)
///
/// @desc Draws a native BBMOD editor debug wireframe AABB.
///
/// @param {Struct.BBMOD_Vec3} _center The box center.
/// @param {Struct.BBMOD_Vec3} _halfSize The box half-size.
/// @param {Constant.Color} _color The wireframe color.
/// @param {Real} _alpha The wireframe alpha.
///
/// @private
function __bbmod_editor_debug_draw_aabb(_center, _halfSize, _color, _alpha)
{
	var _vbuffer = global.__bbmodVBufferDebug;

	var _x1 = _center.X - _halfSize.X;
	var _x2 = _center.X + _halfSize.X;
	var _y1 = _center.Y - _halfSize.Y;
	var _y2 = _center.Y + _halfSize.Y;
	var _z1 = _center.Z - _halfSize.Z;
	var _z2 = _center.Z + _halfSize.Z;

	vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

	vertex_position_3d(_vbuffer, _x1, _y1, _z1);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x2, _y1, _z1);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_position_3d(_vbuffer, _x2, _y1, _z1);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x2, _y2, _z1);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_position_3d(_vbuffer, _x2, _y2, _z1);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x1, _y2, _z1);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_position_3d(_vbuffer, _x1, _y2, _z1);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x1, _y1, _z1);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_position_3d(_vbuffer, _x1, _y1, _z2);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x2, _y1, _z2);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_position_3d(_vbuffer, _x2, _y1, _z2);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x2, _y2, _z2);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_position_3d(_vbuffer, _x2, _y2, _z2);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x1, _y2, _z2);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_position_3d(_vbuffer, _x1, _y2, _z2);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x1, _y1, _z2);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_position_3d(_vbuffer, _x1, _y1, _z1);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x1, _y1, _z2);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_position_3d(_vbuffer, _x2, _y1, _z1);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x2, _y1, _z2);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_position_3d(_vbuffer, _x2, _y2, _z1);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x2, _y2, _z2);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_position_3d(_vbuffer, _x1, _y2, _z1);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _x1, _y2, _z2);
	vertex_color(_vbuffer, _color, _alpha);

	vertex_end(_vbuffer);
	vertex_submit(_vbuffer, pr_linelist, -1);
}

/// @func __bbmod_editor_debug_draw_cone(_position, _direction, _length, _angleDeg, _color, _alpha)
///
/// @desc Draws a native BBMOD editor debug wireframe cone.
///
/// @param {Struct.BBMOD_Vec3} _position The cone apex.
/// @param {Struct.BBMOD_Vec3} _direction The cone direction.
/// @param {Real} _length The cone length.
/// @param {Real} _angleDeg The cone half-angle in degrees.
/// @param {Constant.Color} _color The wireframe color.
/// @param {Real} _alpha The wireframe alpha.
///
/// @private
function __bbmod_editor_debug_draw_cone(_position, _direction, _length, _angleDeg, _color, _alpha)
{
	if (_length <= 0.0)
	{
		return;
	}

	var _forward = _direction.Normalize();
	var _right = _forward.Cross(BBMOD_VEC3_UP);
	if (_right.LengthSqr() <= math_get_epsilon())
	{
		_right = _forward.Cross(BBMOD_VEC3_RIGHT);
	}
	_right = _right.Normalize();
	var _up = _right.Cross(_forward).Normalize();
	var _center = _position.Add(_forward.Scale(_length));
	var _radius = tan(degtorad(_angleDeg)) * _length;
	var _vbuffer = global.__bbmodVBufferDebug;
	var _steps = 24;
	var _inc = 360.0 / _steps;
	var _angle = 0.0;
	var _cos1 = dcos(_angle);
	var _sin1 = dsin(_angle);
	var _point1 = _center.Add(_right.Scale(_cos1 * _radius)).Add(_up.Scale(_sin1 * _radius));

	vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

	repeat(_steps)
	{
		var _angle2 = _angle + _inc;
		var _point2 = _center.Add(_right.Scale(dcos(_angle2) * _radius)).Add(_up.Scale(dsin(_angle2) * _radius));

		vertex_position_3d(_vbuffer, _point1.X, _point1.Y, _point1.Z);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _point2.X, _point2.Y, _point2.Z);
		vertex_color(_vbuffer, _color, _alpha);

		if (_angle mod 90.0 == 0.0)
		{
			vertex_position_3d(_vbuffer, _position.X, _position.Y, _position.Z);
			vertex_color(_vbuffer, _color, _alpha);
			vertex_position_3d(_vbuffer, _point1.X, _point1.Y, _point1.Z);
			vertex_color(_vbuffer, _color, _alpha);
		}

		_point1 = _point2;
		_angle = _angle2;
	}

	vertex_end(_vbuffer);
	vertex_submit(_vbuffer, pr_linelist, -1);
}
