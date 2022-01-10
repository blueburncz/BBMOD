var canvas;
var locked = false;
var movementX = 0;
var movementY = 0;

function bbmod_html5_init() {
  canvas = document.getElementById('canvas');
  document.addEventListener('pointerlockchange', onChange, false);
  document.addEventListener('mozpointerlockchange', onChange, false);
}

function onChange() {
  if (document.pointerLockElement === canvas
    || document.mozPointerLockElement === canvas) {
    document.addEventListener('mousemove', updatePosition, false);
    locked = true;
  } else {
    document.removeEventListener('mousemove', updatePosition, false);
    locked = false;
  }
}

function updatePosition(e) {
  movementX = e.movementX;
  movementY = e.movementY;
}

function bbmod_html5_pointer_lock() {
  canvas.requestPointerLock().catch(function () {});
}

function bbmod_html5_pointer_is_locked() {
  return locked;
}

function bbmod_html5_pointer_get_movement_x() {
  var movement = movementX;
  movementX = 0;
  return movement;
}

function bbmod_html5_pointer_get_movement_y() {
  var movement = movementY;
  movementY = 0;
  return movement;
}
