if (hp <= 0)
{
	emitter ??= instance_create_layer(x, y, layer, ODissolveEmitter);

	dissolve += DELTA_TIME * 0.000001;
	if (dissolve >= 1.0)
	{
		destroy = true;
	}
}
else
{
	if (dissolve > 0.0)
	{
		dissolve = max(dissolve - (DELTA_TIME * 0.000001), 0.0);
	}
}

if (emitter != undefined
	&& instance_exists(emitter))
{
	emitter.x = x;
	emitter.y = y;
	emitter.z = z;
}

materialProps.set_float("u_fDissolveThreshold", dissolve);
materialProps.set_float4("u_vSilhouette", new BBMOD_Vec4(1.0, 1.0, 1.0, hurt * 4.0));
