draw_clear(c_black);
OPlayer.camera.apply();
renderer.render();

if (debugOverlay)
{
	with (OZombie)
	{
		collider.DrawDebug();
	}
}
