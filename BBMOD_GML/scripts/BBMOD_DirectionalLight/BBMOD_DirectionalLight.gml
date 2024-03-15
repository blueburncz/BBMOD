/// @module Core

/// @var {Struct.BBMOD_DirectionalLight}
/// @private
global.__bbmodDirectionalLight = undefined;

/// @func BBMOD_DirectionalLight([_color[, _direction]])
///
/// @extends BBMOD_Light
///
/// @desc A directional light.
///
/// @param {Struct.BBMOD_Color} [_color] The light's color. Defaults to
/// {@link BBMOD_C_WHITE} if `undefined`.
/// @param {Struct.BBMOD_Vec3} [_direction] The light's direction. Defaults to
/// `(-1, 0, -1)` if `undefined`.
function BBMOD_DirectionalLight(_color=undefined, _direction=undefined)
	: BBMOD_Light() constructor
{
	/// @var {Struct.BBMOD_Color} The color of the light. Defaul value is
	/// {@link BBMOD_C_WHITE}.
	Color = _color ?? BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Vec3} The direction of the light. Default value is
	/// `(-1, 0, -1)`.
	Direction = _direction ?? new BBMOD_Vec3(-1.0, 0.0, -1.0).Normalize();

	/// @var {Real} The area captured by the shadowmap. Defaults to 1024.
	ShadowmapArea = 1024;

	/// @var {Real} If `true` then the shadowmap is captured from the camera's
	/// position instead of from the directional light's position. Default
	/// value is `true` for backwards compatibility.
	ShadowmapFollowsCamera = true;

	__getZFar = __get_shadowmap_zfar;

	__getViewMatrix = __get_shadowmap_view;

	__getProjMatrix = __get_shadowmap_projection;

	__getShadowmapMatrix = __get_shadowmap_matrix;

	__shadowmapMatrixPrev = new BBMOD_Matrix();

	static __get_shadowmap_zfar = function ()
	{
		gml_pragma("forceinline");
		return ShadowmapArea;
	};

	static __get_shadowmap_view = function ()
	{
		gml_pragma("forceinline");

		var _position = ShadowmapFollowsCamera
			? bbmod_camera_get_position()
			: Position;

		// Source: https://www.junkship.net/News/2020/11/22/shadow-of-a-doubt-part-2
		var _texelScale = 2.0 / ShadowmapResolution;
		var _invTexelScale = 1.0 / _texelScale;
		var _projectedCenter = new BBMOD_Vec4(_position.X, _position.Y, _position.Z, 1.0)
			.TransformSelf(__shadowmapMatrixPrev);
		var _w = _projectedCenter.W;
		var _x = floor((_projectedCenter.X / _w) * _invTexelScale) * _texelScale;
		var _y = floor((_projectedCenter.Y / _w) * _invTexelScale) * _texelScale;
		var _z = _projectedCenter.Z / _w;
		var _correctedCenter = new BBMOD_Vec4(_x, _y, _z, 1.0)
			.TransformSelf(__shadowmapMatrixPrev.Inverse());
		var _center = _correctedCenter.Scale(1.0 / _correctedCenter.W);

		return matrix_build_lookat(
			_center.X,
			_center.Y,
			_center.Z,
			_center.X + Direction.X,
			_center.Y + Direction.Y,
			_center.Z + Direction.Z,
			0.0, 0.0, 1.0); // TODO: Find the up vector
	};

	static __get_shadowmap_projection = function ()
	{
		gml_pragma("forceinline");
		return matrix_build_projection_ortho(
			ShadowmapArea, ShadowmapArea, -ShadowmapArea * 0.5, ShadowmapArea * 0.5);
	};

	static __get_shadowmap_matrix = function ()
	{
		gml_pragma("forceinline");
		var _matrix = matrix_multiply(
			__getViewMatrix(),
			__getProjMatrix());
		__shadowmapMatrixPrev = new BBMOD_Matrix(_matrix);
		return _matrix;
	};
}

/// @func bbmod_light_directional_get()
///
/// @desc Retrieves the directional light passed to shaders.
///
/// @return {Struct.BBMOD_DirectionalLight} The directional light or `undefined`.
///
/// @see bbmod_light_directional_set
/// @see BBMOD_DirectionalLight
function bbmod_light_directional_get()
{
	gml_pragma("forceinline");
	return global.__bbmodDirectionalLight;
}

/// @func bbmod_light_directional_set(_light)
///
/// @desc Defines the directional light passed to shaders.
///
/// @param {Struct.BBMOD_DirectionalLight} _light The new directional light or
/// `undefined`.
///
/// @see bbmod_light_directional_get
/// @see BBMOD_DirectionalLight
function bbmod_light_directional_set(_light)
{
	gml_pragma("forceinline");
	global.__bbmodDirectionalLight = _light;
}
