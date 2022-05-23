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

var _gizmo = new BBMOD_Gizmo(15.0);
_gizmo.ButtonDrag = mb_right;
_gizmo.GetInstanceRotationX = function (_instance)       { return _instance.rotation.X; };
_gizmo.GetInstanceRotationY = function (_instance)       { return _instance.rotation.Y; };
_gizmo.GetInstanceRotationZ = function (_instance)       { return _instance.rotation.Z; };
_gizmo.GetInstanceScaleX    = function (_instance)       { return _instance.scale.X; };
_gizmo.GetInstanceScaleY    = function (_instance)       { return _instance.scale.Y; };
_gizmo.GetInstanceScaleZ    = function (_instance)       { return _instance.scale.Z; };
_gizmo.SetInstanceRotationX = function (_instance, _val) { _instance.rotation.X = _val; };
_gizmo.SetInstanceRotationY = function (_instance, _val) { _instance.rotation.Y = _val; };
_gizmo.SetInstanceRotationZ = function (_instance, _val) { _instance.rotation.Z = _val; };
_gizmo.SetInstanceScaleX    = function (_instance, _val) { _instance.scale.X = _val; };
_gizmo.SetInstanceScaleY    = function (_instance, _val) { _instance.scale.Y = _val; };
_gizmo.SetInstanceScaleZ    = function (_instance, _val) { _instance.scale.Z = _val; };

renderer.Gizmo = _gizmo;
renderer.EditMode = true;
renderer.ButtonSelect = mb_right;

repeat (100)
{
	var _randomPosition = global.terrain.get_random_position();
	instance_create_layer(
		_randomPosition.X,
		_randomPosition.Y,
		"Instances",
		OEditable);
}
