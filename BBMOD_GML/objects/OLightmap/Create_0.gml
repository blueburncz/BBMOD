model = BBMOD_RESOURCE_MANAGER.load_sync("Data/Lightmap/Lightmap.bbmod").freeze();

var _material = model.Materials[0];
_material.set_base_opacity(BBMOD_C_SILVER);
_material.DitherFadeStart = 200;
_material.DitherFadeEnd = 210;

matrix = new BBMOD_Matrix()
	.ScaleSelf(10, 10, 10)
	.RotateZSelf(90)
	.TranslateSelf(x, y, 0.01);
