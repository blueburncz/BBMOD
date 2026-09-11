if (true)
{
	var _lights = [
		new BBMOD_DirectionalLight(
			new BBMOD_Color(0.8, 0.7, 0.6, 1.0), new BBMOD_Vec3(0.0, 0.0, 1.0)),
		new BBMOD_PointLight(
			new BBMOD_Color(0.4, 0.5, 0.6, 1.0), new BBMOD_Vec3(4.0, 5.0, 6.0), 12.0),
		new BBMOD_SpotLight(
			new BBMOD_Color(0.2, 0.3, 0.4, 1.0), new BBMOD_Vec3(7.0, 8.0, 9.0),
			16.0, new BBMOD_Vec3(0.0, 1.0, 0.0), 15.0, 30.0),
	];
	var _buffer = buffer_create(1, buffer_grow, 1);
	for (var _index = 0; _index < array_length(_lights); ++_index)
	{
		bbmod_struct_to_buffer(_buffer, _lights[_index]);
	}
	buffer_seek(_buffer, buffer_seek_start, 0);
	var _directional = bbmod_struct_from_buffer(_buffer);
	var _point = bbmod_struct_from_buffer(_buffer);
	var _spot = bbmod_struct_from_buffer(_buffer);
	bbmod_assert(instanceof(_directional) == "BBMOD_DirectionalLight");
	bbmod_assert(_directional.Direction.Z == 1.0);
	bbmod_assert(instanceof(_point) == "BBMOD_PointLight");
	bbmod_assert(_point.Range == 12.0);
	bbmod_assert(instanceof(_spot) == "BBMOD_SpotLight");
	bbmod_assert(_spot.AngleOuter == 30.0);
	buffer_delete(_buffer);

	var _ibl = new BBMOD_ImageBasedLight();
	_ibl.TextureSprite = BBMOD_SprWhite;
	_ibl.TextureOwned = false;
	_ibl.TextureSubimage = 0;
	var _iblBuffer = buffer_create(1, buffer_grow, 1);
	_ibl.to_buffer(_iblBuffer);
	buffer_seek(_iblBuffer, buffer_seek_start, 0);
	var _iblClone = new BBMOD_ImageBasedLight().from_buffer(_iblBuffer);
	bbmod_assert(_iblClone.TextureSprite == BBMOD_SprWhite);
	bbmod_assert(!_iblClone.TextureOwned);
	buffer_delete(_iblBuffer);
	_ibl.destroy();
	_iblClone.destroy();

	var _probe = new BBMOD_ReflectionProbe(new BBMOD_Vec3(1.0, 2.0, 3.0));
	_probe.Enabled = false;
	_probe.EnableShadows = false;
	_probe.Infinite = true;
	_probe.Size = new BBMOD_Vec3(4.0, 5.0, 6.0);
	_probe.Resolution = 64;
	var _probeBuffer = buffer_create(1, buffer_grow, 1);
	_probe.to_buffer(_probeBuffer);
	buffer_seek(_probeBuffer, buffer_seek_start, 0);
	var _probeClone = new BBMOD_ReflectionProbe().from_buffer(_probeBuffer);
	bbmod_assert(!_probeClone.Enabled);
	bbmod_assert(!_probeClone.EnableShadows);
	bbmod_assert(_probeClone.Infinite);
	bbmod_assert(_probeClone.Size.Y == 5.0);
	bbmod_assert(_probeClone.Resolution == 64);
	buffer_delete(_probeBuffer);
	_probe.destroy();
	_probeClone.destroy();

	var _invalidBuffer = buffer_create(1, buffer_grow, 1);
	buffer_write(_invalidBuffer, buffer_string, "UnknownSceneStruct");
	buffer_seek(_invalidBuffer, buffer_seek_start, 0);
	var _invalidFailed = false;
	try
	{
		bbmod_struct_from_buffer(_invalidBuffer);
	}
	catch (_error)
	{
		_invalidFailed = true;
	}
	bbmod_assert(_invalidFailed);
	buffer_delete(_invalidBuffer);
}
