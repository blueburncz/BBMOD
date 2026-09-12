/// @module Editor

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
///
/// @example
/// ```gml
/// material = BBMOD_MATERIAL_DEFAULT.clone()
///     .set_shader(BBMOD_ERenderPass.Id, BBMOD_SHADER_INSTANCE_ID);
/// ```
///
/// @see BBMOD_ERenderPass.Id
#macro BBMOD_SHADER_INSTANCE_ID __bbmod_shader_id()

function __bbmod_shader_id()
{
	static _shader = new BBMOD_BaseShader(BBMOD_ShInstanceID, BBMOD_VFORMAT_DEFAULT)
		.add_variant(BBMOD_ShInstanceIDAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED)
		.add_variant(BBMOD_ShInstanceIDBatched, BBMOD_VFORMAT_DEFAULT_BATCHED)
		.add_variant(BBMOD_ShInstanceIDColor, BBMOD_VFORMAT_DEFAULT_COLOR)
		.add_variant(BBMOD_ShInstanceIDColorAnimated, BBMOD_VFORMAT_DEFAULT_COLOR_ANIMATED)
		.add_variant(BBMOD_ShInstanceIDColorBatched, BBMOD_VFORMAT_DEFAULT_COLOR_BATCHED)
		.add_variant(BBMOD_ShInstanceIDLightmap, BBMOD_VFORMAT_DEFAULT_LIGHTMAP);
	return _shader;
}

////////////////////////////////////////////////////////////////////////////////

/// @module Editor Geometry
///
/// @desc Private BBMOD-owned wireframe primitives used by {@link BBMOD_Editor}.
/// Geometry is submitted immediately to the shared debug vertex buffer and is
/// not retained as editor state.

/// @func bbmod_editor_draw_line(_from, _to, [_color, _alpha])
///
/// @desc Draws a colored line in world space using the BBMOD debug vertex format.
///
/// @param {Struct.BBMOD_Vec3} _from The line start position.
/// @param {Struct.BBMOD_Vec3} _to The line end position.
/// @param {Color} [_color] The line color. Defaults to `c_white`.
/// @param {Real} [_alpha] The line alpha. Defaults to `1.0`.
function bbmod_editor_draw_line(_from, _to, _color = c_white, _alpha = 1.0)
{
	var _vbuffer = global.__bbmodVBufferDebug;
	vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);
	vertex_position_3d(_vbuffer, _from.X, _from.Y, _from.Z);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_position_3d(_vbuffer, _to.X, _to.Y, _to.Z);
	vertex_color(_vbuffer, _color, _alpha);
	vertex_end(_vbuffer);
	vertex_submit(_vbuffer, pr_linelist, -1);
}

/// @func bbmod_editor_draw_sphere(_center, _radius, [_color, _alpha])
///
/// @desc Draws a three-axis wireframe sphere approximation in world space.
///
/// @param {Struct.BBMOD_Vec3} _center The sphere center.
/// @param {Real} _radius The sphere radius.
/// @param {Color} [_color] The sphere color. Defaults to `c_white`.
/// @param {Real} [_alpha] The sphere alpha. Defaults to `1.0`.
function bbmod_editor_draw_sphere(_center, _radius, _color = c_white, _alpha = 1.0)
{
	var _vbuffer = global.__bbmodVBufferDebug;
	var _steps = 24;
	var _increment = 360.0 / _steps;
	var _angle = 0.0;
	vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);
	repeat(_steps)
	{
		var _nextAngle = _angle + _increment;
		var _x1 = lengthdir_x(_radius, _angle);
		var _y1 = lengthdir_y(_radius, _angle);
		var _x2 = lengthdir_x(_radius, _nextAngle);
		var _y2 = lengthdir_y(_radius, _nextAngle);
		vertex_position_3d(_vbuffer, _center.X, _center.Y + _x1, _center.Z + _y1);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _center.X, _center.Y + _x2, _center.Z + _y2);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _center.X + _x1, _center.Y, _center.Z + _y1);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _center.X + _x2, _center.Y, _center.Z + _y2);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _center.X + _x1, _center.Y + _y1, _center.Z);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _center.X + _x2, _center.Y + _y2, _center.Z);
		vertex_color(_vbuffer, _color, _alpha);
		_angle = _nextAngle;
	}
	vertex_end(_vbuffer);
	vertex_submit(_vbuffer, pr_linelist, -1);
}

/// @func bbmod_editor_draw_aabb(_center, _halfSize, [_color, _alpha])
///
/// @desc Draws a wireframe axis-aligned bounding box in world space.
///
/// @param {Struct.BBMOD_Vec3} _center The box center.
/// @param {Struct.BBMOD_Vec3} _halfSize The positive half extents.
/// @param {Color} [_color] The box color. Defaults to `c_white`.
/// @param {Real} [_alpha] The box alpha. Defaults to `1.0`.
function bbmod_editor_draw_aabb(_center, _halfSize, _color = c_white, _alpha = 1.0)
{
	var _min = _center.Sub(_halfSize);
	var _max = _center.Add(_halfSize);
	var _corners = [
		new BBMOD_Vec3(_min.X, _min.Y, _min.Z),
		new BBMOD_Vec3(_max.X, _min.Y, _min.Z),
		new BBMOD_Vec3(_max.X, _max.Y, _min.Z),
		new BBMOD_Vec3(_min.X, _max.Y, _min.Z),
		new BBMOD_Vec3(_min.X, _min.Y, _max.Z),
		new BBMOD_Vec3(_max.X, _min.Y, _max.Z),
		new BBMOD_Vec3(_max.X, _max.Y, _max.Z),
		new BBMOD_Vec3(_min.X, _max.Y, _max.Z),
	];
	var _edges = [0, 1, 1, 2, 2, 3, 3, 0, 4, 5, 5, 6, 6, 7, 7, 4, 0, 4, 1, 5, 2, 6, 3, 7];
	var _vbuffer = global.__bbmodVBufferDebug;
	vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);
	for (var i = 0; i < array_length(_edges); i += 2)
	{
		var _from = _corners[_edges[i]];
		var _to = _corners[_edges[i + 1]];
		vertex_position_3d(_vbuffer, _from.X, _from.Y, _from.Z);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _to.X, _to.Y, _to.Z);
		vertex_color(_vbuffer, _color, _alpha);
	}
	vertex_end(_vbuffer);
	vertex_submit(_vbuffer, pr_linelist, -1);
}

