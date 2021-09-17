event_inherited();

hasGun = false;
pickingUp = false;
speedRun = 2;
aiming = false;
shooting = false;

camera = new BBMOD_Camera();
camera.FollowObject = id;
camera.FollowFactor = 0.25;
camera.Offset = new BBMOD_Vec3(10, 0, 25);
camera.Zoom = 50;

matrixBody = matrix_build_identity();
matrixGun = matrix_build_identity();

clearState = method(self, function (_animation) {
	if (_animation == OMain.animInteractGround)
	{
		pickingUp = false;
	}
	else if (_animation == OMain.animShoot)
	{
		shooting = false;
	}
});

animationPlayer
	.on_event(BBMOD_EV_ANIMATION_CHANGE, clearState)
	.on_event(BBMOD_EV_ANIMATION_END, clearState)
	.on_event("PickUp", method(self, function () {
		if (instance_exists(OGun))
		{
			var _gun = instance_nearest(x, y, OGun);
			if (point_distance(x, y, _gun.x, _gun.y) < 20)
			{
				instance_destroy(_gun);
				hasGun = true;
			}
		}
	}));