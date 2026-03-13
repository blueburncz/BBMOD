/// @module Astronomy
///
/// Astronomical position calculations for the sun, moon, and star field.
/// Based on Jean Meeus, "Astronomical Algorithms" (2nd ed.).
///
/// Coordinate convention used throughout:
///   World space is Z-up, North = +Y, East = +X.
///   Azimuth is measured clockwise from North (standard astronomical convention).
///   The returned BBMOD_Vec3 direction points FROM the observer TO the body.

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/// @func __astro_wrap360(_deg)
/// @desc Wraps a degree value to [0, 360).
function __astro_wrap360(_deg)
{
	return _deg - 360.0 * floor(_deg / 360.0);
}

/// @func __astro_wrap24(_h)
/// @desc Wraps an hour value to [0, 24).
function __astro_wrap24(_h)
{
	return _h - 24.0 * floor(_h / 24.0);
}

// ---------------------------------------------------------------------------
// Julian Date
// ---------------------------------------------------------------------------

/// @func bbmod_astronomy_julian_date(_year, _month, _day, _hour, _minute, _second, _utcOffset)
///
/// @desc Computes the Julian Date (JD) for a proleptic Gregorian calendar date.
///
/// @param {Real} _year    Full year (e.g. 2024).
/// @param {Real} _month   Month 1-12.
/// @param {Real} _day     Day of month 1-31.
/// @param {Real} _hour    Hour 0-23 (local time).
/// @param {Real} _minute  Minute 0-59.
/// @param {Real} _second  Second 0-59.
/// @param {Real} _utcOffset  Hours east of UTC (e.g. +1 for CET, -5 for EST).
///
/// @return {Real} Julian Date.
function bbmod_astronomy_julian_date(_year, _month, _day, _hour, _minute, _second, _utcOffset)
{
	// Convert local time to UT (decimal hours).
	var _ut = (_hour - _utcOffset) + _minute / 60.0 + _second / 3600.0;

	var _y = _year;
	var _m = _month;
	if (_m <= 2) { _y -= 1; _m += 12; }

	var _a = floor(_y / 100.0);
	var _b = 2.0 - _a + floor(_a / 4.0);

	return floor(365.25 * (_y + 4716.0))
	     + floor(30.6001 * (_m + 1.0))
	     + _day + _b - 1524.5
	     + _ut / 24.0;
}

// ---------------------------------------------------------------------------
// Greenwich Mean Sidereal Time
// ---------------------------------------------------------------------------

/// @func __astro_gmst(_jd)
/// @desc Returns GMST in degrees for the given Julian Date.
///       Formula from Meeus §12 (IAU 1982 GMST).
function __astro_gmst(_jd)
{
	var _T  = (_jd - 2451545.0) / 36525.0;
	var _st = 280.46061837
	        + 360.98564736629 * (_jd - 2451545.0)
	        + 0.000387933 * _T * _T
	        - _T * _T * _T / 38710000.0;
	return __astro_wrap360(_st);
}

/// @func bbmod_astronomy_local_sidereal_time(_longitude, _jd)
///
/// @desc Returns the Local Sidereal Time (LST) in degrees for a given
///       geographic longitude and Julian Date.
///
/// @param {Real} _longitude  Observer's longitude in degrees (East positive).
/// @param {Real} _jd         Julian Date.
///
/// @return {Real} LST in degrees [0, 360).
function bbmod_astronomy_local_sidereal_time(_longitude, _jd)
{
	return __astro_wrap360(__astro_gmst(_jd) + _longitude);
}

// ---------------------------------------------------------------------------
// Horizontal → direction vector
// ---------------------------------------------------------------------------

/// @func __astro_horiz_to_vec3(_alt, _az)
/// @desc Converts altitude/azimuth (degrees) to a Z-up world-space direction.
///       North = +Y, East = +X, Up = +Z.
///       Azimuth measured clockwise from North.
function __astro_horiz_to_vec3(_alt, _az)
{
	var _x = dcos(_alt) * dsin(_az);  // East
	var _y = dcos(_alt) * dcos(_az);  // North
	var _z = dsin(_alt);              // Up
	return new BBMOD_Vec3(_x, _y, _z);
}

