/// @func BBMOD_ParticleEmitter(_position, _system)
/// @desc Emits particles at a specific position in the world. The behavior of
/// the emitter particles is defined by a particle system.
/// @param {Struct.BBMOD_Vec3} _position The emitter's position in world-space.
/// @param {Struct.BBMOD_ParticleSystem} _system The particle system that defines
/// behavior of emitted particles.
/// @see BBMOD_Particle
/// @see BBBMOD_ParticleSystem
function BBMOD_ParticleEmitter(_position, _system) constructor
{
	/// @var {Struct.BBMOD_Vec3} The emitter's position in world-space.
	Position = _position;

	/// @var {Struct.BBMOD_ParticleSystem} The system of particles that this
	/// emitter emits.
	/// @readonly
	System = _system;

	/// @var {Array<Struct.BBMOD_Particle>} An array of all particles within the
	/// system.
	/// @readonly
	Particles = array_create(System.ParticleCount, undefined);

	/// @var {Array<Struct.BBMOD_Particle>} Particles to be spawned.
	/// @private
	ParticlesToSpawn = [];

	/// @var {Array<Struct.BBMOD_Particle>} Alive particles.
	/// @private
	ParticlesAlive = [];

	/// @var {Array<Struct.BBMOD_Particle>} Dead particles that can be spawned.
	/// @private
	ParticlesDead = array_create(System.ParticleCount, undefined);

	for (var i = 0; i < System.ParticleCount; ++i)
	{
		var _particle = new BBMOD_Particle(i);
		Position.Copy(_particle.Position);
		Particles[i] = _particle;
		ParticlesDead[i] = _particle;
	}

	/// @var {Real}
	/// @private
	Time = 0.0;

	/// @func spawn_particle()
	/// @desc Spawns a particle if the maximum particle count defined in the
	/// particle system has not been reached yet.
	/// @return {Bool} Returns `true` if a particle was spawned.
	static spawn_particle = function () {
		gml_pragma("forceinline");
		if (Time < System.Duration
			&& array_length(ParticlesDead) > 0)
		{
			array_push(ParticlesToSpawn, ParticlesDead[0]);
			array_delete(ParticlesDead, 0, 1);
			return true;
		}
		return false;
	};

	/// @func update(_deltaTime)
	/// @desc Updates the emitter and all its particles.
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @return {Struct.BBMOD_ParticleEmitter} Returns `self`.
	static update = function (_deltaTime) {
		if (finished(true))
		{
			return self;
		}

		var _deltaTimeS = _deltaTime * 0.000001;
		var _modules = System.Modules;
		var _particlesToSpawn = ParticlesToSpawn;
		var _particlesAlive = ParticlesAlive;
		var _particlesDead = ParticlesDead;

		var _timeStart = (Time == 0.0);
		Time += _deltaTimeS;
		var _timeOut = (Time >= System.Duration);
		if (_timeOut && System.Loop)
		{
			Time = 0.0;
		}

		var m = 0;
		repeat (array_length(_modules))
		{
			var _module = _modules[m++];
			if (_module.Enabled)
			{
				// Emitter start
				if (_timeStart && _module.on_start)
				{
					_module.on_start(self);
				}

				// Emitter update
				if (_module.on_update)
				{
					_module.on_update(self, _deltaTime);
				}

				// Emitter finish
				if (_timeOut && _module.on_finish)
				{
					_module.on_finish(self);
				}
			}
		}

		// Spawn particles
		var p = 0;
		repeat (array_length(_particlesToSpawn))
		{
			var _particle = _particlesToSpawn[p++];
			_particle.reset();
			Position.Copy(_particle.Position);
			_particle.IsAlive = true;
			array_push(ParticlesAlive, _particle);

			var m = 0;
			repeat (array_length(_modules))
			{
				var _module = _modules[m++];
				if (_module.Enabled && _module.on_particle_start)
				{
					_module.on_particle_start(_particle);
				}
			}
		}
		ParticlesToSpawn = [];

		var p = 0;
		var _temp1 = _deltaTimeS * 0.5;
		var _temp2 = _deltaTimeS * _deltaTimeS * 0.5;
		repeat (array_length(_particlesAlive))
		{
			with (_particlesAlive[p])
			{
				// Particle pre physics simulation
				Position.Set(
					Position.X + (Velocity.X * _deltaTimeS) + (AccelerationReal.X * _temp2),
					Position.Y + (Velocity.Y * _deltaTimeS) + (AccelerationReal.Y * _temp2),
					Position.Z + (Velocity.Z * _deltaTimeS) + (AccelerationReal.Z * _temp2));
				Acceleration.Set(0.0, 0.0, 0.0);

				// Particle update
				var m = 0;
				repeat (array_length(_modules))
				{
					var _module = _modules[m++];
					if (_module.Enabled && _module.on_particle_update)
					{
						_module.on_particle_update(self, _deltaTime);
					}
				}

				if (HealthLeft <= 0.0)
				{
					// Kill particle
					IsAlive = false;
					array_delete(_particlesAlive, p--, 1);
					array_push(_particlesDead, self);

					var m = 0;
					repeat (array_length(_modules))
					{
						var _module = _modules[m++];
						if (_module.Enabled && _module.on_particle_finish)
						{
							_module.on_particle_finish(self);
						}
					}
				}
				else
				{
					// Particle simulate physics
					Velocity.Set(
						Velocity.X + ((AccelerationReal.X + Acceleration.X) * _temp1),
						Velocity.Y + ((AccelerationReal.Y + Acceleration.Y) * _temp1),
						Velocity.Z + ((AccelerationReal.Z + Acceleration.Z) * _temp1));
					Acceleration.Copy(AccelerationReal);
				}
			}
			++p;
		}

		// Sort particles alive back-to-front by their dostance from the camera
		if (System.Sort)
		{
			array_sort(_particlesAlive, method(self, function (_p1, _p2) {
				var _camPos = global.__bbmodCameraPosition;
				var _d1 = point_distance_3d(
					_p1.Position.X,
					_p1.Position.Y,
					_p1.Position.Z,
					_camPos.X,
					_camPos.Y,
					_camPos.Z);
				var _d2 = point_distance_3d(
					_p2.Position.X,
					_p2.Position.Y,
					_p2.Position.Z,
					_camPos.X,
					_camPos.Y,
					_camPos.Z);
				// Same as:
				//var _d1 = _p1.Position.Sub(_camPos).Length();
				//var _d2 = _p2.Position.Sub(_camPos).Length();
				if (_d2 > _d1) return +1;
				if (_d2 < _d1) return -1;
				return 0;
			}));
		}

		return self;
	};

	/// @func finished([_particlesDead])
	/// @desc Checks if the emitter cycle has finished.
	/// @param {Bool} [_particlesDead] Also check if there are no particles
	/// alive. Defaults to `false.`
	/// @return {Bool} Returns `true` if the emitter cycle has finished
	/// (and there are no particles alive). Aalways returns `false` if the
	/// emitted particle system is looping.
	static finished = function (_particlesDead=false) {
		gml_pragma("forceinline");
		if (System.Loop)
		{
			return false;
		}
		if (Time >= System.Duration)
		{
			if (!_particlesDead
				|| array_length(ParticlesAlive) == 0)
			{
				return true;
			}
		}
		return false;
	};

	static _draw = function (_method, _material=undefined) {
		gml_pragma("forceinline");

		var _dynamicBatch = System.DynamicBatch;
		var _batchSize = _dynamicBatch.Size;
		_material ??= System.Material;

		matrix_set(matrix_world, matrix_build_identity());

		var _particlesAlive = ParticlesAlive;
		var _particleCount = array_length(_particlesAlive);
		var p = 0;
		repeat (ceil(_particleCount / _batchSize))
		{
			var _data = array_create(4 * 4 * _batchSize, 0);
			var d = 0;
			repeat (min(_particleCount, _batchSize))
			{
				_particlesAlive[p++].write_data(_data, d * 16);
				++d;
			}
			_particleCount -= _batchSize;
			_method(_material, _data);
		}
	};

	/// @func submit([_material])
	/// @desc Immediately submits particles for rendering.
	/// @param {Struct.BBMOD_Material/Undefined} [_material] The material to use
	/// instead of the one defined in the particle system.
	/// @return {Struct.BBMOD_ParticleEmitter} Returns `self`.
	static submit = function (_material=undefined) {
		var _dynamicBatch = System.DynamicBatch;
		_draw(method(_dynamicBatch, _dynamicBatch.submit), _material);
		return self;
	};

	/// @func render([_material])
	/// @desc Enqueus particles for rendering.
	/// @param {Struct.BBMOD_Material/Undefined} [_material] The material to use
	/// instead of the one defined in the particle system.
	/// @return {Struct.BBMOD_ParticleEmitter} Returns `self`.
	static render = function (_material=undefined) {
		var _dynamicBatch = System.DynamicBatch;
		_draw(method(_dynamicBatch, _dynamicBatch.render), _material);
		return self;
	};
}