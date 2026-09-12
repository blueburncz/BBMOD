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

if (editorSpawnKey != 0)
{
	var _spawnPosition = renderer.get_world_position(
		window_mouse_get_x(), window_mouse_get_y());
	if (_spawnPosition != undefined)
	{
		if (editorSpawnKey == 1)
		{
			var _pointLight = new BBMOD_PointLight(
				BBMOD_C_RED, _spawnPosition, 6.0);
			bbmod_light_punctual_add(_pointLight);
			renderer.Editor.add_created(_pointLight);
		}
		else if (editorSpawnKey == 2)
		{
			var _spotLight = new BBMOD_SpotLight(
				BBMOD_C_BLUE, _spawnPosition, 8.0, camera.get_forward(), 15.0, 30.0);
			bbmod_light_punctual_add(_spotLight);
			renderer.Editor.add_created(_spotLight);
		}
		else if (editorSpawnKey == 3)
		{
			var _probe = new BBMOD_ReflectionProbe(_spawnPosition);
			_probe.Size.Set(4.0);
			bbmod_reflection_probe_add(_probe);
			renderer.Editor.add_created(_probe);
		}
		else
		{
			var _instance = instance_create_layer(
				_spawnPosition.X,
				_spawnPosition.Y,
				layer_get_name(layer),
				OLightmapTest);
			_instance.z = _spawnPosition.Z;
			renderer.Editor.add_created(_instance);
		}
	}
	editorSpawnKey = 0;
}
if (showRenderStatistics)
{
	renderStatisticsSnapshot = bbmod_render_statistics_end();
}
