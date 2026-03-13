/// @module Extras.Raycasting

/// @func BBMOD_CylinderCollider([_pointA[, _pointB[, _radius]]])
///
/// @extends BBMOD_Collider
///
/// @desc A cylinder collider defined by two endpoints and a radius. Unlike a
/// capsule, a cylinder has flat circular caps at each end. Useful for pillars,
/// poles, tubes, and cylindrical objects.
///
/// @param {Struct.BBMOD_Vec3} [_pointA] The center of the first circular cap.
/// Defaults to (0, 0, 0).
/// @param {Struct.BBMOD_Vec3} [_pointB] The center of the second circular cap.
/// Defaults to (0, 0, 1).
/// @param {Real} [_radius] The radius of the cylinder. Defaults to 0.5.
///
/// @example
/// ```gml
/// // Create a cylinder from (0,0,0) to (0,10,0) with radius 1
/// var cylinder = new BBMOD_CylinderCollider(
///     new BBMOD_Vec3(0.0, 0.0, 0.0),
///     new BBMOD_Vec3(0.0, 10.0, 0.0),
///     1.0
/// );
///
/// // Test if a point is inside the cylinder
/// var point = new BBMOD_Vec3(0.5, 5.0, 0.0);
/// var isInside = cylinder.TestPoint(point);
/// ```
function BBMOD_CylinderCollider(_pointA = undefined, _pointB = undefined, _radius = 0.5): BBMOD_Collider() constructor
{
	/// @var {Struct.BBMOD_Vec3} The center of the first circular cap.
	PointA = _pointA ?? new BBMOD_Vec3(0.0, 0.0, 0.0);

	/// @var {Struct.BBMOD_Vec3} The center of the second circular cap.
	PointB = _pointB ?? new BBMOD_Vec3(0.0, 0.0, 1.0);

	/// @var {Real} The radius of the cylinder.
	Radius = _radius;

	/// @func GetClosestPoint(_point)
	///
	/// @desc Computes the closest point on the cylinder surface to a given point.
	///
	/// @param {Struct.BBMOD_Vec3} _point The point to test.
	///
	/// @return {Struct.BBMOD_Vec3} The closest point on the cylinder surface.
	static GetClosestPoint = function (_point)
	{
		gml_pragma("forceinline");

		// Vector from A to B (cylinder axis)
		var _abX = PointB.X - PointA.X;
		var _abY = PointB.Y - PointA.Y;
		var _abZ = PointB.Z - PointA.Z;

		// Vector from A to point
		var _apX = _point.X - PointA.X;
		var _apY = _point.Y - PointA.Y;
		var _apZ = _point.Z - PointA.Z;

		// Project point onto cylinder axis
		var _abLengthSqr = _abX * _abX + _abY * _abY + _abZ * _abZ;
		var _t = (_abLengthSqr != 0.0)
			? clamp((_apX * _abX + _apY * _abY + _apZ * _abZ) / _abLengthSqr, 0.0, 1.0)
			: 0.0;

		// Point on axis at height t
		var _axisX = PointA.X + _abX * _t;
		var _axisY = PointA.Y + _abY * _t;
		var _axisZ = PointA.Z + _abZ * _t;

		// Vector from axis point to input point
		var _toPointX = _point.X - _axisX;
		var _toPointY = _point.Y - _axisY;
		var _toPointZ = _point.Z - _axisZ;

		var _distFromAxis = point_distance_3d(0, 0, 0, _toPointX, _toPointY, _toPointZ);

		if (_distFromAxis < 0.0001)
		{
			// Point is on the axis - return point on cap
			return new BBMOD_Vec3(_axisX + Radius, _axisY, _axisZ);
		}

		// Normalize and scale to radius
		var _invDist = Radius / _distFromAxis;
		return new BBMOD_Vec3(
			_axisX + _toPointX * _invDist,
			_axisY + _toPointY * _invDist,
			_axisZ + _toPointZ * _invDist
		);
	};

	/// @func TestPoint(_point)
	///
	/// @desc Tests if a point is inside the cylinder.
	///
	/// @param {Struct.BBMOD_Vec3} _point The point to test.
	///
	/// @return {Bool} Returns `true` if the point is inside the cylinder.
	static TestPoint = function (_point)
	{
		gml_pragma("forceinline");

		// Vector from A to B (cylinder axis)
		var _abX = PointB.X - PointA.X;
		var _abY = PointB.Y - PointA.Y;
		var _abZ = PointB.Z - PointA.Z;

		// Vector from A to point
		var _apX = _point.X - PointA.X;
		var _apY = _point.Y - PointA.Y;
		var _apZ = _point.Z - PointA.Z;

		// Project point onto cylinder axis
		var _abLengthSqr = _abX * _abX + _abY * _abY + _abZ * _abZ;
		var _t = (_abLengthSqr != 0.0)
			? (_apX * _abX + _apY * _abY + _apZ * _abZ) / _abLengthSqr
			: 0.0;

		// Check if point is within height bounds [0, 1]
		if (_t < 0.0 || _t > 1.0)
		{
			return false;
		}

		// Point on axis at height t
		var _axisX = PointA.X + _abX * _t;
		var _axisY = PointA.Y + _abY * _t;
		var _axisZ = PointA.Z + _abZ * _t;

		// Distance from point to axis
		var _dist = point_distance_3d(_point.X, _point.Y, _point.Z, _axisX, _axisY, _axisZ);

		return (_dist <= Radius);
	};

	/// @func TestSphere(_sphere)
	///
	/// @desc Tests if the cylinder intersects with a sphere.
	///
	/// @param {Struct.BBMOD_SphereCollider} _sphere The sphere to test against.
	///
	/// @return {Bool} Returns `true` if the cylinder intersects the sphere.
	static TestSphere = function (_sphere)
	{
		gml_pragma("forceinline");

		// Vector from A to B (cylinder axis)
		var _abX = PointB.X - PointA.X;
		var _abY = PointB.Y - PointA.Y;
		var _abZ = PointB.Z - PointA.Z;

		// Vector from A to sphere center
		var _apX = _sphere.Position.X - PointA.X;
		var _apY = _sphere.Position.Y - PointA.Y;
		var _apZ = _sphere.Position.Z - PointA.Z;

		// Project sphere center onto cylinder axis
		var _abLengthSqr = _abX * _abX + _abY * _abY + _abZ * _abZ;
		var _t = (_abLengthSqr != 0.0)
			? (_apX * _abX + _apY * _abY + _apZ * _abZ) / _abLengthSqr
			: 0.0;

		// Clamp to cylinder height
		_t = clamp(_t, 0.0, 1.0);

		// Closest point on axis to sphere
		var _axisX = PointA.X + _abX * _t;
		var _axisY = PointA.Y + _abY * _t;
		var _axisZ = PointA.Z + _abZ * _t;

		// Distance from sphere center to axis
		var _dist = point_distance_3d(
			_sphere.Position.X, _sphere.Position.Y, _sphere.Position.Z,
			_axisX, _axisY, _axisZ
		);

		return (_dist <= Radius + _sphere.Radius);
	};

	/// @func TestAABB(_aabb)
	///
	/// @desc Tests if the cylinder intersects with an axis-aligned bounding box.
	///
	/// @param {Struct.BBMOD_AABBCollider} _aabb The AABB to test against.
	///
	/// @return {Bool} Returns `true` if the cylinder intersects the AABB.
	static TestAABB = function (_aabb)
	{
		gml_pragma("forceinline");

		// Conservative test: Get closest point on AABB to cylinder axis
		// Then check if that point is within radius + some tolerance

		// Vector from A to B (cylinder axis)
		var _abX = PointB.X - PointA.X;
		var _abY = PointB.Y - PointA.Y;
		var _abZ = PointB.Z - PointA.Z;

		// Sample several points along cylinder axis and check against AABB
		var _samples = 5;
		for (var i = 0; i <= _samples; ++i)
		{
			var _t = i / _samples;
			var _pX = PointA.X + _abX * _t;
			var _pY = PointA.Y + _abY * _t;
			var _pZ = PointA.Z + _abZ * _t;

			// Clamp point to AABB
			var _closestX = clamp(_pX, _aabb.Min.X, _aabb.Max.X);
			var _closestY = clamp(_pY, _aabb.Min.Y, _aabb.Max.Y);
			var _closestZ = clamp(_pZ, _aabb.Min.Z, _aabb.Max.Z);

			var _dist = point_distance_3d(_pX, _pY, _pZ, _closestX, _closestY, _closestZ);
			if (_dist <= Radius)
			{
				return true;
			}
		}

		return false;
	};

	/// @func TestPlane(_plane)
	///
	/// @desc Tests if the cylinder intersects with a plane.
	///
	/// @param {Struct.BBMOD_PlaneCollider} _plane The plane to test against.
	///
	/// @return {Bool} Returns `true` if the cylinder intersects the plane.
	static TestPlane = function (_plane)
	{
		gml_pragma("forceinline");

		// Distance from both cap centers to plane
		var _distA = _plane.Normal.X * PointA.X + _plane.Normal.Y * PointA.Y
			+ _plane.Normal.Z * PointA.Z + _plane.Distance;
		var _distB = _plane.Normal.X * PointB.X + _plane.Normal.Y * PointB.Y
			+ _plane.Normal.Z * PointB.Z + _plane.Distance;

		// If both endpoints are on same side and farther than radius, no intersection
		if ((_distA > Radius && _distB > Radius) || (_distA < -Radius && _distB < -Radius))
		{
			return false;
		}

		return true;
	};

	/// @func TestFrustum(_frustum)
	///
	/// @desc Tests if the cylinder is inside or intersects with a frustum.
	///
	/// @param {Struct.BBMOD_FrustumCollider} _frustum The frustum to test against.
	///
	/// @return {Bool} Returns `true` if the cylinder is inside the frustum.
	static TestFrustum = function (_frustum)
	{
		gml_pragma("forceinline");

		// Test both cap centers as spheres against all frustum planes
		for (var i = 0; i < BBMOD_EFrustumPlane.SIZE; ++i)
		{
			var _plane = _frustum.Planes[i];
			var _distA = PointA.X * _plane.Normal.X + PointA.Y * _plane.Normal.Y
				+ PointA.Z * _plane.Normal.Z + _plane.Distance;
			var _distB = PointB.X * _plane.Normal.X + PointB.Y * _plane.Normal.Y
				+ PointB.Z * _plane.Normal.Z + _plane.Distance;

			if (_distA < -Radius && _distB < -Radius)
			{
				return false;
			}
		}

		return true;
	};

	/// @func TestCapsule(_capsule)
	///
	/// @desc Tests if the cylinder intersects with a capsule.
	///
	/// @param {Struct.BBMOD_CapsuleCollider} _capsule The capsule to test against.
	///
	/// @return {Bool} Returns `true` if the cylinder intersects the capsule.
	static TestCapsule = function (_capsule)
	{
		gml_pragma("forceinline");

		// Same as capsule-capsule test but with cylinder's flat cap constraints
		// Compute closest distance between two line segments

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

		return (_dist <= Radius + _capsule.Radius);
	};

	/// @func TestTriangle(_triangle)
	///
	/// @desc Tests if the cylinder intersects with a triangle.
	///
	/// @param {Struct.BBMOD_TriangleCollider} _triangle The triangle to test against.
	///
	/// @return {Bool} Returns `true` if the cylinder intersects the triangle.
	static TestTriangle = function (_triangle)
	{
		gml_pragma("forceinline");

		// Conservative test: Get closest point on triangle to cylinder axis
		// Check if that point is within cylinder bounds

		// Test if any triangle vertex is inside cylinder
		if (TestPoint(_triangle.VertexA) || TestPoint(_triangle.VertexB) || TestPoint(_triangle.VertexC))
		{
			return true;
		}

		// Test if cylinder axis intersects triangle (ray-triangle test for axis)
		var _axisDir = new BBMOD_Vec3(
			PointB.X - PointA.X,
			PointB.Y - PointA.Y,
			PointB.Z - PointA.Z
		);
		var _axisRay = new BBMOD_Ray(PointA, _axisDir.Normalize());
		var _rayResult = new BBMOD_RaycastResult();

		if (_triangle.Raycast(_axisRay, _rayResult))
		{
			// Check if hit point is within cylinder height
			var _axisLen = point_distance_3d(PointA.X, PointA.Y, PointA.Z, PointB.X, PointB.Y, PointB.Z);
			if (_rayResult.Distance <= _axisLen)
			{
				return true;
			}
		}

		// Conservative fallback: check if triangle is close to cylinder caps
		var _distA = point_distance_3d(
			_triangle.VertexA.X, _triangle.VertexA.Y, _triangle.VertexA.Z,
			PointA.X, PointA.Y, PointA.Z
		);
		var _distB = point_distance_3d(
			_triangle.VertexA.X, _triangle.VertexA.Y, _triangle.VertexA.Z,
			PointB.X, PointB.Y, PointB.Z
		);

		return (_distA <= Radius || _distB <= Radius);
	};

	/// @func TestOBB(_obb)
	///
	/// @desc Tests if the cylinder intersects with an oriented bounding box.
	///
	/// @param {Struct.BBMOD_OBBCollider} _obb The OBB to test against.
	///
	/// @return {Bool} Returns `true` if the cylinder intersects the OBB.
	static TestOBB = function (_obb)
	{
		gml_pragma("forceinline");

		// Conservative test: Sample points along cylinder axis and test against OBB
		var _abX = PointB.X - PointA.X;
		var _abY = PointB.Y - PointA.Y;
		var _abZ = PointB.Z - PointA.Z;

		var _samples = 5;
		for (var i = 0; i <= _samples; ++i)
		{
			var _t = i / _samples;
			var _testPoint = new BBMOD_Vec3(
				PointA.X + _abX * _t,
				PointA.Y + _abY * _t,
				PointA.Z + _abZ * _t
			);

			// Create temporary sphere at this point with cylinder radius
			var _testSphere = new BBMOD_SphereCollider(_testPoint, Radius);
			if (_obb.TestSphere(_testSphere))
			{
				return true;
			}
		}

		return false;
	};

	/// @func TestLineSegment(_segment)
	///
	/// @desc Tests if the cylinder intersects with a line segment.
	///
	/// @param {Struct.BBMOD_LineSegmentCollider} _segment The line segment to test against.
	///
	/// @return {Bool} Returns `true` if the cylinder intersects the line segment.
	static TestLineSegment = function (_segment)
	{
		gml_pragma("forceinline");
		return _segment.TestCylinder(self);
	};

	/// @func TestCylinder(_cylinder)
	///
	/// @desc Tests if this cylinder intersects with another cylinder.
	///
	/// @param {Struct.BBMOD_CylinderCollider} _cylinder The other cylinder to test against.
	///
	/// @return {Bool} Returns `true` if the cylinders intersect.
	static TestCylinder = function (_cylinder)
	{
		gml_pragma("forceinline");

		// Same as capsule-capsule line segment distance test
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

		return (_dist <= Radius + _cylinder.Radius);
	};

	/// @func TestEllipsoid(_ellipsoid)
	///
	/// @desc Tests if this cylinder intersects with an ellipsoid.
	///
	/// @param {Struct.BBMOD_EllipsoidCollider} _ellipsoid The ellipsoid to test against.
	///
	/// @return {Bool} Returns `true` if the cylinder intersects the ellipsoid.
	static TestEllipsoid = function (_ellipsoid)
	{
		gml_pragma("forceinline");
		return _ellipsoid.TestCylinder(self);
	};

	/// @func TestCone(_cone)
	///
	/// @desc Tests if this cylinder intersects with a cone.
	///
	/// @param {Struct.BBMOD_ConeCollider} _cone The cone to test against.
	///
	/// @return {Bool} Returns `true` if the cylinder intersects the cone.
	static TestCone = function (_cone)
	{
		gml_pragma("forceinline");
		return _cone.TestCylinder(self);
	};

	/// @func Raycast(_ray, _result)
	///
	/// @desc Casts a ray at the cylinder and finds the closest intersection.
	///
	/// @param {Struct.BBMOD_Ray} _ray The ray to cast.
	/// @param {Struct.BBMOD_RaycastResult} _result The raycast result to populate.
	///
	/// @return {Bool} Returns `true` if the ray intersects the cylinder.
	///
	/// @note This uses ray-cylinder body intersection combined with ray-disc
	/// intersection for the flat caps.
	static Raycast = function (_ray, _result)
	{
		gml_pragma("forceinline");

		if (_result != undefined)
		{
			_result.Reset();
		}

		// Cylinder axis direction
		var _axisX = PointB.X - PointA.X;
		var _axisY = PointB.Y - PointA.Y;
		var _axisZ = PointB.Z - PointA.Z;
		var _axisLen = point_distance_3d(0, 0, 0, _axisX, _axisY, _axisZ);

		if (_axisLen < 0.0001)
		{
			return false; // Degenerate cylinder
		}

		// Normalize axis
		var _invLen = 1.0 / _axisLen;
		_axisX *= _invLen;
		_axisY *= _invLen;
		_axisZ *= _invLen;

		// Ray-infinite cylinder intersection
		// Based on: https://www.cl.cam.ac.uk/teaching/1999/AGraphHCI/SMAG/node2.html

		var _deltaX = _ray.Origin.X - PointA.X;
		var _deltaY = _ray.Origin.Y - PointA.Y;
		var _deltaZ = _ray.Origin.Z - PointA.Z;

		// Project ray direction and delta onto plane perpendicular to axis
		var _dotRayAxis = _ray.Direction.X * _axisX + _ray.Direction.Y * _axisY + _ray.Direction.Z * _axisZ;
		var _dotDeltaAxis = _deltaX * _axisX + _deltaY * _axisY + _deltaZ * _axisZ;

		var _dirPerpX = _ray.Direction.X - _axisX * _dotRayAxis;
		var _dirPerpY = _ray.Direction.Y - _axisY * _dotRayAxis;
		var _dirPerpZ = _ray.Direction.Z - _axisZ * _dotRayAxis;

		var _deltaPerpX = _deltaX - _axisX * _dotDeltaAxis;
		var _deltaPerpY = _deltaY - _axisY * _dotDeltaAxis;
		var _deltaPerpZ = _deltaZ - _axisZ * _dotDeltaAxis;

		// Quadratic equation coefficients
		var _a = _dirPerpX * _dirPerpX + _dirPerpY * _dirPerpY + _dirPerpZ * _dirPerpZ;
		var _b = 2.0 * (_dirPerpX * _deltaPerpX + _dirPerpY * _deltaPerpY + _dirPerpZ * _deltaPerpZ);
		var _c = _deltaPerpX * _deltaPerpX + _deltaPerpY * _deltaPerpY + _deltaPerpZ * _deltaPerpZ - Radius
			* Radius;

		var _discriminant = _b * _b - 4.0 * _a * _c;

		if (_discriminant < 0.0)
		{
			return false; // No intersection with infinite cylinder
		}

		var _sqrtDisc = sqrt(_discriminant);
		var _t1 = (-_b - _sqrtDisc) / (2.0 * _a);
		var _t2 = (-_b + _sqrtDisc) / (2.0 * _a);

		var _tBody = _t1;
		if (_tBody < 0.0)
		{
			_tBody = _t2;
		}

		// Check if intersection is within cylinder height
		var _intersectValid = false;
		if (_tBody >= 0.0)
		{
			var _hitX = _ray.Origin.X + _ray.Direction.X * _tBody;
			var _hitY = _ray.Origin.Y + _ray.Direction.Y * _tBody;
			var _hitZ = _ray.Origin.Z + _ray.Direction.Z * _tBody;

			// Check if hit point is between caps
			var _ahX = _hitX - PointA.X;
			var _ahY = _hitY - PointA.Y;
			var _ahZ = _hitZ - PointA.Z;
			var _projection = _ahX * _axisX + _ahY * _axisY + _ahZ * _axisZ;

			if (_projection >= 0.0 && _projection <= _axisLen)
			{
				_intersectValid = true;
				_result.Distance = _tBody;
				_result.Point.X = _hitX;
				_result.Point.Y = _hitY;
				_result.Point.Z = _hitZ;

				// Normal points from axis to hit point
				var _axisPointX = PointA.X + _axisX * _projection;
				var _axisPointY = PointA.Y + _axisY * _projection;
				var _axisPointZ = PointA.Z + _axisZ * _projection;

				var _normalX = _hitX - _axisPointX;
				var _normalY = _hitY - _axisPointY;
				var _normalZ = _hitZ - _axisPointZ;
				var _normalLen = point_distance_3d(0, 0, 0, _normalX, _normalY, _normalZ);

				if (_normalLen > 0.0001)
				{
					var _invNormalLen = 1.0 / _normalLen;
					_result.Normal.X = _normalX * _invNormalLen;
					_result.Normal.Y = _normalY * _invNormalLen;
					_result.Normal.Z = _normalZ * _invNormalLen;
				}
				else
				{
					_result.Normal.X = 0.0;
					_result.Normal.Y = 1.0;
					_result.Normal.Z = 0.0;
				}
			}
		}

		// Test ray against flat caps (ray-disc intersection)
		// Cap A
		var _planeDistA = _axisX * PointA.X + _axisY * PointA.Y + _axisZ * PointA.Z;
		var _planeDot = _ray.Direction.X * _axisX + _ray.Direction.Y * _axisY + _ray.Direction.Z * _axisZ;

		if (abs(_planeDot) > 0.0001)
		{
			var _tCapA = (_planeDistA - (_ray.Origin.X * _axisX + _ray.Origin.Y * _axisY + _ray.Origin.Z
				* _axisZ)) / _planeDot;

			if (_tCapA >= 0.0 && (!_intersectValid || _tCapA < _result.Distance))
			{
				var _capHitX = _ray.Origin.X + _ray.Direction.X * _tCapA;
				var _capHitY = _ray.Origin.Y + _ray.Direction.Y * _tCapA;
				var _capHitZ = _ray.Origin.Z + _ray.Direction.Z * _tCapA;

				var _distFromCenter = point_distance_3d(_capHitX, _capHitY, _capHitZ, PointA.X, PointA.Y, PointA
					.Z);
				if (_distFromCenter <= Radius)
				{
					_intersectValid = true;
					_result.Distance = _tCapA;
					_result.Point.X = _capHitX;
					_result.Point.Y = _capHitY;
					_result.Point.Z = _capHitZ;
					_result.Normal.X = -_axisX;
					_result.Normal.Y = -_axisY;
					_result.Normal.Z = -_axisZ;
				}
			}
		}

		// Cap B
		var _planeDistB = _axisX * PointB.X + _axisY * PointB.Y + _axisZ * PointB.Z;

		if (abs(_planeDot) > 0.0001)
		{
			var _tCapB = (_planeDistB - (_ray.Origin.X * _axisX + _ray.Origin.Y * _axisY + _ray.Origin.Z
				* _axisZ)) / _planeDot;

			if (_tCapB >= 0.0 && (!_intersectValid || _tCapB < _result.Distance))
			{
				var _capHitX = _ray.Origin.X + _ray.Direction.X * _tCapB;
				var _capHitY = _ray.Origin.Y + _ray.Direction.Y * _tCapB;
				var _capHitZ = _ray.Origin.Z + _ray.Direction.Z * _tCapB;

				var _distFromCenter = point_distance_3d(_capHitX, _capHitY, _capHitZ, PointB.X, PointB.Y, PointB
					.Z);
				if (_distFromCenter <= Radius)
				{
					_intersectValid = true;
					_result.Distance = _tCapB;
					_result.Point.X = _capHitX;
					_result.Point.Y = _capHitY;
					_result.Point.Z = _capHitZ;
					_result.Normal.X = _axisX;
					_result.Normal.Y = _axisY;
					_result.Normal.Z = _axisZ;
				}
			}
		}

		return _intersectValid;
	};

	/// @func DrawDebug([_color[, _alpha]])
	///
	/// @desc Draws a debug visualization of the cylinder.
	///
	/// @param {Constant.Color} [_color] The color of the cylinder. Defaults to
	/// `c_white`.
	/// @param {Real} [_alpha] The alpha value of the cylinder. Defaults to 1.
	static DrawDebug = function (_color = c_white, _alpha = 1.0)
	{
		gml_pragma("forceinline");

		var _vbuffer = global.__bbmodVBufferDebug;

		// Get cylinder axis
		var _axisX = PointB.X - PointA.X;
		var _axisY = PointB.Y - PointA.Y;
		var _axisZ = PointB.Z - PointA.Z;
		var _axisLen = point_distance_3d(0, 0, 0, _axisX, _axisY, _axisZ);

		if (_axisLen < 0.0001)
		{
			return self; // Degenerate cylinder
		}

		// Normalize axis
		_axisX /= _axisLen;
		_axisY /= _axisLen;
		_axisZ /= _axisLen;

		// Get perpendicular vectors for circle generation
		var _perpX, _perpY, _perpZ;
		if (abs(_axisX) < 0.9)
		{
			_perpX = -_axisZ;
			_perpY = 0.0;
			_perpZ = _axisX;
		}
		else
		{
			_perpX = 0.0;
			_perpY = _axisZ;
			_perpZ = -_axisY;
		}

		// Normalize perpendicular
		var _perpLen = point_distance_3d(0, 0, 0, _perpX, _perpY, _perpZ);
		_perpX /= _perpLen;
		_perpY /= _perpLen;
		_perpZ /= _perpLen;

		// Get second perpendicular (cross product of axis and first perp)
		var _perp2X = _axisY * _perpZ - _axisZ * _perpY;
		var _perp2Y = _axisZ * _perpX - _axisX * _perpZ;
		var _perp2Z = _axisX * _perpY - _axisY * _perpX;

		vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

		var _steps = 16;
		var _inc = 360.0 / _steps;
		var _angle = 0.0;

		repeat(_steps)
		{
			var _cos1 = dcos(_angle);
			var _sin1 = dsin(_angle);
			var _cos2 = dcos(_angle + _inc);
			var _sin2 = dsin(_angle + _inc);

			// Circle at cap A
			var _p1X = PointA.X + (_perpX * _cos1 + _perp2X * _sin1) * Radius;
			var _p1Y = PointA.Y + (_perpY * _cos1 + _perp2Y * _sin1) * Radius;
			var _p1Z = PointA.Z + (_perpZ * _cos1 + _perp2Z * _sin1) * Radius;

			var _p2X = PointA.X + (_perpX * _cos2 + _perp2X * _sin2) * Radius;
			var _p2Y = PointA.Y + (_perpY * _cos2 + _perp2Y * _sin2) * Radius;
			var _p2Z = PointA.Z + (_perpZ * _cos2 + _perp2Z * _sin2) * Radius;

			vertex_position_3d(_vbuffer, _p1X, _p1Y, _p1Z);
			vertex_color(_vbuffer, _color, _alpha);
			vertex_position_3d(_vbuffer, _p2X, _p2Y, _p2Z);
			vertex_color(_vbuffer, _color, _alpha);

			// Circle at cap B
			var _p3X = PointB.X + (_perpX * _cos1 + _perp2X * _sin1) * Radius;
			var _p3Y = PointB.Y + (_perpY * _cos1 + _perp2Y * _sin1) * Radius;
			var _p3Z = PointB.Z + (_perpZ * _cos1 + _perp2Z * _sin1) * Radius;

			var _p4X = PointB.X + (_perpX * _cos2 + _perp2X * _sin2) * Radius;
			var _p4Y = PointB.Y + (_perpY * _cos2 + _perp2Y * _sin2) * Radius;
			var _p4Z = PointB.Z + (_perpZ * _cos2 + _perp2Z * _sin2) * Radius;

			vertex_position_3d(_vbuffer, _p3X, _p3Y, _p3Z);
			vertex_color(_vbuffer, _color, _alpha);
			vertex_position_3d(_vbuffer, _p4X, _p4Y, _p4Z);
			vertex_color(_vbuffer, _color, _alpha);

			// Connecting lines (draw every 4th to avoid clutter)
			if (_angle == 0.0 || _angle == 90.0 || _angle == 180.0 || _angle == 270.0)
			{
				vertex_position_3d(_vbuffer, _p1X, _p1Y, _p1Z);
				vertex_color(_vbuffer, _color, _alpha);
				vertex_position_3d(_vbuffer, _p3X, _p3Y, _p3Z);
				vertex_color(_vbuffer, _color, _alpha);
			}

			_angle += _inc;
		}

		vertex_end(_vbuffer);
		vertex_submit(_vbuffer, pr_linelist, -1);

		return self;
	};
}
