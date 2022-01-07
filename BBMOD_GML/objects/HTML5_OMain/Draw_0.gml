bbmod_material_reset();
matrix_set(matrix_world, matrix_build(room_width * 0.5, room_height * 0.5, 0, 0, 90, 0, 64, 64, 64));
model.submit();
matrix_set(matrix_world, matrix_build_identity());
bbmod_material_reset();