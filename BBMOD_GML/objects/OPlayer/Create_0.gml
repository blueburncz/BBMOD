event_inherited();

// The player speed when they're running.
speedRun = 1.75;

// The id of the item that the player is picking up (or undefined).
pickupTarget = undefined;

// Number of ammo that the player has.
ammo = 0;

// If true then the player is aiming.
aiming = false;

// The matrix used when we render a gun in the player's hand.
matrixGun = matrix_build_identity();

punchRight = true;

chainPunch = false;

flashlight = new BBMOD_SpotLight();
flashlight.CastShadows = true;
flashlight.Range = 300;
flashlight.Color.Alpha = 0.5;
flashlight.AngleInner = 15;
flashlight.AngleOuter = 30;
bbmod_light_punctual_add(flashlight);

////////////////////////////////////////////////////////////////////////////////
// Camera

// Define how for the camera is from the player when they aren't aiming.
zoomIdle = 50;

// Define how for the camera is from the player when the are aiming.
zoomAim = 5;

camera = new BBMOD_Camera();
//camera.Width = 200;
//camera.Orthographic = true;
//camera.ZFar *= 0.5;
//camera.ZNear = -camera.ZFar;
camera.FollowObject = self;
camera.FollowFactor = 0.25;
camera.Offset = new BBMOD_Vec3(10, 0, 25);
camera.Zoom = zoomIdle;
camera.MouseSensitivity = 0.75;

////////////////////////////////////////////////////////////////////////////////
// Load resources
matPlayer = global.resourceManager.get_or_add("matPlayer", function () {
	var _material = BBMOD_MATERIAL_DEFAULT.clone()
		.set_shader(BBMOD_ERenderPass.Id, BBMOD_SHADER_INSTANCE_ID) // Enable instance selecting
		.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH); // Enable casting shadows
	_material.BaseOpacity = sprite_get_texture(SprPlayer, choose(0, 1));
	return _material;
});

animAim = global.resourceManager.load(
	"Data/Assets/Character/Character_Aim.bbanim");

animShoot = global.resourceManager.load(
	"Data/Assets/Character/Character_Shoot.bbanim");

animPunchLeft = global.resourceManager.load(
	"Data/Assets/Character/Character_PunchLeft.bbanim",
	undefined,
	function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(3, "Footstep");
			_animation.add_event(round(_animation.Duration / 4), "ChainPunch");
		}
	});

animPunchRight = global.resourceManager.load(
	"Data/Assets/Character/Character_PunchRight.bbanim",
	undefined,
	function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(3, "Footstep");
			_animation.add_event(round(_animation.Duration / 4), "ChainPunch");
		}
	});

animIdle = global.resourceManager.load(
	"Data/Assets/Character/Character_Idle.bbanim");

animInteractGround = global.resourceManager.load(
	"Data/Assets/Character/Character_Interact_ground.bbanim",
	undefined,
	function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(52, "PickUp");
		}
	});

animJump = global.resourceManager.load(
	"Data/Assets/Character/Character_Jump.bbanim");

animRun = global.resourceManager.load(
	"Data/Assets/Character/Character_Run.bbanim",
	undefined,
	function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(0, "Footstep")
				.add_event(16, "Footstep");
		}
	});

animWalk = global.resourceManager.load(
	"Data/Assets/Character/Character_Walk.bbanim",
	undefined,
	function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(0, "Footstep")
				.add_event(32, "Footstep");
		}
	});

////////////////////////////////////////////////////////////////////////////////
// Animation state machine

animationPlayer.on_event("ChainPunch", method(self, function () {
	chainPunch = true;
}));

// Go to the state "Idle" when the state machine starts.
animationStateMachine.OnEnter = method(self, function () {
	animationStateMachine.change_state(stateIdle);
});

// This function is executed independently on the current state.
animationStateMachine.OnPreUpdate = method(self, function () {
	var _stateCurrent = animationStateMachine.State;

	// Go to state "Jump" if the player is above the ground of they're falling
	// out of the map.
	var _terrainHeight = global.terrain.get_height(x, y);

	if ((_terrainHeight == undefined || z > _terrainHeight + 5 || z < -1)
		&& _stateCurrent != stateJump)
	{
		animationStateMachine.change_state(stateJump);
		return;
	}

	// Go to state "InteractGround" when the player is picking up an item.
	if (pickupTarget != undefined
		&& _stateCurrent != stateInteractGround)
	{
		animationStateMachine.change_state(stateInteractGround);
		return;
	}

	// Go to state "Aim" if the player is aiming.
	if (aiming
		&& _stateCurrent != stateAim
		&& _stateCurrent != stateShoot)
	{
		animationStateMachine.change_state(stateAim);
		return;
	}
});

