/// @module Extras.Raycasting

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
/// @see BBMOD_FrustumCollider
/// @see BBMOD_PlaneCollider
function BBMOD_SphereCollider(_position = new BBMOD_Vec3(), _radius = 1.0): BBMOD_Collider() constructor
{
	/// @var {Struct.BBMOD_Vec3} The position of the sphere.
	Position = _position;

	/// @var {Real} The radius of the sphere.
	Radius = _radius;

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L142
	static GetClosestPoint = function (_point)
	{
		gml_pragma("forceinline");
		// var _sphereToPoint = _point.Sub(Position).Normalize().Scale(Radius);
		// return Position.Add(_sphereToPoint);
		var _dx = _point.X - Position.X;
		var _dy = _point.Y - Position.Y;
		var _dz = _point.Z - Position.Z;
		var _len = point_distance_3d(0, 0, 0, _dx, _dy, _dz);
		var _norm = (_len != 0.0) ? (Radius / _len) : 0.0;
		return new BBMOD_Vec3(
			Position.X + _dx * _norm,
			Position.Y + _dy * _norm,
			Position.Z + _dz * _norm
		);
	};

	static __testImpl = function (_collider)
	{
		gml_pragma("forceinline");
		var _closestPoint = _collider.GetClosestPoint(Position);
		// return (Position.Sub(_closestPoint).Length() < Radius);
		var _dx = Position.X - _closestPoint.X;
		var _dy = Position.Y - _closestPoint.Y;
		var _dz = Position.Z - _closestPoint.Z;
		return (point_distance_3d(0, 0, 0, _dx, _dy, _dz) < Radius);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L319
	static TestAABB = __testImpl;

	static TestFrustum = function (_frustum)
	{
		gml_pragma("forceinline");
		return _frustum.TestSphere(self);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L333
	static TestPlane = __testImpl;

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L97
	static TestPoint = function (_point)
	{
		gml_pragma("forceinline");
		// return (_point.Sub(Position).Length() < Radius);
		var _dx = _point.X - Position.X;
		var _dy = _point.Y - Position.Y;
		var _dz = _point.Z - Position.Z;
		return (point_distance_3d(0, 0, 0, _dx, _dy, _dz) < Radius);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L313
	static TestSphere = function (_sphere)
	{
		gml_pragma("forceinline");
		// return (Position.Sub(_sphere.Position).Length() < Radius + _sphere.Radius);
		var _dx = Position.X - _sphere.Position.X;
		var _dy = Position.Y - _sphere.Position.Y;
		var _dz = Position.Z - _sphere.Position.Z;
		return (point_distance_3d(0, 0, 0, _dx, _dy, _dz) < Radius + _sphere.Radius);
	};

	static TestCapsule = function (_capsule)
	{
		gml_pragma("forceinline");
		return _capsule.TestSphere(self);
	};

	static TestTriangle = function (_triangle)
	{
		gml_pragma("forceinline");
		return _triangle.TestSphere(self);
	};

	static TestOBB = function (_obb)
	{
		gml_pragma("forceinline");
		return _obb.TestSphere(self);
	};

	static TestLineSegment = function (_segment)
	{
		gml_pragma("forceinline");
		return _segment.TestSphere(self);
	};

	static TestCylinder = function (_cylinder)
	{
		gml_pragma("forceinline");
		return _cylinder.TestSphere(self);
	};

	static TestEllipsoid = function (_ellipsoid)
	{
		gml_pragma("forceinline");
		return _ellipsoid.TestSphere(self);
	};

	static TestCone = function (_cone)
	{
		gml_pragma("forceinline");
		return _cone.TestSphere(self);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L552
	static Raycast = function (_ray, _result = undefined)
	{
		if (_result != undefined)
		{
			_result.Reset();
		}

		// var _e = Position.Sub(_ray.Origin);
		var _eX = Position.X - _ray.Origin.X;
		var _eY = Position.Y - _ray.Origin.Y;
		var _eZ = Position.Z - _ray.Origin.Z;
		var _rSq = Radius * Radius;

		// var _eSq = _e.LengthSqr();
		var _eSq = _eX * _eX + _eY * _eY + _eZ * _eZ;
		// var _a = _e.Dot(_ray.Direction); // _ray.Direction should be normalized!
		var _a = _eX * _ray.Direction.X + _eY * _ray.Direction.Y + _eZ * _ray.Direction.Z;
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
			// _result.Point = _ray.Origin.Add(_ray.Direction.Scale(_t));
			var _pX = _ray.Origin.X + _ray.Direction.X * _t;
			var _pY = _ray.Origin.Y + _ray.Direction.Y * _t;
			var _pZ = _ray.Origin.Z + _ray.Direction.Z * _t;
			_result.Point = new BBMOD_Vec3(_pX, _pY, _pZ);
			// _result.Normal = _result.Point.Sub(Position).Normalize();
			var _nX = _pX - Position.X;
			var _nY = _pY - Position.Y;
			var _nZ = _pZ - Position.Z;
			var _nLen = point_distance_3d(0, 0, 0, _nX, _nY, _nZ);
			var _nNorm = (_nLen != 0.0) ? (1.0 / _nLen) : 0.0;
			_result.Normal = new BBMOD_Vec3(_nX * _nNorm, _nY * _nNorm, _nZ * _nNorm);
		}

		return true;
	};

	static DrawDebug = function (_color = c_white, _alpha = 1.0)
	{
		var _vbuffer = global.__bbmodVBufferDebug;

		vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

		var _x = Position.X;
		var _y = Position.Y;
		var _z = Position.Z;
		var _radius = Radius;
		var _steps = 16;
		var _inc = 360.0 / _steps;
		var _angle = 0.0;
		var _ldirx1 = lengthdir_x(_radius, _angle);
		var _ldiry1 = lengthdir_y(_radius, _angle);

		repeat(_steps)
		{
			var _ldirx2 = lengthdir_x(_radius, _angle + _inc);
			var _ldiry2 = lengthdir_y(_radius, _angle + _inc);

			// Circle around X axis
			vertex_position_3d(_vbuffer, _x, _y + _ldirx1, _z + _ldiry1);
			vertex_color(_vbuffer, _color, _alpha);

			vertex_position_3d(_vbuffer, _x, _y + _ldirx2, _z + _ldiry2);
			vertex_color(_vbuffer, _color, _alpha);

			// Circle around Y axis
			vertex_position_3d(_vbuffer, _x + _ldirx1, _y, _z + _ldiry1);
			vertex_color(_vbuffer, _color, _alpha);

			vertex_position_3d(_vbuffer, _x + _ldirx2, _y, _z + _ldiry2);
			vertex_color(_vbuffer, _color, _alpha);

			// Circle around Z axis
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

		return self;
	};
}