/// @func bbmod_editor_draw_arrow(_position, _direction, _length, [_color, _alpha])
///
/// @desc Draws a direction arrow with a line shaft and two head lines.
///
/// @param {Struct.BBMOD_Vec3} _position The arrow base position.
/// @param {Struct.BBMOD_Vec3} _direction The arrow direction.
/// @param {Real} _length The arrow length.
/// @param {Color} [_color] The arrow color. Defaults to `c_white`.
/// @param {Real} [_alpha] The arrow alpha. Defaults to `1.0`.
function bbmod_editor_draw_arrow(_position, _direction, _length, _color = c_white, _alpha = 1.0)
{
	var _forward = _direction.Normalize();
	var _tip = _position.Add(_forward.Scale(_length));
	bbmod_editor_draw_line(_position, _tip, _color, _alpha);
	var _side = _forward.Cross(BBMOD_VEC3_UP);
	if (_side.LengthSqr() <= math_get_epsilon()) _side = _forward.Cross(BBMOD_VEC3_RIGHT);
	_side = _side.Normalize().Scale(_length * 0.15);
	var _back = _tip.Sub(_forward.Scale(_length * 0.25));
	bbmod_editor_draw_line(_tip, _back.Add(_side), _color, _alpha);
	bbmod_editor_draw_line(_tip, _back.Sub(_side), _color, _alpha);
}

/// @func bbmod_editor_draw_cone(_position, _direction, _length, _angle[, _color, _alpha])
///
/// @desc Draws a wireframe cone aligned with the supplied direction.
///
/// @param {Struct.BBMOD_Vec3} _position The cone apex position.
/// @param {Struct.BBMOD_Vec3} _direction The cone axis direction.
/// @param {Real} _length The cone length. Non-positive lengths are ignored.
/// @param {Real} _angle The cone half-angle in degrees.
/// @param {Color} [_color] The cone color. Defaults to `c_white`.
/// @param {Real} [_alpha] The cone alpha. Defaults to `1.0`.
function bbmod_editor_draw_cone(_position, _direction, _length, _angle, _color = c_white, _alpha = 1.0)
{
	if (_length <= 0.0) return;
	var _forward = _direction.Normalize();
	var _right = _forward.Cross(BBMOD_VEC3_UP);
	if (_right.LengthSqr() <= math_get_epsilon()) _right = _forward.Cross(BBMOD_VEC3_RIGHT);
	_right = _right.Normalize();
	var _up = _right.Cross(_forward).Normalize();
	var _center = _position.Add(_forward.Scale(_length));
	var _radius = tan(degtorad(_angle)) * _length;
	var _steps = 24;
	var _increment = 360.0 / _steps;
	var _angleCurrent = 0.0;
	var _previous = _center.Add(_right.Scale(_radius));
	var _vbuffer = global.__bbmodVBufferDebug;
	vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);
	repeat(_steps)
	{
		var _nextAngle = _angleCurrent + _increment;
		var _next = _center.Add(_right.Scale(dcos(_nextAngle) * _radius))
			.Add(_up.Scale(dsin(_nextAngle) * _radius));
		vertex_position_3d(_vbuffer, _previous.X, _previous.Y, _previous.Z);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _next.X, _next.Y, _next.Z);
		vertex_color(_vbuffer, _color, _alpha);
		if ((_angleCurrent mod 90.0) == 0.0)
		{
			vertex_position_3d(_vbuffer, _position.X, _position.Y, _position.Z);
			vertex_color(_vbuffer, _color, _alpha);
			vertex_position_3d(_vbuffer, _previous.X, _previous.Y, _previous.Z);
			vertex_color(_vbuffer, _color, _alpha);
		}
		_previous = _next;
		_angleCurrent = _nextAngle;
	}
	vertex_end(_vbuffer);
	vertex_submit(_vbuffer, pr_linelist, -1);
}

////////////////////////////////////////////////////////////////////////////////
// DEPRECATED!!!

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @deprecated Please use {@link BBMOD_SHADER_INSTANCE_ID} instead.
#macro BBMOD_SHADER_INSTANCE_ID_ANIMATED BBMOD_SHADER_INSTANCE_ID

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @deprecated Please use {@link BBMOD_SHADER_INSTANCE_ID} instead.
#macro BBMOD_SHADER_INSTANCE_ID_BATCHED BBMOD_SHADER_INSTANCE_ID

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs
/// for lightmapped models.
/// @deprecated Please use {@link BBMOD_SHADER_INSTANCE_ID} instead.
#macro BBMOD_SHADER_LIGHTMAP_INSTANCE_ID BBMOD_SHADER_INSTANCE_ID

bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID", BBMOD_SHADER_INSTANCE_ID);
bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID_ANIMATED", BBMOD_SHADER_INSTANCE_ID_ANIMATED);
bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID_BATCHED", BBMOD_SHADER_INSTANCE_ID_BATCHED);
bbmod_shader_register("BBMOD_SHADER_LIGHTMAP_INSTANCE_ID", BBMOD_SHADER_LIGHTMAP_INSTANCE_ID);
