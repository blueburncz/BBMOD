if (keyboard_check_pressed(vk_enter))
{
	var _reflectionProbe = new BBMOD_ReflectionProbe(new BBMOD_Vec3(OPlayer.x, OPlayer.y, OPlayer.z + 20));
	_reflectionProbe.Size = new BBMOD_Vec3(100);
	bbmod_reflection_probe_add(_reflectionProbe);
}

draw_clear(c_black);
OPlayer.camera.apply();
renderer.render();

if (debugOverlay)
{
	matrix_set(matrix_world, matrix_build_identity());

	with (OZombie)
	{
		collider.DrawDebug();
	}
}
