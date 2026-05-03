bbmod_set_instance_id(id);

matrix.SetIdentity()
	.ScaleSelf(10, 10, 10)
	.RotateZSelf(90)
	.TranslateSelf(x, y, z)
	.ApplyWorld();

if (bbmod_dither_get_enabled())
{
	bbmod_dither_set_value(DitherFade);
}

model.render();

if (bbmod_dither_get_enabled())
{
	bbmod_dither_set_value(1.0);
}

bbmod_set_instance_id(0);
