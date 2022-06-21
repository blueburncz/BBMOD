/// @func BBMOD_SphereCollider([_position[, _radius]])
///
/// @extends BBMOD_Collider
///
/// @desc A sphere collider.
///
/// @param {Struct.BBMOD_Vec3} [_position] The position of the sphere Defaults
/// to `(0, 0, 0)`.
///
/// @param {Real} [_radius] The radius of the sphere. Defaults to 1.
///
/// @see BBMOD_AABBCollider
/// @see BBMOD_PlaneCollider
function BBMOD_SphereCollider(_position=new BBMOD_Vec3(), _radius=1.0)
	: BBMOD_Collider() constructor
{
	/// @var {Struct.BBMOD_Vec3} The position of the sphere.
	Position = _position;

	/// @var {Real} The radius of the sphere.
	Radius = _radius;

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L142
	static GetClosestPoint = function (_point) {
		gml_pragma("forceinline");
		var _sphereToPoint = _point.Sub(Position).Normalize()
			.Scale(Radius);
		return Position.Add(_sphereToPoint);
	};

	static _TestImpl = function (_collider) {
		gml_pragma("forceinline");
		var _closestPoint = _collider.GetClosestPoint(Position);
		return (Position.Sub(_closestPoint).Length() < Radius);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L319
	static TestAABB = _TestImpl;

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L333
	static TestPlane = _TestImpl;

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L97
	static TestPoint = function (_point) {
		gml_pragma("forceinline");
		return (_point.Sub(Position).Length() < Radius);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L313
	static TestSphere = function (_sphere) {
		gml_pragma("forceinline");
		return (Position.Sub(_sphere.Position).Length() < Radius + _sphere.Radius);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L552
	static Raycast = function (_ray, _result=undefined) {
		if (_result != undefined)
		{
			_result.Reset();
		}

		var _e = Position.Sub(_ray.Origin);
		var _rSq = Radius * Radius;

		var _eSq = _e.LengthSqr();
		var _a = _e.Dot(_ray.Direction); // _ray.Direction should be normalized!
		var _bSq = _eSq - (_a * _a);
		var _f = sqrt(abs((_rSq) - _bSq));

		if (_rSq - _bSq < 0.0)
		{
			return false;
		}

		var _t = _a - _f;

		if (_eSq < _rSq)
		{
			_t = _a + _f;
		}

		if (_result != undefined)
		{
			_result.Distance = _t;
			_result.Point = _ray.Origin.Add(_ray.Direction.Scale(_t));
			_result.Normal = _result.Point.Sub(Position).Normalize();
		}

		return true;
	};
}