stateIdle = new BBMOD_AnimationState("Idle", animIdle, true);
stateIdle.OnUpdate = method(self, function () {
	// Go to state "Run" if the player's speed is greater or equal to the
	// running speed.
	if (speedCurrent >= speedRun)
	{
		animationStateMachine.change_state(stateRun);
		return;
	}

	// Go to state "Walk" if the player's speed is greater or equal to the
	// walking speed.
	if (speedCurrent >= speedWalk)
	{
		animationStateMachine.change_state(stateWalk);
		return;
	}
});
animationStateMachine.add_state(stateIdle);

stateWalk = new BBMOD_AnimationState("Walk", animWalk, true);
stateWalk.OnUpdate = method(self, function () {
	// Go to the "Idle" state if the player's speed is less than the walking
	// speed.
	if (speedCurrent < speedWalk)
	{
		animationStateMachine.change_state(stateIdle);
		return;
	}

	// Go to the "Run" state if the player's speed is greater than the walking
	// speed.
	if (speedCurrent >= speedRun)
	{
		animationStateMachine.change_state(stateRun);
		return;
	}
});
animationStateMachine.add_state(stateWalk);

stateRun = new BBMOD_AnimationState("Run", animRun, true);
stateRun.OnUpdate = method(self, function () {
	// Go to the "Walk" state if the player's speed is less than the running
	// speed.
	if (speedCurrent < speedRun)
	{
		animationStateMachine.change_state(stateWalk);
		return;
	}
});
animationStateMachine.add_state(stateRun);

stateJump = new BBMOD_AnimationState("Jump", animJump, true);
stateJump.OnUpdate = method(self, function () {
	// Go to the "Idle" state when player falls on the ground.
	var _terrainHeight = global.terrain.get_height(x, y);

	if (z == _terrainHeight)
	{
		animationStateMachine.change_state(stateIdle);
		return;
	}
});
animationStateMachine.add_state(stateJump);

stateAim = new BBMOD_AnimationState("Aim", animAim, true);
stateAim.OnUpdate = method(self, function () {
	// Go to the "Idle" state when the player is not aiming.
	if (!aiming)
	{
		animationStateMachine.change_state(stateIdle);
		return;
	}
});
animationStateMachine.add_state(stateAim);

stateShoot = new BBMOD_AnimationState("Shoot", animShoot);
stateShoot.on_event(BBMOD_EV_ANIMATION_END, method(self, function () {
	// Go to the "Aim" state at the end of the shooting animation.
	animationStateMachine.change_state(stateAim);
}));
animationStateMachine.add_state(stateShoot);

statePunchLeft = new BBMOD_AnimationState("PunchLeft", animPunchLeft);
statePunchLeft.on_event(BBMOD_EV_ANIMATION_END, method(self, function () {
	// Go to the "Idle" state at the end of the punching animation.
	animationStateMachine.change_state(stateIdle);
}));
animationStateMachine.add_state(statePunchLeft);

statePunchRight = new BBMOD_AnimationState("PunchRight", animPunchRight);
statePunchRight.on_event(BBMOD_EV_ANIMATION_END, method(self, function () {
	// Go to the "Idle" state at the end of the punching animation.
	animationStateMachine.change_state(stateIdle);
}));
animationStateMachine.add_state(statePunchRight);

stateInteractGround = new BBMOD_AnimationState("InteractGround", animInteractGround);
stateInteractGround.OnUpdate = method(self, function () {
	// Rotate towards an item.
	if (pickupTarget != undefined
		&& instance_exists(pickupTarget)
		&& point_distance(x, y, pickupTarget.x, pickupTarget.y) > 5)
	{
		direction = point_direction(x, y, pickupTarget.x, pickupTarget.y);
	}
});
stateInteractGround.on_event("PickUp", method(self, function () {
	// Pick up an item.
	if (instance_exists(pickupTarget))
	{
		pickupTarget.OnPickUp(self);
		instance_destroy(pickupTarget);
	}
	pickupTarget = undefined;
}));
stateInteractGround.on_event(BBMOD_EV_ANIMATION_END, method(self, function () {
	// Go to the "Idle" state at the end of the animation.
	animationStateMachine.change_state(stateIdle);
}));
animationStateMachine.add_state(stateInteractGround);

animationStateMachine.start();
