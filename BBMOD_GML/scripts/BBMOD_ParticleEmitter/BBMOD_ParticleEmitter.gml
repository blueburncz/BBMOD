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

	/// @var {Array<Struct.BBMOD_Particle>} An array of particles.
	/// @readonly
	Particles = array_create(System.Size, undefined);

	for (var i = 0; i < System.Size; ++i)
	{
		var _particle = new BBMOD_Particle(i);
		Position.Copy(_particle.Position);
		Particles[i] = _particle;
	}

	/// @var {Array<Real>} Data for dynamic batching.
	/// @private
	Data = array_create(3 * 4 * System.Size, 0);

	/// @var {Real}
	/// @private
	Time = 0.0;

	/// @func update(_deltaTime)
	/// @desc
	/// @param {Real} _deltaTime
	/// @return {Struct.BBMOD_ParticleEmitter} Returns `self`.
	static update = function (_deltaTime) {
		static _doSort = 0;

		var _modules = System.Modules;
		var _particles = Particles;

		// Update particles
		var m = 0;
		repeat (array_length(_modules))
		{
			var _module = _modules[m++];
			if (_module.Enabled)
			{
				_module.update(self, _deltaTime);
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
		repeat (System.Size)
		{
			_particles[p].write_data(Data, p * 12);
			++p;
		}

		return self;
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