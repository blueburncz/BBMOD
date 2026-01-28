// Sky
new BBMOD_Matrix().ScaleSelf(1000, 1000, 1000)
	.TranslateSelf(camera.Position)
	.ApplyWorld();
modSphere.render([matSky]);
BBMOD_MATRIX_IDENTITY.ApplyWorld();

// Terrain
terrain.render();
