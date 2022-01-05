event_inherited();

// The player speed when they're running.
speedRun = 2.0;

// The id of the item that the player is picking up (or undefined).
pickupTarget = undefined;

// If true then the player has a gun.
hasGun = false;

// If true then the player is aiming.
aiming = false;

// The matrix used when we render a gun in the player's hand.
matrixGun = matrix_build_identity();

////////////////////////////////////////////////////////////////////////////////
// Camera

// Define how for the camera is from the player when they aren't aiming.
zoomIdle = 50;

// Define how for the camera is from the player when the are aiming.
zoomAim = 5;

camera = new BBMOD_Camera();
camera.FollowObject = id;
camera.FollowFactor = 0.25;
camera.Offset = new BBMOD_Vec3(10, 0, 25);
camera.Zoom = zoomIdle;
camera.MouseSensitivity = 0.75;

////////////////////////////////////////////////////////////////////////////////
// Animation state machine

// Go to the state "Idle" when the state machine starts.
animationStateMachine.OnEnter = method(self, function () {
	animationStateMachine.change_state(stateIdle);
});

// This function is executed independently on the current state.
animationStateMachine.OnPreUpdate = method(self, function () {
	var _stateCurrent = animationStateMachine.State;

	var _terrainHeight = OMain.terrain.get_height_xy(x, y);

	// Go to state "Jump" if the player is above the ground.
	if (z > _terrainHeight
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

stateIdle = new BBMOD_AnimationState("Idle", OMain.animIdle, true);
stateIdle.OnUpdate = method(self, function () {
	// Go to state "Run" if the player's speed is greater or equal to the
	// running speed.
	if (speed >= speedRun)
	{
		animationStateMachine.change_state(stateRun);
		return;
	}

	// Go to state "Walk" if the player's speed is greater or equal to the
	// walking speed.
	if (speed >= speedWalk)
	{
		animationStateMachine.change_state(stateWalk);
		return;
	}
});
animationStateMachine.add_state(stateIdle);

stateWalk = new BBMOD_AnimationState("Walk", OMain.animWalk, true);
stateWalk.OnUpdate = method(self, function () {
	// Go to the "Idle" state if the player's speed is less than the walking
	// speed.
	if (speed < speedWalk)
	{
		animationStateMachine.change_state(stateIdle);
		return;
	}

	// Go to the "Run" state if the player's speed is greater than the walking
	// speed.
	if (speed >= speedRun)
	{
		animationStateMachine.change_state(stateRun);
		return;
	}
});
animationStateMachine.add_state(stateWalk);

stateRun = new BBMOD_AnimationState("Run", OMain.animRun, true);
stateRun.OnUpdate = method(self, function () {
	// Go to the "Walk" state if the player's speed is less than the running
	// speed.
	if (speed < speedRun)
	{
		animationStateMachine.change_state(stateWalk);
		return;
	}
});
animationStateMachine.add_state(stateRun);

stateJump = new BBMOD_AnimationState("Jump", OMain.animJump, true);
stateJump.OnUpdate = method(self, function () {
	// Go to the "Idle" state when player falls on the ground.
	var _terrainHeight = OMain.terrain.get_height_xy(x, y);

	if (z <= _terrainHeight)
	{
		animationStateMachine.change_state(stateIdle);
		return;
	}
});
animationStateMachine.add_state(stateJump);

stateAim = new BBMOD_AnimationState("Aim", OMain.animAim, true);
stateAim.OnUpdate = method(self, function () {
	// Go to the "Idle" state when the player is not aiming.
	if (!aiming)
	{
		animationStateMachine.change_state(stateIdle);
		return;
	}
});
animationStateMachine.add_state(stateAim);

stateShoot = new BBMOD_AnimationState("Shoot", OMain.animShoot);
stateShoot.on_event(BBMOD_EV_ANIMATION_END, method(self, function () {
	// Go to the "Aim" state at the end of the shooting animation.
	animationStateMachine.change_state(stateAim);
}));
animationStateMachine.add_state(stateShoot);

stateInteractGround = new BBMOD_AnimationState("InteractGround", OMain.animInteractGround);
stateInteractGround.on_event("PickUp", method(self, function () {
	// Pick up an item.
	if (instance_exists(pickupTarget))
	{
		if (point_distance(x, y, pickupTarget.x, pickupTarget.y) < 20)
		{
			if (pickupTarget.object_index == OGun)
			{
				hasGun = true;
			}
			instance_destroy(pickupTarget);
		}
	}
	pickupTarget = undefined;
}));
stateInteractGround.on_event(BBMOD_EV_ANIMATION_END, method(self, function () {
	// Go to the "Idle" state at the end of the animation.
	animationStateMachine.change_state(stateIdle);
}));
animationStateMachine.add_state(stateInteractGround);

animationStateMachine.start();