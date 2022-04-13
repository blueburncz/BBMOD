/// @func BBMOD_ParticleEmitter(_position, _system)
/// @desc
/// @param {Struct.BBMOD_Vec3} _position
/// @param {Struct.BBMOD_ParticleSystem} _system
function BBMOD_ParticleEmitter(_position, _system) constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Position = _position;

	/// @var {Struct.BBMOD_ParticleSystem}
	/// @readonly
	System = _system;

	/// @var {Array<Struct.BBMOD_Particle>}
	/// @readonly
	Particles = array_create(System.Size, undefined);

	for (var i = 0; i < System.Size; ++i)
	{
		var _particle = new BBMOD_Particle(i);
		Position.Copy(_particle.Position);
		Particles[i] = _particle;
	}

	/// @var {Array<Real>}
	/// @private
	Data = array_create(3 * 4 * System.Size, 0);

	static update = function (_deltaTime) {
		static _doSort = 0;

		if (System.OnUpdate != undefined)
		{
			var i = 0;

			if ((_doSort == 0) && System.Sort)
			{
				repeat (System.Size)
				{
					System.OnUpdate(Particles[i++], _deltaTime);
				}

				array_sort(Particles, method(self, function (_p1, _p2) {
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

				i = 0;
				repeat (System.Size)
				{
					var _particle = Particles[i];
					_particle.Position.ToArray(Data, i * 12);
					_particle.Scale.Scale(_particle.IsAlive ? 1.0 : 0.0).ToArray(Data, i * 12 + 4);
					_particle.Color.ToRGBM(Data, i * 12 + 8);
					++i;
				}
			}
			else
			{
				repeat (System.Size)
				{
					var _particle = Particles[i];
					System.OnUpdate(_particle, _deltaTime);
					_particle.Position.ToArray(Data, i * 12);
					_particle.Scale.Scale(_particle.IsAlive ? 1.0 : 0.0).ToArray(Data, i * 12 + 4);
					_particle.Color.ToRGBM(Data, i * 12 + 8);
					++i;
				}
			}

			// TODO: Configure particle sorting frequency
			if (++_doSort >= 4) _doSort = 0;
		}
	};

	static submit = function (_material=undefined) {
		gml_pragma("forceinline");
		matrix_set(matrix_world, matrix_build_identity());
		System.DynamicBatch.submit(_material ?? System.DynamicBatch.Model.Materials[0], Data);
		return self;
	};

	static render = function (_material=undefined) {
		gml_pragma("forceinline");
		matrix_set(matrix_world, matrix_build_identity());
		System.DynamicBatch.render(_material ?? System.DynamicBatch.Model.Materials[0], Data);
		return self;
	};
}