#macro DELTA_TIME (delta_time * global.gameSpeed)

// Used to pause the game (with 0.0).
global.gameSpeed = 1.0;

randomize();
os_powersave_enable(false);
display_set_gui_maximize(1, 1);
audio_falloff_set_model(audio_falloff_linear_distance);
gpu_set_tex_max_aniso(2);

// If true then debug overlay is enabled.
debugOverlay = false;

// Score recieved by killing zombies.
score = 0;

// Score recieved when all zombies in a wave are killed before the timeout.
global.scoreBonus = 0;

// Current wave of zombies.
wave = 1;

// Timeout till the next wave of zombies (in seconds).
waveTimeout = 10.0;

////////////////////////////////////////////////////////////////////////////////
// Import OBJ models

var _objImporter = new BBMOD_OBJImporter();
_objImporter.FlipUVVertically = true;

modGun = _objImporter.import("Data/Assets/Pistol.obj");
modGun.freeze();

matGun0 = BBMOD_MATERIAL_DEFAULT.clone()
	.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH) // Enable casting shadows
	.set_base_opacity(BBMOD_C_SILVER)
	.set_specular_color(BBMOD_C_SILVER)
	.set_normal_smoothness(BBMOD_VEC3_UP, 0.8);

matGun1 = BBMOD_MATERIAL_DEFAULT.clone()
	.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH) // Enable casting shadows
	.set_base_opacity(new BBMOD_Color(32, 32, 32));

matGun2 = BBMOD_MATERIAL_DEFAULT.clone()
	.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH) // Enable casting shadows
	.set_base_opacity(BBMOD_C_BLACK);

modGun.Materials[@ 0] = matGun0;
modGun.Materials[@ 1] = matGun1;
modGun.Materials[@ 2] = matGun2;

// Dynamically batch shells
modShell = _objImporter.import("Data/Assets/Shell.obj");

matShell = BBMOD_MATERIAL_DEFAULT_BATCHED.clone()
	.set_base_opacity(new BBMOD_Color().FromHex($E8DA56))
	.set_specular_color(new BBMOD_Color().FromConstant($E8DA56))
	.set_normal_smoothness(BBMOD_VEC3_UP, 0.7);
matShell.Culling = cull_noculling;

batchShell = new BBMOD_DynamicBatch(modShell, 32);
batchShell.freeze();

_objImporter.destroy();

////////////////////////////////////////////////////////////////////////////////
// Create a renderer
renderer = new BBMOD_Renderer();

renderer.UseAppSurface = true;
renderer.RenderScale = (os_browser == browser_not_a_browser) ? 1.0 : 0.8;
renderer.EnableShadows = true;
renderer.EnablePostProcessing = true;
renderer.ChromaticAberration = 3.0;
renderer.ColorGradingLUT = sprite_get_texture(SprColorGrading, 0);
if (os_browser == browser_not_a_browser)
{
	renderer.Antialiasing = BBMOD_EAntialiasing.FXAA;
}

// Any object/struct that has a render method can be added to the renderer:
renderer.add(
	{
		render: method(self, function () {
			matrix_set(matrix_world, matrix_build_identity());
			batchShell.render_object(OShell, matShell);
		})
	})
	.add(global.terrain);

particleSystem = new BBMOD_ParticleSystem(BBMOD_MODEL_PARTICLE, 64);
particleSystem.Sort = true;

/// @func BBMOD_EmissionModule([_interval])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_interval]
function BBMOD_EmissionModule(_interval=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Interval = _interval;

	/// @var {Real]
	/// @private
	Timer = 0.0;

	static on_update = function (_emitter, _deltaTime) {
		Timer += _deltaTime * 0.000001;
		if (Timer >= Interval)
		{
			_emitter.spawn_particle();
			Timer = 0.0;
		}
	};
}