/// @func __astro_equatorial_to_horiz(_lat, _lst, _ra, _dec)
/// @desc Converts equatorial (RA/Dec, degrees) to horizontal (Alt/Az, degrees).
/// @param {Real} _lat  Observer latitude (degrees, North positive).
/// @param {Real} _lst  Local Sidereal Time (degrees).
/// @param {Real} _ra   Right ascension (degrees).
/// @param {Real} _dec  Declination (degrees).
/// @return {Array<Real>} [altitude, azimuth] in degrees.
function __astro_equatorial_to_horiz(_lat, _lst, _ra, _dec)
{
	var _H   = __astro_wrap360(_lst - _ra); // Local Hour Angle
	var _alt = radtodeg(arcsin(
		dsin(_lat) * dsin(_dec) + dcos(_lat) * dcos(_dec) * dcos(_H)));
	var _az  = radtodeg(arctan2(
		-dcos(_dec) * dsin(_H),
		dcos(_lat) * dsin(_dec) - dsin(_lat) * dcos(_dec) * dcos(_H)));
	return [_alt, __astro_wrap360(_az)];
}

// ---------------------------------------------------------------------------
// Sun position
// ---------------------------------------------------------------------------

/// @func bbmod_astronomy_sun_direction(_latitude, _longitude, _jd)
///
/// @desc Computes the direction from the observer toward the sun.
///       Accuracy: ~0.01° in longitude, adequate for real-time sky rendering.
///
/// @param {Real} _latitude   Observer latitude in degrees (North positive).
/// @param {Real} _longitude  Observer longitude in degrees (East positive).
/// @param {Real} _jd         Julian Date (from bbmod_astronomy_julian_date).
///
/// @return {Struct.BBMOD_Vec3} Normalized world-space direction to the sun.
///   Negative Z means the sun is below the horizon.
function bbmod_astronomy_sun_direction(_latitude, _longitude, _jd)
{
	var _T = (_jd - 2451545.0) / 36525.0;

	// Geometric mean longitude and anomaly (degrees).
	var _L0 = __astro_wrap360(280.46646  + 36000.76983  * _T);
	var _M  = __astro_wrap360(357.52911  + 35999.05029  * _T - 0.0001537 * _T * _T);

	// Equation of centre.
	var _C = (1.914602 - 0.004817 * _T - 0.000014 * _T * _T) * dsin(_M)
	       + (0.019993 - 0.000101 * _T) * dsin(2.0 * _M)
	       +  0.000289                  * dsin(3.0 * _M);

	// Sun's apparent longitude (corrects for nutation and aberration).
	var _Lsun  = _L0 + _C;
	var _Omega = __astro_wrap360(125.04 - 1934.136 * _T);
	var _lam   = _Lsun - 0.00569 - 0.00478 * dsin(_Omega);

	// Obliquity of the ecliptic.
	var _eps0 = 23.0 + 26.0/60.0 + 21.448/3600.0
	          - (46.8150 * _T + 0.00059 * _T * _T - 0.001813 * _T * _T * _T) / 3600.0;
	var _eps  = _eps0 + 0.00256 * dcos(_Omega);

	// Right ascension and declination (degrees).
	var _ra  = __astro_wrap360(radtodeg(arctan2(dcos(_eps) * dsin(_lam), dcos(_lam))));
	var _dec = radtodeg(arcsin(dsin(_eps) * dsin(_lam)));

	// Convert to horizontal.
	var _lst    = bbmod_astronomy_local_sidereal_time(_longitude, _jd);
	var _horiz  = __astro_equatorial_to_horiz(_latitude, _lst, _ra, _dec);

	return __astro_horiz_to_vec3(_horiz[0], _horiz[1]);
}

