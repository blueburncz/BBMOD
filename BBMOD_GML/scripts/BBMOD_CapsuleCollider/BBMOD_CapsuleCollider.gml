/// @module Extras.Raycasting

/// @func BBMOD_CapsuleCollider([_pointA[, _pointB[, _radius]]])
///
/// @extends BBMOD_Collider
///
/// @desc A capsule collider (cylinder with hemispherical caps).
///
/// @param {Struct.BBMOD_Vec3} [_pointA] The center of the first hemisphere.
/// Defaults to `(0, 0, 0)`.
/// @param {Struct.BBMOD_Vec3} [_pointB] The center of the second hemisphere.
/// Defaults to `(0, 1, 0)`.
/// @param {Real} [_radius] The radius of the capsule. Defaults to 0.5.
///
/// @see BBMOD_AABBCollider
/// @see BBMOD_SphereCollider
/// @see BBMOD_PlaneCollider
/// @see BBMOD_FrustumCollider
function BBMOD_CapsuleCollider(
	_pointA = new BBMOD_Vec3(0.0, 0.0, 0.0),
	_pointB = new BBMOD_Vec3(0.0, 1.0, 0.0),
	_radius = 0.5
): BBMOD_Collider() constructor
{
	/// @var {Struct.BBMOD_Vec3} The center of the first hemisphere.
	PointA = _pointA;

	/// @var {Struct.BBMOD_Vec3} The center of the second hemisphere.
	PointB = _pointB;

	/// @var {Real} The radius of the capsule.
	Radius = _radius;

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/master/Code/Geometry3D.cpp
	static GetClosestPoint = function (_point)
	{
		gml_pragma("forceinline");
		// Project point onto line segment AB
		// var _ab = PointB.Sub(PointA);
		var _abX = PointB.X - PointA.X;
		var _abY = PointB.Y - PointA.Y;
		var _abZ = PointB.Z - PointA.Z;

		// var _ap = _point.Sub(PointA);
		var _apX = _point.X - PointA.X;
		var _apY = _point.Y - PointA.Y;
		var _apZ = _point.Z - PointA.Z;

		// var _t = clamp(_ap.Dot(_ab) / _ab.LengthSqr(), 0.0, 1.0);
		var _abLengthSqr = _abX * _abX + _abY * _abY + _abZ * _abZ;
		var _t = (_abLengthSqr != 0.0)
			? clamp((_apX * _abX + _apY * _abY + _apZ * _abZ) / _abLengthSqr, 0.0, 1.0)
			: 0.0;

		// var _pointOnSegment = PointA.Add(_ab.Scale(_t));
		var _segX = PointA.X + _abX * _t;
		var _segY = PointA.Y + _abY * _t;
		var _segZ = PointA.Z + _abZ * _t;

		// var _dir = _point.Sub(_pointOnSegment).Normalize().Scale(Radius);
		var _dirX = _point.X - _segX;
		var _dirY = _point.Y - _segY;
		var _dirZ = _point.Z - _segZ;
		var _dirLen = point_distance_3d(0, 0, 0, _dirX, _dirY, _dirZ);
		var _norm = (_dirLen != 0.0) ? (Radius / _dirLen) : 0.0;

		// return _pointOnSegment.Add(_dir);
		return new BBMOD_Vec3(
			_segX + _dirX * _norm,
			_segY + _dirY * _norm,
			_segZ + _dirZ * _norm
		);
	};

	static __testImpl = function (_collider)
	{
		gml_pragma("forceinline");
		var _closestPoint = _collider.GetClosestPoint(PointA);
		// Distance from PointA to closest point on collider
		var _dx = PointA.X - _closestPoint.X;
		var _dy = PointA.Y - _closestPoint.Y;
		var _dz = PointA.Z - _closestPoint.Z;
		var _distA = point_distance_3d(0, 0, 0, _dx, _dy, _dz);

		_closestPoint = _collider.GetClosestPoint(PointB);
		_dx = PointB.X - _closestPoint.X;
		_dy = PointB.Y - _closestPoint.Y;
		_dz = PointB.Z - _closestPoint.Z;
		var _distB = point_distance_3d(0, 0, 0, _dx, _dy, _dz);

		return (min(_distA, _distB) < Radius);
	};

	static TestAABB = __testImpl;

	static TestFrustum = function (_frustum)
	{
		gml_pragma("forceinline");
		return _frustum.TestCapsule(self);
	};

	static TestPlane = function (_plane)
	{
		gml_pragma("forceinline");
		// Distance from both endpoints to plane
		// var _distA = _plane.Normal.Dot(PointA) - _plane.Distance;
		var _distA = _plane.Normal.X * PointA.X + _plane.Normal.Y * PointA.Y
			+ _plane.Normal.Z * PointA.Z - _plane.Distance;
		// var _distB = _plane.Normal.Dot(PointB) - _plane.Distance;
		var _distB = _plane.Normal.X * PointB.X + _plane.Normal.Y * PointB.Y
			+ _plane.Normal.Z * PointB.Z - _plane.Distance;

		// If both points are on same side and farther than radius, no intersection
		if ((_distA > 0.0 && _distB > 0.0 && min(_distA, _distB) > Radius)
			|| (_distA < 0.0 && _distB < 0.0 && max(_distA, _distB) < -Radius))
		{
			return false;
		}

		return true;
	};

	static TestPoint = function (_point)
	{
		gml_pragma("forceinline");
		// Distance from point to line segment
		// var _ab = PointB.Sub(PointA);
		var _abX = PointB.X - PointA.X;
		var _abY = PointB.Y - PointA.Y;
		var _abZ = PointB.Z - PointA.Z;

		// var _ap = _point.Sub(PointA);
		var _apX = _point.X - PointA.X;
		var _apY = _point.Y - PointA.Y;
		var _apZ = _point.Z - PointA.Z;

		// var _t = clamp(_ap.Dot(_ab) / _ab.LengthSqr(), 0.0, 1.0);
		var _abLengthSqr = _abX * _abX + _abY * _abY + _abZ * _abZ;
		var _t = (_abLengthSqr != 0.0)
			? clamp((_apX * _abX + _apY * _abY + _apZ * _abZ) / _abLengthSqr, 0.0, 1.0)
			: 0.0;

		// var _pointOnSegment = PointA.Add(_ab.Scale(_t));
		var _segX = PointA.X + _abX * _t;
		var _segY = PointA.Y + _abY * _t;
		var _segZ = PointA.Z + _abZ * _t;

		// return (_point.Sub(_pointOnSegment).Length() < Radius);
		var _dx = _point.X - _segX;
		var _dy = _point.Y - _segY;
		var _dz = _point.Z - _segZ;
		return (point_distance_3d(0, 0, 0, _dx, _dy, _dz) < Radius);
	};

	static TestSphere = function (_sphere)
	{
		gml_pragma("forceinline");
		// Distance from sphere center to line segment
		// var _ab = PointB.Sub(PointA);
		var _abX = PointB.X - PointA.X;
		var _abY = PointB.Y - PointA.Y;
		var _abZ = PointB.Z - PointA.Z;

		// var _ap = _sphere.Position.Sub(PointA);
		var _apX = _sphere.Position.X - PointA.X;
		var _apY = _sphere.Position.Y - PointA.Y;
		var _apZ = _sphere.Position.Z - PointA.Z;

		// var _t = clamp(_ap.Dot(_ab) / _ab.LengthSqr(), 0.0, 1.0);
		var _abLengthSqr = _abX * _abX + _abY * _abY + _abZ * _abZ;
		var _t = (_abLengthSqr != 0.0)
			? clamp((_apX * _abX + _apY * _abY + _apZ * _abZ) / _abLengthSqr, 0.0, 1.0)
			: 0.0;

		// var _pointOnSegment = PointA.Add(_ab.Scale(_t));
		var _segX = PointA.X + _abX * _t;
		var _segY = PointA.Y + _abY * _t;
		var _segZ = PointA.Z + _abZ * _t;

		// return (_sphere.Position.Sub(_pointOnSegment).Length() < Radius + _sphere.Radius);
		var _dx = _sphere.Position.X - _segX;
		var _dy = _sphere.Position.Y - _segY;
		var _dz = _sphere.Position.Z - _segZ;
		return (point_distance_3d(0, 0, 0, _dx, _dy, _dz) < Radius + _sphere.Radius);
	};

	static TestCapsule = function (_capsule)
	{
		gml_pragma("forceinline");
		// Closest distance between two line segments
		// References: Real-Time Collision Detection by Christer Ericson, Chapter 5.1.9

		var _a1X = PointA.X;
		var _a1Y = PointA.Y;
		var _a1Z = PointA.Z;
		var _a2X = PointB.X;
		var _a2Y = PointB.Y;
		var _a2Z = PointB.Z;

		var _b1X = _capsule.PointA.X;
		var _b1Y = _capsule.PointA.Y;
		var _b1Z = _capsule.PointA.Z;
		var _b2X = _capsule.PointB.X;
		var _b2Y = _capsule.PointB.Y;
		var _b2Z = _capsule.PointB.Z;

		// Direction vectors
		var _d1X = _a2X - _a1X;
		var _d1Y = _a2Y - _a1Y;
		var _d1Z = _a2Z - _a1Z;

		var _d2X = _b2X - _b1X;
		var _d2Y = _b2Y - _b1Y;
		var _d2Z = _b2Z - _b1Z;

		// Vector between segment start points
		var _rX = _a1X - _b1X;
		var _rY = _a1Y - _b1Y;
		var _rZ = _a1Z - _b1Z;

		// Dot products
		var _a = _d1X * _d1X + _d1Y * _d1Y + _d1Z * _d1Z; // Squared length of segment 1
		var _e = _d2X * _d2X + _d2Y * _d2Y + _d2Z * _d2Z; // Squared length of segment 2
		var _f = _d2X * _rX + _d2Y * _rY + _d2Z * _rZ;

		var _s, _t;
		var _c = _d1X * _rX + _d1Y * _rY + _d1Z * _rZ;
		var _b = _d1X * _d2X + _d1Y * _d2Y + _d1Z * _d2Z;
		var _denom = _a * _e - _b * _b;

		// Check if segments are parallel
		if (abs(_denom) < 0.00001)
		{
			_s = 0.0;
			_t = (_e > 0.0) ? (_f / _e) : 0.0;
		}
		else
		{
			_s = clamp((_b * _f - _c * _e) / _denom, 0.0, 1.0);
			_t = (_b * _s + _f);

			if (_e > 0.0)
			{
				_t = clamp(_t / _e, 0.0, 1.0);
			}
			else
			{
				_t = 0.0;
			}
		}

		// Closest points on the two line segments
		var _c1X = _a1X + _d1X * _s;
		var _c1Y = _a1Y + _d1Y * _s;
		var _c1Z = _a1Z + _d1Z * _s;

		var _c2X = _b1X + _d2X * _t;
		var _c2Y = _b1Y + _d2Y * _t;
		var _c2Z = _b1Z + _d2Z * _t;

		// Distance between closest points
		var _dx = _c1X - _c2X;
		var _dy = _c1Y - _c2Y;
		var _dz = _c1Z - _c2Z;
		var _dist = point_distance_3d(0, 0, 0, _dx, _dy, _dz);

		return (_dist < Radius + _capsule.Radius);
	};

	static TestTriangle = function (_triangle)
	{
		gml_pragma("forceinline");
		return _triangle.TestCapsule(self);
	};

	static TestOBB = function (_obb)
	{
		gml_pragma("forceinline");
		return _obb.TestCapsule(self);
	};

	static TestLineSegment = function (_segment)
	{
		gml_pragma("forceinline");
		return _segment.TestCapsule(self);
	};

	static TestCylinder = function (_cylinder)
	{
		gml_pragma("forceinline");
		return _cylinder.TestCapsule(self);
	};

	static TestEllipsoid = function (_ellipsoid)
	{
		gml_pragma("forceinline");
		return _ellipsoid.TestCapsule(self);
	};

	static TestCone = function (_cone)
	{
		gml_pragma("forceinline");
		return _cone.TestCapsule(self);
	};

	// Source: Ray-capsule intersection algorithm
	// Combine ray-cylinder (infinite) + ray-sphere (caps) tests
	static Raycast = function (_ray, _result = undefined)
	{
		if (_result != undefined)
		{
			_result.Reset();
		}

		// Direction of capsule axis
		var _axisX = PointB.X - PointA.X;
		var _axisY = PointB.Y - PointA.Y;
		var _axisZ = PointB.Z - PointA.Z;
		var _axisLen = point_distance_3d(0, 0, 0, _axisX, _axisY, _axisZ);

		if (_axisLen < 0.00001)
		{
			// Degenerate capsule (just a sphere)
			var _sphere = new BBMOD_SphereCollider(PointA, Radius);
			return _sphere.Raycast(_ray, _result);
		}

		// Normalize axis
		var _axisDirX = _axisX / _axisLen;
		var _axisDirY = _axisY / _axisLen;
		var _axisDirZ = _axisZ / _axisLen;

		// Ray origin relative to PointA
		var _roX = _ray.Origin.X - PointA.X;
		var _roY = _ray.Origin.Y - PointA.Y;
		var _roZ = _ray.Origin.Z - PointA.Z;

		// Project ray onto capsule axis
		var _rdDotAxis = _ray.Direction.X * _axisDirX + _ray.Direction.Y * _axisDirY
			+ _ray.Direction.Z * _axisDirZ;
		var _roDotAxis = _roX * _axisDirX + _roY * _axisDirY + _roZ * _axisDirZ;

		// Components perpendicular to axis
		var _rdPerpX = _ray.Direction.X - _axisDirX * _rdDotAxis;
		var _rdPerpY = _ray.Direction.Y - _axisDirY * _rdDotAxis;
		var _rdPerpZ = _ray.Direction.Z - _axisDirZ * _rdDotAxis;

		var _roPerpX = _roX - _axisDirX * _roDotAxis;
		var _roPerpY = _roY - _axisDirY * _roDotAxis;
		var _roPerpZ = _roZ - _axisDirZ * _roDotAxis;

		// Solve quadratic for infinite cylinder
		var _a = _rdPerpX * _rdPerpX + _rdPerpY * _rdPerpY + _rdPerpZ * _rdPerpZ;
		var _b = 2.0 * (_rdPerpX * _roPerpX + _rdPerpY * _roPerpY + _rdPerpZ * _roPerpZ);
		var _c = _roPerpX * _roPerpX + _roPerpY * _roPerpY + _roPerpZ * _roPerpZ - Radius * Radius;
		var _discriminant = _b * _b - 4.0 * _a * _c;

		var _tMin = infinity;
		var _hitCylinder = false;

		// Test infinite cylinder
		if (_discriminant >= 0.0 && abs(_a) > 0.00001)
		{
			var _sqrtDisc = sqrt(_discriminant);
			var _t1 = (-_b - _sqrtDisc) / (2.0 * _a);
			var _t2 = (-_b + _sqrtDisc) / (2.0 * _a);

			// Check if intersection points are within capsule height
			for (var _i = 0; _i < 2; _i++)
			{
				var _t = (_i == 0) ? _t1 : _t2;
				if (_t >= 0.0)
				{
					var _h = _roDotAxis + _t * _rdDotAxis;
					if (_h >= 0.0 && _h <= _axisLen)
					{
						if (_t < _tMin)
						{
							_tMin = _t;
							_hitCylinder = true;
						}
						break;
					}
				}
			}
		}

		// Test sphere caps
		var _sphereA = new BBMOD_SphereCollider(PointA, Radius);
		var _sphereB = new BBMOD_SphereCollider(PointB, Radius);
		var _tempResult = new BBMOD_RaycastResult();

		if (_sphereA.Raycast(_ray, _tempResult) && _tempResult.Distance < _tMin)
		{
			_tMin = _tempResult.Distance;
			_hitCylinder = false;
			if (_result != undefined)
			{
				_result.Distance = _tempResult.Distance;
				_result.Point = _tempResult.Point;
				_result.Normal = _tempResult.Normal;
			}
		}

		if (_sphereB.Raycast(_ray, _tempResult) && _tempResult.Distance < _tMin)
		{
			_tMin = _tempResult.Distance;
			_hitCylinder = false;
			if (_result != undefined)
			{
				_result.Distance = _tempResult.Distance;
				_result.Point = _tempResult.Point;
				_result.Normal = _tempResult.Normal;
			}
		}

		if (_hitCylinder && _result != undefined)
		{
			_result.Distance = _tMin;
			// Calculate hit point and normal
			var _pX = _ray.Origin.X + _ray.Direction.X * _tMin;
			var _pY = _ray.Origin.Y + _ray.Direction.Y * _tMin;
			var _pZ = _ray.Origin.Z + _ray.Direction.Z * _tMin;
			_result.Point = new BBMOD_Vec3(_pX, _pY, _pZ);

			// Normal is perpendicular to axis, pointing outward from cylinder
			var _h = _roDotAxis + _tMin * _rdDotAxis;
			var _centerX = PointA.X + _axisDirX * _h;
			var _centerY = PointA.Y + _axisDirY * _h;
			var _centerZ = PointA.Z + _axisDirZ * _h;

			var _nX = _pX - _centerX;
			var _nY = _pY - _centerY;
			var _nZ = _pZ - _centerZ;
			var _nLen = point_distance_3d(0, 0, 0, _nX, _nY, _nZ);
			var _nNorm = (_nLen != 0.0) ? (1.0 / _nLen) : 0.0;
			_result.Normal = new BBMOD_Vec3(_nX * _nNorm, _nY * _nNorm, _nZ * _nNorm);
		}

		return (_tMin < infinity);
	};

	static DrawDebug = function (_color = c_white, _alpha = 1.0)
	{
		var _vbuffer = global.__bbmodVBufferDebug;
		vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

		// Draw axis line
		vertex_position_3d(_vbuffer, PointA.X, PointA.Y, PointA.Z);
		vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, PointB.X, PointB.Y, PointB.Z);
		vertex_color(_vbuffer, _color, _alpha);

		// Draw circles around the capsule at regular intervals
		var _steps = 16;
		var _segments = 8;
		var _inc = 360.0 / _steps;

		// Direction vector and perpendicular vectors
		var _axisX = PointB.X - PointA.X;
		var _axisY = PointB.Y - PointA.Y;
		var _axisZ = PointB.Z - PointA.Z;
		var _axisLen = point_distance_3d(0, 0, 0, _axisX, _axisY, _axisZ);

		if (_axisLen < 0.00001)
		{
			// Degenerate capsule, draw as sphere
			var _sphere = new BBMOD_SphereCollider(PointA, Radius);
			vertex_end(_vbuffer);
			vertex_submit(_vbuffer, pr_linelist, -1);
			_sphere.DrawDebug(_color, _alpha);
			return self;
		}

		// Normalized axis
		var _axisDirX = _axisX / _axisLen;
		var _axisDirY = _axisY / _axisLen;
		var _axisDirZ = _axisZ / _axisLen;

		// Find perpendicular vector
		var _perpX, _perpY, _perpZ;
		if (abs(_axisDirY) < 0.9)
		{
			// Cross with up vector
			_perpX = _axisDirZ * 1.0 - _axisDirY * 0.0;
			_perpY = _axisDirX * 0.0 - _axisDirZ * 0.0;
			_perpZ = _axisDirY * 0.0 - _axisDirX * 1.0;
		}
		else
		{
			// Cross with right vector
			_perpX = _axisDirZ * 0.0 - _axisDirY * 1.0;
			_perpY = _axisDirX * 1.0 - _axisDirZ * 1.0;
			_perpZ = _axisDirY * 1.0 - _axisDirX * 0.0;
		}
		var _perpLen = point_distance_3d(0, 0, 0, _perpX, _perpY, _perpZ);
		_perpX /= _perpLen;
		_perpY /= _perpLen;
		_perpZ /= _perpLen;

		// Draw circles along the capsule
		for (var _seg = 0; _seg <= _segments; _seg++)
		{
			var _t = _seg / _segments;
			var _cX = PointA.X + _axisX * _t;
			var _cY = PointA.Y + _axisY * _t;
			var _cZ = PointA.Z + _axisZ * _t;

			var _angle = 0.0;
			var _ldirx1 = lengthdir_x(Radius, _angle);
			var _ldiry1 = lengthdir_y(Radius, _angle);

			repeat(_steps)
			{
				var _ldirx2 = lengthdir_x(Radius, _angle + _inc);
				var _ldiry2 = lengthdir_y(Radius, _angle + _inc);

				// Rotate circle to be perpendicular to axis
				// Using _perp as one axis and axis cross perp as another
				var _bX = _axisDirY * _perpZ - _axisDirZ * _perpY;
				var _bY = _axisDirZ * _perpX - _axisDirX * _perpZ;
				var _bZ = _axisDirX * _perpY - _axisDirY * _perpX;

				var _p1X = _cX + _perpX * _ldirx1 + _bX * _ldiry1;
				var _p1Y = _cY + _perpY * _ldirx1 + _bY * _ldiry1;
				var _p1Z = _cZ + _perpZ * _ldirx1 + _bZ * _ldiry1;

				var _p2X = _cX + _perpX * _ldirx2 + _bX * _ldiry2;
				var _p2Y = _cY + _perpY * _ldirx2 + _bY * _ldiry2;
				var _p2Z = _cZ + _perpZ * _ldirx2 + _bZ * _ldiry2;

				vertex_position_3d(_vbuffer, _p1X, _p1Y, _p1Z);
				vertex_color(_vbuffer, _color, _alpha);
				vertex_position_3d(_vbuffer, _p2X, _p2Y, _p2Z);
				vertex_color(_vbuffer, _color, _alpha);

				_ldirx1 = _ldirx2;
				_ldiry1 = _ldiry2;
				_angle += _inc;
			}
		}

		vertex_end(_vbuffer);
		vertex_submit(_vbuffer, pr_linelist, -1);

		return self;
	};
}
