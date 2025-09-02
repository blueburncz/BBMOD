z = OMain.terrain.get_height(x, y) ?? 0;

model = BBMOD_RESOURCE_MANAGER.load_sync("Data/Character/Character.bbmod").freeze();

var _material = OMain.useDeferredRenderer ? BBMOD_MATERIAL_DEFERRED.clone() : BBMOD_MATERIAL_DEFAULT.clone();
_material.BaseOpacity = sprite_get_texture(SprCyborgFemaleA, 0);
_material.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);
model.Materials[@ 0] = _material;

animIdle = BBMOD_RESOURCE_MANAGER.load_sync("Data/Character/Character_Idle.bbanim");
animWalk = BBMOD_RESOURCE_MANAGER.load_sync("Data/Character/Character_Walk.bbanim").add_event(10, "MyEvent");
animRun = BBMOD_RESOURCE_MANAGER.load_sync("Data/Character/Character_Run.bbanim");
animShoot = BBMOD_RESOURCE_MANAGER.load_sync("Data/Character/Character_Shoot.bbanim");
animJump = BBMOD_RESOURCE_MANAGER.load_sync("Data/Character/Character_Jump.bbanim");

animationPlayer = new BBMOD_LayeredAnimationPlayer(model);

layerIdle = animationPlayer.get_layer("Default");
//layerIdle.Enabled = false;
layerIdle.play(animIdle, true);

layerWalk = new BBMOD_AnimationLayer("Walk");
layerWalk.Weight = 1;
//layerWalk.Enabled = false;
layerWalk.PlaybackSpeed = -2;
layerWalk.on_event("MyEvent", function ()
{
	show_debug_message($"MyEvent ({current_time})");
});
animationPlayer.add_layer(layerWalk);
layerWalk.play(animWalk, true);

layerShoot = new BBMOD_AnimationLayer("Shoot");
layerShoot.Weight = 1;
//layerShoot.Enabled = false;
animationPlayer.add_layer(layerShoot);
layerShoot.play(animShoot, true);

var _upperBodyMask = new BBMOD_SkeletonMask(model);
_upperBodyMask.set_node_mask_recursive("Spine", 1.0);
show_debug_message(_upperBodyMask.MaskArray);
layerShoot.Mask = _upperBodyMask;

layerJump = new BBMOD_AnimationLayer("Jump");
layerJump.Weight = 0;
//layerJump.Enabled = false;
animationPlayer.add_layer(layerJump);
layerJump.play(animJump, true);

torsoAngle = 60;

layerTorso = new BBMOD_AnimationLayer("Torso");
layerTorso.Additive = true;
layerTorso.set_node_rotation(1, new BBMOD_Quaternion().FromAxisAngle(BBMOD_VEC3_RIGHT, torsoAngle));
//layerTorso.Enabled = false;
animationPlayer.add_layer(layerTorso);

var _torsoMask = new BBMOD_SkeletonMask(model);
_torsoMask.set_node_mask(1, 1.0);
layerTorso.Mask = _torsoMask;

ui = new CGUI();
