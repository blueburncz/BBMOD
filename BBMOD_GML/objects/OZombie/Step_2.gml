// Pause the animation player for a while when the zombie is hurt
animationStateMachine.AnimationPlayer.Paused = (hurt > 0.25);

event_inherited();

if (destroy)
{
	instance_destroy();
}