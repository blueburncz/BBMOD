if (keyboard_check_pressed(vk_enter))
{
	reflectionProbe.set_position(new BBMOD_Vec3(OPlayer.x, OPlayer.y, OPlayer.z + 20));
	reflectionProbe.NeedsUpdate = true;
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
