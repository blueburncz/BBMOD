event_inherited();

active = false;
timeout = random_range(500, 1000);

materials = [choose(OMain.matZombie0, OMain.matZombie1)];

direction = point_direction(x, y, OPlayer.x, OPlayer.y);
directionBody = direction;

playerInRange = function () {
	return (point_distance(x, y, OPlayer.x, OPlayer.y) <= 25);
};

animationStateMachine.OnPreUpdate = method(self, function () {
	if (dead && animationStateMachine.State != stateDeath)
	{
		animationStateMachine.change_state(stateDeath);
	}
});

animationStateMachine.OnPostUpdate = method(self, function () {
	if (animationStateMachine.State != stateDeactivated
		&& animationStateMachine.State != stateDeath)
	{
		direction = point_direction(x, y, OPlayer.x, OPlayer.y);
	}
});

stateDeactivated = new BBMOD_AnimationState("Deactivated", OMain.animZombieIdle, true);
stateDeactivated.OnUpdate = method(self, function () {
	if (active)
	{
		timeout -= delta_time * 0.001;
		if (timeout <= 0)
		{
			animationStateMachine.change_state(stateIdle);
		}
	}
});
animationStateMachine.add_state(stateDeactivated, true);

stateIdle = new BBMOD_AnimationState("Idle", OMain.animZombieIdle, true);
stateIdle.OnUpdate = method(self, function () {
	if (!playerInRange())
	{
		animationStateMachine.change_state(stateWalk);
	}
});
animationStateMachine.add_state(stateIdle);

stateWalk = new BBMOD_AnimationState("Walk", OMain.animZombieWalk, true);
stateWalk.OnUpdate = method(self, function () {
	if (playerInRange())
	{
		animationStateMachine.change_state(stateIdle);
		return;
	}

	mp_potential_step_object(OPlayer.x, OPlayer.y, speedWalk, OZombie);
});
animationStateMachine.add_state(stateWalk);

stateDeath = new BBMOD_AnimationState("Death", OMain.animZombieDeath);
stateDeath.OnEnter = method(self, function () {
	mask_index = noone;
});
animationStateMachine.add_state(stateDeath);