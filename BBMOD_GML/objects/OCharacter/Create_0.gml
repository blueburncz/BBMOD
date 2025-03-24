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
});

animIdle = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character_Idle.bbanim");
animWalk = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character_Walk.bbanim");
animShoot = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character_Shoot.bbanim");
animJump = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character_Jump.bbanim");

animationPlayer = new BBMOD_LayeredAnimationPlayer(model);

layerIdle = animationPlayer.get_layer("Default");
layerIdle.Weight = 1;
layerIdle.play(animIdle, true);

layerWalk = new BBMOD_AnimationLayer("Walk");
layerWalk.Weight = 0;
animationPlayer.add_layer(layerWalk);
layerWalk.play(animWalk, true);

layerShoot = new BBMOD_AnimationLayer("Shoot");
layerShoot.Weight = 0;
animationPlayer.add_layer(layerShoot);
layerShoot.play(animShoot, true);

layerJump = new BBMOD_AnimationLayer("Jump");
layerJump.Weight = 0;
animationPlayer.add_layer(layerJump);
layerJump.play(animJump, true);