// ---------------------------------------------------------------------------
// Moon position
// ---------------------------------------------------------------------------

/// @func bbmod_astronomy_moon_direction(_latitude, _longitude, _jd)
///
/// @desc Computes the direction from the observer toward the moon.
///       Simplified Meeus (Chapter 22), accuracy ≈ 0.5° — sufficient for
///       sky rendering.
///
/// @param {Real} _latitude   Observer latitude in degrees (North positive).
/// @param {Real} _longitude  Observer longitude in degrees (East positive).
/// @param {Real} _jd         Julian Date.
///
/// @return {Struct.BBMOD_Vec3} Normalized world-space direction to the moon.
function bbmod_astronomy_moon_direction(_latitude, _longitude, _jd)
{
	var _d = _jd - 2451545.0; // days from J2000.0
	var _T = _d / 36525.0;

	// Fundamental arguments (degrees).
	var _Lm = __astro_wrap360(218.3164477 + 13.17639648 * _d);   // mean longitude
	var _M  = __astro_wrap360(134.9633964 + 13.06499295 * _d);   // mean anomaly
	var _F  = __astro_wrap360(93.2720950  + 13.22935024 * _d);   // arg of latitude
	var _D  = __astro_wrap360(297.8501921 + 12.19074912 * _d);   // mean elongation
	var _Ms = __astro_wrap360(357.5291092 +  0.98560028 * _d);   // sun mean anomaly

	// Ecliptic longitude corrections (dominant terms, Meeus Table 45.A).
	var _lam = _Lm
	    + 6.288774 * dsin(_M)
	    + 1.274027 * dsin(2.0*_D - _M)
	    + 0.658314 * dsin(2.0*_D)
	    + 0.213618 * dsin(2.0*_M)
	    - 0.185116 * dsin(_Ms)
	    - 0.114332 * dsin(2.0*_F)
	    + 0.058793 * dsin(2.0*_D - 2.0*_M)
	    + 0.057066 * dsin(2.0*_D - _Ms - _M)
	    + 0.053322 * dsin(2.0*_D + _M)
	    + 0.045758 * dsin(2.0*_D - _Ms)
	    - 0.040923 * dsin(_Ms - _M)
	    - 0.034720 * dsin(_D)
	    - 0.030383 * dsin(_Ms + _M);

	// Ecliptic latitude corrections.
	var _bet = 0.0
	    + 5.128122 * dsin(_F)
	    + 0.280602 * dsin(_M  + _F)
	    + 0.277693 * dsin(_M  - _F)
	    + 0.173237 * dsin(2.0*_D - _F)
	    + 0.055413 * dsin(2.0*_D - _M + _F)
	    + 0.046272 * dsin(2.0*_D - _M - _F)
	    + 0.032573 * dsin(2.0*_D + _F)
	    + 0.017198 * dsin(2.0*_M + _F)
	    + 0.009267 * dsin(2.0*_D + _M - _F)
	    + 0.008823 * dsin(2.0*_M - _F);

	// Obliquity and equatorial coordinates.
	var _eps = 23.439291 - 0.013004 * _T;

	var _sinLam = dsin(_lam);
	var _cosLam = dcos(_lam);
	var _sinBet = dsin(_bet);
	var _cosBet = dcos(_bet);
	var _sinEps = dsin(_eps);
	var _cosEps = dcos(_eps);

	var _ra  = __astro_wrap360(radtodeg(arctan2(
		_sinLam * _cosEps - _sinBet * _sinEps / _cosBet,
		_cosLam)));
	var _dec = radtodeg(arcsin(_sinBet * _cosEps + _cosBet * _sinEps * _sinLam));

	// Convert to horizontal.
	var _lst   = bbmod_astronomy_local_sidereal_time(_longitude, _jd);
	var _horiz = __astro_equatorial_to_horiz(_latitude, _lst, _ra, _dec);

	return __astro_horiz_to_vec3(_horiz[0], _horiz[1]);
}
