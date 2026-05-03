var _matrix = new BBMOD_Matrix();
var _ditherEnabled = bbmod_dither_get_enabled();
var _regularFade0 = ditherRegularStates[0].Fade;
var _regularFade1 = ditherRegularStates[1].Fade;
var _regularFade2 = ditherRegularStates[2].Fade;
var _regularFade3 = ditherRegularStates[3].Fade;

if (_ditherEnabled)
{
	bbmod_dither_set_value(1.0);
}

_matrix.ScaleSelf(1000, 1000, 1000)
	.TranslateSelf(camera.Position)
	.ApplyWorld();
bbmod_set_instance_id(1001);
modSphere.render([matSky]);

if (_ditherEnabled)
{
	bbmod_dither_set_value(_regularFade0);
}

_matrix.SetIdentity()
	.TranslateSelf(0, 0, 1)
	.ApplyWorld();
bbmod_set_instance_id(1002);
modSphere.render([matSphere]);

if (_ditherEnabled)
{
	bbmod_dither_set_value(_regularFade1);
}

_matrix.SetIdentity()
	.TranslateSelf(4, 0, 1)
	.ApplyWorld();
bbmod_set_instance_id(1003);
modSphere.render([matSphereMetallic]);

if (_ditherEnabled)
{
	bbmod_dither_set_value(_regularFade2);
}

_matrix.SetIdentity()
	.TranslateSelf(8, 0, 1)
	.ApplyWorld();
bbmod_set_instance_id(1004);
modSphere.render([matSphereEmissive]);

if (_ditherEnabled)
{
	// Dynamic batch uses per-instance local dither multipliers.
	bbmod_dither_set_value(1.0);
}

batchSphere.render([matSphereMetallic]);

if (particleModuleShowcaseEnabled)
{
	var i = 0;
	repeat(array_length(particleModuleShowcaseEmitters))
	{
		particleModuleShowcaseEmitters[i++].render();
	}
}

if (_ditherEnabled)
{
	bbmod_dither_set_value(_regularFade3);
}

terrain.render();

_matrix.SetIdentity()
	.TranslateSelf(0, -8, 0)
	.ApplyWorld();
bbmod_set_instance_id(1100);
characterPlayer.render();

if (_ditherEnabled)
{
	bbmod_dither_set_value(1.0);
}

BBMOD_MATRIX_IDENTITY.ApplyWorld();
bbmod_set_instance_id(0);

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
