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

modPlane = _objImporter.import("Data/Assets/Plane.obj");
modPlane.freeze();
matFloor = BBMOD_MATERIAL_DEFAULT.clone()
	.set_base_opacity(BBMOD_C_WHITE, 1.0)
	.set_specular_color(BBMOD_C_GRAY);
matFloor.NormalSmoothness = sprite_get_texture(SprFloor, 0);
matFloor.Repeat = true;
matFloor.TextureScale = matFloor.TextureScale.Scale(20.0);
modPlane.Materials[0] = matFloor;

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

//renderer.add({
//	render: method(self, function () {
//		var _scale = max(room_width, room_height);
//		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _scale, _scale, _scale));
//		modPlane.render();
//	})
//});

var _sh = new BBMOD_DefaultShader(BBMOD_ShTerrain, BBMOD_VFORMAT_DEFAULT);
var _m = new BBMOD_DefaultMaterial(_sh);
_m.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH);
_m.TextureScale = new BBMOD_Vec2(64.0, 64.0);
_m.Mipmapping = mip_on;
_m.Repeat = true;

var _rock = _m.clone();
_rock.set_base_opacity(BBMOD_C_GRAY);
_rock.NormalSmoothness = sprite_get_texture(SprFloor, 0);

var _dirt = _m.clone();
_dirt.set_base_opacity(BBMOD_C_ORANGE);
_dirt.NormalSmoothness = sprite_get_texture(SprFloor, 0);

var _grass = _m.clone();
_grass.set_base_opacity(BBMOD_C_LIME);
_grass.NormalSmoothness = sprite_get_texture(SprFloor, 0);

var _sand = _m.clone();
_sand.set_base_opacity(BBMOD_C_YELLOW);
_sand.NormalSmoothness = sprite_get_texture(SprFloor, 0);

splatmap = -1;

// TODO: Fix memory leak
bbmod_sprite_add_async("splatmap.png", method(self, function (_err, _sprite) {
	if (!_err)
	{
		splatmap = sprite_get_texture(_sprite, 0);
	}
}));

terrain = new BBMOD_Terrain().from_heightmap(SprHeightmap, 0, 128 * 4 * 2);

terrain.Layer[0] = _grass;
terrain.Layer[0].set_priority(0);
terrain.Layer[0].OnApply = method(self, function (_material) {
	var _uSplatmap = BBMOD_SHADER_CURRENT.get_sampler_index("bbmod_Splatmap");
	var _uSplatmapIndex = BBMOD_SHADER_CURRENT.get_uniform("bbmod_SplatmapIndex");
	if (splatmap != -1)
	{
		texture_set_stage(_uSplatmap, splatmap);
	}
	shader_set_uniform_i(_uSplatmapIndex, -1);
});

terrain.Layer[1] = _dirt;
terrain.Layer[1].set_priority(1);
terrain.Layer[1].remove_shader(BBMOD_ERenderPass.Shadows);
terrain.Layer[1].ZWrite = false;
terrain.Layer[1].ZTest = cmpfunc_equal;
terrain.Layer[1].OnApply = method(self, function (_material) {
	var _uSplatmap = BBMOD_SHADER_CURRENT.get_sampler_index("bbmod_Splatmap");
	var _uSplatmapIndex = BBMOD_SHADER_CURRENT.get_uniform("bbmod_SplatmapIndex");
	if (splatmap != -1)
	{
		texture_set_stage(_uSplatmap, splatmap);
	}
	shader_set_uniform_i(_uSplatmapIndex, 0);
});

//terrain.Layer[2] = ;
//terrain.Layer[2].set_priority(2);
//terrain.Layer[2].remove_shader(BBMOD_ERenderPass.Shadows);
//terrain.Layer[2].ZWrite = false;
//terrain.Layer[2].ZTest = cmpfunc_equal;
//terrain.Layer[2].OnApply = method(self, function (_material) {
//	var _shader = BBMOD_SHADER_CURRENT.Raw;
//	var _uSplatmap = shader_get_sampler_index(_shader, "bbmod_Splatmap");
//	var _uSplatmapIndex = shader_get_uniform(_shader, "bbmod_SplatmapIndex");
//	texture_set_stage(_uSplatmap, splatmap);
//	shader_set_uniform_i(_uSplatmapIndex, 1);
//});

terrain.Layer[3] = _rock;
terrain.Layer[3].set_priority(3);
terrain.Layer[3].remove_shader(BBMOD_ERenderPass.Shadows);
terrain.Layer[3].ZWrite = false;
terrain.Layer[3].ZTest = cmpfunc_equal;
terrain.Layer[3].OnApply = method(self, function (_material) {
	var _uSplatmap = BBMOD_SHADER_CURRENT.get_sampler_index("bbmod_Splatmap");
	var _uSplatmapIndex = BBMOD_SHADER_CURRENT.get_uniform("bbmod_SplatmapIndex");
	if (splatmap != -1)
	{
		texture_set_stage(_uSplatmap, splatmap);
	}
	shader_set_uniform_i(_uSplatmapIndex, 2);
});

terrain.Layer[4] = _sand;
terrain.Layer[4].set_priority(4);
terrain.Layer[4].remove_shader(BBMOD_ERenderPass.Shadows);
terrain.Layer[4].ZWrite = false;
terrain.Layer[4].ZTest = cmpfunc_equal;
terrain.Layer[4].OnApply = method(self, function (_material) {
	var _uSplatmap = BBMOD_SHADER_CURRENT.get_sampler_index("bbmod_Splatmap");
	var _uSplatmapIndex = BBMOD_SHADER_CURRENT.get_uniform("bbmod_SplatmapIndex");
	if (splatmap != -1)
	{
		texture_set_stage(_uSplatmap, splatmap);
	}
	shader_set_uniform_i(_uSplatmapIndex, 3);
});

terrain.Splatmap = splatmap;
terrain.build_mesh();