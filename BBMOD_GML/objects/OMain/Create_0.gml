randomize();
os_powersave_enable(false);
display_set_gui_maximize(1, 1);
audio_falloff_set_model(audio_falloff_linear_distance);

// If true then debug overlay is enabled.
debugOverlay = false;

////////////////////////////////////////////////////////////////////////////////
// Load resources

// Sky model
modSky = new BBMOD_Model()
	.from_file_async("Data/BBMOD/Models/Sphere.bbmod", undefined, function (_err, _model) {
		if (!_err)
		{
			_model.freeze();
		}
	});

// Player material
matPlayer = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone()
	.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH_ANIMATED); // Enable casting shadows
matPlayer.BaseOpacity = sprite_get_texture(SprPlayer, choose(0, 1));

// Character model
modCharacter = new BBMOD_Model()
	.from_file_async("Data/Assets/Character/Character.bbmod", undefined, method(self, function (_err, _model) {
		if (!_err)
		{
			_model.Materials[0] = matPlayer;
			_model.freeze();
		}
	}));

animAim = new BBMOD_Animation().from_file_async("Data/Assets/Character/Character_Aim.bbanim");

animShoot = new BBMOD_Animation().from_file_async("Data/Assets/Character/Character_Shoot.bbanim");

animIdle = new BBMOD_Animation().from_file_async("Data/Assets/Character/Character_Idle.bbanim");

animInteractGround = new BBMOD_Animation()
	.from_file_async("Data/Assets/Character/Character_Interact_ground.bbanim", undefined, function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(52, "PickUp");
		}
	});

animJump = new BBMOD_Animation().from_file_async("Data/Assets/Character/Character_Jump.bbanim");

animRun = new BBMOD_Animation()
	.from_file_async("Data/Assets/Character/Character_Run.bbanim", undefined, function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(0, "Footstep")
				.add_event(16, "Footstep");
		}
	});

animWalk = new BBMOD_Animation()
	.from_file_async("Data/Assets/Character/Character_Walk.bbanim", undefined, function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(0, "Footstep")
				.add_event(32, "Footstep");
		}
	});

// Zombie
matZombie0 = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone()
	.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH_ANIMATED); // Enable casting shadows
matZombie0.BaseOpacity = sprite_get_texture(SprZombie, 0);

matZombie1 = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone()
	.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH_ANIMATED); // Enable casting shadows
matZombie1.BaseOpacity = sprite_get_texture(SprZombie, 1);

animZombieIdle = new BBMOD_Animation().from_file_async("Data/Assets/Character/Zombie_Idle.bbanim");

animZombieWalk = new BBMOD_Animation()
	.from_file_async("Data/Assets/Character/Zombie_Walk.bbanim", undefined, function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(0, "Footstep")
				.add_event(32, "Footstep");
		}
	});

animZombieDeath = new BBMOD_Animation().from_file_async("Data/Assets/Character/Zombie_Death.bbanim");

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
	.add(OSky)
	;

renderer.UseAppSurface = true;
renderer.RenderScale = 1.0;
renderer.EnableShadows = true;
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

renderer.add({
	render: method(self, function () {
		var _scale = max(room_width, room_height);
		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _scale, _scale, _scale));
		modPlane.render();
	})
});