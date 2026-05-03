var _camera = global.__bbmodCameraCurrent;
if (_camera != undefined)
{
	DitherFrustum.FromCamera(_camera);

	DitherDistanceScratch.Set(x, y, z);
	var _distanceToCamera = abs(_camera.get_distance(DitherDistanceScratch));

	if (DitherInside)
	{
		if (_distanceToCamera > DitherTriggerExitDistance)
		{
			DitherInside = false;
		}
	}
	else if (_distanceToCamera < DitherTriggerEnterDistance)
	{
		DitherInside = true;
	}

	var _targetFade = DitherInside ? 1.0 : 0.0;
	var _deltaSeconds = delta_time * 0.000001;
	var _wasVisible = DitherWasVisible;
	var _isVisible = DitherFrustum.TestPoint(DitherDistanceScratch);
	DitherWasVisible = _isVisible;

	if (_isVisible && !_wasVisible)
	{
		DitherFade = _targetFade;
	}
	else if (_targetFade > DitherFade)
	{
		DitherFade = min(1.0, DitherFade + DitherFadeInRate * _deltaSeconds);
	}
	else if (_targetFade < DitherFade)
	{
		DitherFade = max(0.0, DitherFade - DitherFadeOutRate * _deltaSeconds);
	}
}
