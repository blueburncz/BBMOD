model = BBMOD_RESOURCE_MANAGER.load_async("Data/Lightmap/Lightmap.bbmod");
matrix = new BBMOD_Matrix()
	.ScaleSelf(10, 10, 10)
	.RotateZSelf(90)
	.TranslateSelf(x, y, 0.01)
