event_inherited();

active = false;
timeout = random_range(500, 1000);
attacking = false;

materials = [choose(OMain.matZombie0, OMain.matZombie1)];

direction = point_direction(x, y, OPlayer.x, OPlayer.y);
directionBody = direction;