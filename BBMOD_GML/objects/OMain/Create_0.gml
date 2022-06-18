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
	renderer.EnableGBuffer = true;
	renderer.EnableSSAO = true;
	renderer.SSAORadius = 32.0;
	renderer.SSAODepthRange = 5.0;
	renderer.SSAOPower = 2.0;
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

////////////////////////////////////////////////////////////////////////////////
// Particles
matParticles = BBMOD_MATERIAL_PARTICLE_UNLIT.clone();
matParticles.BlendMode = bm_add;

particleSystem = new BBMOD_ParticleSystem(BBMOD_MODEL_PARTICLE, matParticles, 100)
	.add_modules(
		new BBMOD_EmissionOverTimeModule(1, 0.02),
		new BBMOD_SphereEmissionModule(5),
		new BBMOD_MixVec3Module(BBMOD_EParticle.VelocityX, new BBMOD_Vec3(-1.0, -1.0, -100.0), new BBMOD_Vec3(1.0, 1.0, -50.0)),
		new BBMOD_SetRealModule(BBMOD_EParticle.Bounce, 0.8),
		new BBMOD_SetRealModule(BBMOD_EParticle.Drag, 0.01),
		new BBMOD_SetVec3Module(BBMOD_EParticle.ScaleX, new BBMOD_Vec3(10.0)),
		new BBMOD_MixVec3FromHealthModule(BBMOD_EParticle.ScaleX, new BBMOD_Vec3(1.0), new BBMOD_Vec3(0.0)),
		new BBMOD_MixColorFromHealthModule(BBMOD_EParticle.ColorR, BBMOD_C_ORANGE, BBMOD_C_RED),
		new BBMOD_GravityModule(BBMOD_VEC3_UP.Scale(-98.0)),
		new BBMOD_DragModule(),
		new BBMOD_TerrainCollisionModule(global.terrain),
		new BBMOD_AddRealOnCollisionModule(BBMOD_EParticle.HealthLeft, -1.0 / 3.0),
	);
particleSystem.Loop = true;

var _emitterPosition = new BBMOD_Vec3(OPlayer.x + 80, OPlayer.y + 80, 30);

particleEmitter = new BBMOD_ParticleEmitter(
	_emitterPosition,
	particleSystem);

emitterLight = new BBMOD_PointLight(BBMOD_C_ORANGE, _emitterPosition, 30);

bbmod_light_point_add(emitterLight);

renderer.add(particleEmitter);
