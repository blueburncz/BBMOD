if (true)
{
	var _surface = bbmod_surface_check(-1, 2, 2, surface_rgba8unorm, false);
	surface_set_target(_surface);
	draw_clear_alpha(make_color_rgb(32, 64, 128), 1.0);
	surface_reset_target();
	var _runtimeSprite = sprite_create_from_surface(
		_surface, 0, 0, 2, 2, false, false, 0, 0);
	surface_free(_surface);
	var _externalSpritePath = working_directory + "bbmod_lens_flare_sprite.png";
	sprite_save_strip(_runtimeSprite, _externalSpritePath);

	var _lensFlare = new BBMOD_LensFlare(
		new BBMOD_Color(0.2, 0.4, 0.8, 0.75),
		new BBMOD_Vec3(1.0, 2.0, 3.0),
		64.0,
		0.6,
		0.25,
		new BBMOD_Vec3(0.0, 1.0, 0.0),
		15.0,
		45.0);
	_lensFlare.add_element(new BBMOD_LensFlareElement(
		BBMOD_SprLensFlareHeptagon,
		2,
		new BBMOD_Vec2(-0.3, 0.1),
		new BBMOD_Vec2(0.5, 0.75),
		new BBMOD_Vec2(0.25, 0.5),
		new BBMOD_Vec2(1.25, 1.5),
		new BBMOD_Color(1.0, 0.5, 0.25, 0.8),
		true,
		12.0,
		true,
		true,
		true));
	_lensFlare.add_element(new BBMOD_LensFlareElement(
		BBMOD_SprLensFlareHeptagon,
		0,
		new BBMOD_Vec2(0.2, -0.4),
		new BBMOD_Vec2(0.75, 0.5),
		undefined,
		undefined,
		BBMOD_C_WHITE,
		false,
		-8.0,
		false,
		false,
		false));
	var _externalElement = new BBMOD_LensFlareElement(
		_runtimeSprite,
		0,
		new BBMOD_Vec2(0.1, 0.2));
	_externalElement.SpritePath = _externalSpritePath;
	_lensFlare.add_element(_externalElement);
	var _embeddedElement = new BBMOD_LensFlareElement(
		_runtimeSprite,
		0,
		new BBMOD_Vec2(-0.2, -0.1));
	_embeddedElement.SpriteOwned = true;
	_lensFlare.add_element(_embeddedElement);

	var _path = working_directory + "bbmod_lens_flare_test.bbflare";
	_lensFlare.to_file(_path);
	var _lensFlareClone = new BBMOD_LensFlare().from_file(_path);

	bbmod_assert(_lensFlareClone.IsLoaded);
	bbmod_assert(abs(_lensFlareClone.Tint.Red - _lensFlare.Tint.Red) < 0.001);
	bbmod_assert(abs(_lensFlareClone.Tint.Alpha - _lensFlare.Tint.Alpha) < 0.001);
	bbmod_assert(abs(_lensFlareClone.Position.X - _lensFlare.Position.X) < 0.001);
	bbmod_assert(abs(_lensFlareClone.Direction.Y - _lensFlare.Direction.Y) < 0.001);
	bbmod_assert(abs(_lensFlareClone.Range - _lensFlare.Range) < 0.001);
	bbmod_assert(abs(_lensFlareClone.Falloff - _lensFlare.Falloff) < 0.001);
	bbmod_assert(abs(_lensFlareClone.DepthThreshold - _lensFlare.DepthThreshold) < 0.001);
	bbmod_assert(abs(_lensFlareClone.AngleInner - _lensFlare.AngleInner) < 0.001);
	bbmod_assert(abs(_lensFlareClone.AngleOuter - _lensFlare.AngleOuter) < 0.001);

	var _lensFlareElements = _lensFlareClone.get_elements();
	bbmod_assert(array_length(_lensFlareElements) == 4);
	bbmod_assert(instanceof(_lensFlareElements[0]) == "BBMOD_LensFlareElement");
	bbmod_assert(_lensFlareElements[0].Sprite == BBMOD_SprLensFlareHeptagon);
	bbmod_assert(_lensFlareElements[0].Subimage == 2);
	bbmod_assert(abs(_lensFlareElements[0].Offset.X - (-0.3)) < 0.001);
	bbmod_assert(abs(_lensFlareElements[0].ScaleByDistanceMax.Y - 1.5) < 0.001);
	bbmod_assert(_lensFlareElements[0].ApplyStarburst);
	bbmod_assert(_lensFlareElements[1].Subimage == 0);
	bbmod_assert(abs(_lensFlareElements[1].Angle - (-8.0)) < 0.001);
	bbmod_assert(_lensFlareElements[2].SpritePath == _externalSpritePath);
	bbmod_assert(_lensFlareElements[2].SpriteOwned);
	bbmod_assert(_lensFlareElements[3].SpriteOwned);

	var _roundTripPath = working_directory + "bbmod_lens_flare_roundtrip.bbflare";
	_lensFlareClone.to_file(_roundTripPath);
	var _originalBuffer = buffer_load(_path);
	var _roundTripBuffer = buffer_load(_roundTripPath);
	bbmod_assert(buffer_get_size(_originalBuffer) == buffer_get_size(_roundTripBuffer));
	buffer_seek(_originalBuffer, buffer_seek_start, 0);
	buffer_seek(_roundTripBuffer, buffer_seek_start, 0);
	for (var i = 0; i < buffer_get_size(_originalBuffer); ++i)
	{
		bbmod_assert(
			buffer_read(_originalBuffer, buffer_u8)
			== buffer_read(_roundTripBuffer, buffer_u8));
	}
	buffer_delete(_originalBuffer);
	buffer_delete(_roundTripBuffer);

	var _lensFlareManager = new BBMOD_ResourceManager();
	var _managedLensFlare = _lensFlareManager.load_sync(_path);
	bbmod_assert(
		_managedLensFlare.get_elements()[0].Sprite == BBMOD_SprLensFlareHeptagon);
	_managedLensFlare.free();
	_lensFlareManager.destroy();

	file_delete(_externalSpritePath);
	var _missingDependencyFailed = false;
	try
	{
		new BBMOD_LensFlare().from_file(_path);
	}
	catch (_error)
	{
		_missingDependencyFailed = true;
	}
	bbmod_assert(_missingDependencyFailed);

	var _invalidPath = working_directory + "bbmod_invalid_lens_flare.bbflare";
	var _invalidBuffer = buffer_create(1, buffer_grow, 1);
	buffer_write(_invalidBuffer, buffer_string, "INVALID");
	buffer_save(_invalidBuffer, _invalidPath);
	buffer_delete(_invalidBuffer);
	var _invalidFileFailed = false;
	try
	{
		new BBMOD_LensFlare().from_file(_invalidPath);
	}
	catch (_error)
	{
		_invalidFileFailed = true;
	}
	bbmod_assert(_invalidFileFailed);

	var _unsupportedVersionPath = working_directory
		+ "bbmod_unsupported_lens_flare.bbflare";
	var _unsupportedVersionBuffer = buffer_create(1, buffer_grow, 1);
	buffer_write(_unsupportedVersionBuffer, buffer_string, "BBFLARE");
	buffer_write(_unsupportedVersionBuffer, buffer_u32, 99);
	buffer_save(_unsupportedVersionBuffer, _unsupportedVersionPath);
	buffer_delete(_unsupportedVersionBuffer);
	var _unsupportedVersionFailed = false;
	try
	{
		new BBMOD_LensFlare().from_file(_unsupportedVersionPath);
	}
	catch (_error)
	{
		_unsupportedVersionFailed = true;
	}
	bbmod_assert(_unsupportedVersionFailed);

	var _unknownConstructorPath = working_directory
		+ "bbmod_unknown_lens_flare_constructor.bbflare";
	var _unknownConstructorBuffer = buffer_create(1, buffer_grow, 1);
	buffer_write(_unknownConstructorBuffer, buffer_string, "BBFLARE");
	buffer_write(_unknownConstructorBuffer, buffer_u32, 2);
	new BBMOD_Color().ToBuffer(_unknownConstructorBuffer);
	buffer_write(_unknownConstructorBuffer, buffer_u8, 0);
	buffer_write(_unknownConstructorBuffer, buffer_f64, 1.0);
	buffer_write(_unknownConstructorBuffer, buffer_f64, 0.8);
	buffer_write(_unknownConstructorBuffer, buffer_f64, 1.0);
	buffer_write(_unknownConstructorBuffer, buffer_u8, 0);
	buffer_write(_unknownConstructorBuffer, buffer_u8, 0);
	buffer_write(_unknownConstructorBuffer, buffer_u8, 0);
	buffer_write(_unknownConstructorBuffer, buffer_u32, 1);
	buffer_write(
		_unknownConstructorBuffer,
		buffer_string,
		"BBMOD_UnknownLensFlareElement");
	buffer_save(_unknownConstructorBuffer, _unknownConstructorPath);
	buffer_delete(_unknownConstructorBuffer);
	var _unknownConstructorFailed = false;
	try
	{
		new BBMOD_LensFlare().from_file(_unknownConstructorPath);
	}
	catch (_error)
	{
		_unknownConstructorFailed = true;
	}
	bbmod_assert(_unknownConstructorFailed);

	_lensFlareClone.destroy();
	_lensFlare.destroy();
	file_delete(_path);
	file_delete(_roundTripPath);
	file_delete(_invalidPath);
	file_delete(_unsupportedVersionPath);
	file_delete(_unknownConstructorPath);
}
