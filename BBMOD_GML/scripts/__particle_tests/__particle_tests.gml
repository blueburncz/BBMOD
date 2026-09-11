if (true)
{
	var _particleSystem = new BBMOD_ParticleSystem(undefined, undefined, 64, 16);
	_particleSystem.Sort = true;
	_particleSystem.Duration = 7.5;
	_particleSystem.Loop = true;
	_particleSystem.add_modules(
		new BBMOD_GravityModule(new BBMOD_Vec3(0.0, 0.0, -3.0)),
		new BBMOD_MixEmissionModule(2, 5),
		new BBMOD_SetRealModule(BBMOD_EParticle.Bounce, 0.25),
		new BBMOD_SetVec2Module(BBMOD_EParticle.ScaleX, new BBMOD_Vec2(2.0, 3.0)),
		new BBMOD_SetVec3Module(BBMOD_EParticle.PositionX, new BBMOD_Vec3(4.0, 5.0, 6.0)),
		new BBMOD_SetVec4Module(BBMOD_EParticle.RotationX, new BBMOD_Vec4(0.0, 0.0, 0.0, 1.0)),
		new BBMOD_SetQuaternionModule(
			BBMOD_EParticle.RotationX, new BBMOD_Quaternion()),
		new BBMOD_SetColorModule(
			BBMOD_EParticle.ColorR, new BBMOD_Color(10.0, 20.0, 30.0, 0.5)),
		new BBMOD_RandomRotationModule(new BBMOD_Vec3(0.0, 1.0, 0.0), -10.0, 20.0),
		new BBMOD_MixSpeedModule(1.0, 4.0),
		new BBMOD_MixRealModule(BBMOD_EParticle.ColorA, 0.25, 0.75),
		new BBMOD_MixVec2Module(
			BBMOD_EParticle.ScaleX, new BBMOD_Vec2(1.0, 2.0),
			new BBMOD_Vec2(3.0, 4.0), false),
		new BBMOD_MixVec3Module(
			BBMOD_EParticle.PositionX, new BBMOD_Vec3(1.0, 2.0, 3.0),
			new BBMOD_Vec3(4.0, 5.0, 6.0), false),
		new BBMOD_MixVec4Module(
			BBMOD_EParticle.RotationX, new BBMOD_Vec4(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Vec4(5.0, 6.0, 7.0, 8.0), false),
		new BBMOD_MixColorModule(
			BBMOD_EParticle.ColorR, new BBMOD_Color(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Color(5.0, 6.0, 7.0, 8.0)),
		new BBMOD_MixQuaternionModule(
			BBMOD_EParticle.RotationX, new BBMOD_Quaternion(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Quaternion(5.0, 6.0, 7.0, 8.0)),
		new BBMOD_AddRealOverTimeModule(BBMOD_EParticle.HealthLeft, 2.0, 3.0),
		new BBMOD_AddVec2OverTimeModule(
			BBMOD_EParticle.ScaleX, new BBMOD_Vec2(1.0, 2.0), 3.0),
		new BBMOD_AddVec3OverTimeModule(
			BBMOD_EParticle.PositionX, new BBMOD_Vec3(1.0, 2.0, 3.0), 4.0),
		new BBMOD_AddVec4OverTimeModule(
			BBMOD_EParticle.RotationX, new BBMOD_Vec4(1.0, 2.0, 3.0, 4.0), 5.0),
		new BBMOD_MixRealOverTimeModule(BBMOD_EParticle.ColorA, 0.1, 0.9, 6.0),
		new BBMOD_MixVec2OverTimeModule(
			BBMOD_EParticle.ScaleX, new BBMOD_Vec2(1.0, 2.0),
			new BBMOD_Vec2(3.0, 4.0), 7.0),
		new BBMOD_MixVec3OverTimeModule(
			BBMOD_EParticle.PositionX, new BBMOD_Vec3(1.0, 2.0, 3.0),
			new BBMOD_Vec3(4.0, 5.0, 6.0), 8.0),
		new BBMOD_MixVec4OverTimeModule(
			BBMOD_EParticle.RotationX, new BBMOD_Vec4(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Vec4(5.0, 6.0, 7.0, 8.0), 9.0),
		new BBMOD_MixColorOverTimeModule(
			BBMOD_EParticle.ColorR, new BBMOD_Color(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Color(5.0, 6.0, 7.0, 8.0), 10.0),
		new BBMOD_MixQuaternionOverTimeModule(
			BBMOD_EParticle.RotationX, new BBMOD_Quaternion(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Quaternion(5.0, 6.0, 7.0, 8.0), 11.0),
		new BBMOD_MixRealFromHealthModule(BBMOD_EParticle.ScaleZ, 0.1, 0.9),
		new BBMOD_MixRealFromSpeedModule(BBMOD_EParticle.ScaleY, 1.0, 2.0, 3.0, 4.0),
		new BBMOD_MixVec2FromHealthModule(
			BBMOD_EParticle.PositionX, new BBMOD_Vec2(1.0, 2.0),
			new BBMOD_Vec2(3.0, 4.0)),
		new BBMOD_MixVec2FromSpeedModule(
			BBMOD_EParticle.ScaleX, new BBMOD_Vec2(1.0, 2.0),
			new BBMOD_Vec2(3.0, 4.0), 5.0, 6.0),
		new BBMOD_MixVec3FromHealthModule(
			BBMOD_EParticle.PositionX, new BBMOD_Vec3(1.0, 2.0, 3.0),
			new BBMOD_Vec3(4.0, 5.0, 6.0)),
		new BBMOD_MixVec3FromSpeedModule(
			BBMOD_EParticle.PositionX, new BBMOD_Vec3(1.0, 2.0, 3.0),
			new BBMOD_Vec3(4.0, 5.0, 6.0), 7.0, 8.0),
		new BBMOD_MixVec4FromHealthModule(
			BBMOD_EParticle.RotationX, new BBMOD_Vec4(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Vec4(5.0, 6.0, 7.0, 8.0)),
		new BBMOD_MixVec4FromSpeedModule(
			BBMOD_EParticle.RotationX, new BBMOD_Vec4(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Vec4(5.0, 6.0, 7.0, 8.0), 9.0, 10.0),
		new BBMOD_MixColorFromHealthModule(
			BBMOD_EParticle.ColorR, new BBMOD_Color(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Color(5.0, 6.0, 7.0, 8.0)),
		new BBMOD_MixColorFromSpeedModule(
			BBMOD_EParticle.ColorR, new BBMOD_Color(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Color(5.0, 6.0, 7.0, 8.0), 11.0, 12.0),
		new BBMOD_MixQuaternionFromHealthModule(
			BBMOD_EParticle.RotationX, new BBMOD_Quaternion(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Quaternion(5.0, 6.0, 7.0, 8.0)),
		new BBMOD_MixQuaternionFromSpeedModule(
			BBMOD_EParticle.RotationX, new BBMOD_Quaternion(1.0, 2.0, 3.0, 4.0),
			new BBMOD_Quaternion(5.0, 6.0, 7.0, 8.0), 13.0, 14.0),
		new BBMOD_DragModule(),
		new BBMOD_CollisionKillModule(),
		new BBMOD_EmissionModule(3),
		new BBMOD_SphereEmissionModule(2.5, false),
		new BBMOD_EmissionOverTimeModule(4, 2.5),
		new BBMOD_AABBEmissionModule(
			new BBMOD_Vec3(-1.0, -2.0, -3.0), new BBMOD_Vec3(1.0, 2.0, 3.0), false),
		new BBMOD_AddRealOnCollisionModule(BBMOD_EParticle.HealthLeft, -0.5),
		new BBMOD_AddVec2OnCollisionModule(
			BBMOD_EParticle.ScaleX, new BBMOD_Vec2(1.0, 2.0)),
		new BBMOD_AddVec3OnCollisionModule(
			BBMOD_EParticle.PositionX, new BBMOD_Vec3(1.0, 2.0, 3.0)),
		new BBMOD_AddVec4OnCollisionModule(
			BBMOD_EParticle.RotationX, new BBMOD_Vec4(1.0, 2.0, 3.0, 4.0)),
		new BBMOD_AttractorModule(new BBMOD_Vec3(1.0, 2.0, 3.0), false, 4.0, -5.0));

	var _path = working_directory + "bbmod_particle_test.bbpart";
	_particleSystem.to_file(_path);
	var _particleSystemClone = new BBMOD_ParticleSystem().from_file(_path);
	bbmod_assert(_particleSystemClone.IsLoaded);
	bbmod_assert(_particleSystemClone.ParticleCount == 64);
	bbmod_assert(_particleSystemClone.BatchSize == 16);
	bbmod_assert(_particleSystemClone.Sort);
	bbmod_assert(_particleSystemClone.Loop);
	bbmod_assert(abs(_particleSystemClone.Duration - 7.5) < 0.001);
	bbmod_assert(array_length(_particleSystemClone.Modules) == 49);
	bbmod_assert(instanceof(_particleSystemClone.Modules[0]) == "BBMOD_GravityModule");
	bbmod_assert(instanceof(_particleSystemClone.Modules[1]) == "BBMOD_MixEmissionModule");
	bbmod_assert(instanceof(_particleSystemClone.Modules[2]) == "BBMOD_SetRealModule");
	bbmod_assert(_particleSystemClone.Modules[0].Gravity.Z == -3.0);
	bbmod_assert(_particleSystemClone.Modules[1].From == 2);
	bbmod_assert(_particleSystemClone.Modules[2].Property == BBMOD_EParticle.Bounce);
	bbmod_assert(instanceof(_particleSystemClone.Modules[3]) == "BBMOD_SetVec2Module");
	bbmod_assert(_particleSystemClone.Modules[3].Value.Y == 3.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[4]) == "BBMOD_SetVec3Module");
	bbmod_assert(_particleSystemClone.Modules[4].Value.Z == 6.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[5]) == "BBMOD_SetVec4Module");
	bbmod_assert(instanceof(_particleSystemClone.Modules[6]) == "BBMOD_SetQuaternionModule");
	bbmod_assert(instanceof(_particleSystemClone.Modules[7]) == "BBMOD_SetColorModule");
	bbmod_assert(_particleSystemClone.Modules[7].Value.Green == 20.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[8]) == "BBMOD_RandomRotationModule");
	bbmod_assert(_particleSystemClone.Modules[8].To == 20.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[9]) == "BBMOD_MixSpeedModule");
	bbmod_assert(instanceof(_particleSystemClone.Modules[10]) == "BBMOD_MixRealModule");
	bbmod_assert(_particleSystemClone.Modules[10].From == 0.25);
	bbmod_assert(instanceof(_particleSystemClone.Modules[11]) == "BBMOD_MixVec2Module");
	bbmod_assert(_particleSystemClone.Modules[11].To.Y == 4.0);
	bbmod_assert(!_particleSystemClone.Modules[11].Separate);
	bbmod_assert(instanceof(_particleSystemClone.Modules[12]) == "BBMOD_MixVec3Module");
	bbmod_assert(_particleSystemClone.Modules[12].From.Z == 3.0);
	bbmod_assert(!_particleSystemClone.Modules[12].Separate);
	bbmod_assert(instanceof(_particleSystemClone.Modules[13]) == "BBMOD_MixVec4Module");
	bbmod_assert(_particleSystemClone.Modules[13].To.W == 8.0);
	bbmod_assert(!_particleSystemClone.Modules[13].Separate);
	bbmod_assert(instanceof(_particleSystemClone.Modules[14]) == "BBMOD_MixColorModule");
	bbmod_assert(_particleSystemClone.Modules[14].From.Green == 2.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[15]) == "BBMOD_MixQuaternionModule");
	bbmod_assert(_particleSystemClone.Modules[15].To.W == 8.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[16]) == "BBMOD_AddRealOverTimeModule");
	bbmod_assert(_particleSystemClone.Modules[16].Period == 3.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[17]) == "BBMOD_AddVec2OverTimeModule");
	bbmod_assert(_particleSystemClone.Modules[17].Change.Y == 2.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[18]) == "BBMOD_AddVec3OverTimeModule");
	bbmod_assert(_particleSystemClone.Modules[18].Change.Z == 3.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[19]) == "BBMOD_AddVec4OverTimeModule");
	bbmod_assert(_particleSystemClone.Modules[19].Change.W == 4.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[20]) == "BBMOD_MixRealOverTimeModule");
	bbmod_assert(_particleSystemClone.Modules[20].Duration == 6.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[21]) == "BBMOD_MixVec2OverTimeModule");
	bbmod_assert(_particleSystemClone.Modules[21].To.Y == 4.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[22]) == "BBMOD_MixVec3OverTimeModule");
	bbmod_assert(_particleSystemClone.Modules[22].From.Z == 3.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[23]) == "BBMOD_MixVec4OverTimeModule");
	bbmod_assert(_particleSystemClone.Modules[23].To.W == 8.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[24]) == "BBMOD_MixColorOverTimeModule");
	bbmod_assert(_particleSystemClone.Modules[24].To.Alpha == 8.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[25]) == "BBMOD_MixQuaternionOverTimeModule");
	bbmod_assert(_particleSystemClone.Modules[25].Duration == 11.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[26]) == "BBMOD_MixRealFromHealthModule");
	bbmod_assert(_particleSystemClone.Modules[26].To == 0.9);
	bbmod_assert(instanceof(_particleSystemClone.Modules[27]) == "BBMOD_MixRealFromSpeedModule");
	bbmod_assert(_particleSystemClone.Modules[27].Max == 4.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[28]) == "BBMOD_MixVec2FromHealthModule");
	bbmod_assert(_particleSystemClone.Modules[28].From.Y == 2.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[29]) == "BBMOD_MixVec2FromSpeedModule");
	bbmod_assert(_particleSystemClone.Modules[29].Min == 5.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[30]) == "BBMOD_MixVec3FromHealthModule");
	bbmod_assert(_particleSystemClone.Modules[30].From.Z == 3.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[31]) == "BBMOD_MixVec3FromSpeedModule");
	bbmod_assert(_particleSystemClone.Modules[31].Max == 8.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[32]) == "BBMOD_MixVec4FromHealthModule");
	bbmod_assert(_particleSystemClone.Modules[32].To.W == 8.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[33]) == "BBMOD_MixVec4FromSpeedModule");
	bbmod_assert(_particleSystemClone.Modules[33].Min == 9.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[34]) == "BBMOD_MixColorFromHealthModule");
	bbmod_assert(_particleSystemClone.Modules[34].To.Alpha == 8.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[35]) == "BBMOD_MixColorFromSpeedModule");
	bbmod_assert(_particleSystemClone.Modules[35].Max == 12.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[36]) == "BBMOD_MixQuaternionFromHealthModule");
	bbmod_assert(_particleSystemClone.Modules[36].From.W == 4.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[37]) == "BBMOD_MixQuaternionFromSpeedModule");
	bbmod_assert(_particleSystemClone.Modules[37].Min == 13.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[38]) == "BBMOD_DragModule");
	bbmod_assert(instanceof(_particleSystemClone.Modules[39]) == "BBMOD_CollisionKillModule");
	bbmod_assert(instanceof(_particleSystemClone.Modules[40]) == "BBMOD_EmissionModule");
	bbmod_assert(_particleSystemClone.Modules[40].Count == 3.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[41]) == "BBMOD_SphereEmissionModule");
	bbmod_assert(_particleSystemClone.Modules[41].Radius == 2.5);
	bbmod_assert(!_particleSystemClone.Modules[41].Inside);
	bbmod_assert(instanceof(_particleSystemClone.Modules[42]) == "BBMOD_EmissionOverTimeModule");
	bbmod_assert(_particleSystemClone.Modules[42].Interval == 2.5);
	bbmod_assert(instanceof(_particleSystemClone.Modules[43]) == "BBMOD_AABBEmissionModule");
	bbmod_assert(_particleSystemClone.Modules[43].Min.Z == -3.0);
	bbmod_assert(!_particleSystemClone.Modules[43].Inside);
	bbmod_assert(instanceof(_particleSystemClone.Modules[44]) == "BBMOD_AddRealOnCollisionModule");
	bbmod_assert(_particleSystemClone.Modules[44].Change == -0.5);
	bbmod_assert(instanceof(_particleSystemClone.Modules[45]) == "BBMOD_AddVec2OnCollisionModule");
	bbmod_assert(_particleSystemClone.Modules[45].Change.Y == 2.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[46]) == "BBMOD_AddVec3OnCollisionModule");
	bbmod_assert(_particleSystemClone.Modules[46].Change.Z == 3.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[47]) == "BBMOD_AddVec4OnCollisionModule");
	bbmod_assert(_particleSystemClone.Modules[47].Change.W == 4.0);
	bbmod_assert(instanceof(_particleSystemClone.Modules[48]) == "BBMOD_AttractorModule");
	bbmod_assert(_particleSystemClone.Modules[48].Position.Z == 3.0);
	bbmod_assert(!_particleSystemClone.Modules[48].Relative);
	bbmod_assert(_particleSystemClone.Modules[48].Force == -5.0);
	var _roundTripPath = working_directory + "bbmod_particle_roundtrip.bbpart";
	_particleSystemClone.to_file(_roundTripPath);
	var _originalBuffer = buffer_load(_path);
	var _roundTripBuffer = buffer_load(_roundTripPath);
	bbmod_assert(buffer_get_size(_originalBuffer) == buffer_get_size(_roundTripBuffer));
	buffer_delete(_originalBuffer);
	buffer_delete(_roundTripBuffer);

	var _dependencyManager = new BBMOD_ResourceManager();
	var _dependencyModel = _dependencyManager.load_sync("Data/BBMOD/Models/Cube.bbmod");
	var _dependencyMaterial = _dependencyManager.load_sync("Data/Lightmap/Material.bbmat");
	var _dependencyParticleSystem = new BBMOD_ParticleSystem(
		_dependencyModel, _dependencyMaterial, 8, 4);
	_dependencyParticleSystem.add_modules(new BBMOD_DragModule());
	var _dependencyPath = working_directory + "bbmod_particle_dependencies.bbpart";
	_dependencyParticleSystem.to_file(_dependencyPath);
	var _managedDependencyParticleSystem = _dependencyManager.load_sync(_dependencyPath);
	bbmod_assert(_managedDependencyParticleSystem.Model == _dependencyModel);
	bbmod_assert(_managedDependencyParticleSystem.Material == _dependencyMaterial);
	_managedDependencyParticleSystem.free();
	_dependencyParticleSystem.destroy();
	_dependencyManager.destroy();

	var _manager = new BBMOD_ResourceManager();
	var _managedParticleSystem = _manager.load_sync(_path);
	bbmod_assert(_managedParticleSystem.IsLoaded);
	bbmod_assert(array_length(_managedParticleSystem.Modules) == 49);
	_managedParticleSystem.free();
	_manager.destroy();

	var _invalidPath = working_directory + "bbmod_invalid_particle.bbpart";
	var _invalidBuffer = buffer_create(1, buffer_grow, 1);
	buffer_write(_invalidBuffer, buffer_string, "INVALID");
	buffer_save(_invalidBuffer, _invalidPath);
	buffer_delete(_invalidBuffer);
	var _invalidFailed = false;
	try
	{
		new BBMOD_ParticleSystem().from_file(_invalidPath);
	}
	catch (_error)
	{
		_invalidFailed = true;
	}
	bbmod_assert(_invalidFailed);

	var _unknownPath = working_directory + "bbmod_unknown_particle.bbpart";
	var _unknownBuffer = buffer_create(1, buffer_grow, 1);
	buffer_write(_unknownBuffer, buffer_string, "BBPART");
	buffer_write(_unknownBuffer, buffer_u32, 1);
	buffer_write(_unknownBuffer, buffer_u32, 0);
	buffer_write(_unknownBuffer, buffer_u32, 32);
	buffer_write(_unknownBuffer, buffer_bool, false);
	buffer_write(_unknownBuffer, buffer_f64, 5.0);
	buffer_write(_unknownBuffer, buffer_bool, false);
	buffer_write(_unknownBuffer, buffer_string, "");
	buffer_write(_unknownBuffer, buffer_u32, 1);
	buffer_write(_unknownBuffer, buffer_string, "BBMOD_UnknownParticleModule");
	buffer_save(_unknownBuffer, _unknownPath);
	buffer_delete(_unknownBuffer);
	var _unknownFailed = false;
	try
	{
		new BBMOD_ParticleSystem().from_file(_unknownPath);
	}
	catch (_error)
	{
		_unknownFailed = true;
	}
	bbmod_assert(_unknownFailed);

	var _unsupportedModules = [
		new BBMOD_TerrainCollisionModule(),
		new BBMOD_CollisionEventModule(),
	];
	for (var _unsupportedIndex = 0; _unsupportedIndex < 2; ++_unsupportedIndex)
	{
		var _unsupportedSystem = new BBMOD_ParticleSystem();
		_unsupportedSystem.add_modules(_unsupportedModules[_unsupportedIndex]);
		var _unsupportedBuffer = buffer_create(1, buffer_grow, 1);
		var _unsupportedFailed = false;
		try
		{
			_unsupportedSystem.to_buffer(_unsupportedBuffer);
		}
		catch (_error)
		{
			_unsupportedFailed = true;
		}
		bbmod_assert(_unsupportedFailed);
		buffer_delete(_unsupportedBuffer);
		_unsupportedSystem.destroy();
	}

	_particleSystemClone.destroy();
	_particleSystem.destroy();
	file_delete(_path);
	file_delete(_roundTripPath);
	file_delete(_dependencyPath);
	file_delete(_invalidPath);
	file_delete(_unknownPath);
}
