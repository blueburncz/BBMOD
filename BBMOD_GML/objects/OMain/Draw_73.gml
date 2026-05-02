var _matrix = new BBMOD_Matrix();

_matrix.ScaleSelf(1000, 1000, 1000)
	.TranslateSelf(camera.Position)
	.ApplyWorld();
modSphere.render([matSky]);

_matrix.SetIdentity()
	.TranslateSelf(0, 0, 1)
	.ApplyWorld();
modSphere.render([matSphere]);

_matrix.SetIdentity()
	.TranslateSelf(4, 0, 1)
	.ApplyWorld();
modSphere.render([matSphereMetallic]);

_matrix.SetIdentity()
	.TranslateSelf(8, 0, 1)
	.ApplyWorld();
modSphere.render([matSphereEmissive]);

terrain.render();

_matrix.SetIdentity()
	.TranslateSelf(0, -8, 0)
	.ApplyWorld();
characterPlayer.render();

BBMOD_MATRIX_IDENTITY.ApplyWorld();

camera.apply();
renderer.render();
