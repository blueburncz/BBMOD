event_inherited();

animationPlayer.update(delta_time);

// Slow turn body towards direction
directionBody += angle_difference(direction, directionBody) * 0.2;

var _scale = 10;
matrixBody = matrix_build(x, y, z, 0, 0, directionBody, _scale, _scale, _scale);