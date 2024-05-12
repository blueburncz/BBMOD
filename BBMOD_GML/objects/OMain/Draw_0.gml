new BBMOD_Matrix()
	.Scale(1000, 1000, 1000)
	.Translate(camera.Position)
	.ApplyWorld();
modSphere.render([matSky]);

new BBMOD_Matrix()
	.Translate(0, 0, 1)
	.ApplyWorld();
modSphere.render([matSphere]);

terrain.render();

BBMOD_MATRIX_IDENTITY.ApplyWorld();
camera.apply();
renderer.render();
