event_inherited();

// The player speed when they're running.
speedRun = 2.0;

// The id of the item that the player is picking up (or undefined).
pickupTarget = undefined;

// If true then the player has a gun.
hasGun = false;

// If true then the player is aiming.
aiming = false;

// The matrix used when we render a gun in the player's hand.
matrixGun = matrix_build_identity();

////////////////////////////////////////////////////////////////////////////////
// Camera

// Define how for the camera is from the player when they aren't aiming.
zoomIdle = 50;

// Define how for the camera is from the player when the are aiming.
zoomAim = 5;

camera = new BBMOD_Camera();
camera.FollowObject = id;
camera.FollowFactor = 0.25;
camera.Offset = new BBMOD_Vec3(10, 0, 25);
camera.Zoom = zoomIdle;
camera.MouseSensitivity = 0.75;

////////////////////////////////////////////////////////////////////////////////
// Add custom event listeners to the animation player (inherited from OCharacter).
animationPlayer.on_event("PickUp", method(self, function () {
	if (instance_exists(pickupTarget))
	{
		if (point_distance(x, y, pickupTarget.x, pickupTarget.y) < 20)
		{
			if (pickupTarget.object_index == OGun)
			{
				hasGun = true;
			}
			instance_destroy(pickupTarget);
		}
	}
	pickupTarget = undefined;
}));