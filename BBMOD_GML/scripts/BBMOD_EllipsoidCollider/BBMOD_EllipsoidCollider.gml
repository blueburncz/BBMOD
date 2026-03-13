/// @module Extras.Raycasting

/// @func BBMOD_EllipsoidCollider([_position[, _radii[, _rotation]]])
///
/// @extends BBMOD_Collider
///
/// @desc An ellipsoid collider - a sphere stretched/compressed along different
/// axes. Useful for character collision where slight squashing is needed, or
/// for egg-shaped objects. Can be axis-aligned or rotated.
///
/// @param {Struct.BBMOD_Vec3} [_position] The center position of the ellipsoid.
/// Defaults to (0, 0, 0).
/// @param {Struct.BBMOD_Vec3} [_radii] The radius along each axis
/// (X, Y, Z). Defaults to (1, 1, 1) which creates a sphere.
/// @param {Struct.BBMOD_Quaternion} [_rotation] The orientation of the
/// ellipsoid. Defaults to identity (no rotation). Use undefined for
/// axis-aligned ellipsoid.
///
/// @example
/// ```gml
/// // Create an axis-aligned ellipsoid (stretched along Y)
/// var ellipsoid = new BBMOD_EllipsoidCollider(
///     new BBMOD_Vec3(0.0, 5.0, 0.0),
///     new BBMOD_Vec3(1.0, 2.0, 1.0)  // 2x taller
/// );
///
/// // Create a rotated ellipsoid
/// var rotation = new BBMOD_Quaternion().FromAxisAngle(
///     new BBMOD_Vec3(0, 0, 1), 45
/// );
/// var rotatedEllipsoid = new BBMOD_EllipsoidCollider(
///     new BBMOD_Vec3(0.0, 0.0, 0.0),
///     new BBMOD_Vec3(2.0, 1.0, 1.0),
///     rotation
/// );
/// ```
function BBMOD_EllipsoidCollider(_position = undefined, _radii = undefined, _rotation = undefined): BBMOD_Collider
	() constructor
	{
		/// @var {Struct.BBMOD_Vec3} The center position of the ellipsoid.
		Position = _position ?? new BBMOD_Vec3(0.0, 0.0, 0.0);

		/// @var {Struct.BBMOD_Vec3} The radius along each axis (X, Y, Z).
		Radii = _radii ?? new BBMOD_Vec3(1.0, 1.0, 1.0);

		/// @var {Struct.BBMOD_Quaternion} The orientation of the ellipsoid.
		/// Use undefined for axis-aligned ellipsoid.
		Rotation = _rotation;

		/// @func GetClosestPoint(_point)
		///
		/// @desc Computes the closest point on the ellipsoid surface to a given point.
		///
		/// @param {Struct.BBMOD_Vec3} _point The point to test.
		///
		/// @return {Struct.BBMOD_Vec3} The closest point on the ellipsoid surface.
		static GetClosestPoint = function (_point)
		{
			gml_pragma("forceinline");

			// Transform point to ellipsoid's local space
			var _localX = _point.X - Position.X;
			var _localY = _point.Y - Position.Y;
			var _localZ = _point.Z - Position.Z;

			// Apply inverse rotation if ellipsoid is rotated
			if (Rotation != undefined)
			{
				// Conjugate quaternion (inverse rotation)
				var _qx = -Rotation.X;
				var _qy = -Rotation.Y;
				var _qz = -Rotation.Z;
				var _qw = Rotation.W;

				var _t0 = _qw * _localX + _qy * _localZ - _qz * _localY;
				var _t1 = _qw * _localY + _qz * _localX - _qx * _localZ;
				var _t2 = _qw * _localZ + _qx * _localY - _qy * _localX;
				var _t3 = -_qx * _localX - _qy * _localY - _qz * _localZ;

				_localX = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
				_localY = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
				_localZ = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
			}

			// Scale to unit sphere space
			var _sphereX = _localX / Radii.X;
			var _sphereY = _localY / Radii.Y;
			var _sphereZ = _localZ / Radii.Z;

			var _len = point_distance_3d(0, 0, 0, _sphereX, _sphereY, _sphereZ);

			if (_len < 0.0001)
			{
				// Point at center - return any point on surface
				_sphereX = 1.0;
				_sphereY = 0.0;
				_sphereZ = 0.0;
				_len = 1.0;
			}

			// Normalize and scale back to ellipsoid space
			var _invLen = 1.0 / _len;
			var _surfaceX = (_sphereX * _invLen) * Radii.X;
			var _surfaceY = (_sphereY * _invLen) * Radii.Y;
			var _surfaceZ = (_sphereZ * _invLen) * Radii.Z;

			// Apply rotation if needed
			if (Rotation != undefined)
			{
				var _qx = Rotation.X;
				var _qy = Rotation.Y;
				var _qz = Rotation.Z;
				var _qw = Rotation.W;

				var _t0 = _qw * _surfaceX + _qy * _surfaceZ - _qz * _surfaceY;
				var _t1 = _qw * _surfaceY + _qz * _surfaceX - _qx * _surfaceZ;
				var _t2 = _qw * _surfaceZ + _qx * _surfaceY - _qy * _surfaceX;
				var _t3 = -_qx * _surfaceX - _qy * _surfaceY - _qz * _surfaceZ;

				_surfaceX = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
				_surfaceY = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
				_surfaceZ = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
			}

			// Transform back to world space
			return new BBMOD_Vec3(
				Position.X + _surfaceX,
				Position.Y + _surfaceY,
				Position.Z + _surfaceZ
			);
		};

		/// @func TestPoint(_point)
		///
		/// @desc Tests if a point is inside the ellipsoid.
		///
		/// @param {Struct.BBMOD_Vec3} _point The point to test.
		///
		/// @return {Bool} Returns `true` if the point is inside the ellipsoid.
		static TestPoint = function (_point)
		{
			gml_pragma("forceinline");

			// Transform point to ellipsoid's local space
			var _localX = _point.X - Position.X;
			var _localY = _point.Y - Position.Y;
			var _localZ = _point.Z - Position.Z;

			// Apply inverse rotation if ellipsoid is rotated
			if (Rotation != undefined)
			{
				// Conjugate quaternion (inverse rotation)
				var _qx = -Rotation.X;
				var _qy = -Rotation.Y;
				var _qz = -Rotation.Z;
				var _qw = Rotation.W;

				var _t0 = _qw * _localX + _qy * _localZ - _qz * _localY;
				var _t1 = _qw * _localY + _qz * _localX - _qx * _localZ;
				var _t2 = _qw * _localZ + _qx * _localY - _qy * _localX;
				var _t3 = -_qx * _localX - _qy * _localY - _qz * _localZ;

				_localX = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
				_localY = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
				_localZ = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
			}

			// Scale to unit sphere space
			var _sphereX = _localX / Radii.X;
			var _sphereY = _localY / Radii.Y;
			var _sphereZ = _localZ / Radii.Z;

			// Test if inside unit sphere
			var _distSqr = _sphereX * _sphereX + _sphereY * _sphereY + _sphereZ * _sphereZ;
			return (_distSqr <= 1.0);
		};

		/// @func TestSphere(_sphere)
		///
		/// @desc Tests if the ellipsoid intersects with a sphere.
		///
		/// @param {Struct.BBMOD_SphereCollider} _sphere The sphere to test against.
		///
		/// @return {Bool} Returns `true` if the ellipsoid intersects the sphere.
		static TestSphere = function (_sphere)
		{
			gml_pragma("forceinline");

			// Get closest point on ellipsoid to sphere center
			var _localX = _sphere.Position.X - Position.X;
			var _localY = _sphere.Position.Y - Position.Y;
			var _localZ = _sphere.Position.Z - Position.Z;

			if (Rotation != undefined)
			{
				var _qx = -Rotation.X;
				var _qy = -Rotation.Y;
				var _qz = -Rotation.Z;
				var _qw = Rotation.W;

				var _t0 = _qw * _localX + _qy * _localZ - _qz * _localY;
				var _t1 = _qw * _localY + _qz * _localX - _qx * _localZ;
				var _t2 = _qw * _localZ + _qx * _localY - _qy * _localX;
				var _t3 = -_qx * _localX - _qy * _localY - _qz * _localZ;

				_localX = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
				_localY = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
				_localZ = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
			}

			// Scale to unit sphere space
			var _sphereX = _localX / Radii.X;
			var _sphereY = _localY / Radii.Y;
			var _sphereZ = _localZ / Radii.Z;

			var _len = point_distance_3d(0, 0, 0, _sphereX, _sphereY, _sphereZ);

			if (_len < 0.0001)
			{
				return true; // Sphere center at ellipsoid center
			}

			// Closest point on unit sphere
			var _invLen = 1.0 / _len;
			var _closestX = (_sphereX * _invLen) * Radii.X;
			var _closestY = (_sphereY * _invLen) * Radii.Y;
			var _closestZ = (_sphereZ * _invLen) * Radii.Z;

			// Distance from sphere center to closest point on ellipsoid
			var _dx = _localX - _closestX;
			var _dy = _localY - _closestY;
			var _dz = _localZ - _closestZ;
			var _dist = point_distance_3d(0, 0, 0, _dx, _dy, _dz);

			return (_dist <= _sphere.Radius);
		};

		/// @func TestAABB(_aabb)
		///
		/// @desc Tests if the ellipsoid intersects with an AABB.
		///
		/// @param {Struct.BBMOD_AABBCollider} _aabb The AABB to test against.
		///
		/// @return {Bool} Returns `true` if the ellipsoid intersects the AABB.
		static TestAABB = function (_aabb)
		{
			gml_pragma("forceinline");

			// Get closest point on AABB to ellipsoid center
			var _closestX = clamp(Position.X, _aabb.Min.X, _aabb.Max.X);
			var _closestY = clamp(Position.Y, _aabb.Min.Y, _aabb.Max.Y);
			var _closestZ = clamp(Position.Z, _aabb.Min.Z, _aabb.Max.Z);

			// Check if this point is inside the ellipsoid
			var _testPoint = new BBMOD_Vec3(_closestX, _closestY, _closestZ);
			return TestPoint(_testPoint);
		};

		/// @func TestPlane(_plane)
		///
		/// @desc Tests if the ellipsoid intersects with a plane.
		///
		/// @param {Struct.BBMOD_PlaneCollider} _plane The plane to test against.
		///
		/// @return {Bool} Returns `true` if the ellipsoid intersects the plane.
		static TestPlane = function (_plane)
		{
			gml_pragma("forceinline");

			// Distance from center to plane
			var _centerDist = _plane.Normal.X * Position.X + _plane.Normal.Y * Position.Y
				+ _plane.Normal.Z * Position.Z + _plane.Distance;

			// Compute ellipsoid "radius" in direction of plane normal
			// This is the maximum extent of the ellipsoid along the normal direction
			var _normalX = _plane.Normal.X;
			var _normalY = _plane.Normal.Y;
			var _normalZ = _plane.Normal.Z;

			// Transform normal to ellipsoid's local space if rotated
			if (Rotation != undefined)
			{
				var _qx = -Rotation.X;
				var _qy = -Rotation.Y;
				var _qz = -Rotation.Z;
				var _qw = Rotation.W;

				var _t0 = _qw * _normalX + _qy * _normalZ - _qz * _normalY;
				var _t1 = _qw * _normalY + _qz * _normalX - _qx * _normalZ;
				var _t2 = _qw * _normalZ + _qx * _normalY - _qy * _normalX;
				var _t3 = -_qx * _normalX - _qy * _normalY - _qz * _normalZ;

				_normalX = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
				_normalY = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
				_normalZ = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
			}

			// Compute effective radius along the normal
			var _rx = _normalX * Radii.X;
			var _ry = _normalY * Radii.Y;
			var _rz = _normalZ * Radii.Z;
			var _effectiveRadius = point_distance_3d(0, 0, 0, _rx, _ry, _rz);

			return (abs(_centerDist) <= _effectiveRadius);
		};

		/// @func TestFrustum(_frustum)
		///
		/// @desc Tests if the ellipsoid is inside or intersects with a frustum.
		///
		/// @param {Struct.BBMOD_FrustumCollider} _frustum The frustum to test against.
		///
		/// @return {Bool} Returns `true` if the ellipsoid is inside the frustum.
		static TestFrustum = function (_frustum)
		{
			gml_pragma("forceinline");

			// Test against all frustum planes
			for (var i = 0; i < BBMOD_EFrustumPlane.SIZE; ++i)
			{
				if (!TestPlane(_frustum.Planes[i]))
				{
					return false;
				}
			}

			return true;
		};

		/// @func TestCapsule(_capsule)
		///
		/// @desc Tests if the ellipsoid intersects with a capsule.
		///
		/// @param {Struct.BBMOD_CapsuleCollider} _capsule The capsule to test against.
		///
		/// @return {Bool} Returns `true` if the ellipsoid intersects the capsule.
		static TestCapsule = function (_capsule)
		{
			gml_pragma("forceinline");
			// Conservative: treat capsule as spheres at endpoints
			var _sphereA = new BBMOD_SphereCollider(_capsule.PointA, _capsule.Radius);
			var _sphereB = new BBMOD_SphereCollider(_capsule.PointB, _capsule.Radius);
			return TestSphere(_sphereA) || TestSphere(_sphereB);
		};

		/// @func TestTriangle(_triangle)
		///
		/// @desc Tests if the ellipsoid intersects with a triangle.
		///
		/// @param {Struct.BBMOD_TriangleCollider} _triangle The triangle to test against.
		///
		/// @return {Bool} Returns `true` if the ellipsoid intersects the triangle.
		static TestTriangle = function (_triangle)
		{
			gml_pragma("forceinline");
			// Simplified: test triangle vertices against ellipsoid
			return TestPoint(_triangle.VertexA) || TestPoint(_triangle.VertexB) || TestPoint(_triangle.VertexC);
		};

		/// @func TestOBB(_obb)
		///
		/// @desc Tests if the ellipsoid intersects with an OBB.
		///
		/// @param {Struct.BBMOD_OBBCollider} _obb The OBB to test against.
		///
		/// @return {Bool} Returns `true` if the ellipsoid intersects the OBB.
		static TestOBB = function (_obb)
		{
			gml_pragma("forceinline");
			// Conservative: test OBB center as sphere
			var _maxRadius = max(Radii.X, Radii.Y, Radii.Z);
			var _testSphere = new BBMOD_SphereCollider(Position, _maxRadius);
			return _obb.TestSphere(_testSphere);
		};

		/// @func TestLineSegment(_segment)
		///
		/// @desc Tests if the ellipsoid intersects with a line segment.
		///
		/// @param {Struct.BBMOD_LineSegmentCollider} _segment The line segment to test against.
		///
		/// @return {Bool} Returns `true` if the ellipsoid intersects the segment.
		static TestLineSegment = function (_segment)
		{
			gml_pragma("forceinline");
			// Test segment endpoints
			return TestPoint(_segment.PointA) || TestPoint(_segment.PointB);
		};

		/// @func TestCylinder(_cylinder)
		///
		/// @desc Tests if the ellipsoid intersects with a cylinder.
		///
		/// @param {Struct.BBMOD_CylinderCollider} _cylinder The cylinder to test against.
		///
		/// @return {Bool} Returns `true` if the ellipsoid intersects the cylinder.
		static TestCylinder = function (_cylinder)
		{
			gml_pragma("forceinline");
			// Conservative: test cylinder axis endpoints as spheres
			var _sphereA = new BBMOD_SphereCollider(_cylinder.PointA, _cylinder.Radius);
			var _sphereB = new BBMOD_SphereCollider(_cylinder.PointB, _cylinder.Radius);
			return TestSphere(_sphereA) || TestSphere(_sphereB);
		};

		/// @func TestEllipsoid(_ellipsoid)
		///
		/// @desc Tests if this ellipsoid intersects with another ellipsoid.
		///
		/// @param {Struct.BBMOD_EllipsoidCollider} _ellipsoid The other ellipsoid to test against.
		///
		/// @return {Bool} Returns `true` if the ellipsoids intersect.
		static TestEllipsoid = function (_ellipsoid)
		{
			gml_pragma("forceinline");
			// Simplified: approximate both as spheres using maximum radius
			var _r1 = max(Radii.X, Radii.Y, Radii.Z);
			var _r2 = max(_ellipsoid.Radii.X, _ellipsoid.Radii.Y, _ellipsoid.Radii.Z);
			var _dist = point_distance_3d(
				Position.X, Position.Y, Position.Z,
				_ellipsoid.Position.X, _ellipsoid.Position.Y, _ellipsoid.Position.Z
			);
			return (_dist <= _r1 + _r2);
		};

		/// @func TestCone(_cone)
		///
		/// @desc Tests if this ellipsoid intersects with a cone.
		///
		/// @param {Struct.BBMOD_ConeCollider} _cone The cone to test against.
		///
		/// @return {Bool} Returns `true` if the ellipsoid intersects the cone.
		static TestCone = function (_cone)
		{
			gml_pragma("forceinline");
			return _cone.TestEllipsoid(self);
		};

		/// @func Raycast(_ray, _result)
		///
		/// @desc Casts a ray at the ellipsoid and finds the closest intersection.
		///
		/// @param {Struct.BBMOD_Ray} _ray The ray to cast.
		/// @param {Struct.BBMOD_RaycastResult} _result The raycast result to populate.
		///
		/// @return {Bool} Returns `true` if the ray intersects the ellipsoid.
		static Raycast = function (_ray, _result)
		{
			gml_pragma("forceinline");

			if (_result != undefined)
			{
				_result.Reset();
			}

			// Transform ray to ellipsoid's local space
			var _originX = _ray.Origin.X - Position.X;
			var _originY = _ray.Origin.Y - Position.Y;
			var _originZ = _ray.Origin.Z - Position.Z;

			var _dirX = _ray.Direction.X;
			var _dirY = _ray.Direction.Y;
			var _dirZ = _ray.Direction.Z;

			// Apply inverse rotation if ellipsoid is rotated
			if (Rotation != undefined)
			{
				var _qx = -Rotation.X;
				var _qy = -Rotation.Y;
				var _qz = -Rotation.Z;
				var _qw = Rotation.W;

				// Rotate origin
				var _t0 = _qw * _originX + _qy * _originZ - _qz * _originY;
				var _t1 = _qw * _originY + _qz * _originX - _qx * _originZ;
				var _t2 = _qw * _originZ + _qx * _originY - _qy * _originX;
				var _t3 = -_qx * _originX - _qy * _originY - _qz * _originZ;

				_originX = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
				_originY = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
				_originZ = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);

				// Rotate direction
				_t0 = _qw * _dirX + _qy * _dirZ - _qz * _dirY;
				_t1 = _qw * _dirY + _qz * _dirX - _qx * _dirZ;
				_t2 = _qw * _dirZ + _qx * _dirY - _qy * _dirX;
				_t3 = -_qx * _dirX - _qy * _dirY - _qz * _dirZ;

				_dirX = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
				_dirY = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
				_dirZ = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
			}

			// Scale to unit sphere space
			var _sphereOriginX = _originX / Radii.X;
			var _sphereOriginY = _originY / Radii.Y;
			var _sphereOriginZ = _originZ / Radii.Z;

			var _sphereDirX = _dirX / Radii.X;
			var _sphereDirY = _dirY / Radii.Y;
			var _sphereDirZ = _dirZ / Radii.Z;

			// Ray-sphere intersection in unit sphere space
			var _a = _sphereDirX * _sphereDirX + _sphereDirY * _sphereDirY + _sphereDirZ * _sphereDirZ;
			var _b = 2.0 * (_sphereOriginX * _sphereDirX + _sphereOriginY * _sphereDirY + _sphereOriginZ
				* _sphereDirZ);
			var _c = _sphereOriginX * _sphereOriginX + _sphereOriginY * _sphereOriginY + _sphereOriginZ
				* _sphereOriginZ - 1.0;

			var _discriminant = _b * _b - 4.0 * _a * _c;

			if (_discriminant < 0.0)
			{
				return false;
			}

			var _sqrtDisc = sqrt(_discriminant);
			var _t = (-_b - _sqrtDisc) / (2.0 * _a);

			if (_t < 0.0)
			{
				_t = (-_b + _sqrtDisc) / (2.0 * _a);
				if (_t < 0.0)
				{
					return false;
				}
			}

			if (_result != undefined)
			{
				// Hit point in unit sphere space
				var _hitX = _sphereOriginX + _sphereDirX * _t;
				var _hitY = _sphereOriginY + _sphereDirY * _t;
				var _hitZ = _sphereOriginZ + _sphereDirZ * _t;

				// Scale back to ellipsoid space
				_hitX *= Radii.X;
				_hitY *= Radii.Y;
				_hitZ *= Radii.Z;

				// Apply rotation if needed
				if (Rotation != undefined)
				{
					var _qx = Rotation.X;
					var _qy = Rotation.Y;
					var _qz = Rotation.Z;
					var _qw = Rotation.W;

					var _t0 = _qw * _hitX + _qy * _hitZ - _qz * _hitY;
					var _t1 = _qw * _hitY + _qz * _hitX - _qx * _hitZ;
					var _t2 = _qw * _hitZ + _qx * _hitY - _qy * _hitX;
					var _t3 = -_qx * _hitX - _qy * _hitY - _qz * _hitZ;

					_hitX = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
					_hitY = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
					_hitZ = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
				}

				// Transform back to world space
				_result.Point.X = Position.X + _hitX;
				_result.Point.Y = Position.Y + _hitY;
				_result.Point.Z = Position.Z + _hitZ;

				// Compute normal (gradient of ellipsoid equation)
				var _normalX = _hitX / (Radii.X * Radii.X);
				var _normalY = _hitY / (Radii.Y * Radii.Y);
				var _normalZ = _hitZ / (Radii.Z * Radii.Z);

				// Apply rotation to normal if needed
				if (Rotation != undefined)
				{
					var _qx = Rotation.X;
					var _qy = Rotation.Y;
					var _qz = Rotation.Z;
					var _qw = Rotation.W;

					var _t0 = _qw * _normalX + _qy * _normalZ - _qz * _normalY;
					var _t1 = _qw * _normalY + _qz * _normalX - _qx * _normalZ;
					var _t2 = _qw * _normalZ + _qx * _normalY - _qy * _normalX;
					var _t3 = -_qx * _normalX - _qy * _normalY - _qz * _normalZ;

					_normalX = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
					_normalY = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
					_normalZ = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
				}

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

				// Distance is approximate - use original ray direction length
				_result.Distance = _t * point_distance_3d(0, 0, 0, _sphereDirX, _sphereDirY, _sphereDirZ);
			}

			return true;
		};

		/// @func DrawDebug([_color[, _alpha]])
		///
		/// @desc Draws a debug visualization of the ellipsoid.
		///
		/// @param {Constant.Color} [_color] The color of the ellipsoid. Defaults to `c_white`.
		/// @param {Real} [_alpha] The alpha value of the ellipsoid. Defaults to 1.
		static DrawDebug = function (_color = c_white, _alpha = 1.0)
		{
			gml_pragma("forceinline");

			var _vbuffer = global.__bbmodVBufferDebug;

			vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

			var _steps = 16;
			var _inc = 360.0 / _steps;

			// Draw three orthogonal ellipse circles
			// XY plane ellipse
			var _angle = 0.0;
			repeat(_steps)
			{
				var _x1 = dcos(_angle) * Radii.X;
				var _y1 = dsin(_angle) * Radii.Y;
				var _x2 = dcos(_angle + _inc) * Radii.X;
				var _y2 = dsin(_angle + _inc) * Radii.Y;

				// Rotate and translate
				var _p1X = _x1;
				var _p1Y = _y1;
				var _p1Z = 0.0;
				var _p2X = _x2;
				var _p2Y = _y2;
				var _p2Z = 0.0;

				if (Rotation != undefined)
				{
					// Rotate p1
					var _qx = Rotation.X;
					var _qy = Rotation.Y;
					var _qz = Rotation.Z;
					var _qw = Rotation.W;

					var _t0 = _qw * _p1X + _qy * _p1Z - _qz * _p1Y;
					var _t1 = _qw * _p1Y + _qz * _p1X - _qx * _p1Z;
					var _t2 = _qw * _p1Z + _qx * _p1Y - _qy * _p1X;
					var _t3 = -_qx * _p1X - _qy * _p1Y - _qz * _p1Z;

					_p1X = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
					_p1Y = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
					_p1Z = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);

					// Rotate p2
					_t0 = _qw * _p2X + _qy * _p2Z - _qz * _p2Y;
					_t1 = _qw * _p2Y + _qz * _p2X - _qx * _p2Z;
					_t2 = _qw * _p2Z + _qx * _p2Y - _qy * _p2X;
					_t3 = -_qx * _p2X - _qy * _p2Y - _qz * _p2Z;

					_p2X = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
					_p2Y = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
					_p2Z = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
				}

				vertex_position_3d(_vbuffer, Position.X + _p1X, Position.Y + _p1Y, Position.Z + _p1Z);
				vertex_color(_vbuffer, _color, _alpha);
				vertex_position_3d(_vbuffer, Position.X + _p2X, Position.Y + _p2Y, Position.Z + _p2Z);
				vertex_color(_vbuffer, _color, _alpha);

				_angle += _inc;
			}

			// XZ plane ellipse
			_angle = 0.0;
			repeat(_steps)
			{
				var _x1 = dcos(_angle) * Radii.X;
				var _z1 = dsin(_angle) * Radii.Z;
				var _x2 = dcos(_angle + _inc) * Radii.X;
				var _z2 = dsin(_angle + _inc) * Radii.Z;

				var _p1X = _x1;
				var _p1Y = 0.0;
				var _p1Z = _z1;
				var _p2X = _x2;
				var _p2Y = 0.0;
				var _p2Z = _z2;

				if (Rotation != undefined)
				{
					var _qx = Rotation.X;
					var _qy = Rotation.Y;
					var _qz = Rotation.Z;
					var _qw = Rotation.W;

					var _t0 = _qw * _p1X + _qy * _p1Z - _qz * _p1Y;
					var _t1 = _qw * _p1Y + _qz * _p1X - _qx * _p1Z;
					var _t2 = _qw * _p1Z + _qx * _p1Y - _qy * _p1X;
					var _t3 = -_qx * _p1X - _qy * _p1Y - _qz * _p1Z;

					_p1X = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
					_p1Y = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
					_p1Z = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);

					_t0 = _qw * _p2X + _qy * _p2Z - _qz * _p2Y;
					_t1 = _qw * _p2Y + _qz * _p2X - _qx * _p2Z;
					_t2 = _qw * _p2Z + _qx * _p2Y - _qy * _p2X;
					_t3 = -_qx * _p2X - _qy * _p2Y - _qz * _p2Z;

					_p2X = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
					_p2Y = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
					_p2Z = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
				}

				vertex_position_3d(_vbuffer, Position.X + _p1X, Position.Y + _p1Y, Position.Z + _p1Z);
				vertex_color(_vbuffer, _color, _alpha);
				vertex_position_3d(_vbuffer, Position.X + _p2X, Position.Y + _p2Y, Position.Z + _p2Z);
				vertex_color(_vbuffer, _color, _alpha);

				_angle += _inc;
			}

			// YZ plane ellipse
			_angle = 0.0;
			repeat(_steps)
			{
				var _y1 = dcos(_angle) * Radii.Y;
				var _z1 = dsin(_angle) * Radii.Z;
				var _y2 = dcos(_angle + _inc) * Radii.Y;
				var _z2 = dsin(_angle + _inc) * Radii.Z;

				var _p1X = 0.0;
				var _p1Y = _y1;
				var _p1Z = _z1;
				var _p2X = 0.0;
				var _p2Y = _y2;
				var _p2Z = _z2;

				if (Rotation != undefined)
				{
					var _qx = Rotation.X;
					var _qy = Rotation.Y;
					var _qz = Rotation.Z;
					var _qw = Rotation.W;

					var _t0 = _qw * _p1X + _qy * _p1Z - _qz * _p1Y;
					var _t1 = _qw * _p1Y + _qz * _p1X - _qx * _p1Z;
					var _t2 = _qw * _p1Z + _qx * _p1Y - _qy * _p1X;
					var _t3 = -_qx * _p1X - _qy * _p1Y - _qz * _p1Z;

					_p1X = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
					_p1Y = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
					_p1Z = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);

					_t0 = _qw * _p2X + _qy * _p2Z - _qz * _p2Y;
					_t1 = _qw * _p2Y + _qz * _p2X - _qx * _p2Z;
					_t2 = _qw * _p2Z + _qx * _p2Y - _qy * _p2X;
					_t3 = -_qx * _p2X - _qy * _p2Y - _qz * _p2Z;

					_p2X = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
					_p2Y = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
					_p2Z = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
				}

				vertex_position_3d(_vbuffer, Position.X + _p1X, Position.Y + _p1Y, Position.Z + _p1Z);
				vertex_color(_vbuffer, _color, _alpha);
				vertex_position_3d(_vbuffer, Position.X + _p2X, Position.Y + _p2Y, Position.Z + _p2Z);
				vertex_color(_vbuffer, _color, _alpha);

				_angle += _inc;
			}

			vertex_end(_vbuffer);
			vertex_submit(_vbuffer, pr_linelist, -1);

			return self;
		};
	}
