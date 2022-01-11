event_inherited();

matZombie0 = OMain.resourceManager.add_or_get("matZombie0", function () {
	var _material = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone()
		.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH_ANIMATED); // Enable casting shadows
	_material.BaseOpacity = sprite_get_texture(SprZombie, 0);
	return _material;
});

matZombie1 = OMain.resourceManager.add_or_get("matZombie1", function () {
	var _material = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone()
		.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH_ANIMATED); // Enable casting shadows
	_material.BaseOpacity = sprite_get_texture(SprZombie, 1);
	return _material;
});

animIdle = OMain.resourceManager.load("Data/Assets/Character/Zombie_Idle.bbanim");

animWalk = OMain.resourceManager.load(
	"Data/Assets/Character/Zombie_Walk.bbanim",
	undefined,
	function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(0, "Footstep")
				.add_event(32, "Footstep");
		}
	});

animDeath = OMain.resourceManager.load("Data/Assets/Character/Zombie_Death.bbanim");

// If true then the zombie is dead.
dead = false;

// Number of ms till the zombie changes to the "Idle" state.
timeout = random_range(500, 1000);

// If true then the zombie will be destroyed.
destroy = false;

// Randomly choose material.
materials = [choose(matZombie0, matZombie1)];

// Rotate the zombie towards the player on spawn.
direction = point_direction(x, y, OPlayer.x, OPlayer.y);
directionBody = direction;

// Returns true if the player is within the zombie's attack range.
playerInRange = function () {
	return (point_distance(x, y, OPlayer.x, OPlayer.y) <= 25);
};

// Enter the "Deactivated" state on the start of the state machine.
animationStateMachine.OnEnter = method(self, function () {
	animationStateMachine.change_state(stateDeactivated);
});

// Regardless on the current state, go to state "Death" if the zombie
// is dead.
animationStateMachine.OnPreUpdate = method(self, function () {
	if (dead && animationStateMachine.State != stateDeath)
	{
		animationStateMachine.change_state(stateDeath);
	}
});

// If the zombie is active, rotate it towards the player.
animationStateMachine.OnPostUpdate = method(self, function () {
	if (animationStateMachine.State != stateDeactivated
		&& animationStateMachine.State != stateDeath)
	{
		direction = point_direction(x, y, OPlayer.x, OPlayer.y);
	}
});

// When the zombie is activated, wait for the timeout and then switch to the
// "Idle" state.
stateDeactivated = new BBMOD_AnimationState("Deactivated", animIdle, true);
stateDeactivated.OnUpdate = method(self, function () {
	timeout -= delta_time * 0.001;
	if (timeout <= 0)
	{
		animationStateMachine.change_state(stateIdle);
	}
});
animationStateMachine.add_state(stateDeactivated);

// When the player is out of the zombie's range, change to the "Walk" state.
stateIdle = new BBMOD_AnimationState("Idle", animIdle, true);
stateIdle.OnUpdate = method(self, function () {
	if (!playerInRange())
	{
		animationStateMachine.change_state(stateWalk);
	}
});
animationStateMachine.add_state(stateIdle);

// When the player is within the zombie's range again, change to the "Idle" state.
stateWalk = new BBMOD_AnimationState("Walk", animWalk, true);
stateWalk.OnUpdate = method(self, function () {
	if (playerInRange())
	{
		animationStateMachine.change_state(stateIdle);
		return;
	}
	mp_potential_step_object(OPlayer.x, OPlayer.y, speedWalk, OZombie);
});
animationStateMachine.add_state(stateWalk);

// When the zombie is killed, remove its collision mask and enter the final state
// of the state machine after the death animation is finished.
stateDeath = new BBMOD_AnimationState("Death", animDeath);
stateDeath.OnEnter = method(self, function () {
	mask_index = noone;
	dead = true;
});
stateDeath.on_event(BBMOD_EV_ANIMATION_END, method(self, function () {
	animationStateMachine.finish();
}));
animationStateMachine.add_state(stateDeath);

// You could also destroy the zombie when the state machine enters its final state:
//animationStateMachine.OnExit = method(self, function () {
//	destroy = true;
//});

animationStateMachine.start();