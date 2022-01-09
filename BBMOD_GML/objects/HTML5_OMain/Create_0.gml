bbmod_light_ambient_set_down(BBMOD_C_WHITE);
bbmod_light_ambient_set_up(BBMOD_C_GRAY);

model = new BBMOD_Model()
	.from_file_async("Data/Assets/Character/Character.bbmod", undefined, function (_err, _model) {
		if (_err == undefined)
		{
			var _material = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone();
			_material.BaseOpacity = sprite_get_texture(SprPlayer, 1);
			_material.Culling = cull_noculling;
			_model.Materials[0] = _material;
		}
	});

animation = new BBMOD_Animation()
	.from_file_async("Data/Assets/Character/Character_Run.bbanim");

animationPlayer = new BBMOD_AnimationPlayer(model);
animationPlayer.play(animation, true);