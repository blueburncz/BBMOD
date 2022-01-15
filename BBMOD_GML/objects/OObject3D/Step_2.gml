z += zspeed;
zspeed -= 0.1;

if (z < 0
	&& x >= 0 && x < room_width
	&& y >= 0 && y < room_height)
{
	z = 0;
	zspeed = 0;
}