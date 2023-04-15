bbmod_set_instance_id(id);
matrix_set(matrix_world, matrixBody);
bbmod_material_props_set(materialProps);
animationPlayer.render([material]);
bbmod_material_props_reset();
