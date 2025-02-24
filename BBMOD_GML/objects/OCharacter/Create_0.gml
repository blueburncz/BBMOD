z = OMain.terrain.get_height(x, y) ?? 0;

model = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character.bbmod", undefined, function (_error, _model)
{
	bbmod_assert(_error == undefined, "Failed to load character model!");

	_model.freeze();

	var _material = OMain.useDeferredRenderer ? BBMOD_MATERIAL_DEFERRED.clone() : BBMOD_MATERIAL_DEFAULT.clone();
	_material.BaseOpacity = sprite_get_texture(SprCyborgFemaleA, 0);
	_material.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);
	_model.Materials[@ 0] = _material;
});

animIdle = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character_Idle.bbanim");
animWalk = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character_Walk.bbanim");
animShoot = BBMOD_RESOURCE_MANAGER.load("Data/Character/Character_Shoot.bbanim");

//animationPlayer = new BBMOD_AnimationPlayer2(model);

//var _layer2 = new BBMOD_AnimationLayer("Layer2");
//_layer2.Additive = true;
//_layer2.Weight = 0.5;
//animationPlayer.add_layer(_layer2);

//animationPlayer.play("Default", animWalk, true);
//animationPlayer.play("Layer2", animShoot, true);

animationPlayer = new BBMOD_AnimationPlayer(model);
animationPlayer.play(animIdle, true);
