if (true)
{
	var _point = new BBMOD_PointLight(BBMOD_C_WHITE, new BBMOD_Vec3(1.0, 2.0, 3.0), 4.0);
	var _spot = new BBMOD_SpotLight(
		BBMOD_C_WHITE, new BBMOD_Vec3(2.0, 3.0, 4.0), 10.0,
		BBMOD_VEC3_FORWARD, 10.0, 20.0);
	var _particleModel = BBMOD_RESOURCE_MANAGER.load_sync(
		"Data/BBMOD/Models/Sphere.bbmod");
	var _particleSystem = new BBMOD_ParticleSystem(_particleModel, undefined, 1, 1);
	var _emitter = new BBMOD_ParticleEmitter(new BBMOD_Vec3(11.0, 12.0, 13.0), _particleSystem);
	var _lensFlare = new BBMOD_LensFlare(
		BBMOD_C_WHITE, new BBMOD_Vec3(14.0, 15.0, 16.0), 20.0);
	var _probe = new BBMOD_ReflectionProbe(new BBMOD_Vec3(5.0, 6.0, 7.0));
	bbmod_light_punctual_add(_point);
	bbmod_light_punctual_add(_spot);
	bbmod_particle_emitter_add(_emitter);
	bbmod_lens_flare_add(_lensFlare);
	bbmod_reflection_probe_add(_probe);
	var _punctualCount = bbmod_light_punctual_count();
	var _editor = new BBMOD_Editor();

	var _editables = _editor.get_editables();
	bbmod_assert(array_length(_editables) >= 2);
	var _hasEmitter = false;
	var _hasLensFlare = false;
	for (var _editableIndex = 0; _editableIndex < array_length(_editables); ++_editableIndex)
	{
		_hasEmitter = _hasEmitter || (_editables[_editableIndex] == _emitter);
		_hasLensFlare = _hasLensFlare || (_editables[_editableIndex] == _lensFlare);
	}
	bbmod_assert(_hasEmitter);
	bbmod_assert(_hasLensFlare);
	_editor.set_position(_point, new BBMOD_Vec3(2.0, 3.0, 4.0));
	bbmod_assert(_point.Position.Z == 4.0);
	_editor.set_scale(_point, new BBMOD_Vec3(9.0, 9.0, 9.0));
	bbmod_assert(_point.Range == 9.0);
	_editor.set_scale(_spot, new BBMOD_Vec3(40.0, 15.0, 20.0));
	bbmod_assert(_spot.Range == 20.0);
	bbmod_assert(_spot.AngleInner == 15.0);
	bbmod_assert(_spot.AngleOuter == 40.0);
	_editor.set_position(_probe, new BBMOD_Vec3(8.0, 9.0, 10.0));
	bbmod_assert(_probe.Position.X == 8.0);
	_editor.set_position(_emitter, new BBMOD_Vec3(17.0, 18.0, 19.0));
	bbmod_assert(_emitter.Position.Z == 19.0);
	_editor.set_scale(_lensFlare, new BBMOD_Vec3(30.0));
	bbmod_assert(_lensFlare.Range == 30.0);

	var _projected = _editor.project_editables(
		bbmod_matrix_get_identity(), new BBMOD_Vec3(), 100.0, 100.0, 24.0);
	bbmod_assert(array_length(_projected) > 0);
	var _picked = _editor.pick(_projected, _projected[0].X, _projected[0].Y);
	bbmod_assert(_picked != undefined);
	_editor.select(_point);
	bbmod_assert(_editor.get_selected() == _point);
	_editor.clear_selection();
	bbmod_assert(_editor.get_selected() == undefined);

	var _gizmo = _editor.Gizmo;
	_gizmo.select(_point);
	_gizmo.update_position();
	bbmod_assert(_gizmo.Position.X == _point.Position.X);
	_gizmo.OnEditBegin();
	_editor.set_position(_point, new BBMOD_Vec3(21.0, 22.0, 23.0));
	_gizmo.OnEditEnd();
	bbmod_assert(_editor.can_undo());
	_editor.undo();
	bbmod_assert(_point.Position.X == 2.0);
	_editor.redo();
	bbmod_assert(_point.Position.X == 21.0);
	_gizmo.clear_selection();
	_gizmo.select(_point);
	_gizmo.select(_spot);
	_gizmo.OnEditBegin();
	_editor.set_position(_point, new BBMOD_Vec3(31.0, 32.0, 33.0));
	_editor.set_position(_spot, new BBMOD_Vec3(41.0, 42.0, 43.0));
	_gizmo.OnEditEnd();
	bbmod_assert(array_length(_editor.UndoStack[array_length(_editor.UndoStack) - 1].Targets) == 2);
	_editor.undo();
	bbmod_assert(_point.Position.X == 21.0);
	bbmod_assert(_spot.Position.X == 2.0);
	_editor.redo();
	bbmod_assert(_point.Position.X == 31.0);
	bbmod_assert(_spot.Position.X == 41.0);
	_gizmo.clear_selection();
	_gizmo.select(_spot);
	_gizmo.OnEditBegin();
	_editor.set_scale(_spot, new BBMOD_Vec3(50.0, 25.0, 30.0));
	_gizmo.OnEditEnd();
	_editor.undo();
	bbmod_assert(_spot.Range == 20.0);
	_editor.redo();
	bbmod_assert(_spot.Range == 30.0);
	var _testInstance = instance_find(OLightmapTest, 0);
	if (instance_exists(_testInstance))
	{
		var _instanceSnapshot = _editor.capture_instance_snapshot(_testInstance);
		var _restoredInstance = _editor.restore_instance_snapshot(_instanceSnapshot);
		bbmod_assert(instance_exists(_restoredInstance));
		bbmod_assert(_restoredInstance.object_index == _testInstance.object_index);
		instance_destroy(_restoredInstance);
		_editor.dispose_instance_snapshot(_instanceSnapshot);
		var _instanceX = _testInstance.x;
		_gizmo.clear_selection();
		_gizmo.select(_point);
		_gizmo.select(_testInstance);
		_gizmo.OnEditBegin();
		_editor.set_position(_point, new BBMOD_Vec3(61.0, 62.0, 63.0));
		_testInstance.x = _instanceX + 5.0;
		_gizmo.OnEditEnd();
		_editor.undo();
		bbmod_assert(_point.Position.X == 31.0);
		bbmod_assert(_testInstance.x == _instanceX);
		_editor.redo();
		bbmod_assert(_point.Position.X == 61.0);
		bbmod_assert(_testInstance.x == _instanceX + 5.0);
		_editor.undo();
		var _deleteInstanceX = _testInstance.x;
		_gizmo.clear_selection();
		_gizmo.select(_point);
		_gizmo.select(_testInstance);
		_editor.delete_selected();
		_editor.undo();
		_editor.undo();
		bbmod_assert(_point.Position.X == 31.0);
		bbmod_assert(_testInstance.x == _deleteInstanceX);
		_editor.redo();
		_editor.redo();
	}
	_gizmo.clear_selection();
	_gizmo.select(_point);
	_editor.delete_selected();
	bbmod_assert(bbmod_light_punctual_count() == _punctualCount - 1);
	_editor.undo();
	bbmod_assert(bbmod_light_punctual_count() == _punctualCount);
	_editor.redo();
	bbmod_assert(bbmod_light_punctual_count() == _punctualCount - 1);
	_editor.undo();
	var _createdPoint = new BBMOD_PointLight(
		BBMOD_C_WHITE, new BBMOD_Vec3(70.0, 71.0, 72.0), 6.0);
	bbmod_light_punctual_add(_createdPoint);
	_editor.add_created(_createdPoint);
	bbmod_assert(bbmod_light_punctual_count() == _punctualCount + 1);
	_editor.undo();
	bbmod_assert(bbmod_light_punctual_count() == _punctualCount);
	_editor.redo();
	bbmod_assert(bbmod_light_punctual_count() == _punctualCount + 1);
	_editor.undo();
	if (instance_exists(_testInstance))
	{
		var _createdInstance = instance_create_layer(
			_testInstance.x + 16.0,
			_testInstance.y,
			layer_get_name(_testInstance.layer),
			_testInstance.object_index);
		_editor.add_created(_createdInstance);
		_editor.undo();
		bbmod_assert(!instance_exists(_createdInstance));
		_editor.redo();
		bbmod_assert(ds_list_size(_gizmo.Selected) == 1);
		_editor.undo();
	}
	_editor.destroy();

	_editor.draw_wireframe(_point);
	_editor.draw_wireframe(_probe);

	bbmod_reflection_probe_remove(_probe);
	bbmod_light_punctual_remove(_point);
	bbmod_light_punctual_remove(_spot);
	bbmod_particle_emitter_remove(_emitter);
	bbmod_lens_flare_remove(_lensFlare);
	_probe.destroy();
	_point.destroy();
	_emitter.destroy();
	_particleSystem.destroy();
	_lensFlare.destroy();
}
