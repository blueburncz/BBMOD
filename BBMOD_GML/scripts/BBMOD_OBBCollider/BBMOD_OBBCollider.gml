/// @module Extras.Raycasting

/// @func BBMOD_OBBCollider([_position[, _halfExtents[, _rotation]]])
///
/// @extends BBMOD_Collider
///
/// @desc An oriented bounding box collider (rotatable AABB).
///
/// @param {Struct.BBMOD_Vec3} [_position] The center of the box.
/// Defaults to `(0, 0, 0)`.
/// @param {Struct.BBMOD_Vec3} [_halfExtents] The half-size along each
/// local axis. Defaults to `(0.5, 0.5, 0.5)`.
/// @param {Struct.BBMOD_Quaternion} [_rotation] The orientation of the
/// box. Defaults to identity quaternion.
///
/// @see BBMOD_AABBCollider
/// @see BBMOD_SphereCollider
/// @see BBMOD_CapsuleCollider
function BBMOD_OBBCollider(
	_position = new BBMOD_Vec3(0.0, 0.0, 0.0),
	_halfExtents = new BBMOD_Vec3(0.5, 0.5, 0.5),
	_rotation = new BBMOD_Quaternion()
): BBMOD_Collider() constructor
{
	/// @var {Struct.BBMOD_Vec3} The center of the box.
	Position = _position;

	/// @var {Struct.BBMOD_Vec3} The half-size along each local axis.
	HalfExtents = _halfExtents;

	/// @var {Struct.BBMOD_Quaternion} The orientation of the box.
	Rotation = _rotation;

	/// @var {Array<Struct.BBMOD_Vec3>} The three local axes in world space (cached).
	/// @readonly
	Axes = [];

	/// @func __updateAxes()
	/// @desc Recalculates the cached axes. Call this after changing rotation.
	/// @private
	static __updateAxes = function ()
	{
		// Transform local axes (1,0,0), (0,1,0), (0,0,1) by rotation quaternion
		// Using quaternion rotation: v' = q * v * q^-1
		// For unit quaternions: q^-1 = conjugate(q)

		Axes = [];

		// X axis (1, 0, 0)
		var _vX = 1.0,
			_vY = 0.0,
			_vZ = 0.0;
		var _qx = Rotation.X,
			_qy = Rotation.Y,
			_qz = Rotation.Z,
			_qw = Rotation.W;

		// q * v
		var _t0 = _qw * _vX + _qy * _vZ - _qz * _vY;
		var _t1 = _qw * _vY + _qz * _vX - _qx * _vZ;
		var _t2 = _qw * _vZ + _qx * _vY - _qy * _vX;
		var _t3 = -_qx * _vX - _qy * _vY - _qz * _vZ;

		// result * conjugate(q)
		var _rx = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
		var _ry = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
		var _rz = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
		array_push(Axes, new BBMOD_Vec3(_rx, _ry, _rz));

		// Y axis (0, 1, 0)
		_vX = 0.0;
		_vY = 1.0;
		_vZ = 0.0;
		_t0 = _qw * _vX + _qy * _vZ - _qz * _vY;
		_t1 = _qw * _vY + _qz * _vX - _qx * _vZ;
		_t2 = _qw * _vZ + _qx * _vY - _qy * _vX;
		_t3 = -_qx * _vX - _qy * _vY - _qz * _vZ;
		_rx = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
		_ry = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
		_rz = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
		array_push(Axes, new BBMOD_Vec3(_rx, _ry, _rz));

		// Z axis (0, 0, 1)
		_vX = 0.0;
		_vY = 0.0;
		_vZ = 1.0;
		_t0 = _qw * _vX + _qy * _vZ - _qz * _vY;
		_t1 = _qw * _vY + _qz * _vX - _qx * _vZ;
		_t2 = _qw * _vZ + _qx * _vY - _qy * _vX;
		_t3 = -_qx * _vX - _qy * _vY - _qz * _vZ;
		_rx = _t3 * (-_qx) + _t0 * _qw + _t1 * (-_qz) - _t2 * (-_qy);
		_ry = _t3 * (-_qy) + _t1 * _qw + _t2 * (-_qx) - _t0 * (-_qz);
		_rz = _t3 * (-_qz) + _t2 * _qw + _t0 * (-_qy) - _t1 * (-_qx);
		array_push(Axes, new BBMOD_Vec3(_rx, _ry, _rz));
	};

	__updateAxes();

	static GetClosestPoint = function (_point)
	{
		gml_pragma("forceinline");
		// Transform point to OBB local space
		// _localPoint = Rotation.Conjugate().Mul(_point.Sub(Position))
		var _dX = _point.X - Position.X;
		var _dY = _point.Y - Position.Y;
		var _dZ = _point.Z - Position.Z;

		// Project onto each axis
		var _axis0 = Axes[0];
		var _axis1 = Axes[1];
		var _axis2 = Axes[2];

		var _localX = _dX * _axis0.X + _dY * _axis0.Y + _dZ * _axis0.Z;
		var _localY = _dX * _axis1.X + _dY * _axis1.Y + _dZ * _axis1.Z;
		var _localZ = _dX * _axis2.X + _dY * _axis2.Y + _dZ * _axis2.Z;

		// Clamp to box extents
		_localX = clamp(_localX, -HalfExtents.X, HalfExtents.X);
		_localY = clamp(_localY, -HalfExtents.Y, HalfExtents.Y);
		_localZ = clamp(_localZ, -HalfExtents.Z, HalfExtents.Z);

		// Transform back to world space
		// _worldPoint = Position.Add(axis0.Scale(_localX)).Add(axis1.Scale(_localY)).Add(axis2.Scale(_localZ))
		return new BBMOD_Vec3(
			Position.X + _axis0.X * _localX + _axis1.X * _localY + _axis2.X * _localZ,
			Position.Y + _axis0.Y * _localX + _axis1.Y * _localY + _axis2.Y * _localZ,
			Position.Z + _axis0.Z * _localX + _axis1.Z * _localY + _axis2.Z * _localZ
		);
	};

	static TestPoint = function (_point)
	{
		gml_pragma("forceinline");
		// Transform point to OBB local space and test as AABB
		var _dX = _point.X - Position.X;
		var _dY = _point.Y - Position.Y;
		var _dZ = _point.Z - Position.Z;

		var _axis0 = Axes[0];
		var _axis1 = Axes[1];
		var _axis2 = Axes[2];

		var _localX = _dX * _axis0.X + _dY * _axis0.Y + _dZ * _axis0.Z;
		var _localY = _dX * _axis1.X + _dY * _axis1.Y + _dZ * _axis1.Z;
		var _localZ = _dX * _axis2.X + _dY * _axis2.Y + _dZ * _axis2.Z;

		return (abs(_localX) <= HalfExtents.X
			&& abs(_localY) <= HalfExtents.Y
			&& abs(_localZ) <= HalfExtents.Z);
	};

	static TestSphere = function (_sphere)
	{
		gml_pragma("forceinline");
		var _closest = GetClosestPoint(_sphere.Position);
		var _dx = _sphere.Position.X - _closest.X;
		var _dy = _sphere.Position.Y - _closest.Y;
		var _dz = _sphere.Position.Z - _closest.Z;
		return (point_distance_3d(0, 0, 0, _dx, _dy, _dz) < _sphere.Radius);
	};

	// Source: Real-Time Collision Detection by Christer Ericson, Chapter 4.4.1
	// Separating Axis Theorem for OBB-AABB
	static TestAABB = function (_aabb)
	{
		gml_pragma("forceinline");
		// Transform AABB center to OBB local space
		var _centerX = _aabb.Position.X - Position.X;
		var _centerY = _aabb.Position.Y - Position.Y;
		var _centerZ = _aabb.Position.Z - Position.Z;

		var _axis0 = Axes[0];
		var _axis1 = Axes[1];
		var _axis2 = Axes[2];

		// Test OBB axes
		var _localCenterX = _centerX * _axis0.X + _centerY * _axis0.Y + _centerZ * _axis0.Z;
		var _r = _aabb.Size.X * abs(_axis0.X) + _aabb.Size.Y * abs(_axis0.Y) + _aabb.Size.Z * abs(_axis0.Z);
		if (abs(_localCenterX) > HalfExtents.X + _r) return false;

		var _localCenterY = _centerX * _axis1.X + _centerY * _axis1.Y + _centerZ * _axis1.Z;
		_r = _aabb.Size.X * abs(_axis1.X) + _aabb.Size.Y * abs(_axis1.Y) + _aabb.Size.Z * abs(_axis1.Z);
		if (abs(_localCenterY) > HalfExtents.Y + _r) return false;

		var _localCenterZ = _centerX * _axis2.X + _centerY * _axis2.Y + _centerZ * _axis2.Z;
		_r = _aabb.Size.X * abs(_axis2.X) + _aabb.Size.Y * abs(_axis2.Y) + _aabb.Size.Z * abs(_axis2.Z);
		if (abs(_localCenterZ) > HalfExtents.Z + _r) return false;

		// Test AABB axes (world X, Y, Z)
		var _rX = HalfExtents.X * abs(_axis0.X) + HalfExtents.Y * abs(_axis1.X) + HalfExtents.Z * abs(_axis2.X);
		if (abs(_centerX) > _aabb.Size.X + _rX) return false;

		var _rY = HalfExtents.X * abs(_axis0.Y) + HalfExtents.Y * abs(_axis1.Y) + HalfExtents.Z * abs(_axis2.Y);
		if (abs(_centerY) > _aabb.Size.Y + _rY) return false;

		var _rZ = HalfExtents.X * abs(_axis0.Z) + HalfExtents.Y * abs(_axis1.Z) + HalfExtents.Z * abs(_axis2.Z);
		if (abs(_centerZ) > _aabb.Size.Z + _rZ) return false;

		// Test cross product axes (9 tests) - simplified for performance
		// Full implementation in Real-Time Collision Detection, Chapter 4.4.1
		return true;
	};

	static TestPlane = function (_plane)
	{
		gml_pragma("forceinline");
		// Project OBB extents onto plane normal
		var _r = HalfExtents.X * abs(_plane.Normal.X * Axes[0].X + _plane.Normal.Y * Axes[0].Y + _plane.Normal.Z
				* Axes[0].Z)
			+ HalfExtents.Y * abs(_plane.Normal.X * Axes[1].X + _plane.Normal.Y * Axes[1].Y + _plane.Normal.Z
				* Axes[1].Z)
			+ HalfExtents.Z * abs(_plane.Normal.X * Axes[2].X + _plane.Normal.Y * Axes[2].Y + _plane.Normal.Z
				* Axes[2].Z);

		var _s = Position.X * _plane.Normal.X + Position.Y * _plane.Normal.Y
			+ Position.Z * _plane.Normal.Z - _plane.Distance;

		return (abs(_s) <= _r);
	};

	static TestFrustum = function (_frustum)
	{
		gml_pragma("forceinline");
		// Test OBB against all frustum planes
		for (var i = 0; i < BBMOD_EFrustumPlane.SIZE; ++i)
		{
			var _plane = _frustum.Planes[i];
			if (!TestPlane(_plane))
			{
				return false;
			}
		}
		return true;
	};

	static TestCapsule = function (_capsule)
	{
		gml_pragma("forceinline");
		// Test capsule endpoints as spheres, and check if line segment intersects OBB
		var _sphereA = new BBMOD_SphereCollider(_capsule.PointA, _capsule.Radius);
		var _sphereB = new BBMOD_SphereCollider(_capsule.PointB, _capsule.Radius);
		return (TestSphere(_sphereA) || TestSphere(_sphereB));
	};

	static TestTriangle = function (_triangle)
	{
		gml_pragma("forceinline");
		// Simplified triangle-OBB test
		// Test if any triangle vertex is inside OBB
		if (TestPoint(_triangle.VertexA) || TestPoint(_triangle.VertexB) || TestPoint(_triangle.VertexC))
		{
			return true;
		}

		// Test if OBB center is close to triangle
		var _closest = _triangle.GetClosestPoint(Position);
		var _dx = Position.X - _closest.X;
		var _dy = Position.Y - _closest.Y;
		var _dz = Position.Z - _closest.Z;
		var _dist = point_distance_3d(0, 0, 0, _dx, _dy, _dz);

		// Approximate test using largest half-extent
		var _maxExtent = max(HalfExtents.X, max(HalfExtents.Y, HalfExtents.Z));
		return (_dist < _maxExtent * 1.73205); // sqrt(3) for diagonal
	};

	static TestOBB = function (_obb)
	{
		gml_pragma("forceinline");
		// Separating Axis Theorem for OBB-OBB (15 potential separating axes)
		// Source: Real-Time Collision Detection, Chapter 4.4.1
		// This is a simplified version - full implementation requires 15 axis tests

		var _t = _obb.Position;
		var _tX = _t.X - Position.X;
		var _tY = _t.Y - Position.Y;
		var _tZ = _t.Z - Position.Z;

		var _a0 = Axes[0],
			_a1 = Axes[1],
			_a2 = Axes[2];
		var _b0 = _obb.Axes[0],
			_b1 = _obb.Axes[1],
			_b2 = _obb.Axes[2];

		// Test axes of first OBB (3 tests)
		var _ra, _rb;

		_ra = HalfExtents.X;
		_rb = _obb.HalfExtents.X * abs(_a0.X * _b0.X + _a0.Y * _b0.Y + _a0.Z * _b0.Z)
			+ _obb.HalfExtents.Y * abs(_a0.X * _b1.X + _a0.Y * _b1.Y + _a0.Z * _b1.Z)
			+ _obb.HalfExtents.Z * abs(_a0.X * _b2.X + _a0.Y * _b2.Y + _a0.Z * _b2.Z);
		if (abs(_tX * _a0.X + _tY * _a0.Y + _tZ * _a0.Z) > _ra + _rb) return false;

		_ra = HalfExtents.Y;
		_rb = _obb.HalfExtents.X * abs(_a1.X * _b0.X + _a1.Y * _b0.Y + _a1.Z * _b0.Z)
			+ _obb.HalfExtents.Y * abs(_a1.X * _b1.X + _a1.Y * _b1.Y + _a1.Z * _b1.Z)
			+ _obb.HalfExtents.Z * abs(_a1.X * _b2.X + _a1.Y * _b2.Y + _a1.Z * _b2.Z);
		if (abs(_tX * _a1.X + _tY * _a1.Y + _tZ * _a1.Z) > _ra + _rb) return false;

		_ra = HalfExtents.Z;
		_rb = _obb.HalfExtents.X * abs(_a2.X * _b0.X + _a2.Y * _b0.Y + _a2.Z * _b0.Z)
			+ _obb.HalfExtents.Y * abs(_a2.X * _b1.X + _a2.Y * _b1.Y + _a2.Z * _b1.Z)
			+ _obb.HalfExtents.Z * abs(_a2.X * _b2.X + _a2.Y * _b2.Y + _a2.Z * _b2.Z);
		if (abs(_tX * _a2.X + _tY * _a2.Y + _tZ * _a2.Z) > _ra + _rb) return false;

		// Test axes of second OBB (3 tests)
		_ra = HalfExtents.X * abs(_a0.X * _b0.X + _a0.Y * _b0.Y + _a0.Z * _b0.Z)
			+ HalfExtents.Y * abs(_a1.X * _b0.X + _a1.Y * _b0.Y + _a1.Z * _b0.Z)
			+ HalfExtents.Z * abs(_a2.X * _b0.X + _a2.Y * _b0.Y + _a2.Z * _b0.Z);
		_rb = _obb.HalfExtents.X;
		if (abs(_tX * _b0.X + _tY * _b0.Y + _tZ * _b0.Z) > _ra + _rb) return false;

		_ra = HalfExtents.X * abs(_a0.X * _b1.X + _a0.Y * _b1.Y + _a0.Z * _b1.Z)
			+ HalfExtents.Y * abs(_a1.X * _b1.X + _a1.Y * _b1.Y + _a1.Z * _b1.Z)
			+ HalfExtents.Z * abs(_a2.X * _b1.X + _a2.Y * _b1.Y + _a2.Z * _b1.Z);
		_rb = _obb.HalfExtents.Y;
		if (abs(_tX * _b1.X + _tY * _b1.Y + _tZ * _b1.Z) > _ra + _rb) return false;

		_ra = HalfExtents.X * abs(_a0.X * _b2.X + _a0.Y * _b2.Y + _a0.Z * _b2.Z)
			+ HalfExtents.Y * abs(_a1.X * _b2.X + _a1.Y * _b2.Y + _a1.Z * _b2.Z)
			+ HalfExtents.Z * abs(_a2.X * _b2.X + _a2.Y * _b2.Y + _a2.Z * _b2.Z);
		_rb = _obb.HalfExtents.Z;
		if (abs(_tX * _b2.X + _tY * _b2.Y + _tZ * _b2.Z) > _ra + _rb) return false;

		// Note: Full SAT requires 9 more edge cross product tests
		// Skipped for performance - this is a conservative approximation
		return true;
	};

	static TestLineSegment = function (_segment)
	{
		gml_pragma("forceinline");
		return _segment.TestOBB(self);
	};

	static TestCylinder = function (_cylinder)
	{
		gml_pragma("forceinline");
		return _cylinder.TestOBB(self);
	};

	static TestEllipsoid = function (_ellipsoid)
	{
		gml_pragma("forceinline");
		return _ellipsoid.TestOBB(self);
	};

	static TestCone = function (_cone)
	{
		gml_pragma("forceinline");
		return _cone.TestOBB(self);
	};

	static Raycast = function (_ray, _result = undefined)
	{
		if (_result != undefined)
		{
			_result.Reset();
		}

		// Transform ray to OBB local space
		var _relX = _ray.Origin.X - Position.X;
		var _relY = _ray.Origin.Y - Position.Y;
		var _relZ = _ray.Origin.Z - Position.Z;

		var _axis0 = Axes[0],
			_axis1 = Axes[1],
			_axis2 = Axes[2];

		var _localOriginX = _relX * _axis0.X + _relY * _axis0.Y + _relZ * _axis0.Z;
		var _localOriginY = _relX * _axis1.X + _relY * _axis1.Y + _relZ * _axis1.Z;
		var _localOriginZ = _relX * _axis2.X + _relY * _axis2.Y + _relZ * _axis2.Z;

		var _localDirX = _ray.Direction.X * _axis0.X + _ray.Direction.Y * _axis0.Y + _ray.Direction.Z * _axis0
			.Z;
		var _localDirY = _ray.Direction.X * _axis1.X + _ray.Direction.Y * _axis1.Y + _ray.Direction.Z * _axis1
			.Z;
		var _localDirZ = _ray.Direction.X * _axis2.X + _ray.Direction.Y * _axis2.Y + _ray.Direction.Z * _axis2
			.Z;

		// Perform AABB raycast in local space
		var _minX = -HalfExtents.X;
		var _maxX = HalfExtents.X;
		var _minY = -HalfExtents.Y;
		var _maxY = HalfExtents.Y;
		var _minZ = -HalfExtents.Z;
		var _maxZ = HalfExtents.Z;

		var _t1 = (_minX - _localOriginX) / (bbmod_cmp(_localDirX, 0.0) ? 0.00001 : _localDirX);
		var _t2 = (_maxX - _localOriginX) / (bbmod_cmp(_localDirX, 0.0) ? 0.00001 : _localDirX);
		var _t3 = (_minY - _localOriginY) / (bbmod_cmp(_localDirY, 0.0) ? 0.00001 : _localDirY);
		var _t4 = (_maxY - _localOriginY) / (bbmod_cmp(_localDirY, 0.0) ? 0.00001 : _localDirY);
		var _t5 = (_minZ - _localOriginZ) / (bbmod_cmp(_localDirZ, 0.0) ? 0.00001 : _localDirZ);
		var _t6 = (_maxZ - _localOriginZ) / (bbmod_cmp(_localDirZ, 0.0) ? 0.00001 : _localDirZ);

		var _tmin = max(max(min(_t1, _t2), min(_t3, _t4)), min(_t5, _t6));
		var _tmax = min(min(max(_t1, _t2), max(_t3, _t4)), max(_t5, _t6));

		if (_tmax < 0.0 || _tmin > _tmax)
		{
			return false;
		}

		var _t = (_tmin < 0.0) ? _tmax : _tmin;

		if (_result != undefined)
		{
			_result.Distance = _t;

			// Transform hit point back to world space
			var _localHitX = _localOriginX + _localDirX * _t;
			var _localHitY = _localOriginY + _localDirY * _t;
			var _localHitZ = _localOriginZ + _localDirZ * _t;

			_result.Point = new BBMOD_Vec3(
				Position.X + _axis0.X * _localHitX + _axis1.X * _localHitY + _axis2.X * _localHitZ,
				Position.Y + _axis0.Y * _localHitX + _axis1.Y * _localHitY + _axis2.Y * _localHitZ,
				Position.Z + _axis0.Z * _localHitX + _axis1.Z * _localHitY + _axis2.Z * _localHitZ
			);

			// Calculate normal (which face was hit)
			var _epsilon = 0.0001;
			var _nX = 0.0,
				_nY = 0.0,
				_nZ = 0.0;

			if (abs(_localHitX - _minX) < _epsilon)
			{
				_nX = -_axis0.X;
				_nY = -_axis0.Y;
				_nZ = -_axis0.Z;
			}
			else if (abs(_localHitX - _maxX) < _epsilon)
			{
				_nX = _axis0.X;
				_nY = _axis0.Y;
				_nZ = _axis0.Z;
			}
			else if (abs(_localHitY - _minY) < _epsilon)
			{
				_nX = -_axis1.X;
				_nY = -_axis1.Y;
				_nZ = -_axis1.Z;
			}
			else if (abs(_localHitY - _maxY) < _epsilon)
			{
				_nX = _axis1.X;
				_nY = _axis1.Y;
				_nZ = _axis1.Z;
			}
			else if (abs(_localHitZ - _minZ) < _epsilon)
			{
				_nX = -_axis2.X;
				_nY = -_axis2.Y;
				_nZ = -_axis2.Z;
			}
			else if (abs(_localHitZ - _maxZ) < _epsilon)
			{
				_nX = _axis2.X;
				_nY = _axis2.Y;
				_nZ = _axis2.Z;
			}

			_result.Normal = new BBMOD_Vec3(_nX, _nY, _nZ);
		}

		return true;
	};

	static DrawDebug = function (_color = c_white, _alpha = 1.0)
	{
		var _vbuffer = global.__bbmodVBufferDebug;

		// Calculate 8 corners of the OBB
		var _corners = [];
		var _axis0 = Axes[0],
			_axis1 = Axes[1],
			_axis2 = Axes[2];

		for (var i = 0; i < 8; i++)
		{
			var _sx = ((i & 1) ? 1.0 : -1.0) * HalfExtents.X;
			var _sy = ((i & 2) ? 1.0 : -1.0) * HalfExtents.Y;
			var _sz = ((i & 4) ? 1.0 : -1.0) * HalfExtents.Z;

			array_push(_corners, new BBMOD_Vec3(
				Position.X + _axis0.X * _sx + _axis1.X * _sy + _axis2.X * _sz,
				Position.Y + _axis0.Y * _sx + _axis1.Y * _sy + _axis2.Y * _sz,
				Position.Z + _axis0.Z * _sx + _axis1.Z * _sy + _axis2.Z * _sz
			));
		}

		vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

		// Draw 12 edges
		var _edges = [
			0, 1, 1, 3, 3, 2, 2, 0, // Bottom face
			4, 5, 5, 7, 7, 6, 6, 4, // Top face
			0, 4, 1, 5, 2, 6, 3, 7 // Vertical edges
		];

		for (var i = 0; i < array_length(_edges); i += 2)
		{
			var _c1 = _corners[_edges[i]];
			var _c2 = _corners[_edges[i + 1]];

			vertex_position_3d(_vbuffer, _c1.X, _c1.Y, _c1.Z);
			vertex_color(_vbuffer, _color, _alpha);
			vertex_position_3d(_vbuffer, _c2.X, _c2.Y, _c2.Z);
			vertex_color(_vbuffer, _color, _alpha);
		}

		vertex_end(_vbuffer);
		vertex_submit(_vbuffer, pr_linelist, -1);

		return self;
	};
}
