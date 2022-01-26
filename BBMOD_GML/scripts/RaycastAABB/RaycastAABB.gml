/// @func RaycastAABB(_origin, _direction, _min, _max)
/// @desc Checks whether a ray intersects an AABB.
/// @param {BBMOD_Vec3} _origin The origin of the ray.
/// @param {BBMOD_Vec3} _direction The ray's direction.
/// @param {BBMOD_Vec3} _min The minimum coordinate of the AABB.
/// @param {BBMOD_Vec3} _max The maxmimum coordinate of the AABB.
/// @return {real} Returns the distance (from the origin) at which the
/// ray intersects the AABB. If -1 is returned, then they do not in
/// intersect.
/// @source https://gamephysicscookbook.com/
function RaycastAABB(_origin, _direction, _min, _max)
{
	static CMP = function (_x, _y) {
		return (abs(_x - _y) <= math_get_epsilon() * max(1.0, abs(_x), abs(_y)));
	};

	_direction = _direction.Normalize();

	var _t1 = (_min.X - _origin.X) / (CMP(_direction.X, 0.0) ? 0.00001 : _direction.X);
	var _t2 = (_max.X - _origin.X) / (CMP(_direction.X, 0.0) ? 0.00001 : _direction.X);
	var _t3 = (_min.Y - _origin.Y) / (CMP(_direction.Y, 0.0) ? 0.00001 : _direction.Y);
	var _t4 = (_max.Y - _origin.Y) / (CMP(_direction.Y, 0.0) ? 0.00001 : _direction.Y);
	var _t5 = (_min.Z - _origin.Z) / (CMP(_direction.Z, 0.0) ? 0.00001 : _direction.Z);
	var _t6 = (_max.Z - _origin.Z) / (CMP(_direction.Z, 0.0) ? 0.00001 : _direction.Z);

	var _tmin = max(max(min(_t1, _t2), min(_t3, _t4)), min(_t5, _t6));
	var _tmax = min(min(max(_t1, _t2), max(_t3, _t4)), max(_t5, _t6));

	if (_tmax < 0.0
		|| _tmin > _tmax)
	{
		return -1.0;
	}

	if (_tmin < 0.0)
	{
		return _tmax;
	}

	return _tmin;
}