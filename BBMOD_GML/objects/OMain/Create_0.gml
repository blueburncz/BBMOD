randomize();
os_powersave_enable(false);
display_set_gui_maximize(1, 1);
audio_falloff_set_model(audio_falloff_linear_distance);

// If true then debug overlay is enabled.
debugOverlay = false;

////////////////////////////////////////////////////////////////////////////////
// Load resources

// Sky model
modSky = new BBMOD_Model("Data/BBMOD/Models/Sphere.bbmod");
modSky.freeze();

// Character
modCharacter = new BBMOD_Model("Data/Assets/Character/Character.bbmod");
modCharacter.freeze();

matPlayer = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone()
	.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH_ANIMATED); // Enable casting shadows
matPlayer.BaseOpacity = sprite_get_texture(SprPlayer, choose(0, 1));
modCharacter.Materials[0] = matPlayer;

animAim = new BBMOD_Animation("Data/Assets/Character/Character_Aim.bbanim");
animShoot = new BBMOD_Animation("Data/Assets/Character/Character_Shoot.bbanim");
animIdle = new BBMOD_Animation("Data/Assets/Character/Character_Idle.bbanim");
animInteractGround = new BBMOD_Animation("Data/Assets/Character/Character_Interact_ground.bbanim");
animInteractGround.add_event(52, "PickUp");
animJump = new BBMOD_Animation("Data/Assets/Character/Character_Jump.bbanim");
animRun = new BBMOD_Animation("Data/Assets/Character/Character_Run.bbanim");
animRun.add_event(0, "Footstep").add_event(16, "Footstep");
animWalk = new BBMOD_Animation("Data/Assets/Character/Character_Walk.bbanim");
animWalk.add_event(0, "Footstep").add_event(32, "Footstep");

// Zombie
matZombie0 = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone()
	.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH_ANIMATED); // Enable casting shadows
matZombie0.BaseOpacity = sprite_get_texture(SprZombie, 0);

matZombie1 = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone()
	.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH_ANIMATED); // Enable casting shadows
matZombie1.BaseOpacity = sprite_get_texture(SprZombie, 1);

animZombieIdle = new BBMOD_Animation("Data/Assets/Character/Zombie_Idle.bbanim");
animZombieWalk = new BBMOD_Animation("Data/Assets/Character/Zombie_Walk.bbanim");
animZombieWalk.add_event(0, "Footstep").add_event(32, "Footstep");
animZombieDeath = new BBMOD_Animation("Data/Assets/Character/Zombie_Death.bbanim");

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

// Prepare static batch for signs
matWood = BBMOD_MATERIAL_DEFAULT.clone()
	.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH) // Enable casting shadows
	.set_base_opacity(new BBMOD_Color().FromHex($FFC5A7));

modLever = _objImporter.import("Data/Assets/Lever.obj");
modLever.Materials[@ 0] = BBMOD_MATERIAL_DEFAULT.clone()
	.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH) // Enable casting shadows
	.set_base_opacity(BBMOD_C_SILVER);
modLever.Materials[@ 1] = matWood;
modLever.freeze();

modSign = _objImporter.import("Data/Assets/Sign.obj");

batchSign = new BBMOD_StaticBatch(modSign.VertexFormat);

modPlane = _objImporter.import("Data/Assets/Plane.obj");
modPlane.freeze();
matGrass = BBMOD_MATERIAL_DEFAULT.clone()
	.set_base_opacity(BBMOD_C_WHITE, 1.0);
modPlane.Materials[0] = matGrass;

_objImporter.destroy();

////////////////////////////////////////////////////////////////////////////////
// Create a renderer
renderer = new BBMOD_Renderer()
	.add(OCharacter)
	.add(OGun)
	.add(OLever)
	.add(OSky);

renderer.UseAppSurface = true;
renderer.RenderScale = 1.0;
renderer.EnableShadows = true;
renderer.ShadowmapArea *= 4;
renderer.ShadowmapResolution *= 4;
renderer.ShadowmapNormalOffset *= 2;
renderer.EnablePostProcessing = true;
renderer.ChromaticAberration = 3.0;
renderer.ColorGradingLUT = sprite_get_texture(SprColorGrading, 0);
renderer.Vignette = 0.8;
renderer.Antialiasing = BBMOD_EAntialiasing.FXAA;

