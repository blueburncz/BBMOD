event_inherited();

if (totallyDead)
{
	exit;
}

var _animation = OMain.animZombieIdle;
var _animationLoop = true;

if (active)
{
	if (dead)
	{
		_animation = OMain.animZombieDeath;
		_animationLoop = false;
		mask_index = noone;
	}
	else if (timeout > 0)
	{
		timeout -= delta_time * 0.001;
	}
	else
	{
		var _player = instance_find(OPlayer, 0);
		if (point_distance(x, y, _player.x, _player.y) > 25)
		{
			mp_potential_step_object(_player.x, _player.y, speedWalk, OZombie);
			_animation = OMain.animZombieWalk;
		}
		direction = point_direction(x, y, _player.x, _player.y);
	}
}

animationPlayer.change(_animation, _animationLoop);