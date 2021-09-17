randomize();
show_debug_overlay(false);
display_set_gui_maximize(1, 1);
gpu_set_tex_filter(true);
gpu_set_tex_mip_enable(mip_on);
audio_falloff_set_model(audio_falloff_linear_distance);

renderer = new BBMOD_Renderer()
	.add(OCharacter)
	.add(OGun)
	.add(OSky);

renderer.UseAppSurface = true;
renderer.RenderScale = 2;

modSky = new BBMOD_Model("Data/BBMOD/Models/Sphere.bbmod");
modSky.Materials[@ 0] = BBMOD_MATERIAL_SKY;
modSky.freeze();

modCharacter = new BBMOD_Model("Data/Assets/Character/Character.bbmod");
modCharacter.freeze();

matPlayer = BBMOD_MATERIAL_PBR_ANIMATED.clone();
matPlayer.BaseOpacity = sprite_get_texture(SprPlayer, choose(0, 1));
modCharacter.Materials[0] = matPlayer;

matZombie0 = BBMOD_MATERIAL_PBR_ANIMATED.clone();
matZombie0.BaseOpacity = sprite_get_texture(SprZombie, 0);

matZombie1 = BBMOD_MATERIAL_PBR_ANIMATED.clone();
matZombie1.BaseOpacity = sprite_get_texture(SprZombie, 1);

animAim = new BBMOD_Animation("Data/Assets/Character/Character_Root_Aim.bbanim");
animShoot = new BBMOD_Animation("Data/Assets/Character/Character_Root_Shoot.bbanim");
animIdle = new BBMOD_Animation("Data/Assets/Character/Character_Root_Idle.bbanim");
animInteractGround = new BBMOD_Animation("Data/Assets/Character/Character_Root_Interact_ground.bbanim");
animInteractGround.add_event(52, "PickUp");
animJump = new BBMOD_Animation("Data/Assets/Character/Character_Root_Jump.bbanim");
animRun = new BBMOD_Animation("Data/Assets/Character/Character_Root_Run.bbanim");
animRun.add_event(0, "Footstep").add_event(16, "Footstep");
animWalk = new BBMOD_Animation("Data/Assets/Character/Character_Root_Walk.bbanim");
animWalk.add_event(0, "Footstep").add_event(32, "Footstep");

animZombieIdle = new BBMOD_Animation("Data/Assets/Character/Zombie_Root_Idle.bbanim");
animZombieWalk = new BBMOD_Animation("Data/Assets/Character/Zombie_Root_Walk.bbanim");
animZombieWalk.add_event(0, "Footstep").add_event(32, "Footstep");
animZombieAttack = new BBMOD_Animation("Data/Assets/Character/Zombie_Root_Attack.bbanim");
animZombieDeath = new BBMOD_Animation("Data/Assets/Character/Zombie_Root_Death.bbanim");

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

modShell = _objImporter.import("Data/Assets/Shell.obj");

matShell = BBMOD_MATERIAL_PBR_BATCHED.clone()
	.set_base_opacity($56DAE8, 1.0)
	.set_normal_roughness(BBMOD_VEC3_UP, 0.3)
	.set_metallic_ao(1.0, 1.0);
matShell.Culling = cull_noculling;

batchShell = new BBMOD_DynamicBatch(modShell, 32);

modSign = _objImporter.import("Data/Assets/Sign.obj");
matSign = BBMOD_MATERIAL_PBR.clone()
	.set_base_opacity($A7C5FF, 1.0);

batchSign = new BBMOD_StaticBatch(modSign.VertexFormat);

_objImporter.destroy();