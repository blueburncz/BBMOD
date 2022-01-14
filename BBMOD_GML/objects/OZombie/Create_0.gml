event_inherited();

knockback = new BBMOD_Vec3();

// Number of ms till the zombie changes to the "Idle" state.
timeout = random_range(500, 1000);

// If true then the zombie will be destroyed.
destroy = false;

// Rotate the zombie towards the player on spawn.
direction = point_direction(x, y, OPlayer.x, OPlayer.y);
directionBody = direction;

// Returns true if the player is within the zombie's attack range.
playerInRange = function () {
	return (point_distance(x, y, OPlayer.x, OPlayer.y) <= 25);
};

// Strength of the dissolve shader effect.
dissolve = 0;

////////////////////////////////////////////////////////////////////////////////
// Create a custom material. Each zombie has its own since each instance needs
// to pass its own values for the dissolve effect.

material = mat_zombie().clone();
material.BaseOpacity = sprite_get_texture(SprZombie, choose(0, 1));
material.OnApply = method(self, function (_material) {
	var _shader = BBMOD_SHADER_CURRENT;
	var _dissolveColor = _shader.get_uniform("u_vDissolveColor");
	var _dissolveThreshold = _shader.get_uniform("u_fDissolveThreshold");
	var _dissolveRange = _shader.get_uniform("u_fDissolveRange");
	var _dissolveScale = _shader.get_uniform("u_vDissolveScale");
	_shader.set_uniform_f3(_dissolveColor, 0.0, 1.0, 0.5);
	_shader.set_uniform_f(_dissolveThreshold, dissolve);
	_shader.set_uniform_f(_dissolveRange, 0.3);
	_shader.set_uniform_f2(_dissolveScale, 20.0, 20.0);
});

////////////////////////////////////////////////////////////////////////////////
// Load resources

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

////////////////////////////////////////////////////////////////////////////////
// Animation state machine

// Enter the "Deactivated" state on the start of the state machine.
animationStateMachine.OnEnter = method(self, function () {
	animationStateMachine.change_state(stateDeactivated);
});

// Regardless on the current state, go to state "Death" if the zombie
// is dead.
animationStateMachine.OnPreUpdate = method(self, function () {
	if (animationStateMachine.State != stateDeath)
	{
		if (hp <= 0)
		{
			animationStateMachine.change_state(stateDeath);
			return;
		}
		x += knockback.X;
		y += knockback.Y;
		z += knockback.Z;
		knockback = knockback.Scale(0.9);
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
	hp = 0;
});
stateDeath.on_event(BBMOD_EV_ANIMATION_END, method(self, function () {
	animationStateMachine.finish();
}));
animationStateMachine.add_state(stateDeath);

animationStateMachine.start();