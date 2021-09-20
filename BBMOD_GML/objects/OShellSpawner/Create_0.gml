repeat (100)
{
	var _len = random(10);
	var _dir = random(360);
	var _shell = instance_create_depth(
		x + lengthdir_x(_len, _dir),
		y + lengthdir_y(_len, _dir),
		0, OShell);
	_shell.image_angle = random(360);
}

timeout = 0;