var _ditherEnabled = bbmod_dither_get_enabled();

if (_ditherEnabled)
{
	bbmod_dither_set_value(1.0);
}

batchSphere.render([matSphereMetallic]);

if (_ditherEnabled)
{
	bbmod_dither_set_value(1.0);
}

camera.apply();
if (showRenderStatistics)
{
	bbmod_render_statistics_start();
}
renderer.render();
if (showRenderStatistics)
{
	renderStatisticsSnapshot = bbmod_render_statistics_end();
}
