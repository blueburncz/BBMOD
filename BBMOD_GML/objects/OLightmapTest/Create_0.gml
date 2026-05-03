z = 0.01;
model = BBMOD_RESOURCE_MANAGER.load_async("Data/Lightmap/Lightmap.bbmod", undefined, function (_error, _model)
{
	if (_error == undefined)
	{
		_model.Meshes[0].update_bbox(); // For frustum culling
	}
});
matrix = new BBMOD_Matrix();

// Trigger-zone temporal dither state for this instance.
DitherTriggerEnterDistance = 128.0;
DitherTriggerExitDistance = 136.0;
DitherFadeInSeconds = 0.35;
DitherFadeOutSeconds = 0.55;
DitherFadeInRate = 1.0 / max(DitherFadeInSeconds, 0.001);
DitherFadeOutRate = 1.0 / max(DitherFadeOutSeconds, 0.001);
DitherInside = true;
DitherWasVisible = true;
DitherFade = 1.0;
DitherDistanceScratch = new BBMOD_Vec3(0.0);
DitherFrustum = new BBMOD_FrustumCollider();
