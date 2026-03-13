
var _dt = delta_time / 1_000_000.0;

var _astroHour = ((astroHourAccum mod 24) + 24) mod 24;
var _jd = astroJdEpoch + astroHourAccum / 24.0;

var _sunVec = bbmod_astronomy_sun_direction(astroLat, astroLon, _jd);
var _sx = _sunVec.X;
var _sy = _sunVec.Y;
var _sz = _sunVec.Z;

var _moonVec = bbmod_astronomy_moon_direction(astroLat, astroLon, _jd);

var _lst = bbmod_astronomy_local_sidereal_time(astroLon, _jd);
bbmod_shader_set_global_f("bbmod_StarLST", _lst);

bbmod_shader_set_global_f3("bbmod_SunDirection", _sx, _sy, _sz);
bbmod_shader_set_global_sampler(BBMOD_U_TRANSMITTANCE_LUT, bbmod_sky_transmittance_lut_get());

var _nightIntensity = clamp((-_sz + 0.1) / 0.2, 0.0, 1.0);
_nightIntensity = _nightIntensity * _nightIntensity * (3.0 - 2.0 * _nightIntensity);
bbmod_shader_set_global_f("bbmod_NightIntensity", _nightIntensity);
bbmod_shader_set_global_f("bbmod_StarTime", current_time / 1000.0);
bbmod_shader_set_global_f("bbmod_LightDirectionalDiskSize", lerp(0.0093, 0.0436, _nightIntensity));

var _targetExposure = lerp(1.0, 2.5, _nightIntensity);
var _expBlend = clamp(_dt / 10.0, 0.0, 1.0); // ~10 s half-life
camera.Exposure += (_targetExposure - camera.Exposure) * _expBlend;

if (astroJumped)
{
	astroJumped = false;
	probe.NeedsUpdate = true;

	bbmod_shader_set_global_f3("bbmod_MoonDirection", _moonVec.X, _moonVec.Y, _moonVec.Z);

	// sun.Direction = light travel direction = FROM sun/moon TO earth.
	if (_nightIntensity >= 0.5)
	{
		sun.Direction.Set(-_moonVec.X, -_moonVec.Y, -_moonVec.Z);
	}
	else
	{
		sun.Direction.Set(-_sx, -_sy, -_sz);
	}

	var _sunColor = bbmod_sky_sun_transmittance_color(_sz);
	sun.Color.Red = lerp(_sunColor.Red, 10, _nightIntensity);
	sun.Color.Green = lerp(_sunColor.Green, 12, _nightIntensity);
	sun.Color.Blue = lerp(_sunColor.Blue, 18, _nightIntensity);
}

if (mouse_check_button_pressed(mb_right))
{
	camera.set_mouselook(true);
	window_set_cursor(cr_none);
}
else if (keyboard_check_pressed(vk_escape))
{
	camera.set_mouselook(false);
	window_set_cursor(cr_default);
}

var _moveSpeed = 0.5;
var _speed = (keyboard_check(vk_shift) ? 2 : 1) * _moveSpeed;
var _forward = (keyboard_check(ord("W")) - keyboard_check(ord("S"))) * _speed;
var _right = (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * _speed;
var _up = (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * _speed;

x += lengthdir_x(_forward, camera.Direction) + lengthdir_x(_right, camera.Direction - 90);
y += lengthdir_y(_forward, camera.Direction) + lengthdir_y(_right, camera.Direction - 90);
z += _up;

var _directionPrev = camera.Direction;
var _directionUpPrev = camera.DirectionUp;

UI.Update();
clouds.update(delta_time, x, y, z);
renderer.update(delta_time);

camera.AspectRatio = surface_get_width(application_surface) / surface_get_height(application_surface);
camera.update(delta_time);

var _fogFwd = camera.get_forward();
var _fogRgt = camera.get_right();
var _fogUp = camera.get_up();
bbmod_shader_set_global_f3("bbmod_FogCamForward", _fogFwd.X, _fogFwd.Y, _fogFwd.Z);
bbmod_shader_set_global_f3("bbmod_FogCamRight", _fogRgt.X, _fogRgt.Y, _fogRgt.Z);
bbmod_shader_set_global_f3("bbmod_FogCamUp", _fogUp.X, _fogUp.Y, _fogUp.Z);
bbmod_shader_set_global_f("bbmod_FogTanHalfFovY", dtan(camera.Fov * 0.5));
bbmod_shader_set_global_f("bbmod_FogAspect", camera.AspectRatio);

var _scale = 8.0;
directionalBlur.Vector.Set(
	angle_difference(camera.Direction, _directionPrev) * _scale,
	angle_difference(camera.DirectionUp, _directionUpPrev) * _scale);
var _length = directionalBlur.Vector.Length();
_length = (_length > 0.0) ? _length : 1.0;
directionalBlur.Step = 2.0 / min(_length, 32.0);
