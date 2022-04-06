#macro DELTA_TIME (delta_time * global.gameSpeed)

// Used to pause the game (with 0.0).
global.gameSpeed = 1.0;

randomize();
os_powersave_enable(false);
display_set_gui_maximize(1, 1);
audio_falloff_set_model(audio_falloff_linear_distance);

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
renderer.RenderScale = 1.0;
renderer.EnableShadows = true;
renderer.EnablePostProcessing = true;
renderer.ChromaticAberration = 3.0;
renderer.ColorGradingLUT = sprite_get_texture(SprColorGrading, 0);
renderer.Antialiasing = BBMOD_EAntialiasing.FXAA;

// Any object/struct that has a render method can be added to the renderer:
renderer.add({
	render: method(self, function () {
		matrix_set(matrix_world, matrix_build_identity());
		batchShell.render_object(OShell, matShell);
	})
});

////////////////////////////////////////////////////////////////////////////////
// Create terrain
var _rock = BBMOD_MATERIAL_TERRAIN.clone();
_rock.BaseOpacity = sprite_get_texture(SprRocks, 0);
_rock.NormalSmoothness = sprite_get_texture(SprRocks, 1);

var _dirt = BBMOD_MATERIAL_TERRAIN.clone();
_dirt.BaseOpacity = sprite_get_texture(SprDirt, 0);
_dirt.NormalSmoothness = sprite_get_texture(SprDirt, 1);

var _grass = BBMOD_MATERIAL_TERRAIN.clone();
_grass.BaseOpacity = sprite_get_texture(SprGrass, 0);
_grass.NormalSmoothness = sprite_get_texture(SprGrass, 1);

var _sand = BBMOD_MATERIAL_TERRAIN.clone();
_sand.BaseOpacity = sprite_get_texture(SprSand, 0);
_sand.NormalSmoothness = sprite_get_texture(SprSand, 1);

terrain = new BBMOD_Terrain(SprHeightmap);
terrain.Scale = new BBMOD_Vec3(2.0);
terrain.TextureRepeat = new BBMOD_Vec2(32.0, 32.0);
terrain.Layer[0] = _grass;
terrain.Layer[1] = _dirt;
terrain.Layer[2] = _rock;
terrain.Layer[3] = _sand;
terrain.Splatmap = sprite_get_texture(SprSplatmap, 0);
