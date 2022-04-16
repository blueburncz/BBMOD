/// @func BBMOD_ParticleEmitter(_position, _system)
/// @desc
/// @param {Struct.BBMOD_Vec3} _position The emitter's position in world-space.
/// @param {Struct.BBMOD_ParticleSystem} _system The system of particles that
/// this emitter emits.
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
	Particles = array_create(System.Size, undefined);

	/// @var {Array<Struct.BBMOD_Particle>} Particles to be spawned.
	/// @private
	ParticlesToSpawn = [];

	/// @var {Array<Struct.BBMOD_Particle>} Alive particles.
	/// @private
	ParticlesAlive = [];

	/// @var {Array<Struct.BBMOD_Particle>} Dead particles that can be spawned.
	/// @private
	ParticlesDead = array_create(System.Size, undefined);

	for (var i = 0; i < System.Size; ++i)
	{
		var _particle = new BBMOD_Particle(i);
		Position.Copy(_particle.Position);
		Particles[i] = _particle;
		ParticlesDead[i] = _particle;
	}

	/// @var {Array<Real>} Data for dynamic batching.
	/// @private
	Data = array_create(3 * 4 * System.Size, 0);

	/// @var {Real}
	/// @private
	Time = 0.0;

	/// @func spawn_particle()
	/// @desc
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
	/// @desc
	/// @param {Real} _deltaTime
	/// @return {Struct.BBMOD_ParticleEmitter} Returns `self`.
	static update = function (_deltaTime) {
		if (finished(true))
		{
			return self;
		}

		static _doSort = 0;

		var _modules = System.Modules;
		var _particles = Particles;
		var _particlesToSpawn = ParticlesToSpawn;
		var _particlesAlive = ParticlesAlive;
		var _particlesToKill = [];
		var _particlesDead = ParticlesDead;

		var _timeStart = (Time == 0.0);
		Time += _deltaTime * 0.000001;
		var _timeOut = (Time >= System.Duration);
		if (_timeOut && System.Loop)
		{
			Time = 0.0;
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
				if (_module.Enabled)
				{
					_module.on_particle_start(_particle);
				}
			}
		}
		ParticlesToSpawn = [];

		var m = 0;
		repeat (array_length(_modules))
		{
			var _module = _modules[m++];
			if (_module.Enabled)
			{
				// Emitter start
				if (_timeStart)
				{
					_module.on_start(self);
				}

				// Emitter update
				_module.on_update(self, _deltaTime);

				// Particle update
				var p = 0;
				repeat (array_length(_particlesAlive))
				{
					var _particle = _particlesAlive[p];
					if (_particle.HealthLeft <= 0.0)
					{
						_particle.IsAlive = false;
						array_delete(_particlesAlive, p--, 1);
						array_push(_particlesToKill, _particle);
					}
					else
					{
						_module.on_particle_update(_particle, _deltaTime);
					}
					++p;
				}

				// Emitter finish
				if (_timeOut)
				{
					_module.on_finish(self);
				}
			}
		}

		// Kill particles
		var p = 0;
		repeat (array_length(_particlesToKill))
		{
			var _particle = _particlesToKill[p++];
			array_push(_particlesDead, _particle);

			var m = 0;
			repeat (array_length(_modules))
			{
				var _module = _modules[m++];
				if (_module.Enabled)
				{
					_module.on_particle_fiinish(_particle);
				}
			}
		}

		// Sort particles
		if (System.Sort && (_doSort == 0))
		{
			// Sort particles back-to-front by their dostance from the camera
			array_sort(_particles, method(self, function (_p1, _p2) {
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
				//var _d1 = _p1.Position.Sub(_camPos).Length();
				//var _d2 = _p2.Position.Sub(_camPos).Length();
				if (_d2 > _d1) return +1;
				if (_d2 < _d1) return -1;
				return 0;
			}));
		}

		// TODO: Configure particle sorting frequency
		if (++_doSort >= 4) _doSort = 0;

		// Write particle data
		var p = 0;
		repeat (array_length(_particles))
		{
			_particles[p].write_data(Data, p * 12);
			++p;
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

	/// @func submit([_material])
	/// @desc
	/// @param {Struct.BBMOD_Material/Undefined} [_material]
	/// @return {Struct.BBMOD_ParticleEmitter} Returns `self`.
	static submit = function (_material=undefined) {
		gml_pragma("forceinline");
		matrix_set(matrix_world, matrix_build_identity());
		var _dynamicBatch = System.DynamicBatch;
		_dynamicBatch.submit(_material ?? _dynamicBatch.Model.Materials[0], Data);
		return self;
	};

	/// @func render([_material])
	/// @desc
	/// @param {Struct.BBMOD_Material/Undefined} [_material]
	/// @return {Struct.BBMOD_ParticleEmitter} Returns `self`.
	static render = function (_material=undefined) {
		gml_pragma("forceinline");
		matrix_set(matrix_world, matrix_build_identity());
		var _dynamicBatch = System.DynamicBatch;
		_dynamicBatch.render(_material ?? _dynamicBatch.Model.Materials[0], Data);
		return self;
	};
}