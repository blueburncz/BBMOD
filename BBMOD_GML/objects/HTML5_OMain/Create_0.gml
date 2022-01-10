z = 0;

camera = new BBMOD_Camera();
camera.FollowObject = self;
camera.Zoom = 4;
camera.Offset.Set(0, 0, 2);
camera.Direction = 180;

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
	.from_file_async("Data/Assets/Character/Character_Idle.bbanim");

animationPlayer = new BBMOD_AnimationPlayer(model);
animationPlayer.play(animation, true);