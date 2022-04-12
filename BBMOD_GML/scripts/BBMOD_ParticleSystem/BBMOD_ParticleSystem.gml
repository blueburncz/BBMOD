/// @func BBMOD_ParticleSystem(_model, _size)
/// @param {Struct.BBMOD_Model} _model
/// @param {Real} _size
function BBMOD_ParticleSystem(_model, _size)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Struct.BBMOD_Vec3}
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Model}
	/// @readonly
	Model = _model;

	/// @var {Real}
	/// @readonly
	Size = _size;

	/// @var {Bool}
	Sort = false;

	/// @var {Struct.BBMOD_DynamicBatch}
	/// @private
	DynamicBatch = new BBMOD_DynamicBatch(_model, _size);

	/// @var {Array.Struct.BBMOD_Particle}
	/// @readonly
	Particles = array_create(_size, undefined);

	for (var i = 0; i < _size; ++i)
	{
		Particles[i] = new BBMOD_Particle(i);
	}

	/// @var {Array.Real}
	/// @private
	Data = array_create(3 * 4 * _size, 0);

	/// @var {Function} A function that takes a particle and delta time.
	OnUpdate = undefined;

	static update = function (_deltaTime) {
		static _doSort = 0;

		if (OnUpdate != undefined)
		{
			var i = 0;

			if ((_doSort == 0) && Sort)
			{
				repeat (Size)
				{
					OnUpdate(Particles[i++], _deltaTime);
				}

				array_sort(Particles, method(self, function (_p1, _p2) {
					// TODO: Should be sorted in view-space, not by distance from the camera!
					var _camPos = global.__bbmodCameraPosition;
					var _d1 = point_distance_3d(
						Position.X + _p1.Position.X,
						Position.Y + _p1.Position.Y,
						Position.Z + _p1.Position.Z,
						_camPos.X,
						_camPos.Y,
						_camPos.Z);
					var _d2 = point_distance_3d(
						Position.X + _p2.Position.X,
						Position.Y + _p2.Position.Y,
						Position.Z + _p2.Position.Z,
						_camPos.X,
						_camPos.Y,
						_camPos.Z);
					//var _d1 = Position.Add(_p1.Position).Sub(_camPos).Length();
					//var _d2 = Position.Add(_p2.Position).Sub(_camPos).Length();
					if (_d2 > _d1) return +1;
					if (_d2 < _d1) return -1;
					return 0;
				}));

				i = 0;
				repeat (Size)
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
				repeat (Size)
				{
					var _particle = Particles[i];
					OnUpdate(_particle, _deltaTime);
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
		new BBMOD_Matrix().Translate(Position).ApplyWorld();
		DynamicBatch.submit(_material ?? Model.Materials[0], Data);
		new BBMOD_Matrix().ApplyWorld();
		return self;
	};

	static render = function (_material=undefined) {
		gml_pragma("forceinline");
		new BBMOD_Matrix().Translate(Position).ApplyWorld();
		DynamicBatch.render(_material ?? Model.Materials[0], Data);
		new BBMOD_Matrix().ApplyWorld();
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		DynamicBatch.destroy();
	};
}