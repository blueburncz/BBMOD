if (sceneModel == undefined && model.IsLoaded)
{
	model.Meshes[0].update_bbox(); // For frustum culling
	sceneModel = model.make_instance();
	sceneModel.set_position(new BBMOD_Vec3(x, y, z));
	sceneModel.set_rotation(new BBMOD_Vec3(0.0, 0.0, 90.0));
	sceneModel.set_scale(new BBMOD_Vec3(10.0));
	scene.add_node(sceneModel);
}
