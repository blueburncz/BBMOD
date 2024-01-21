event_inherited();

z = global.terrain.get_height(x, y) ?? 0.0;

// Used to raycast shots from the player's gun.
collider = new BBMOD_AABBCollider(
	new BBMOD_Vec3(x, y, z),
	new BBMOD_Vec3(5, 5, 18));

ReceiveDamage = function (_damage)
{
	hp -= _damage;
	hurt = 1.0;
	var _floatingText = instance_create_layer(x, y, layer, OFloatingText);
	_floatingText.z = z + 42;
	_floatingText.text = "-" + string(_damage);
	var _index = audio_play_sound_at(choose(SndZombie0, SndZombie1),
		x, y, z + 30, 10, 200, 1, false, 1);
	audio_sound_pitch(_index, random_range(1.0, 1.5));
};

// Knockback vector.
knockback = new BBMOD_Vec3();

// If true then the zombie drops a gun when killed.
dropGun = false;

// Number of ms till the zombie changes to the "Idle" state.
timeout = random_range(500, 1000);

// Number of ms till the zombie changes from "Idle" to "Attack" state if player
// is in range.
timeoutAttack = undefined;

// If true then the zombie will be destroyed.
destroy = false;

// Rotate the zombie towards the player on spawn.
direction = point_direction(x, y, OPlayer.x, OPlayer.y);
directionBody = direction;

// Returns true if the player is within the zombie's attack range.
playerInRange = function ()
{
	return (point_distance(x, y, OPlayer.x, OPlayer.y) <= 30);
};

// Strength of the dissolve shader effect.
dissolve = 1.0;

emitter = undefined;

////////////////////////////////////////////////////////////////////////////////
// Create material and prepare material property block

material = choose(MatZombieMale, MatZombieFemale)();

materialProps = new BBMOD_MaterialPropertyBlock();
materialProps.set_float3("u_vDissolveColor", new BBMOD_Vec3(0.0, 1.0, 0.5));
materialProps.set_float("u_fDissolveRange", 0.3);
materialProps.set_float2("u_vDissolveScale", new BBMOD_Vec2(20.0));

////////////////////////////////////////////////////////////////////////////////
// Load resources

animIdle = global.resourceManager.load("Data/Assets/Character/Zombie_Idle.bbanim");

animWalk = global.resourceManager.load(
	"Data/Assets/Character/Zombie_Walk.bbanim",
	function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(0, "Footstep")
				.add_event(32, "Footstep");
		}
	});

animAttack = global.resourceManager.load(
	"Data/Assets/Character/Zombie_Attack.bbanim",
	function (_err, _animation) {
		if (!_err)
		{
			_animation.add_event(50, "Attack");
		}
	});

animDeath = global.resourceManager.load("Data/Assets/Character/Zombie_Death.bbanim");

////////////////////////////////////////////////////////////////////////////////
// Animation state machine

// Enter the "Deactivated" state on the start of the state machine.
animationStateMachine.OnEnter = method(self, function () {
	animationStateMachine.change_state(stateDeactivated);
});

// Regardless on the current state, go to state "Death" if the zombie
// is dead.
animationStateMachine.OnPreUpdate = method(self, function () {
	var _gameSpeed = game_get_speed(gamespeed_microseconds);
	var _deltaTime = DELTA_TIME / _gameSpeed;
	x += knockback.X * _deltaTime;
	y += knockback.Y * _deltaTime;
	z += knockback.Z * _deltaTime;
	knockback = knockback.Scale(1.0 - (0.1 * _deltaTime));

	if (animationStateMachine.State != stateAttack)
	{
		if (hp <= 0
			&& animationStateMachine.State != stateDeath)
		{
			animationStateMachine.change_state(stateDeath);
			return;
		}
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
	timeout -= DELTA_TIME * 0.001;
	if (timeout <= 0)
	{
		animationStateMachine.change_state(stateIdle);
	}
});
animationStateMachine.add_state(stateDeactivated);

// When the player is out of the zombie's range, change to the "Walk" state.
stateIdle = new BBMOD_AnimationState("Idle", animIdle, true);
stateIdle.OnEnter = method(self, function () {
	timeoutAttack = random(100);
});
stateIdle.OnUpdate = method(self, function () {
	if (!playerInRange())
	{
		animationStateMachine.change_state(stateWalk);
		return;
	}

	timeoutAttack -= DELTA_TIME * 0.001;
	if (timeoutAttack <= 0)
	{
		animationStateMachine.change_state(stateAttack);
		return;
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

	if (global.terrain.in_bounds(x, y))
	{
		mp_potential_step_object(OPlayer.x, OPlayer.y, speedWalk * global.gameSpeed, OZombie);
	}
});
animationStateMachine.add_state(stateWalk);

// Attack the player.
stateAttack = new BBMOD_AnimationState("Attack", animAttack);
stateAttack.on_event("Attack", method(self, function () {
	if (z >= 0)
	{
		var _index;

		if (playerInRange())
		{
			// Player is killed in 3 hits
			OPlayer.ReceiveDamage(OPlayer.hpMax / 3.0);

			_index = audio_play_sound_at(
				SndPunch,
				x + lengthdir_x(30, direction),
				y + lengthdir_y(30, direction),
				z + 30,
				10, 200, 1, false, 1);
		}
		else
		{
			_index = audio_play_sound_at(
				SndWhoosh,
				x + lengthdir_x(30, direction),
				y + lengthdir_y(30, direction),
				z + 30,
				10, 200, 1, false, 1);
		}

		audio_sound_pitch(_index, random_range(0.5, 0.8));
	}
}));
stateAttack.on_event(BBMOD_EV_ANIMATION_END, method(self, function () {
	knockback.Set(0.0);
	animationStateMachine.change_state(stateIdle);
}));
animationStateMachine.add_state(stateAttack);

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
