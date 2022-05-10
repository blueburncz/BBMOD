matrix_set(matrix_world, matrix_build_identity());
renderer.present();
gizmo.draw(OPlayer.camera);
if (renderer.RenderInstanceIDs)
{
	draw_surface_stretched(renderer.SurInstanceIDs, 0, 0, window_get_width(), window_get_height());
}