// Any object/struct that has a render method can be added to the renderer:
renderer.add({
	render: method(self, function () {
		matrix_set(matrix_world, matrix_build_identity());
		batchShell.render_object(OShell, matShell);
		batchSign.render(matWood);
	})
});

//renderer.add({
//	render: method(self, function () {
//		var _scale = max(room_width, room_height);
//		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _scale, _scale, _scale));
//		modPlane.render();
//	})
//});

var _sh = new BBMOD_DefaultShader(BBMOD_ShTerrain, BBMOD_MATERIAL_DEFAULT);
var _m = new BBMOD_DefaultMaterial(_sh);
_m.TextureScale = new BBMOD_Vec2(64.0, 64.0);
_m.Repeat = true;

var _m1 = _m.clone();
_m1.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH);
_m1.BaseOpacity = sprite_get_texture(SprTextures, 0);
_m1.ZWrite = false;
_m1.ZTest = cmpfunc_equal;

var _m2 = _m.clone();
_m2.BaseOpacity = sprite_get_texture(SprTextures, 1);
_m1.ZWrite = false;
_m1.ZTest = cmpfunc_equal;

var _m3 = _m.clone();
_m3.BaseOpacity = sprite_get_texture(SprTextures, 2);
_m1.ZWrite = false;
_m1.ZTest = cmpfunc_equal;

var _m4 = _m.clone();
_m4.BaseOpacity = sprite_get_texture(SprTextures, 3);
_m1.ZWrite = false;
_m1.ZTest = cmpfunc_equal;

splatmap = sprite_add("splatmap.png", 0, false, false, 0, 0);


_m1.OnApply = method(self, function () {
	var _shader = BBMOD_SHADER_CURRENT.Raw;
	var _uSplatmap = shader_get_sampler_index(_shader, "bbmod_Splatmap");
	var _uSplatmapIndex = shader_get_uniform(_shader, "bbmod_SplatmapIndex");
	texture_set_stage(_uSplatmap, sprite_get_texture(splatmap, 0));
	shader_set_uniform_i(_uSplatmapIndex, -1);
});
_m2.OnApply = method(self, function () {
	var _shader = BBMOD_SHADER_CURRENT.Raw;
	var _uSplatmap = shader_get_sampler_index(_shader, "bbmod_Splatmap");
	var _uSplatmapIndex = shader_get_uniform(_shader, "bbmod_SplatmapIndex");
	texture_set_stage(_uSplatmap, sprite_get_texture(splatmap, 0));
	shader_set_uniform_i(_uSplatmapIndex, 0);
});
_m3.OnApply = method(self, function () {
	var _shader = BBMOD_SHADER_CURRENT.Raw;
	var _uSplatmap = shader_get_sampler_index(_shader, "bbmod_Splatmap");
	var _uSplatmapIndex = shader_get_uniform(_shader, "bbmod_SplatmapIndex");
	texture_set_stage(_uSplatmap, sprite_get_texture(splatmap, 0));
	shader_set_uniform_i(_uSplatmapIndex, 1);
});
_m4.OnApply = method(self, function () {
	var _shader = BBMOD_SHADER_CURRENT.Raw;
	var _uSplatmap = shader_get_sampler_index(_shader, "bbmod_Splatmap");
	var _uSplatmapIndex = shader_get_uniform(_shader, "bbmod_SplatmapIndex");
	texture_set_stage(_uSplatmap, sprite_get_texture(splatmap, 0));
	shader_set_uniform_i(_uSplatmapIndex, 2);
});

terrain = new BBMOD_Terrain().from_heightmap(SprHeightmap, 0, 128 * 4 * 2);
terrain.Layer[0] = _m1;
terrain.Layer[1] = _m2;
terrain.Layer[2] = _m3;
terrain.Layer[3] = _m4;
terrain.Splatmap = sprite_get_texture(splatmap, 0);
terrain.build_mesh();