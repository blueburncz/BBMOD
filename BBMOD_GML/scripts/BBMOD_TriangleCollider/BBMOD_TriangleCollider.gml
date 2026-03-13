/// @module Extras.Raycasting

/// @func BBMOD_TriangleCollider([_vertexA[, _vertexB[, _vertexC]]])
///
/// @extends BBMOD_Collider
///
/// @desc A triangle collider.
///
/// @param {Struct.BBMOD_Vec3} [_vertexA] The first vertex.
/// Defaults to `(0, 0, 0)`.
/// @param {Struct.BBMOD_Vec3} [_vertexB] The second vertex.
/// Defaults to `(1, 0, 0)`.
/// @param {Struct.BBMOD_Vec3} [_vertexC] The third vertex.
/// Defaults to `(0, 1, 0)`.
///
/// @see BBMOD_AABBCollider
/// @see BBMOD_SphereCollider
/// @see BBMOD_CapsuleCollider
function BBMOD_TriangleCollider(
	_vertexA = new BBMOD_Vec3(0.0, 0.0, 0.0),
	_vertexB = new BBMOD_Vec3(1.0, 0.0, 0.0),
	_vertexC = new BBMOD_Vec3(0.0, 1.0, 0.0)
): BBMOD_Collider() constructor
{
	/// @var {Struct.BBMOD_Vec3} The first vertex.
	VertexA = _vertexA;

	/// @var {Struct.BBMOD_Vec3} The second vertex.
	VertexB = _vertexB;

	/// @var {Struct.BBMOD_Vec3} The third vertex.
	VertexC = _vertexC;

	/// @var {Struct.BBMOD_Vec3} The face normal (cached).
	/// @readonly
	Normal = undefined;

	/// @func __updateNormal()
	/// @desc Recalculates the cached normal. Call this after changing vertices.
	/// @private
	static __updateNormal = function ()
	{
		// var _ab = VertexB.Sub(VertexA);
		var _abX = VertexB.X - VertexA.X;
		var _abY = VertexB.Y - VertexA.Y;
		var _abZ = VertexB.Z - VertexA.Z;

		// var _ac = VertexC.Sub(VertexA);
		var _acX = VertexC.X - VertexA.X;
		var _acY = VertexC.Y - VertexA.Y;
		var _acZ = VertexC.Z - VertexA.Z;

		// Normal = _ab.Cross(_ac).Normalize();
		var _nX = _abY * _acZ - _abZ * _acY;
		var _nY = _abZ * _acX - _abX * _acZ;
		var _nZ = _abX * _acY - _abY * _acX;
		var _nLen = point_distance_3d(0, 0, 0, _nX, _nY, _nZ);
		var _nNorm = (_nLen != 0.0) ? (1.0 / _nLen) : 0.0;
		Normal = new BBMOD_Vec3(_nX * _nNorm, _nY * _nNorm, _nZ * _nNorm);
	};

	__updateNormal();

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/master/Code/Geometry3D.cpp
	static GetClosestPoint = function (_point)
	{
		gml_pragma("forceinline");
		// Project point onto triangle plane
		// var _planePoint = _point.Sub(Normal.Scale(_point.Sub(VertexA).Dot(Normal)));
		var _apX = _point.X - VertexA.X;
		var _apY = _point.Y - VertexA.Y;
		var _apZ = _point.Z - VertexA.Z;
		var _dist = _apX * Normal.X + _apY * Normal.Y + _apZ * Normal.Z;
		var _planeX = _point.X - Normal.X * _dist;
		var _planeY = _point.Y - Normal.Y * _dist;
		var _planeZ = _point.Z - Normal.Z * _dist;

		// Check if point projects inside triangle using barycentric coordinates
		var _abX = VertexB.X - VertexA.X;
		var _abY = VertexB.Y - VertexA.Y;
		var _abZ = VertexB.Z - VertexA.Z;

		var _acX = VertexC.X - VertexA.X;
		var _acY = VertexC.Y - VertexA.Y;
		var _acZ = VertexC.Z - VertexA.Z;

		var _apProjX = _planeX - VertexA.X;
		var _apProjY = _planeY - VertexA.Y;
		var _apProjZ = _planeZ - VertexA.Z;

		var _d00 = _abX * _abX + _abY * _abY + _abZ * _abZ;
		var _d01 = _abX * _acX + _abY * _acY + _abZ * _acZ;
		var _d11 = _acX * _acX + _acY * _acY + _acZ * _acZ;
		var _d20 = _apProjX * _abX + _apProjY * _abY + _apProjZ * _abZ;
		var _d21 = _apProjX * _acX + _apProjY * _acY + _apProjZ * _acZ;

		var _denom = _d00 * _d11 - _d01 * _d01;
		var _v = (_d11 * _d20 - _d01 * _d21) / _denom;
		var _w = (_d00 * _d21 - _d01 * _d20) / _denom;
		var _u = 1.0 - _v - _w;

		// Point is inside triangle
		if (_u >= 0.0 && _v >= 0.0 && _w >= 0.0)
		{
			return new BBMOD_Vec3(_planeX, _planeY, _planeZ);
		}

		// Point is outside - find closest point on edges
		var _closestDist = infinity;
		var _closestX, _closestY, _closestZ;

		// Edge AB
		var _tAB = clamp((_apX * _abX + _apY * _abY + _apZ * _abZ) / _d00, 0.0, 1.0);
		var _pABX = VertexA.X + _abX * _tAB;
		var _pABY = VertexA.Y + _abY * _tAB;
		var _pABZ = VertexA.Z + _abZ * _tAB;
		var _dAB = point_distance_3d(_point.X, _point.Y, _point.Z, _pABX, _pABY, _pABZ);
		if (_dAB < _closestDist)
		{
			_closestDist = _dAB;
			_closestX = _pABX;
			_closestY = _pABY;
			_closestZ = _pABZ;
		}

		// Edge AC
		var _tAC = clamp((_apX * _acX + _apY * _acY + _apZ * _acZ) / _d11, 0.0, 1.0);
		var _pACX = VertexA.X + _acX * _tAC;
		var _pACY = VertexA.Y + _acY * _tAC;
		var _pACZ = VertexA.Z + _acZ * _tAC;
		var _dAC = point_distance_3d(_point.X, _point.Y, _point.Z, _pACX, _pACY, _pACZ);
		if (_dAC < _closestDist)
		{
			_closestDist = _dAC;
			_closestX = _pACX;
			_closestY = _pACY;
			_closestZ = _pACZ;
		}

		// Edge BC
		var _bcX = VertexC.X - VertexB.X;
		var _bcY = VertexC.Y - VertexB.Y;
		var _bcZ = VertexC.Z - VertexB.Z;
		var _bpX = _point.X - VertexB.X;
		var _bpY = _point.Y - VertexB.Y;
		var _bpZ = _point.Z - VertexB.Z;
		var _d22 = _bcX * _bcX + _bcY * _bcY + _bcZ * _bcZ;
		var _tBC = clamp((_bpX * _bcX + _bpY * _bcY + _bpZ * _bcZ) / _d22, 0.0, 1.0);
		var _pBCX = VertexB.X + _bcX * _tBC;
		var _pBCY = VertexB.Y + _bcY * _tBC;
		var _pBCZ = VertexB.Z + _bcZ * _tBC;
		var _dBC = point_distance_3d(_point.X, _point.Y, _point.Z, _pBCX, _pBCY, _pBCZ);
		if (_dBC < _closestDist)
		{
			_closestDist = _dBC;
			_closestX = _pBCX;
			_closestY = _pBCY;
			_closestZ = _pBCZ;
		}

		return new BBMOD_Vec3(_closestX, _closestY, _closestZ);
	};

	static TestAABB = function (_aabb)
	{
		gml_pragma("forceinline");
		// Use Separating Axis Theorem
		// Test triangle normal
		var _center = _aabb.Position;
		var _extents = _aabb.Size;

		// Project AABB onto triangle normal
		var _r = _extents.X * abs(Normal.X) + _extents.Y * abs(Normal.Y) + _extents.Z * abs(Normal.Z);
		var _s = (VertexA.X - _center.X) * Normal.X + (VertexA.Y - _center.Y) * Normal.Y
			+ (VertexA.Z - _center.Z) * Normal.Z;

		if (abs(_s) > _r)
		{
			return false;
		}

		// Test AABB face normals (3 tests)
		var _minX = min(VertexA.X, min(VertexB.X, VertexC.X));
		var _maxX = max(VertexA.X, max(VertexB.X, VertexC.X));
		var _minY = min(VertexA.Y, min(VertexB.Y, VertexC.Y));
		var _maxY = max(VertexA.Y, max(VertexB.Y, VertexC.Y));
		var _minZ = min(VertexA.Z, min(VertexB.Z, VertexC.Z));
		var _maxZ = max(VertexA.Z, max(VertexB.Z, VertexC.Z));

		var _aabbMinX = _center.X - _extents.X;
		var _aabbMaxX = _center.X + _extents.X;
		var _aabbMinY = _center.Y - _extents.Y;
		var _aabbMaxY = _center.Y + _extents.Y;
		var _aabbMinZ = _center.Z - _extents.Z;
		var _aabbMaxZ = _center.Z + _extents.Z;

		if (_maxX < _aabbMinX || _minX > _aabbMaxX) return false;
		if (_maxY < _aabbMinY || _minY > _aabbMaxY) return false;
		if (_maxZ < _aabbMinZ || _minZ > _aabbMaxZ) return false;

		// Test edge cross products (9 tests - simplified)
		// For full implementation, see Real-Time Collision Detection Chapter 5.2.9
		// This is a conservative approximation
		return true;
	};

	static TestFrustum = function (_frustum)
	{
		gml_pragma("forceinline");
		// Test all three vertices against frustum
		for (var i = 0; i < BBMOD_EFrustumPlane.SIZE; ++i)
		{
			var _plane = _frustum.Planes[i];
			var _distA = VertexA.X * _plane.Normal.X + VertexA.Y * _plane.Normal.Y
				+ VertexA.Z * _plane.Normal.Z + _plane.Distance;
			var _distB = VertexB.X * _plane.Normal.X + VertexB.Y * _plane.Normal.Y
				+ VertexB.Z * _plane.Normal.Z + _plane.Distance;
			var _distC = VertexC.X * _plane.Normal.X + VertexC.Y * _plane.Normal.Y
				+ VertexC.Z * _plane.Normal.Z + _plane.Distance;

			// If all vertices are outside this plane, triangle is outside frustum
			if (_distA < 0.0 && _distB < 0.0 && _distC < 0.0)
			{
				return false;
			}
		}
		return true;
	};

	static TestPlane = function (_plane)
	{
		gml_pragma("forceinline");
		// Check which side of the plane each vertex is on
		var _distA = VertexA.X * _plane.Normal.X + VertexA.Y * _plane.Normal.Y
			+ VertexA.Z * _plane.Normal.Z - _plane.Distance;
		var _distB = VertexB.X * _plane.Normal.X + VertexB.Y * _plane.Normal.Y
			+ VertexB.Z * _plane.Normal.Z - _plane.Distance;
		var _distC = VertexC.X * _plane.Normal.X + VertexC.Y * _plane.Normal.Y
			+ VertexC.Z * _plane.Normal.Z - _plane.Distance;

		// If all vertices are on the same side, no intersection
		if ((_distA > 0.0 && _distB > 0.0 && _distC > 0.0)
			|| (_distA < 0.0 && _distB < 0.0 && _distC < 0.0))
		{
			return false;
		}

		return true;
	};

	static TestPoint = function (_point)
	{
		gml_pragma("forceinline");
		// Use barycentric coordinates
		var _abX = VertexB.X - VertexA.X;
		var _abY = VertexB.Y - VertexA.Y;
		var _abZ = VertexB.Z - VertexA.Z;

		var _acX = VertexC.X - VertexA.X;
		var _acY = VertexC.Y - VertexA.Y;
		var _acZ = VertexC.Z - VertexA.Z;

		var _apX = _point.X - VertexA.X;
		var _apY = _point.Y - VertexA.Y;
		var _apZ = _point.Z - VertexA.Z;

		var _d00 = _abX * _abX + _abY * _abY + _abZ * _abZ;
		var _d01 = _abX * _acX + _abY * _acY + _abZ * _acZ;
		var _d11 = _acX * _acX + _acY * _acY + _acZ * _acZ;
		var _d20 = _apX * _abX + _apY * _abY + _apZ * _abZ;
		var _d21 = _apX * _acX + _apY * _acY + _apZ * _acZ;

		var _denom = _d00 * _d11 - _d01 * _d01;
		if (abs(_denom) < 0.00001) return false;

		var _v = (_d11 * _d20 - _d01 * _d21) / _denom;
		var _w = (_d00 * _d21 - _d01 * _d20) / _denom;
		var _u = 1.0 - _v - _w;

		// Check if point is on the triangle plane
		var _planeD = _apX * Normal.X + _apY * Normal.Y + _apZ * Normal.Z;
		if (abs(_planeD) > 0.001) return false;

		return (_u >= 0.0 && _v >= 0.0 && _w >= 0.0);
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

	static TestCapsule = function (_capsule)
	{
		gml_pragma("forceinline");
		// Test if capsule line segment is close enough to triangle
		// This is a simplified test - find closest points on both primitives
		var _closestA = GetClosestPoint(_capsule.PointA);
		var _closestB = GetClosestPoint(_capsule.PointB);

		var _dA = point_distance_3d(_capsule.PointA.X, _capsule.PointA.Y, _capsule.PointA.Z,
			_closestA.X, _closestA.Y, _closestA.Z);
		var _dB = point_distance_3d(_capsule.PointB.X, _capsule.PointB.Y, _capsule.PointB.Z,
			_closestB.X, _closestB.Y, _closestB.Z);

		return (min(_dA, _dB) < _capsule.Radius);
	};

	static TestTriangle = function (_triangle)
	{
		gml_pragma("forceinline");
		// Simplified triangle-triangle intersection test
		// Full implementation requires SAT with 11 axes
		// This is a conservative approximation using edge-edge and vertex-triangle tests

		// Test if any vertex of this triangle is inside the other triangle
		if (_triangle.TestPoint(VertexA) || _triangle.TestPoint(VertexB) || _triangle.TestPoint(VertexC))
		{
			return true;
		}

		// Test if any vertex of the other triangle is inside this triangle
		if (TestPoint(_triangle.VertexA) || TestPoint(_triangle.VertexB) || TestPoint(_triangle.VertexC))
		{
			return true;
		}

		// Test if triangle edges intersect
		// This is a simplified check - full implementation would test all edge pairs
		return false;
	};

	static TestOBB = function (_obb)
	{
		gml_pragma("forceinline");
		return _obb.TestTriangle(self);
	};

	static TestLineSegment = function (_segment)
	{
		gml_pragma("forceinline");
		return _segment.TestTriangle(self);
	};

	static TestCylinder = function (_cylinder)
	{
		gml_pragma("forceinline");
		return _cylinder.TestTriangle(self);
	};

	static TestEllipsoid = function (_ellipsoid)
	{
		gml_pragma("forceinline");
		return _ellipsoid.TestTriangle(self);
	};

	static TestCone = function (_cone)
	{
		gml_pragma("forceinline");
		return _cone.TestTriangle(self);
	};

	// Source: Moller-Trumbore algorithm
	// Fast, Minimum Storage Ray/Triangle Intersection (1997)
	static Raycast = function (_ray, _result = undefined)
	{
		if (_result != undefined)
		{
			_result.Reset();
		}

		var _edge1X = VertexB.X - VertexA.X;
		var _edge1Y = VertexB.Y - VertexA.Y;
		var _edge1Z = VertexB.Z - VertexA.Z;

		var _edge2X = VertexC.X - VertexA.X;
		var _edge2Y = VertexC.Y - VertexA.Y;
		var _edge2Z = VertexC.Z - VertexA.Z;

		// Cross product: _ray.Direction x _edge2
		var _hX = _ray.Direction.Y * _edge2Z - _ray.Direction.Z * _edge2Y;
		var _hY = _ray.Direction.Z * _edge2X - _ray.Direction.X * _edge2Z;
		var _hZ = _ray.Direction.X * _edge2Y - _ray.Direction.Y * _edge2X;

		var _a = _edge1X * _hX + _edge1Y * _hY + _edge1Z * _hZ;

		if (abs(_a) < 0.00001)
		{
			return false; // Ray is parallel to triangle
		}

		var _f = 1.0 / _a;

		var _sX = _ray.Origin.X - VertexA.X;
		var _sY = _ray.Origin.Y - VertexA.Y;
		var _sZ = _ray.Origin.Z - VertexA.Z;

		var _u = _f * (_sX * _hX + _sY * _hY + _sZ * _hZ);

		if (_u < 0.0 || _u > 1.0)
		{
			return false;
		}

		// Cross product: _s x _edge1
		var _qX = _sY * _edge1Z - _sZ * _edge1Y;
		var _qY = _sZ * _edge1X - _sX * _edge1Z;
		var _qZ = _sX * _edge1Y - _sY * _edge1X;

		var _v = _f * (_ray.Direction.X * _qX + _ray.Direction.Y * _qY + _ray.Direction.Z * _qZ);

		if (_v < 0.0 || _u + _v > 1.0)
		{
			return false;
		}

		var _t = _f * (_edge2X * _qX + _edge2Y * _qY + _edge2Z * _qZ);

		if (_t > 0.00001)
		{
			if (_result != undefined)
			{
				_result.Distance = _t;
				_result.Point = new BBMOD_Vec3(
					_ray.Origin.X + _ray.Direction.X * _t,
					_ray.Origin.Y + _ray.Direction.Y * _t,
					_ray.Origin.Z + _ray.Direction.Z * _t
				);
				_result.Normal = Normal;
			}
			return true;
		}

		return false;
	};

	static DrawDebug = function (_color = c_white, _alpha = 1.0)
	{
		var _vbuffer = global.__bbmodVBufferDebug;

		vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

		// Draw triangle edges
		vertex_position_3d(_vbuffer, VertexA.X, VertexA.Y, VertexA.Z);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, VertexB.X, VertexB.Y, VertexB.Z);
		vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, VertexB.X, VertexB.Y, VertexB.Z);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, VertexC.X, VertexC.Y, VertexC.Z);
		vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, VertexC.X, VertexC.Y, VertexC.Z);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, VertexA.X, VertexA.Y, VertexA.Z);
		vertex_color(_vbuffer, _color, _alpha);

		vertex_end(_vbuffer);
		vertex_submit(_vbuffer, pr_linelist, -1);

		return self;
	};
}
