draw_clear(c_black);
OPlayer.camera.apply();
treeBatch.render();
//new BBMOD_Matrix().Scale(new BBMOD_Vec3(10)).Translate(100, 100, 100).ApplyWorld();
//modTree.render();
//BBMOD_MATRIX_IDENTITY.ApplyWorld();
renderer.render();

if (debugOverlay)
{
	matrix_set(matrix_world, matrix_build_identity());

	with (OZombie)
	{
		collider.DrawDebug();
	}
}
