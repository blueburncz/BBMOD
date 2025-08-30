z = OMain.terrain.get_height(x, y) ?? 0;

model = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character.bbmod", undefined, function (_error, _model)
{
	bbmod_assert(_error == undefined, "Failed to load character model!");

	_model.freeze();

	var _material = OMain.useDeferredRenderer ? BBMOD_MATERIAL_DEFERRED.clone() : BBMOD_MATERIAL_DEFAULT.clone();
	_material.BaseOpacity = sprite_get_texture(SprCyborgFemaleA, 0);
	_material.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);
	_model.Materials[@ 0] = _material;

	var _upperBodyMask = new BBMOD_SkeletonMask(_model);
	_upperBodyMask.set_node_mask_recursive("Spine", 1.0);
	show_debug_message(_upperBodyMask.MaskArray);
	layerShoot.Mask = _upperBodyMask;

	var _torsoMask = new BBMOD_SkeletonMask(_model);
	_torsoMask.set_node_mask(2, 1.0);
	layerTorso.Mask = _torsoMask;
});

animIdle = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character_Idle.bbanim");
animWalk = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character_Walk.bbanim", undefined, function (_err, _anim)
{
	bbmod_assert(_err == undefined);
	_anim.add_event(10, "MyEvent");
});
animShoot = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character_Shoot.bbanim");
animJump = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character_Jump.bbanim");

animationPlayer = new BBMOD_LayeredAnimationPlayer(model);

layerIdle = animationPlayer.get_layer("Default");
layerIdle.Additive = true;
layerIdle.Weight = 1;
layerIdle.play(animIdle, true);

layerWalk = new BBMOD_AnimationLayer("Walk");
layerWalk.Weight = 1;
layerWalk.SpeedMultiplier = -2;
layerWalk.on_event("MyEvent", function ()
{
	show_debug_message("MyEvent!!!");
});
animationPlayer.add_layer(layerWalk);
layerWalk.play(animWalk, true);

layerShoot = new BBMOD_AnimationLayer("Shoot");
layerShoot.Weight = 1;
animationPlayer.add_layer(layerShoot);
layerShoot.play(animShoot, true);

layerTorso = new BBMOD_AnimationLayer("Torso");
layerTorso.Additive = true;
layerTorso.set_node_rotation(2, new BBMOD_Quaternion().FromAxisAngle(BBMOD_VEC3_RIGHT, 60));
animationPlayer.add_layer(layerTorso);

layerJump = new BBMOD_AnimationLayer("Jump");
layerJump.Weight = 0;
animationPlayer.add_layer(layerJump);
layerJump.play(animJump, true);
