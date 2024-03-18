#macro DELTA_TIME (delta_time * global.gameSpeed)

var _deferred = bbmod_deferred_renderer_is_supported();

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

var _matGunBase = (_deferred ? BBMOD_MATERIAL_DEFERRED : BBMOD_MATERIAL_DEFAULT).clone()
	.set_shader(
		BBMOD_ERenderPass.Id, BBMOD_SHADER_INSTANCE_ID) // Enable instance selecting
	.set_shader(
		BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH); // Enable casting shadows

matGun0 = _matGunBase.clone()
	.set_base_opacity(BBMOD_C_SILVER, 1.0)
	.set_metallic_ao(1.0, 1.0)
	.set_normal_roughness(BBMOD_VEC3_UP, 0.3);

matGun1 = _matGunBase.clone()
	.set_base_opacity(new BBMOD_Color(32, 32, 32));

matGun2 = _matGunBase.clone()
	.set_base_opacity(BBMOD_C_BLACK);

modGun.Materials[@ 0] = matGun0;
modGun.Materials[@ 1] = matGun1;
modGun.Materials[@ 2] = matGun2;

// Dynamically batch shells
modShell = _objImporter.import("Data/Assets/Shell.obj");

matShell = (_deferred ? BBMOD_MATERIAL_DEFERRED : BBMOD_MATERIAL_DEFAULT).clone()
	.set_shader(BBMOD_ERenderPass.Id, BBMOD_SHADER_INSTANCE_ID_BATCHED)
	.set_base_opacity(new BBMOD_Color().FromHex($E8DA56))
	.set_specular_color(new BBMOD_Color().FromConstant($E8DA56))
	.set_normal_smoothness(BBMOD_VEC3_UP, 0.7);
matShell.Culling = cull_noculling;

batchShell = new BBMOD_DynamicBatch(modShell, 32).freeze();
batchShell.Batch.Materials[0] = matShell;

_objImporter = _objImporter.destroy();

////////////////////////////////////////////////////////////////////////////////
// Create a renderer
gizmo = new BBMOD_Gizmo();
gizmo.ButtonDrag = mb_right;

renderer = new (_deferred ? BBMOD_DeferredRenderer : BBMOD_DefaultRenderer)();
renderer.Gizmo = gizmo;
renderer.ButtonSelect = mb_right;
renderer.UseAppSurface = true;
renderer.RenderScale = (os_browser == browser_not_a_browser) ? 1.0 : 0.8;
renderer.EnableShadows = true;

postProcessor = new BBMOD_PostProcessor();
renderer.PostProcessor = postProcessor;

//postProcessor.add_effect(new BBMOD_LumaSharpenEffect(1.5, 1.0, 2.0));
postProcessor.add_effect(new BBMOD_DepthOfFieldEffect());
postProcessor.add_effect(new BBMOD_LightBloomEffect(new BBMOD_Vec3(0.75), new BBMOD_Vec3(2.0), true));
directionalBlur = new BBMOD_DirectionalBlurEffect();
postProcessor.add_effect(directionalBlur);
radialBlur = new BBMOD_RadialBlurEffect();
radialBlur.Strength = 0.0;
radialBlur.Step = 1.0 / 16.0;
postProcessor.add_effect(radialBlur);

if (bbmod_hdr_is_supported())
{
	postProcessor.add_effect(new BBMOD_ReinhardTonemapEffect());
}

postProcessor.add_effect(new BBMOD_LensFlaresEffect());

postProcessor.add_effect(
	new BBMOD_ColorGradingEffect(
		sprite_get_texture(SprColorGrading, 0)
	)
);

//postProcessor.add_effect(new BBMOD_NormalDistortionEffect(sprite_get_texture(SprRaindrops, 0), 10));

monochrome = new BBMOD_MonochromeEffect(0.0);
postProcessor.add_effect(monochrome);
postProcessor.add_effect(
	new BBMOD_ChromaticAberrationEffect(
		3.0,
		new BBMOD_Vec3(-1.0, 1.0, -1.0)
	)
);
//postProcessor.add_effect(new BBMOD_FilmGrainEffect());
vignette = new BBMOD_VignetteEffect(0.0, c_red);
postProcessor.add_effect(vignette);
postProcessor.add_effect(new BBMOD_VignetteEffect(0.8));

if (os_browser == browser_not_a_browser)
{
	renderer.EnableGBuffer = true;
	renderer.EnableSSAO = true;
	renderer.SSAORadius = 32.0;
	renderer.SSAODepthRange = 5.0;
	renderer.SSAOPower = 2.0;

	postProcessor.add_effect(new BBMOD_FXAAEffect());
}

// Any object/struct that has a render method can be added to the renderer:
renderer
	.add(batchShell)
	.add(global.terrain)
	;

// Add a refleciton probe
var _terrainWidth = global.terrain.Size.X * global.terrain.Scale.X;
var _terrainHeight = global.terrain.Size.Y * global.terrain.Scale.Y;
var _probeX = _terrainWidth / 2;
var _probeY = _terrainHeight / 2;
var _probeZ = global.terrain.get_height(_probeX, _probeY) + 20;

reflectionProbe = new BBMOD_ReflectionProbe(new BBMOD_Vec3(_probeX, _probeY, _probeZ));
reflectionProbe.Infinite = true;
bbmod_reflection_probe_add(reflectionProbe);

// Trees
modTree = global.resourceManager.load("Data/Assets/Tree/Tree.bbmod", method(self, function (_err, _model) {
	if (!_err)
	{
		_model.Materials[0].RenderQueue = new BBMOD_MeshRenderQueue();
		_model.Materials[1].RenderQueue = new BBMOD_MeshRenderQueue();
		treeBatch = new BBMOD_DynamicBatch(modTree).freeze();

		var _terrainWidth = global.terrain.Size.X * global.terrain.Scale.X;
		var _terrainHeight = global.terrain.Size.Y * global.terrain.Scale.Y;
		repeat (10)
		{
			instance_create_layer(random(_terrainWidth), random(_terrainHeight), layer, OTree);
		}
	}
}));
