event_inherited();

position = new BBMOD_Vec3(x, y, z);

emitter = new BBMOD_ParticleEmitter(position, DissolveParticleSystem());

light = new BBMOD_PointLight(new BBMOD_Color(0, 255, 127, 0), position, 40);
light.RenderPass = ~(1 << BBMOD_ERenderPass.ReflectionCapture);

bbmod_light_punctual_add(light);

lensFlare = new BBMOD_LensFlare();
lensFlare.Position = position.Add(new BBMOD_Vec3(0, 0, 30));
lensFlare.Range = 100;

var _e;

_e = new BBMOD_LensFlareElement(BBMOD_SprLensFlareShimmer, 0, new BBMOD_Vec2(0.0));
_e.Scale.Set(2.0);
_e.Color = light.Color;
lensFlare.add_element(_e);

for (var i = 0.05; i <= 0.5; i += 0.1)
{
	if (i > 0.05)
	{
		_e = new BBMOD_LensFlareElement(BBMOD_SprLensFlareGhost, 0, new BBMOD_Vec2(i));
		_e.Scale.Set((0.5 - i) * 0.3);
		_e.Color = light.Color;
		_e.FadeOut = true;
		lensFlare.add_element(_e);
	}

	_e = new BBMOD_LensFlareElement(BBMOD_SprLensFlareGhost, 0, new BBMOD_Vec2(0.5 + i));
	_e.Scale.Set(i * 2.0 * 0.5);
	_e.Color = light.Color;
	_e.FadeOut = true;
	lensFlare.add_element(_e);
}

bbmod_lens_flare_add(lensFlare);
