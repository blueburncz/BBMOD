/// @module Extras.Raycasting

/// @func BBMOD_ConeCollider([_tip[, _base[, _radius]]])
///
/// @extends BBMOD_Collider
///
/// @desc A cone collider with a pointed tip and circular base.
///
/// @param {Struct.BBMOD_Vec3} [_tip] The tip (apex) of the cone.
/// Defaults to `(0, 0, 0)`.
/// @param {Struct.BBMOD_Vec3} [_base] The center of the circular base.
/// Defaults to `(0, 0, 1)`.
/// @param {Real} [_radius] The radius of the circular base.
/// Defaults to 1.
///
/// @see BBMOD_CylinderCollider
/// @see BBMOD_SphereCollider
function BBMOD_ConeCollider(_tip = new BBMOD_Vec3(0, 0, 0), _base = new BBMOD_Vec3(0, 0, 1), _radius = 1.0):
BBMOD_Collider() constructor
{
	/// @var {Struct.BBMOD_Vec3} The tip (apex) of the cone.
	Tip = _tip;

	/// @var {Struct.BBMOD_Vec3} The center of the circular base.
	Base = _base;

	/// @var {Real} The radius of the circular base.
	Radius = _radius;

	/// @func GetClosestPoint(_point)
	///
	/// @desc Finds the closest point on the cone surface to the given point.
	///
	/// @param {Struct.BBMOD_Vec3} _point The point to test.
	///
	/// @return {Struct.BBMOD_Vec3} The closest point on the cone surface.
	static GetClosestPoint = function (_point)
	{
		gml_pragma("forceinline");

		// Cone axis from tip to base
		var _axisX = Base.X - Tip.X;
		var _axisY = Base.Y - Tip.Y;
		var _axisZ = Base.Z - Tip.Z;
		var _height = point_distance_3d(0, 0, 0, _axisX, _axisY, _axisZ);

		if (_height == 0.0)
		{
			// Degenerate cone (tip and base at same point)
			return Tip.Clone();
		}

		// Normalized axis
		var _axisNormX = _axisX / _height;
		var _axisNormY = _axisY / _height;
		var _axisNormZ = _axisZ / _height;

		// Vector from tip to point
		var _tipToPointX = _point.X - Tip.X;
		var _tipToPointY = _point.Y - Tip.Y;
		var _tipToPointZ = _point.Z - Tip.Z;

		// Project onto axis
		var _t = _tipToPointX * _axisNormX + _tipToPointY * _axisNormY + _tipToPointZ * _axisNormZ;

		// Clamp to cone range [0, height]
		if (_t <= 0.0)
		{
			// Closest to tip
			return Tip.Clone();
		}
		else if (_t >= _height)
		{
			// Closest to base disc
			// Project point onto base plane
			var _baseToPointX = _point.X - Base.X;
			var _baseToPointY = _point.Y - Base.Y;
			var _baseToPointZ = _point.Z - Base.Z;

			// Remove component along axis
			var _proj = _baseToPointX * _axisNormX + _baseToPointY * _axisNormY + _baseToPointZ * _axisNormZ;
			var _radialX = _baseToPointX - _axisNormX * _proj;
			var _radialY = _baseToPointY - _axisNormY * _proj;
			var _radialZ = _baseToPointZ - _axisNormZ * _proj;

			var _radialLen = point_distance_3d(0, 0, 0, _radialX, _radialY, _radialZ);

			if (_radialLen <= Radius)
			{
				// Inside base disc
				return new BBMOD_Vec3(_point.X, _point.Y, _point.Z);
			}
			else
			{
				// On base circle edge
				var _norm = Radius / _radialLen;
				return new BBMOD_Vec3(
					Base.X + _radialX * _norm,
					Base.Y + _radialY * _norm,
					Base.Z + _radialZ * _norm
				);
			}
		}
		else
		{
			// Between tip and base - check cone surface
			// Radius at this height
			var _radiusAtT = Radius * (_t / _height);

			// Point on axis at this height
			var _axisPointX = Tip.X + _axisNormX * _t;
			var _axisPointY = Tip.Y + _axisNormY * _t;
			var _axisPointZ = Tip.Z + _axisNormZ * _t;

			// Radial vector from axis point to input point
			var _radialX = _point.X - _axisPointX;
			var _radialY = _point.Y - _axisPointY;
			var _radialZ = _point.Z - _axisPointZ;

			var _radialLen = point_distance_3d(0, 0, 0, _radialX, _radialY, _radialZ);

			if (_radialLen <= _radiusAtT)
			{
				// Inside cone
				return new BBMOD_Vec3(_point.X, _point.Y, _point.Z);
			}
			else
			{
				// On cone surface
				var _norm = (_radialLen != 0.0) ? (_radiusAtT / _radialLen) : 0.0;
				return new BBMOD_Vec3(
					_axisPointX + _radialX * _norm,
					_axisPointY + _radialY * _norm,
					_axisPointZ + _radialZ * _norm
				);
			}
		}
	};

	/// @func TestPoint(_point)
	///
	/// @desc Tests if a point is inside the cone.
	///
	/// @param {Struct.BBMOD_Vec3} _point The point to test.
	///
	/// @return {Bool} Returns `true` if the point is inside the cone.
	static TestPoint = function (_point)
	{
		gml_pragma("forceinline");

		// Cone axis from tip to base
		var _axisX = Base.X - Tip.X;
		var _axisY = Base.Y - Tip.Y;
		var _axisZ = Base.Z - Tip.Z;
		var _height = point_distance_3d(0, 0, 0, _axisX, _axisY, _axisZ);

		if (_height == 0.0)
		{
			return false;
		}

		// Normalized axis
		var _axisNormX = _axisX / _height;
		var _axisNormY = _axisY / _height;
		var _axisNormZ = _axisZ / _height;

		// Vector from tip to point
		var _tipToPointX = _point.X - Tip.X;
		var _tipToPointY = _point.Y - Tip.Y;
		var _tipToPointZ = _point.Z - Tip.Z;

		// Project onto axis
		var _t = _tipToPointX * _axisNormX + _tipToPointY * _axisNormY + _tipToPointZ * _axisNormZ;

		// Check if within cone height
		if (_t < 0.0 || _t > _height)
		{
			return false;
		}

		// Radius at this height
		var _radiusAtT = Radius * (_t / _height);

		// Point on axis at this height
		var _axisPointX = Tip.X + _axisNormX * _t;
		var _axisPointY = Tip.Y + _axisNormY * _t;
		var _axisPointZ = Tip.Z + _axisNormZ * _t;

		// Distance from axis
		var _distFromAxis = point_distance_3d(_point.X, _point.Y, _point.Z, _axisPointX, _axisPointY,
			_axisPointZ);

		return (_distFromAxis <= _radiusAtT);
	};

	/// @func TestSphere(_sphere)
	///
	/// @desc Tests if a sphere intersects the cone.
	///
	/// @param {Struct.BBMOD_SphereCollider} _sphere The sphere to test against.
	///
	/// @return {Bool} Returns `true` if the sphere intersects the cone.
	static TestSphere = function (_sphere)
	{
		gml_pragma("forceinline");
		var _closestPoint = GetClosestPoint(_sphere.Position);
		var _dx = _sphere.Position.X - _closestPoint.X;
		var _dy = _sphere.Position.Y - _closestPoint.Y;
		var _dz = _sphere.Position.Z - _closestPoint.Z;
		return (point_distance_3d(0, 0, 0, _dx, _dy, _dz) <= _sphere.Radius);
	};

	/// @func TestAABB(_aabb)
	///
	/// @desc Tests if an AABB intersects the cone.
	///
	/// @param {Struct.BBMOD_AABBCollider} _aabb The AABB to test against.
	///
	/// @return {Bool} Returns `true` if the AABB intersects the cone.
	static TestAABB = function (_aabb)
	{
		gml_pragma("forceinline");
		var _closestPoint = _aabb.GetClosestPoint(Tip);
		var _testPoint = GetClosestPoint(_closestPoint);
		var _dx = _closestPoint.X - _testPoint.X;
		var _dy = _closestPoint.Y - _testPoint.Y;
		var _dz = _closestPoint.Z - _testPoint.Z;
		return (point_distance_3d(0, 0, 0, _dx, _dy, _dz) < 0.001);
	};

	/// @func TestPlane(_plane)
	///
	/// @desc Tests if a plane intersects the cone.
	///
	/// @param {Struct.BBMOD_PlaneCollider} _plane The plane to test against.
	///
	/// @return {Bool} Returns `true` if the plane intersects the cone.
	static TestPlane = function (_plane)
	{
		gml_pragma("forceinline");
		// Test tip and base center
		var _tipDist = _plane.Normal.X * Tip.X + _plane.Normal.Y * Tip.Y + _plane.Normal.Z * Tip.Z - _plane
			.Distance;
		var _baseDist = _plane.Normal.X * Base.X + _plane.Normal.Y * Base.Y + _plane.Normal.Z * Base.Z - _plane
			.Distance;

		// If tip and base on opposite sides, plane intersects
		if (_tipDist * _baseDist < 0.0)
		{
			return true;
		}

		// Also test if base circle intersects plane
		// Simplified: if base center is within radius of plane
		return (abs(_baseDist) <= Radius);
	};

	/// @func TestFrustum(_frustum)
	///
	/// @desc Tests if a frustum contains or intersects the cone.
	///
	/// @param {Struct.BBMOD_FrustumCollider} _frustum The frustum to test against.
	///
	/// @return {Bool} Returns `true` if the frustum contains or intersects the cone.
	static TestFrustum = function (_frustum)
	{
		gml_pragma("forceinline");
		// Test tip and base against frustum
		if (!_frustum.TestPoint(Tip) && !_frustum.TestPoint(Base))
		{
			// Both outside, check if cone intersects frustum
			// Simplified: test base sphere
			var _baseSphere = new BBMOD_SphereCollider(Base, Radius);
			return _frustum.TestSphere(_baseSphere);
		}
		return true;
	};

	/// @func TestCapsule(_capsule)
	///
	/// @desc Tests if a capsule intersects the cone.
	///
	/// @param {Struct.BBMOD_CapsuleCollider} _capsule The capsule to test against.
	///
	/// @return {Bool} Returns `true` if the capsule intersects the cone.
	static TestCapsule = function (_capsule)
	{
		gml_pragma("forceinline");
		// Simplified: test capsule axis line segment against cone, then add radius
		var _closestOnCone = GetClosestPoint(_capsule.PointA);
		var _dist1 = point_distance_3d(_capsule.PointA.X, _capsule.PointA.Y, _capsule.PointA.Z, _closestOnCone
			.X, _closestOnCone.Y, _closestOnCone.Z);
		if (_dist1 <= _capsule.Radius)
		{
			return true;
		}

		_closestOnCone = GetClosestPoint(_capsule.PointB);
		var _dist2 = point_distance_3d(_capsule.PointB.X, _capsule.PointB.Y, _capsule.PointB.Z, _closestOnCone
			.X, _closestOnCone.Y, _closestOnCone.Z);
		return (_dist2 <= _capsule.Radius);
	};

	/// @func TestTriangle(_triangle)
	///
	/// @desc Tests if a triangle intersects the cone.
	///
	/// @param {Struct.BBMOD_TriangleCollider} _triangle The triangle to test against.
	///
	/// @return {Bool} Returns `true` if the triangle intersects the cone.
	static TestTriangle = function (_triangle)
	{
		gml_pragma("forceinline");
		// Test triangle vertices against cone
		if (TestPoint(_triangle.Point1) || TestPoint(_triangle.Point2) || TestPoint(_triangle.Point3))
		{
			return true;
		}

		// Test cone tip and base against triangle
		var _closestOnTri = _triangle.GetClosestPoint(Tip);
		if (TestPoint(_closestOnTri))
		{
			return true;
		}

		_closestOnTri = _triangle.GetClosestPoint(Base);
		return TestPoint(_closestOnTri);
	};

	/// @func TestOBB(_obb)
	///
	/// @desc Tests if an OBB intersects the cone.
	///
	/// @param {Struct.BBMOD_OBBCollider} _obb The OBB to test against.
	///
	/// @return {Bool} Returns `true` if the OBB intersects the cone.
	static TestOBB = function (_obb)
	{
		gml_pragma("forceinline");
		var _closestPoint = _obb.GetClosestPoint(Tip);
		var _testPoint = GetClosestPoint(_closestPoint);
		var _dx = _closestPoint.X - _testPoint.X;
		var _dy = _closestPoint.Y - _testPoint.Y;
		var _dz = _closestPoint.Z - _testPoint.Z;
		return (point_distance_3d(0, 0, 0, _dx, _dy, _dz) < 0.001);
	};

	/// @func TestLineSegment(_segment)
	///
	/// @desc Tests if a line segment intersects the cone.
	///
	/// @param {Struct.BBMOD_LineSegmentCollider} _segment The line segment to test against.
	///
	/// @return {Bool} Returns `true` if the line segment intersects the cone.
	static TestLineSegment = function (_segment)
	{
		gml_pragma("forceinline");
		// Test segment endpoints
		if (TestPoint(_segment.PointA) || TestPoint(_segment.PointB))
		{
			return true;
		}

		// Test closest points
		var _closestOnCone = GetClosestPoint(_segment.PointA);
		var _closestOnSeg = _segment.GetClosestPoint(_closestOnCone);
		var _dx = _closestOnCone.X - _closestOnSeg.X;
		var _dy = _closestOnCone.Y - _closestOnSeg.Y;
		var _dz = _closestOnCone.Z - _closestOnSeg.Z;
		return (point_distance_3d(0, 0, 0, _dx, _dy, _dz) < 0.001);
	};

	/// @func TestCylinder(_cylinder)
	///
	/// @desc Tests if a cylinder intersects the cone.
	///
	/// @param {Struct.BBMOD_CylinderCollider} _cylinder The cylinder to test against.
	///
	/// @return {Bool} Returns `true` if the cylinder intersects the cone.
	static TestCylinder = function (_cylinder)
	{
		gml_pragma("forceinline");
		// Simplified: test closest points between axes, then consider radii
		var _closestOnCone = GetClosestPoint(_cylinder.PointA);
		var _dist1 = point_distance_3d(_cylinder.PointA.X, _cylinder.PointA.Y, _cylinder.PointA.Z,
			_closestOnCone.X, _closestOnCone.Y, _closestOnCone.Z);
		if (_dist1 <= _cylinder.Radius)
		{
			return true;
		}

		_closestOnCone = GetClosestPoint(_cylinder.PointB);
		var _dist2 = point_distance_3d(_cylinder.PointB.X, _cylinder.PointB.Y, _cylinder.PointB.Z,
			_closestOnCone.X, _closestOnCone.Y, _closestOnCone.Z);
		return (_dist2 <= _cylinder.Radius);
	};

	/// @func TestEllipsoid(_ellipsoid)
	///
	/// @desc Tests if an ellipsoid intersects the cone.
	///
	/// @param {Struct.BBMOD_EllipsoidCollider} _ellipsoid The ellipsoid to test against.
	///
	/// @return {Bool} Returns `true` if the ellipsoid intersects the cone.
	static TestEllipsoid = function (_ellipsoid)
	{
		gml_pragma("forceinline");
		var _closestPoint = GetClosestPoint(_ellipsoid.Position);
		return _ellipsoid.TestPoint(_closestPoint);
	};

	/// @func TestCone(_cone)
	///
	/// @desc Tests if this cone intersects with another cone.
	///
	/// @param {Struct.BBMOD_ConeCollider} _cone The other cone to test against.
	///
	/// @return {Bool} Returns `true` if the cones intersect.
	static TestCone = function (_cone)
	{
		gml_pragma("forceinline");
		// Test tips and bases
		if (TestPoint(_cone.Tip) || TestPoint(_cone.Base) || _cone.TestPoint(Tip) || _cone.TestPoint(Base))
		{
			return true;
		}

		// Test closest points
		var _closestOnThis = GetClosestPoint(_cone.Tip);
		if (_cone.TestPoint(_closestOnThis))
		{
			return true;
		}

		var _closestOnOther = _cone.GetClosestPoint(Tip);
		return TestPoint(_closestOnOther);
	};

	/// @func Raycast(_ray, _result)
	///
	/// @desc Casts a ray at the cone and finds the closest intersection.
	///
	/// @param {Struct.BBMOD_Ray} _ray The ray to cast.
	/// @param {Struct.BBMOD_RaycastResult} _result The raycast result to populate.
	///
	/// @return {Bool} Returns `true` if the ray intersects the cone.
	static Raycast = function (_ray, _result = undefined)
	{
		if (_result != undefined)
		{
			_result.Reset();
		}

		// Cone axis from tip to base
		var _axisX = Base.X - Tip.X;
		var _axisY = Base.Y - Tip.Y;
		var _axisZ = Base.Z - Tip.Z;
		var _height = point_distance_3d(0, 0, 0, _axisX, _axisY, _axisZ);

		if (_height == 0.0)
		{
			return false;
		}

		// Normalized axis
		var _axisNormX = _axisX / _height;
		var _axisNormY = _axisY / _height;
		var _axisNormZ = _axisZ / _height;

		// Cone half-angle (cos)
		var _cosAngle = _height / sqrt(_height * _height + Radius * Radius);
		var _cosAngleSq = _cosAngle * _cosAngle;

		// Vector from tip to ray origin
		var _coX = _ray.Origin.X - Tip.X;
		var _coY = _ray.Origin.Y - Tip.Y;
		var _coZ = _ray.Origin.Z - Tip.Z;

		// Quadratic equation coefficients for infinite cone
		var _adotd = _ray.Direction.X * _axisNormX + _ray.Direction.Y * _axisNormY + _ray.Direction.Z
			* _axisNormZ;
		var _adotco = _axisNormX * _coX + _axisNormY * _coY + _axisNormZ * _coZ;

		var _a = _adotd * _adotd - _cosAngleSq;
		var _b = 2.0 * (_adotd * _adotco - (_ray.Direction.X * _coX + _ray.Direction.Y * _coY + _ray.Direction.Z
			* _coZ) * _cosAngleSq);
		var _c = _adotco * _adotco - (_coX * _coX + _coY * _coY + _coZ * _coZ) * _cosAngleSq;

		var _discriminant = _b * _b - 4.0 * _a * _c;

		if (_discriminant < 0.0)
		{
			return false;
		}

		var _sqrtDisc = sqrt(_discriminant);
		var _t1 = (-_b - _sqrtDisc) / (2.0 * _a);
		var _t2 = (-_b + _sqrtDisc) / (2.0 * _a);

		var _t = -1.0;

		// Check both intersections
		for (var _i = 0; _i < 2; _i++)
		{
			var _ti = (_i == 0) ? _t1 : _t2;

			if (_ti < 0.0)
			{
				continue;
			}

			// Intersection point
			var _pX = _ray.Origin.X + _ray.Direction.X * _ti;
			var _pY = _ray.Origin.Y + _ray.Direction.Y * _ti;
			var _pZ = _ray.Origin.Z + _ray.Direction.Z * _ti;

			// Check if within cone bounds
			var _tipToPX = _pX - Tip.X;
			var _tipToPY = _pY - Tip.Y;
			var _tipToPZ = _pZ - Tip.Z;
			var _proj = _tipToPX * _axisNormX + _tipToPY * _axisNormY + _tipToPZ * _axisNormZ;

			if (_proj >= 0.0 && _proj <= _height)
			{
				if (_t < 0.0 || _ti < _t)
				{
					_t = _ti;
				}
			}
		}

		// Also test base disc
		var _denom = _ray.Direction.X * _axisNormX + _ray.Direction.Y * _axisNormY + _ray.Direction.Z
			* _axisNormZ;
		if (abs(_denom) > 0.0001)
		{
			var _baseToRayX = Base.X - _ray.Origin.X;
			var _baseToRayY = Base.Y - _ray.Origin.Y;
			var _baseToRayZ = Base.Z - _ray.Origin.Z;
			var _tBase = (_baseToRayX * _axisNormX + _baseToRayY * _axisNormY + _baseToRayZ * _axisNormZ)
				/ _denom;

			if (_tBase >= 0.0)
			{
				var _pX = _ray.Origin.X + _ray.Direction.X * _tBase;
				var _pY = _ray.Origin.Y + _ray.Direction.Y * _tBase;
				var _pZ = _ray.Origin.Z + _ray.Direction.Z * _tBase;

				var _distFromBase = point_distance_3d(_pX, _pY, _pZ, Base.X, Base.Y, Base.Z);
				if (_distFromBase <= Radius)
				{
					if (_t < 0.0 || _tBase < _t)
					{
						_t = _tBase;
					}
				}
			}
		}

		if (_t < 0.0)
		{
			return false;
		}

		if (_result != undefined)
		{
			_result.Distance = _t;
			var _pX = _ray.Origin.X + _ray.Direction.X * _t;
			var _pY = _ray.Origin.Y + _ray.Direction.Y * _t;
			var _pZ = _ray.Origin.Z + _ray.Direction.Z * _t;
			_result.Point = new BBMOD_Vec3(_pX, _pY, _pZ);

			// Compute normal (simplified)
			var _tipToPX = _pX - Tip.X;
			var _tipToPY = _pY - Tip.Y;
			var _tipToPZ = _pZ - Tip.Z;
			var _proj = _tipToPX * _axisNormX + _tipToPY * _axisNormY + _tipToPZ * _axisNormZ;

			// Check if on base
			if (abs(_proj - _height) < 0.001)
			{
				_result.Normal = new BBMOD_Vec3(_axisNormX, _axisNormY, _axisNormZ);
			}
			else
			{
				// On cone surface
				var _radialX = _tipToPX - _axisNormX * _proj;
				var _radialY = _tipToPY - _axisNormY * _proj;
				var _radialZ = _tipToPZ - _axisNormZ * _proj;
				var _radialLen = point_distance_3d(0, 0, 0, _radialX, _radialY, _radialZ);
				var _norm = (_radialLen != 0.0) ? (1.0 / _radialLen) : 0.0;
				_result.Normal = new BBMOD_Vec3(_radialX * _norm, _radialY * _norm, _radialZ * _norm);
			}
		}

		return true;
	};

	/// @func DrawDebug(_color, _alpha)
	///
	/// @desc Draws a debug visualization of the cone.
	///
	/// @param {Constant.Color} [_color] The color to use. Defaults to `c_white`.
	/// @param {Real} [_alpha] The alpha value to use. Defaults to 1.
	///
	/// @return {Struct.BBMOD_ConeCollider} Returns `self`.
	static DrawDebug = function (_color = c_white, _alpha = 1.0)
	{
		var _vbuffer = global.__bbmodVBufferDebug;

		vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

		var _tipX = Tip.X;
		var _tipY = Tip.Y;
		var _tipZ = Tip.Z;

		var _baseX = Base.X;
		var _baseY = Base.Y;
		var _baseZ = Base.Z;

		// Cone axis
		var _axisX = _baseX - _tipX;
		var _axisY = _baseY - _tipY;
		var _axisZ = _baseZ - _tipZ;
		var _height = point_distance_3d(0, 0, 0, _axisX, _axisY, _axisZ);

		if (_height == 0.0)
		{
			vertex_end(_vbuffer);
			vertex_submit(_vbuffer, pr_linelist, -1);
			return self;
		}

		// Normalized axis
		var _axisNormX = _axisX / _height;
		var _axisNormY = _axisY / _height;
		var _axisNormZ = _axisZ / _height;

		// Find perpendicular vectors for base circle
		var _perpX, _perpY, _perpZ;
		if (abs(_axisNormX) < 0.9)
		{
			_perpX = 0.0;
			_perpY = _axisNormZ;
			_perpZ = -_axisNormY;
		}
		else
		{
			_perpX = _axisNormZ;
			_perpY = 0.0;
			_perpZ = -_axisNormX;
		}

		var _perpLen = point_distance_3d(0, 0, 0, _perpX, _perpY, _perpZ);
		_perpX /= _perpLen;
		_perpY /= _perpLen;
		_perpZ /= _perpLen;

		// Second perpendicular (cross product)
		var _perp2X = _axisNormY * _perpZ - _axisNormZ * _perpY;
		var _perp2Y = _axisNormZ * _perpX - _axisNormX * _perpZ;
		var _perp2Z = _axisNormX * _perpY - _axisNormY * _perpX;

		// Draw base circle
		var _steps = 16;
		var _inc = 360.0 / _steps;
		var _angle = 0.0;

		repeat(_steps)
		{
			var _cos1 = dcos(_angle);
			var _sin1 = dsin(_angle);
			var _cos2 = dcos(_angle + _inc);
			var _sin2 = dsin(_angle + _inc);

			var _x1 = _baseX + (_perpX * _cos1 + _perp2X * _sin1) * Radius;
			var _y1 = _baseY + (_perpY * _cos1 + _perp2Y * _sin1) * Radius;
			var _z1 = _baseZ + (_perpZ * _cos1 + _perp2Z * _sin1) * Radius;

			var _x2 = _baseX + (_perpX * _cos2 + _perp2X * _sin2) * Radius;
			var _y2 = _baseY + (_perpY * _cos2 + _perp2Y * _sin2) * Radius;
			var _z2 = _baseZ + (_perpZ * _cos2 + _perp2Z * _sin2) * Radius;

			// Base circle edge
			vertex_position_3d(_vbuffer, _x1, _y1, _z1);
			vertex_color(_vbuffer, _color, _alpha);
			vertex_position_3d(_vbuffer, _x2, _y2, _z2);
			vertex_color(_vbuffer, _color, _alpha);

			// Lines from tip to base circle
			vertex_position_3d(_vbuffer, _tipX, _tipY, _tipZ);
			vertex_color(_vbuffer, _color, _alpha);
			vertex_position_3d(_vbuffer, _x1, _y1, _z1);
			vertex_color(_vbuffer, _color, _alpha);

			_angle += _inc;
		}

		vertex_end(_vbuffer);
		vertex_submit(_vbuffer, pr_linelist, -1);

		return self;
	};
}
