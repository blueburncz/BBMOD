/// @enum Enumeration of frustum planes.
enum BBMOD_EFrustumPlane
{
	/// @member The left plane.
	Left,
	/// @member The right plane.
	Right,
	/// @member The top plane.
	Top,
	/// @member The bottom plane.
	Bottom,
	/// @member The near plane.
	Near,
	/// @member The far plane.
	Far,
	/// @member Total number of frustum planes.
	SIZE
};

/// @func BBMOD_FrustumCollider()
///
/// @extends BBMOD_Collider
///
/// @desc A frustum collider.
///
/// @see BBMOD_AABBCollider
/// @see BBMOD_PlaneCollider
/// @see BBMOD_SphereCollider
function BBMOD_FrustumCollider()
	: BBMOD_Collider() constructor
{
	/// @var {Array<Struct.BBMOD_PlaneCollider>}
	/// @see BBMOD_PlaneCollider
	/// @see BBMOD_EFrustumPlane
	Planes = [
		new BBMOD_PlaneCollider(),
		new BBMOD_PlaneCollider(),
		new BBMOD_PlaneCollider(),
		new BBMOD_PlaneCollider(),
		new BBMOD_PlaneCollider(),
		new BBMOD_PlaneCollider(),
	];

	/// @func FromViewProjectionMatrix(_vp)
	///
	/// @desc Initializes the frustum from a view-projection matrix.
	///
	/// @param {Array<Real>} _vp The view-projection matrix.
	///
	/// @return {Struct.BBMOD_FrustumCollider} Returns `self`.
	static FromViewProjectionMatrix = function (_vp) {
		var _col1 = new BBMOD_Vec3(_vp[0], _vp[4], _vp[ 8]);
		var _col2 = new BBMOD_Vec3(_vp[1], _vp[5], _vp[ 9]);
		var _col3 = new BBMOD_Vec3(_vp[2], _vp[6], _vp[10]);
		var _col4 = new BBMOD_Vec3(_vp[3], _vp[7], _vp[11]);

		// Find plane magnitudes
		Planes[BBMOD_EFrustumPlane.Left].Normal = _col4.Add(_col1);
		Planes[BBMOD_EFrustumPlane.Right].Normal = _col4.Sub(_col1);
		Planes[BBMOD_EFrustumPlane.Bottom].Normal = _col4.Add(_col2);
		Planes[BBMOD_EFrustumPlane.Top].Normal = _col4.Sub(_col2);
		Planes[BBMOD_EFrustumPlane.Near].Normal = /*_col4.Add(*/_col3/*)*/;
		Planes[BBMOD_EFrustumPlane.Far].Normal = _col4.Sub(_col3);

		// Find plane distances
		var _vp12 = _vp[12];
		var _vp13 = _vp[13];
		var _vp14 = _vp[14];
		var _vp15 = _vp[15];

		Planes[BBMOD_EFrustumPlane.Left].Distance = _vp15 + _vp12;
		Planes[BBMOD_EFrustumPlane.Right].Distance = _vp15 - _vp12;
		Planes[BBMOD_EFrustumPlane.Bottom].Distance = _vp15 + _vp13;
		Planes[BBMOD_EFrustumPlane.Top].Distance = _vp15 - _vp13;
		Planes[BBMOD_EFrustumPlane.Near].Distance = /*_vp15 +*/ _vp14;
		Planes[BBMOD_EFrustumPlane.Far].Distance = _vp15 - _vp14;

		// Normalize all 6 planes
		for (var i = 0; i < BBMOD_EFrustumPlane.SIZE; ++i)
		{
			with (Planes[i])
			{
				var _n = 1.0 / Normal.Length();
				Normal = Normal.Scale(_n);
				Distance *= _n;
			}
		}

		return self;
	};

	/// @func FromCamera(_camera)
	///
	/// @desc Initializes the frustum using a camera's view-projection matrix.
	///
	/// @param {Struct.BBMOD_BaseCamera} _camera The camera.
	///
	/// @return {Struct.BBMOD_FrustumCollider} Returns `self`.
	///
	/// @see BBMOD_BaseCamera.ViewProjectionMatrix
	static FromCamera = function (_camera) {
		gml_pragma("forceinline");
		FromViewProjectionMatrix(_camera.ViewProjectionMatrix);
		return self;
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L1861
	static TestPoint = function (_point) {
		for (var i = 0; i < BBMOD_EFrustumPlane.SIZE; ++i)
		{
			var _plane = Planes[i];
			if ((_point.Dot(_plane.Normal) + _plane.Distance) < 0.0)
			{
				return false;
			}
		}
		return true;
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L1874
	static TestSphere = function (_sphere) {
		for (var i = 0; i < BBMOD_EFrustumPlane.SIZE; ++i)
		{
			var _plane = Planes[i];
			if ((_sphere.Position.Dot(_plane.Normal) + _plane.Distance) < -_sphere.Radius)
			{
				return false;
			}
		}
		return true;
	};
}
