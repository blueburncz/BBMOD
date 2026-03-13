camera.apply();
clouds.render_shadow(x, y, z);
renderer.render();
bbmod_material_reset();
matrix_set(matrix_world, bbmod_matrix_get_identity());
