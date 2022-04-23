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

//matSmoke = BBMOD_MATERIAL_PARTICLE_LIT.clone();
//matSmoke.BaseOpacity = sprite_get_texture(SprSmoke, 0);
//matSmoke.NormalSmoothness = sprite_get_texture(SprSmoke, 1);

particleSystem = new BBMOD_ParticleSystem(BBMOD_MODEL_PARTICLE, BBMOD_MATERIAL_PARTICLE_UNLIT, 100)
	.add_module(new BBMOD_EmissionModule(1 / 60))
	.add_module(new BBMOD_RandomVelocityModule(new BBMOD_Vec3(-10, -10, 50), new BBMOD_Vec3(10, 10, 150)))
	.add_module(new BBMOD_RandomColorModule(BBMOD_C_RED, BBMOD_C_YELLOW))
	.add_module(new BBMOD_HealthOverTimeModule(-1, 1))
	.add_module(new BBMOD_ScaleByHealthModule(new BBMOD_Vec3(5)))
	.add_module(new BBMOD_PhysicsModule(BBMOD_VEC3_UP.Scale(-9800)));
particleSystem.Sort = true;
particleSystem.Loop = true;

particleEmitter = new BBMOD_ParticleEmitter(
	new BBMOD_Vec3(OPlayer.x + 100, OPlayer.y + 100, 10),
	particleSystem);

renderer.add(particleEmitter);
