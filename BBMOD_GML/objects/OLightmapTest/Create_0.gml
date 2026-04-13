model = BBMOD_RESOURCE_MANAGER.load_sync("Data/Lightmap/Lightmap.bbmod").freeze();

model.Materials[0].set_base_opacity(BBMOD_C_SILVER);

matrix = new BBMOD_Matrix()
	.ScaleSelf(10, 10, 10)
	.RotateZSelf(90)
	.TranslateSelf(x, y, 0.01)
