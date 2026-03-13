/// @module Extras.Raycasting

/// @func BBMOD_LineSegmentCollider([_pointA[, _pointB]])
///
/// @extends BBMOD_Collider
///
/// @desc A line segment collider defined by two endpoints. Represents
/// a finite line with zero thickness. Useful for weapon collision
/// (swords, melee attacks), rope/cable physics, and line-of-sight checks.
///
/// @param {Struct.BBMOD_Vec3} [_pointA] The start point of the line segment.
/// Defaults to (0, 0, 0).
/// @param {Struct.BBMOD_Vec3} [_pointB] The end point of the line segment.
/// Defaults to (0, 0, 1).
///
/// @example
/// ```gml
/// // Create a line segment from (0,0,0) to (10,0,0)
/// var lineSegment = new BBMOD_LineSegmentCollider(
///     new BBMOD_Vec3(0.0, 0.0, 0.0),
///     new BBMOD_Vec3(10.0, 0.0, 0.0)
/// );
///
/// // Test if a point is near the line segment
/// var point = new BBMOD_Vec3(5.0, 0.1, 0.0);
/// // true if point is on segment (with epsilon)
/// var isNear = lineSegment.TestPoint(point);
///
/// // Get closest point on segment
/// var closest = lineSegment.GetClosestPoint(point);
/// ```
function BBMOD_LineSegmentCollider(_pointA = undefined, _pointB = undefined): BBMOD_Collider() constructor
{
	/// @var {Struct.BBMOD_Vec3} The start point of the line segment.
	PointA = _pointA ?? new BBMOD_Vec3(0.0, 0.0, 0.0);

	/// @var {Struct.BBMOD_Vec3} The end point of the line segment.
	PointB = _pointB ?? new BBMOD_Vec3(0.0, 0.0, 1.0);

	/// @func GetClosestPoint(_point)
	///
	/// @desc Computes the closest point on the line segment to a given point.
	///
	/// @param {Struct.BBMOD_Vec3} _point The point to test.
	///
	/// @return {Struct.BBMOD_Vec3} The closest point on the line segment.
	static GetClosestPoint = function (_point)
	{
		gml_pragma("forceinline");

		// Compute vector from A to B
		var _abX = PointB.X - PointA.X;
		var _abY = PointB.Y - PointA.Y;
		var _abZ = PointB.Z - PointA.Z;

		// Compute vector from A to point
		var _apX = _point.X - PointA.X;
		var _apY = _point.Y - PointA.Y;
		var _apZ = _point.Z - PointA.Z;

		// Project point onto line segment
		var _abLengthSqr = _abX * _abX + _abY * _abY + _abZ * _abZ;
		var _t = (_abLengthSqr != 0.0)
			? clamp((_apX * _abX + _apY * _abY + _apZ * _abZ) / _abLengthSqr, 0.0, 1.0)
			: 0.0;

		// Return closest point
		return new BBMOD_Vec3(
			PointA.X + _abX * _t,
			PointA.Y + _abY * _t,
			PointA.Z + _abZ * _t
		);
	};

	/// @func TestPoint(_point)
	///
	/// @desc Tests if a point lies on the line segment (within epsilon tolerance).
	///
	/// @param {Struct.BBMOD_Vec3} _point The point to test.
	///
	/// @return {Bool} Returns `true` if the point is on the line segment.
	static TestPoint = function (_point)
	{
		gml_pragma("forceinline");

		// Get closest point on line segment
		var _abX = PointB.X - PointA.X;
		var _abY = PointB.Y - PointA.Y;
		var _abZ = PointB.Z - PointA.Z;

		var _apX = _point.X - PointA.X;
		var _apY = _point.Y - PointA.Y;
		var _apZ = _point.Z - PointA.Z;

		var _abLengthSqr = _abX * _abX + _abY * _abY + _abZ * _abZ;
		var _t = (_abLengthSqr != 0.0)
			? clamp((_apX * _abX + _apY * _abY + _apZ * _abZ) / _abLengthSqr, 0.0, 1.0)
			: 0.0;

		var _closestX = PointA.X + _abX * _t;
		var _closestY = PointA.Y + _abY * _t;
		var _closestZ = PointA.Z + _abZ * _t;

		// Check if point is on segment (within epsilon)
		var _distSqr = point_distance_3d(_point.X, _point.Y, _point.Z, _closestX, _closestY, _closestZ);
		return (_distSqr < 0.0001); // Epsilon threshold
	};

	/// @func TestSphere(_sphere)
	///
	/// @desc Tests if the line segment intersects with a sphere.
	///
	/// @param {Struct.BBMOD_SphereCollider} _sphere The sphere to test against.
	///
	/// @return {Bool} Returns `true` if the line segment intersects the sphere.
	static TestSphere = function (_sphere)
	{
		gml_pragma("forceinline");

		// Get closest point on line segment to sphere center
		var _abX = PointB.X - PointA.X;
		var _abY = PointB.Y - PointA.Y;
		var _abZ = PointB.Z - PointA.Z;

		var _apX = _sphere.Position.X - PointA.X;
		var _apY = _sphere.Position.Y - PointA.Y;
		var _apZ = _sphere.Position.Z - PointA.Z;

		var _abLengthSqr = _abX * _abX + _abY * _abY + _abZ * _abZ;
		var _t = (_abLengthSqr != 0.0)
			? clamp((_apX * _abX + _apY * _abY + _apZ * _abZ) / _abLengthSqr, 0.0, 1.0)
			: 0.0;

		var _closestX = PointA.X + _abX * _t;
		var _closestY = PointA.Y + _abY * _t;
		var _closestZ = PointA.Z + _abZ * _t;

		// Check if distance to closest point is within radius
		var _dist = point_distance_3d(
			_sphere.Position.X, _sphere.Position.Y, _sphere.Position.Z,
			_closestX, _closestY, _closestZ
		);

		return (_dist <= _sphere.Radius);
	};

	/// @func TestAABB(_aabb)
	///
	/// @desc Tests if the line segment intersects with an axis-aligned bounding box.
	///
	/// @param {Struct.BBMOD_AABBCollider} _aabb The AABB to test against.
	///
	/// @return {Bool} Returns `true` if the line segment intersects the AABB.
	static TestAABB = function (_aabb)
	{
		gml_pragma("forceinline");

		// Use slab method for ray-AABB intersection applied to segment
		var _dirX = PointB.X - PointA.X;
		var _dirY = PointB.Y - PointA.Y;
		var _dirZ = PointB.Z - PointA.Z;

		var _tMin = 0.0;
		var _tMax = 1.0;

		// X axis slab
		if (abs(_dirX) > 0.0001)
		{
			var _t1 = (_aabb.Min.X - PointA.X) / _dirX;
			var _t2 = (_aabb.Max.X - PointA.X) / _dirX;
			_tMin = max(_tMin, min(_t1, _t2));
			_tMax = min(_tMax, max(_t1, _t2));
		}
		else
		{
			// Segment parallel to YZ plane
			if (PointA.X < _aabb.Min.X || PointA.X > _aabb.Max.X)
			{
				return false;
			}
		}

		// Y axis slab
		if (abs(_dirY) > 0.0001)
		{
			var _t1 = (_aabb.Min.Y - PointA.Y) / _dirY;
			var _t2 = (_aabb.Max.Y - PointA.Y) / _dirY;
			_tMin = max(_tMin, min(_t1, _t2));
			_tMax = min(_tMax, max(_t1, _t2));
		}
		else
		{
			// Segment parallel to XZ plane
			if (PointA.Y < _aabb.Min.Y || PointA.Y > _aabb.Max.Y)
			{
				return false;
			}
		}

		// Z axis slab
		if (abs(_dirZ) > 0.0001)
		{
			var _t1 = (_aabb.Min.Z - PointA.Z) / _dirZ;
			var _t2 = (_aabb.Max.Z - PointA.Z) / _dirZ;
			_tMin = max(_tMin, min(_t1, _t2));
			_tMax = min(_tMax, max(_t1, _t2));
		}
		else
		{
			// Segment parallel to XY plane
			if (PointA.Z < _aabb.Min.Z || PointA.Z > _aabb.Max.Z)
			{
				return false;
			}
		}

		return (_tMax >= _tMin);
	};

	/// @func TestPlane(_plane)
	///
	/// @desc Tests if the line segment intersects with a plane.
	///
	/// @param {Struct.BBMOD_PlaneCollider} _plane The plane to test against.
	///
	/// @return {Bool} Returns `true` if the line segment intersects the plane.
	static TestPlane = function (_plane)
	{
		gml_pragma("forceinline");

		// Calculate signed distances from endpoints to plane
		var _distA = _plane.Normal.X * PointA.X + _plane.Normal.Y * PointA.Y
			+ _plane.Normal.Z * PointA.Z + _plane.Distance;
		var _distB = _plane.Normal.X * PointB.X + _plane.Normal.Y * PointB.Y
			+ _plane.Normal.Z * PointB.Z + _plane.Distance;

		// If endpoints are on opposite sides, segment crosses plane
		// Also true if either endpoint is on the plane
		return ((_distA * _distB) <= 0.0);
	};

	/// @func TestFrustum(_frustum)
	///
	/// @desc Tests if the line segment is inside or intersects with a frustum.
	///
	/// @param {Struct.BBMOD_FrustumCollider} _frustum The frustum to test against.
	///
	/// @return {Bool} Returns `true` if the line segment is inside the frustum.
	static TestFrustum = function (_frustum)
	{
		gml_pragma("forceinline");

		// Test both endpoints against all frustum planes
		// If both endpoints are outside any single plane, segment is outside
		for (var i = 0; i < BBMOD_EFrustumPlane.SIZE; ++i)
		{
			var _plane = _frustum.Planes[i];
			var _distA = PointA.X * _plane.Normal.X + PointA.Y * _plane.Normal.Y
				+ PointA.Z * _plane.Normal.Z + _plane.Distance;
			var _distB = PointB.X * _plane.Normal.X + PointB.Y * _plane.Normal.Y
				+ PointB.Z * _plane.Normal.Z + _plane.Distance;

			if (_distA < 0.0 && _distB < 0.0)
			{
				return false;
			}
		}

		return true;
	};

	/// @func TestCapsule(_capsule)
	///
	/// @desc Tests if the line segment intersects with a capsule.
	///
	/// @param {Struct.BBMOD_CapsuleCollider} _capsule The capsule to test against.
	///
	/// @return {Bool} Returns `true` if the line segment intersects the capsule.
	static TestCapsule = function (_capsule)
	{
		gml_pragma("forceinline");

		// Compute closest distance between two line segments (this segment and capsule axis)
		// Algorithm: Real-Time Collision Detection, Chapter 5.1.9

		var _d1X = PointB.X - PointA.X;
		var _d1Y = PointB.Y - PointA.Y;
		var _d1Z = PointB.Z - PointA.Z;

		var _d2X = _capsule.PointB.X - _capsule.PointA.X;
		var _d2Y = _capsule.PointB.Y - _capsule.PointA.Y;
		var _d2Z = _capsule.PointB.Z - _capsule.PointA.Z;

		var _rX = PointA.X - _capsule.PointA.X;
		var _rY = PointA.Y - _capsule.PointA.Y;
		var _rZ = PointA.Z - _capsule.PointA.Z;

		var _a = _d1X * _d1X + _d1Y * _d1Y + _d1Z * _d1Z;
		var _e = _d2X * _d2X + _d2Y * _d2Y + _d2Z * _d2Z;
		var _f = _d2X * _rX + _d2Y * _rY + _d2Z * _rZ;

		var _s, _t;
		var _c = _d1X * _rX + _d1Y * _rY + _d1Z * _rZ;
		var _b = _d1X * _d2X + _d1Y * _d2Y + _d1Z * _d2Z;
		var _denom = _a * _e - _b * _b;

		if (_denom != 0.0)
		{
			_s = clamp((_b * _f - _c * _e) / _denom, 0.0, 1.0);
		}
		else
		{
			_s = 0.0;
		}

		_t = (_b * _s + _f) / _e;

		if (_t < 0.0)
		{
			_t = 0.0;
			_s = clamp(-_c / _a, 0.0, 1.0);
		}
		else if (_t > 1.0)
		{
			_t = 1.0;
			_s = clamp((_b - _c) / _a, 0.0, 1.0);
		}

		// Compute closest points
		var _c1X = PointA.X + _d1X * _s;
		var _c1Y = PointA.Y + _d1Y * _s;
		var _c1Z = PointA.Z + _d1Z * _s;

		var _c2X = _capsule.PointA.X + _d2X * _t;
		var _c2Y = _capsule.PointA.Y + _d2Y * _t;
		var _c2Z = _capsule.PointA.Z + _d2Z * _t;

		var _dist = point_distance_3d(_c1X, _c1Y, _c1Z, _c2X, _c2Y, _c2Z);

		return (_dist <= _capsule.Radius);
	};

	/// @func TestTriangle(_triangle)
	///
	/// @desc Tests if the line segment intersects with a triangle.
	///
	/// @param {Struct.BBMOD_TriangleCollider} _triangle The triangle to test against.
	///
	/// @return {Bool} Returns `true` if the line segment intersects the triangle.
	static TestTriangle = function (_triangle)
	{
		gml_pragma("forceinline");

		// Use Moller-Trumbore algorithm adapted for segment
		var _edge1X = _triangle.VertexB.X - _triangle.VertexA.X;
		var _edge1Y = _triangle.VertexB.Y - _triangle.VertexA.Y;
		var _edge1Z = _triangle.VertexB.Z - _triangle.VertexA.Z;

		var _edge2X = _triangle.VertexC.X - _triangle.VertexA.X;
		var _edge2Y = _triangle.VertexC.Y - _triangle.VertexA.Y;
		var _edge2Z = _triangle.VertexC.Z - _triangle.VertexA.Z;

		var _dirX = PointB.X - PointA.X;
		var _dirY = PointB.Y - PointA.Y;
		var _dirZ = PointB.Z - PointA.Z;

		// Cross product: _dir x _edge2
		var _hX = _dirY * _edge2Z - _dirZ * _edge2Y;
		var _hY = _dirZ * _edge2X - _dirX * _edge2Z;
		var _hZ = _dirX * _edge2Y - _dirY * _edge2X;

		var _a = _edge1X * _hX + _edge1Y * _hY + _edge1Z * _hZ;

		if (abs(_a) < 0.0001)
		{
			return false; // Segment parallel to triangle
		}

		var _f = 1.0 / _a;
		var _sX = PointA.X - _triangle.VertexA.X;
		var _sY = PointA.Y - _triangle.VertexA.Y;
		var _sZ = PointA.Z - _triangle.VertexA.Z;

		var _u = _f * (_sX * _hX + _sY * _hY + _sZ * _hZ);

		if (_u < 0.0 || _u > 1.0)
		{
			return false;
		}

		// Cross product: _s x _edge1
		var _qX = _sY * _edge1Z - _sZ * _edge1Y;
		var _qY = _sZ * _edge1X - _sX * _edge1Z;
		var _qZ = _sX * _edge1Y - _sY * _edge1X;

		var _v = _f * (_dirX * _qX + _dirY * _qY + _dirZ * _qZ);

		if (_v < 0.0 || _u + _v > 1.0)
		{
			return false;
		}

		// Check if intersection is within segment bounds [0, 1]
		var _t = _f * (_edge2X * _qX + _edge2Y * _qY + _edge2Z * _qZ);

		return (_t >= 0.0 && _t <= 1.0);
	};

	/// @func TestOBB(_obb)
	///
	/// @desc Tests if the line segment intersects with an oriented bounding box.
	///
	/// @param {Struct.BBMOD_OBBCollider} _obb The OBB to test against.
	///
	/// @return {Bool} Returns `true` if the line segment intersects the OBB.
	static TestOBB = function (_obb)
	{
		gml_pragma("forceinline");

		// Transform segment endpoints to OBB's local space
		// This converts the OBB test into an AABB test

		// Get inverse rotation (conjugate quaternion)
		var _qx = -_obb.Rotation.X;
		var _qy = -_obb.Rotation.Y;
		var _qz = -_obb.Rotation.Z;
		var _qw = _obb.Rotation.W;

		// Transform PointA to local space
		var _localAX = PointA.X - _obb.Position.X;
		var _localAY = PointA.Y - _obb.Position.Y;
		var _localAZ = PointA.Z - _obb.Position.Z;

		// Rotate by conjugate quaternion
		var _t0 = _qw * _localAX + _qy * _localAZ - _qz * _localAY;
		var _t1 = _qw * _localAY + _qz * _localAX - _qx * _localAZ;
		var _t2 = _qw * _localAZ + _qx * _localAY - _qy * _localAX;
		var _t3 = -_qx * _localAX - _qy * _localAY - _qz * _localAZ;

		_localAX = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
		_localAY = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
		_localAZ = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);

		// Transform PointB to local space
		var _localBX = PointB.X - _obb.Position.X;
		var _localBY = PointB.Y - _obb.Position.Y;
		var _localBZ = PointB.Z - _obb.Position.Z;

		_t0 = _qw * _localBX + _qy * _localBZ - _qz * _localBY;
		_t1 = _qw * _localBY + _qz * _localBX - _qx * _localBZ;
		_t2 = _qw * _localBZ + _qx * _localBY - _qy * _localBX;
		_t3 = -_qx * _localBX - _qy * _localBY - _qz * _localBZ;

		_localBX = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
		_localBY = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
		_localBZ = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);

		// Now perform slab test against AABB in local space
		var _dirX = _localBX - _localAX;
		var _dirY = _localBY - _localAY;
		var _dirZ = _localBZ - _localAZ;

		var _tMin = 0.0;
		var _tMax = 1.0;

		// X axis slab
		if (abs(_dirX) > 0.0001)
		{
			var _t1 = (-_obb.HalfExtents.X - _localAX) / _dirX;
			var _t2 = (_obb.HalfExtents.X - _localAX) / _dirX;
			_tMin = max(_tMin, min(_t1, _t2));
			_tMax = min(_tMax, max(_t1, _t2));
		}
		else
		{
			if (abs(_localAX) > _obb.HalfExtents.X)
			{
				return false;
			}
		}

		// Y axis slab
		if (abs(_dirY) > 0.0001)
		{
			var _t1 = (-_obb.HalfExtents.Y - _localAY) / _dirY;
			var _t2 = (_obb.HalfExtents.Y - _localAY) / _dirY;
			_tMin = max(_tMin, min(_t1, _t2));
			_tMax = min(_tMax, max(_t1, _t2));
		}
		else
		{
			if (abs(_localAY) > _obb.HalfExtents.Y)
			{
				return false;
			}
		}

		// Z axis slab
		if (abs(_dirZ) > 0.0001)
		{
			var _t1 = (-_obb.HalfExtents.Z - _localAZ) / _dirZ;
			var _t2 = (_obb.HalfExtents.Z - _localAZ) / _dirZ;
			_tMin = max(_tMin, min(_t1, _t2));
			_tMax = min(_tMax, max(_t1, _t2));
		}
		else
		{
			if (abs(_localAZ) > _obb.HalfExtents.Z)
			{
				return false;
			}
		}

		return (_tMax >= _tMin);
	};

	/// @func TestLineSegment(_segment)
	///
	/// @desc Tests if this line segment intersects with another line segment.
	///
	/// @param {Struct.BBMOD_LineSegmentCollider} _segment The other line segment to test against.
	///
	/// @return {Bool} Returns `true` if the line segments intersect (or are very close).
	static TestLineSegment = function (_segment)
	{
		gml_pragma("forceinline");

		// Compute closest distance between two line segments
		// Same algorithm as TestCapsule but with zero radius threshold

		var _d1X = PointB.X - PointA.X;
		var _d1Y = PointB.Y - PointA.Y;
		var _d1Z = PointB.Z - PointA.Z;

		var _d2X = _segment.PointB.X - _segment.PointA.X;
		var _d2Y = _segment.PointB.Y - _segment.PointA.Y;
		var _d2Z = _segment.PointB.Z - _segment.PointA.Z;

		var _rX = PointA.X - _segment.PointA.X;
		var _rY = PointA.Y - _segment.PointA.Y;
		var _rZ = PointA.Z - _segment.PointA.Z;

		var _a = _d1X * _d1X + _d1Y * _d1Y + _d1Z * _d1Z;
		var _e = _d2X * _d2X + _d2Y * _d2Y + _d2Z * _d2Z;
		var _f = _d2X * _rX + _d2Y * _rY + _d2Z * _rZ;

		var _s, _t;
		var _c = _d1X * _rX + _d1Y * _rY + _d1Z * _rZ;
		var _b = _d1X * _d2X + _d1Y * _d2Y + _d1Z * _d2Z;
		var _denom = _a * _e - _b * _b;

		if (_denom != 0.0)
		{
			_s = clamp((_b * _f - _c * _e) / _denom, 0.0, 1.0);
		}
		else
		{
			_s = 0.0;
		}

		_t = (_b * _s + _f) / _e;

		if (_t < 0.0)
		{
			_t = 0.0;
			_s = clamp(-_c / _a, 0.0, 1.0);
		}
		else if (_t > 1.0)
		{
			_t = 1.0;
			_s = clamp((_b - _c) / _a, 0.0, 1.0);
		}

		// Compute closest points
		var _c1X = PointA.X + _d1X * _s;
		var _c1Y = PointA.Y + _d1Y * _s;
		var _c1Z = PointA.Z + _d1Z * _s;

		var _c2X = _segment.PointA.X + _d2X * _t;
		var _c2Y = _segment.PointA.Y + _d2Y * _t;
		var _c2Z = _segment.PointA.Z + _d2Z * _t;

		var _dist = point_distance_3d(_c1X, _c1Y, _c1Z, _c2X, _c2Y, _c2Z);

		return (_dist < 0.0001); // Epsilon threshold for intersection
	};

	/// @func TestCylinder(_cylinder)
	///
	/// @desc Tests if the line segment intersects with a cylinder.
	///
	/// @param {Struct.BBMOD_CylinderCollider} _cylinder The cylinder to test against.
	///
	/// @return {Bool} Returns `true` if the line segment intersects the cylinder.
	static TestCylinder = function (_cylinder)
	{
		gml_pragma("forceinline");

		// Compute closest distance between line segment and cylinder axis
		var _d1X = PointB.X - PointA.X;
		var _d1Y = PointB.Y - PointA.Y;
		var _d1Z = PointB.Z - PointA.Z;

		var _d2X = _cylinder.PointB.X - _cylinder.PointA.X;
		var _d2Y = _cylinder.PointB.Y - _cylinder.PointA.Y;
		var _d2Z = _cylinder.PointB.Z - _cylinder.PointA.Z;

		var _rX = PointA.X - _cylinder.PointA.X;
		var _rY = PointA.Y - _cylinder.PointA.Y;
		var _rZ = PointA.Z - _cylinder.PointA.Z;

		var _a = _d1X * _d1X + _d1Y * _d1Y + _d1Z * _d1Z;
		var _e = _d2X * _d2X + _d2Y * _d2Y + _d2Z * _d2Z;
		var _f = _d2X * _rX + _d2Y * _rY + _d2Z * _rZ;

		var _s, _t;
		var _c = _d1X * _rX + _d1Y * _rY + _d1Z * _rZ;
		var _b = _d1X * _d2X + _d1Y * _d2Y + _d1Z * _d2Z;
		var _denom = _a * _e - _b * _b;

		if (_denom != 0.0)
		{
			_s = clamp((_b * _f - _c * _e) / _denom, 0.0, 1.0);
		}
		else
		{
			_s = 0.0;
		}

		_t = (_b * _s + _f) / _e;

		if (_t < 0.0)
		{
			_t = 0.0;
			_s = clamp(-_c / _a, 0.0, 1.0);
		}
		else if (_t > 1.0)
		{
			_t = 1.0;
			_s = clamp((_b - _c) / _a, 0.0, 1.0);
		}

		// Compute closest points
		var _c1X = PointA.X + _d1X * _s;
		var _c1Y = PointA.Y + _d1Y * _s;
		var _c1Z = PointA.Z + _d1Z * _s;

		var _c2X = _cylinder.PointA.X + _d2X * _t;
		var _c2Y = _cylinder.PointA.Y + _d2Y * _t;
		var _c2Z = _cylinder.PointA.Z + _d2Z * _t;

		var _dist = point_distance_3d(_c1X, _c1Y, _c1Z, _c2X, _c2Y, _c2Z);

		return (_dist <= _cylinder.Radius);
	};

	/// @func TestEllipsoid(_ellipsoid)
	///
	/// @desc Tests if this line segment intersects with an ellipsoid.
	///
	/// @param {Struct.BBMOD_EllipsoidCollider} _ellipsoid The ellipsoid to test against.
	///
	/// @return {Bool} Returns `true` if the line segment intersects the ellipsoid.
	static TestEllipsoid = function (_ellipsoid)
	{
		gml_pragma("forceinline");
		return _ellipsoid.TestLineSegment(self);
	};

	/// @func TestCone(_cone)
	///
	/// @desc Tests if this line segment intersects with a cone.
	///
	/// @param {Struct.BBMOD_ConeCollider} _cone The cone to test against.
	///
	/// @return {Bool} Returns `true` if the line segment intersects the cone.
	static TestCone = function (_cone)
	{
		gml_pragma("forceinline");
		return _cone.TestLineSegment(self);
	};

	/// @func Raycast(_ray, _result)
	///
	/// @desc Casts a ray at the line segment and finds the closest intersection.
	///
	/// @param {Struct.BBMOD_Ray} _ray The ray to cast.
	/// @param {Struct.BBMOD_RaycastResult} _result The raycast result to populate.
	///
	/// @return {Bool} Returns `true` if the ray intersects the line segment.
	///
	/// @note This performs a ray vs line segment intersection test. Due to the
	/// zero thickness of line segments, this test uses an epsilon threshold.
	static Raycast = function (_ray, _result)
	{
		gml_pragma("forceinline");

		// Ray-line segment intersection using closest point approach
		// Algorithm: Find closest points between ray and segment, check if distance is near zero

		var _d1X = _ray.Direction.X;
		var _d1Y = _ray.Direction.Y;
		var _d1Z = _ray.Direction.Z;

		var _d2X = PointB.X - PointA.X;
		var _d2Y = PointB.Y - PointA.Y;
		var _d2Z = PointB.Z - PointA.Z;

		var _rX = _ray.Origin.X - PointA.X;
		var _rY = _ray.Origin.Y - PointA.Y;
		var _rZ = _ray.Origin.Z - PointA.Z;

		var _a = _d1X * _d1X + _d1Y * _d1Y + _d1Z * _d1Z;
		var _e = _d2X * _d2X + _d2Y * _d2Y + _d2Z * _d2Z;
		var _f = _d2X * _rX + _d2Y * _rY + _d2Z * _rZ;

		var _c = _d1X * _rX + _d1Y * _rY + _d1Z * _rZ;
		var _b = _d1X * _d2X + _d1Y * _d2Y + _d1Z * _d2Z;
		var _denom = _a * _e - _b * _b;

		var _s, _t;

		if (_denom != 0.0)
		{
			_s = (_b * _f - _c * _e) / _denom;
		}
		else
		{
			_s = 0.0;
		}

		_t = (_b * _s + _f) / _e;

		// Clamp to segment bounds
		if (_t < 0.0)
		{
			_t = 0.0;
			_s = -_c / _a;
		}
		else if (_t > 1.0)
		{
			_t = 1.0;
			_s = (_b - _c) / _a;
		}

		// Ray must go forward
		if (_s < 0.0)
		{
			return false;
		}

		// Compute closest points
		var _c1X = _ray.Origin.X + _d1X * _s;
		var _c1Y = _ray.Origin.Y + _d1Y * _s;
		var _c1Z = _ray.Origin.Z + _d1Z * _s;

		var _c2X = PointA.X + _d2X * _t;
		var _c2Y = PointA.Y + _d2Y * _t;
		var _c2Z = PointA.Z + _d2Z * _t;

		var _dist = point_distance_3d(_c1X, _c1Y, _c1Z, _c2X, _c2Y, _c2Z);

		if (_dist < 0.01) // Epsilon threshold for ray hitting zero-thickness segment
		{
			_result.Distance = _s;
			_result.Point.X = _c1X;
			_result.Point.Y = _c1Y;
			_result.Point.Z = _c1Z;

			// Normal points from segment to ray hit point
			if (_dist > 0.0001)
			{
				var _invDist = 1.0 / _dist;
				_result.Normal.X = (_c1X - _c2X) * _invDist;
				_result.Normal.Y = (_c1Y - _c2Y) * _invDist;
				_result.Normal.Z = (_c1Z - _c2Z) * _invDist;
			}
			else
			{
				// Ray hits segment directly, use perpendicular direction
				_result.Normal.X = 0.0;
				_result.Normal.Y = 0.0;
				_result.Normal.Z = 1.0;
			}

			return true;
		}

		return false;
	};

	/// @func DrawDebug([_color[, _alpha]])
	///
	/// @desc Draws a debug visualization of the line segment.
	///
	/// @param {Constant.Color} [_color] The color of the line. Defaults to
	/// `c_white`.
	/// @param {Real} [_alpha] The alpha value of the line. Defaults to 1.
	static DrawDebug = function (_color = c_white, _alpha = 1.0)
	{
		gml_pragma("forceinline");

		var _vbuffer = global.__bbmodVBufferDebug;

		vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

		// Draw the line segment
		vertex_position_3d(_vbuffer, PointA.X, PointA.Y, PointA.Z);
		vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, PointB.X, PointB.Y, PointB.Z);
		vertex_color(_vbuffer, _color, _alpha);

		vertex_end(_vbuffer);

		vertex_submit(_vbuffer, pr_linelist, -1);

		return self;
	};
}
