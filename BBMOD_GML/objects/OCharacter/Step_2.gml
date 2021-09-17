event_inherited();

// Update animation player
animationPlayer.update(delta_time);

// Slow turn body towards direction
directionBody += angle_difference(direction, directionBody) * 0.2;