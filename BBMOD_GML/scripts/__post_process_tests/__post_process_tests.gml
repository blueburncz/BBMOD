if (true)
{
	var _postProcessor = new BBMOD_PostProcessor();
	_postProcessor.Enabled = false;
	_postProcessor.DesignWidth = 1920.0;
	_postProcessor.DesignHeight = undefined;
	_postProcessor.add_effect(new BBMOD_ChromaticAberrationEffect(
		0.75, new BBMOD_Vec3(-0.5, 0.0, 0.5)));
	_postProcessor.add_effect(new BBMOD_ExposureEffect(1.25));
	_postProcessor.add_effect(new BBMOD_FilmGrainEffect(0.2));
	_postProcessor.add_effect(new BBMOD_GammaCorrectEffect(2.0));
	_postProcessor.add_effect(new BBMOD_MonochromeEffect(0.4, c_white));
	_postProcessor.add_effect(new BBMOD_VignetteEffect(0.8, c_black));

	var _path = working_directory + "bbmod_post_process_test.bbpost";
	_postProcessor.to_file(_path);
	var _postProcessorClone = new BBMOD_PostProcessor().from_file(_path);
	bbmod_assert(_postProcessorClone.IsLoaded);
	bbmod_assert(!_postProcessorClone.Enabled);
	bbmod_assert(_postProcessorClone.DesignWidth == 1920.0);
	bbmod_assert(_postProcessorClone.DesignHeight == undefined);
	bbmod_assert(array_length(_postProcessorClone.Effects) == 6);
	bbmod_assert(
		instanceof(_postProcessorClone.Effects[0])
		== "BBMOD_ChromaticAberrationEffect");
	bbmod_assert(
		abs(_postProcessorClone.Effects[0].Strength - 0.75) < 0.001);
	bbmod_assert(
		instanceof(_postProcessorClone.Effects[1]) == "BBMOD_ExposureEffect");
	bbmod_assert(abs(_postProcessorClone.Effects[1].Exposure - 1.25) < 0.001);
	bbmod_assert(
		instanceof(_postProcessorClone.Effects[5]) == "BBMOD_VignetteEffect");
	bbmod_assert(abs(_postProcessorClone.Effects[5].Strength - 0.8) < 0.001);
	bbmod_assert(_postProcessorClone.Effects[0].PostProcessor == _postProcessorClone);

	var _roundTripPath = working_directory + "bbmod_post_process_roundtrip.bbpost";
	_postProcessorClone.to_file(_roundTripPath);
	var _originalBuffer = buffer_load(_path);
	var _roundTripBuffer = buffer_load(_roundTripPath);
	bbmod_assert(buffer_get_size(_originalBuffer) == buffer_get_size(_roundTripBuffer));
	buffer_delete(_originalBuffer);
	buffer_delete(_roundTripBuffer);

	var _manager = new BBMOD_ResourceManager();
	var _managedPostProcessor = _manager.load_sync(_path);
	bbmod_assert(_managedPostProcessor.IsLoaded);
	bbmod_assert(array_length(_managedPostProcessor.Effects) == 6);
	_managedPostProcessor.free();
	_manager.destroy();

	var _invalidPath = working_directory + "bbmod_invalid_post_process.bbpost";
	var _invalidBuffer = buffer_create(1, buffer_grow, 1);
	buffer_write(_invalidBuffer, buffer_string, "INVALID");
	buffer_save(_invalidBuffer, _invalidPath);
	buffer_delete(_invalidBuffer);
	var _invalidFailed = false;
	try
	{
		new BBMOD_PostProcessor().from_file(_invalidPath);
	}
	catch (_error)
	{
		_invalidFailed = true;
	}
	bbmod_assert(_invalidFailed);

	var _unknownPath = working_directory + "bbmod_unknown_post_process.bbpost";
	var _unknownBuffer = buffer_create(1, buffer_grow, 1);
	buffer_write(_unknownBuffer, buffer_string, "BBPOST");
	buffer_write(_unknownBuffer, buffer_u32, 1);
	buffer_write(_unknownBuffer, buffer_bool, true);
	buffer_write(_unknownBuffer, buffer_bool, true);
	buffer_write(_unknownBuffer, buffer_f64, 1920.0);
	buffer_write(_unknownBuffer, buffer_bool, false);
	buffer_write(_unknownBuffer, buffer_f64, 0.0);
	new BBMOD_Vec3().ToBuffer(_unknownBuffer, buffer_f64);
	buffer_write(_unknownBuffer, buffer_f64, 0.0);
	buffer_write(_unknownBuffer, buffer_f64, 0.0);
	buffer_write(_unknownBuffer, buffer_u32, c_black);
	buffer_write(_unknownBuffer, buffer_u32, BBMOD_EAntialiasing.None);
	buffer_write(_unknownBuffer, buffer_bool, false);
	buffer_write(_unknownBuffer, buffer_bool, false);
	buffer_write(_unknownBuffer, buffer_f64, 1.0);
	buffer_write(_unknownBuffer, buffer_bool, false);
	buffer_write(_unknownBuffer, buffer_f64, 1.0);
	buffer_write(_unknownBuffer, buffer_u32, 1);
	buffer_write(_unknownBuffer, buffer_string, "BBMOD_UnknownPostEffect");
	buffer_save(_unknownBuffer, _unknownPath);
	buffer_delete(_unknownBuffer);
	var _unknownFailed = false;
	try
	{
		new BBMOD_PostProcessor().from_file(_unknownPath);
	}
	catch (_error)
	{
		_unknownFailed = true;
	}
	bbmod_assert(_unknownFailed);

	_postProcessorClone.destroy();
	_postProcessor.destroy();
	file_delete(_path);
	file_delete(_roundTripPath);
	file_delete(_invalidPath);
	file_delete(_unknownPath);
}
