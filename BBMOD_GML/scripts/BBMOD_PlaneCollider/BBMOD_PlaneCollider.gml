/// @module Extras.Raycasting

/// @func BBMOD_PlaneCollider([_normal[, _distance]])
///
/// @extends BBMOD_Collider
///
/// @desc A plane collider.
///
/// @param {Struct.BBMOD_Vec3} [_normal] The plane's normal vector. Defaults to
/// {@link BBMOD_VEC3_UP}.
/// @param {Real} [_distance] The plane's distance from the world origin.
///
/// @see BBMOD_AABBCollider
/// @see BBMOD_FrustumCollider
/// @see BBMOD_SphereCollider
function BBMOD_PlaneCollider(_normal = undefined, _distance = 0.0): BBMOD_Collider() constructor
{
	/// @var {Struct.BBMOD_Vec3} The plane's normal vector.
	Normal = _normal ?? BBMOD_VEC3_UP;

	/// @var {Real} The plane's distance from the world origin.
	Distance = _distance;

	/// @func __getPointDistance(_point)
	///
	/// @param {Struct.BBMOD_Vec3} _point
	///
	/// @return {Real}
	///
	/// @private
	static __getPointDistance = function (_point)
	{
		gml_pragma("forceinline");
		// return (_point.Dot(Normal) - Distance);
		return (_point.X * Normal.X + _point.Y * Normal.Y + _point.Z * Normal.Z - Distance);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L188
	static GetClosestPoint = function (_point)
	{
		gml_pragma("forceinline");
		// return _point.Sub(Normal.Scale(__getPointDistance(_point)));
		var _dist = __getPointDistance(_point);
		return new BBMOD_Vec3(
			_point.X - Normal.X * _dist,
			_point.Y - Normal.Y * _dist,
			_point.Z - Normal.Z * _dist
		);
	};

	static TestAABB = function (_aabb)
	{
		gml_pragma("forceinline");
		return _aabb.TestPlane(self);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L541
	static TestPlane = function (_plane)
	{
		gml_pragma("forceinline");
		// var _d = Normal.Cross(_plane.Normal);
		// return !bbmod_cmp(_d.Dot(_d), 0.0);
		var _dX = Normal.Y * _plane.Normal.Z - Normal.Z * _plane.Normal.Y;
		var _dY = Normal.Z * _plane.Normal.X - Normal.X * _plane.Normal.Z;
		var _dZ = Normal.X * _plane.Normal.Y - Normal.Y * _plane.Normal.X;
		var _dotSelf = _dX * _dX + _dY * _dY + _dZ * _dZ;
		return !bbmod_cmp(_dotSelf, 0.0);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L101
	static TestPoint = function (_point)
	{
		gml_pragma("forceinline");
		return bbmod_cmp(__getPointDistance(_point), 0.0);
	};

	static TestSphere = function (_sphere)
	{
		gml_pragma("forceinline");
		return _sphere.TestPlane(self);
	};

	static TestCapsule = function (_capsule)
	{
		gml_pragma("forceinline");
		return _capsule.TestPlane(self);
	};

	static TestTriangle = function (_triangle)
	{
		gml_pragma("forceinline");
		return _triangle.TestPlane(self);
	};

	static TestOBB = function (_obb)
	{
		gml_pragma("forceinline");
		return _obb.TestPlane(self);
	};

	static TestLineSegment = function (_segment)
	{
		gml_pragma("forceinline");
		return _segment.TestPlane(self);
	};

	static TestCylinder = function (_cylinder)
	{
		gml_pragma("forceinline");
		return _cylinder.TestPlane(self);
	};

	static TestEllipsoid = function (_ellipsoid)
	{
		gml_pragma("forceinline");
		return _ellipsoid.TestPlane(self);
	};

	static TestCone = function (_cone)
	{
		gml_pragma("forceinline");
		return _cone.TestPlane(self);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L769
	static Raycast = function (_ray, _result = undefined)
	{
		if (_result != undefined)
		{
			_result.Reset();
		}

		// var _nd = _ray.Direction.Dot(Normal);
		var _nd = _ray.Direction.X * Normal.X + _ray.Direction.Y * Normal.Y + _ray.Direction.Z * Normal.Z;
		// var _pn = _ray.Origin.Dot(Normal);
		var _pn = _ray.Origin.X * Normal.X + _ray.Origin.Y * Normal.Y + _ray.Origin.Z * Normal.Z;

		if (_nd >= 0.0)
		{
			return false;
		}

		var _t = (Distance - _pn) / _nd;

		if (_t >= 0.0)
		{
			if (_result != undefined)
			{
				_result.Distance = _t;
				// _result.Point = _ray.Origin.Add(_ray.Direction.Scale(_t));
				_result.Point = new BBMOD_Vec3(
					_ray.Origin.X + _ray.Direction.X * _t,
					_ray.Origin.Y + _ray.Direction.Y * _t,
					_ray.Origin.Z + _ray.Direction.Z * _t
				);
				// _result.Normal = Normal.Normalize();
				var _nX = Normal.X;
				var _nY = Normal.Y;
				var _nZ = Normal.Z;
				var _nLen = point_distance_3d(0, 0, 0, _nX, _nY, _nZ);
				var _nNorm = (_nLen != 0.0) ? (1.0 / _nLen) : 0.0;
				_result.Normal = new BBMOD_Vec3(_nX * _nNorm, _nY * _nNorm, _nZ * _nNorm);
			}
			return true;
		}

		return false;
	};
}
