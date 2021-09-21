randomize();
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

matPlayer = BBMOD_MATERIAL_PBR_ANIMATED.clone();
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
matZombie0 = BBMOD_MATERIAL_PBR_ANIMATED.clone();
matZombie0.BaseOpacity = sprite_get_texture(SprZombie, 0);

matZombie1 = BBMOD_MATERIAL_PBR_ANIMATED.clone();
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

matGun0 = BBMOD_MATERIAL_PBR.clone()
	.set_base_opacity(c_silver, 1.0)
	.set_normal_roughness(BBMOD_VEC3_UP, 0.3)
	.set_metallic_ao(1.0, 1.0);

matGun1 = BBMOD_MATERIAL_PBR.clone()
	.set_base_opacity($101010, 1.0);

matGun2 = BBMOD_MATERIAL_PBR.clone()
	.set_base_opacity(c_black, 1.0);

modGun.Materials[@ 0] = matGun0;
modGun.Materials[@ 1] = matGun1;
modGun.Materials[@ 2] = matGun2;

// Dynamically batch shells
modShell = _objImporter.import("Data/Assets/Shell.obj");

matShell = BBMOD_MATERIAL_PBR_BATCHED.clone()
	.set_base_opacity($56DAE8, 1.0)
	.set_normal_roughness(BBMOD_VEC3_UP, 0.3)
	.set_metallic_ao(1.0, 1.0);
matShell.Culling = cull_noculling;

batchShell = new BBMOD_DynamicBatch(modShell, 32);
batchShell.freeze();

// Prepare static batch for signs
matWood = BBMOD_MATERIAL_PBR.clone()
	.set_base_opacity($A7C5FF, 1.0);

modLever = _objImporter.import("Data/Assets/Lever.obj");
modLever.Materials[@ 0] = BBMOD_MATERIAL_PBR.clone()
	.set_base_opacity(c_silver, 1.0);
modLever.Materials[@ 1] = matWood;
modLever.freeze();

modSign = _objImporter.import("Data/Assets/Sign.obj");

batchSign = new BBMOD_StaticBatch(modSign.VertexFormat);

_objImporter.destroy();

////////////////////////////////////////////////////////////////////////////////
// Create a renderer
renderer = new BBMOD_Renderer()
	.add(OCharacter)
	.add(OGun)
	.add(OLever)
	.add(OSky);

renderer.UseAppSurface = true;
renderer.RenderScale = 2;

// Any object/struct that has a render method can be added to the renderer:
renderer.add({
	render: method(self, function () {
		matrix_set(matrix_world, matrix_build_identity());
		batchShell.render_object(OShell, matShell);
		batchSign.render(matWood);
	})
});