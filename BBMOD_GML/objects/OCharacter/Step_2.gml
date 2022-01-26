event_inherited();

// Kill the character if it falls out of the map
if (z < -200)
{
	hp = 0;
}

animationStateMachine.update(DELTA_TIME);

// Slow turn body towards direction
directionBody += angle_difference(direction, directionBody) * global.gameSpeed * 0.2;

var _scale = 10;
matrixBody = matrix_build(x, y, z, 0, 0, directionBody, _scale, _scale, _scale);