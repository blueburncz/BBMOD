var _scale = 10;
var _matrixBody = matrix_build(x, y, z, 0, 0, directionBody, _scale, _scale, _scale);
matrix_set(matrix_world, _matrixBody);
animationPlayer.render(materials);