/// @func BBMOD_RandomScaleModule([_min[, _max]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_min]
/// @param {Struct.BBMOD_Vec3/Undefined} [_max]
function BBMOD_RandomScaleModule(_min=undefined, _max=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Min = _min ?? new BBMOD_Vec3(1.0);

	/// @var {Struct.BBMOD_Vec3}
	Max = _max ?? Min;

	static on_start_particle = function (_particle) {
		_particle.Scale = Min.Lerp(Max, random(1.0));
	};
}

function BBMOD_HealthOverTimeModule(_change=-1.0, _period=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Change = _change;

	/// @var {Real}
	Period = _period;

	static on_update_particle = function (_particle, _deltaTime) {
		_particle.HealthLeft += Change * ((_deltaTime * 0.000001) / Period);
	};
}

/// @func BBMOD_ScaleByHealthModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @param {Struct.BBMOD_Vec3/Undefined} [_from]
/// @param {Struct.BBMOD_Vec3/Undefined} [_to]
function BBMOD_ScaleByHealthModule(_from=undefined, _to=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	From = _from ?? new BBMOD_Vec3(1.0);

	/// @var {Struct.BBMOD_Vec3}
	To = _to ?? new BBMOD_Vec3();

	static on_update_particle = function (_particle, _deltaTime) {
		with (_particle)
		{
			Scale = other.To.Lerp(other.From, clamp(HealthLeft / Health, 0.0, 1.0));
		}
	};
}

/// @func BBMOD_RandomVelocityModule([_min[, _max]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_min]
/// @param {Struct.BBMOD_Vec3/Undefined} [_max]
function BBMOD_RandomVelocityModule(_min=undefined, _max=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Min = _min ?? BBMOD_VEC3_UP;

	/// @var {Struct.BBMOD_Vec3}
	Max = _max ?? Min;

	static on_start_particle = function (_particle) {
		_particle.Velocity = new BBMOD_Vec3(
			lerp(Min.X, Max.X, random(1)),
			lerp(Min.Y, Max.Y, random(1)),
			lerp(Min.Z, Max.Z, random(1)));
	};
}

/// @func BBMOD_RandomColorModule([_color1[, _color2]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Color/Undefined} [_color1]
/// @param {Struct.BBMOD_Color/Undefined} [_color2]
function BBMOD_RandomColorModule(_color1=undefined, _color2=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Color}
	Color1 = _color1 ?? BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Color}
	Color2 = _color2 ?? Color1;

	static on_start_particle = function (_particle) {
		_particle.Color = Color1.Mix(Color2, random(1.0));
	};
}

/// @func BBMOD_PhysicsModule()
/// @extends BBMOD_ParticleModule
/// @desc
function BBMOD_PhysicsModule()
	: BBMOD_ParticleModule() constructor
{
	/// @func {Struct.BBMOD_Vec3}
	Gravity = BBMOD_VEC3_UP.Scale(-9800);

	static on_update_particle = function (_particle, _deltaTime) {
		_deltaTime *= 0.000001;
		with (_particle)
		{
			Velocity = Velocity.Add(other.Gravity.Scale(_deltaTime * _deltaTime));
			Position = Position.Add(Velocity.Scale(_deltaTime));
		}
	};
}

particleSystem.add_module(new BBMOD_EmissionModule(1 / 64));
particleSystem.add_module(new BBMOD_RandomVelocityModule(new BBMOD_Vec3(-10, -10, 50), new BBMOD_Vec3(10, 10, 150)));
particleSystem.add_module(new BBMOD_RandomColorModule(BBMOD_C_FUCHSIA, BBMOD_C_AQUA));
particleSystem.add_module(new BBMOD_HealthOverTimeModule(-1, 1));
particleSystem.add_module(new BBMOD_ScaleByHealthModule(new BBMOD_Vec3(5)));
particleSystem.add_module(new BBMOD_PhysicsModule());

particleEmitter = new BBMOD_ParticleEmitter(
	new BBMOD_Vec3(room_width * 0.5 - 200, room_height * 0.5 - 200, 10),
	particleSystem);

renderer.add(particleEmitter);
