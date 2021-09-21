event_inherited();

active = false;
timeout = random_range(500, 1000);
totallyDead = false;

materials = [choose(OMain.matZombie0, OMain.matZombie1)];

direction = point_direction(x, y, OPlayer.x, OPlayer.y);
directionBody = direction;

animationPlayer.on_event(BBMOD_EV_ANIMATION_END, method(self, function (_animation) {
	if (_animation == OMain.animZombieDeath)
	{
		totallyDead = true;
	}
}));