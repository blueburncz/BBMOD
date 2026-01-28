var _matrix = new BBMOD_Matrix();

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

BBMOD_MATRIX_IDENTITY.ApplyWorld();
