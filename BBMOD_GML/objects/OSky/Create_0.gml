event_inherited();

global.day = !global.day;

modSky = global.resourceManager.load(
	"Data/BBMOD/Models/Sphere.bbmod",
	function (_err, _model) {
		if (!_err)
		{
			_model.freeze();
		}
	});

matSky = BBMOD_MATERIAL_SKY.clone();
matSky.BaseOpacity = -1;

bbmod_light_ambient_set(BBMOD_C_BLACK);

sunLight = new BBMOD_DirectionalLight();
sunLight.CastShadows = bbmod_deferred_renderer_is_supported() || global.day;
sunLight.ShadowmapResolution = 4096;
bbmod_light_directional_set(sunLight);

// TODO: Fix memory leaks
bbmod_sprite_add_async(
	global.day ? "Data/BBMOD/Skies/Sky+60.png" : "Data/BBMOD/Skies/Sky-15.png",
	method(self, function (_err, _sprite) {
		if (!_err)
		{
			matSky.BaseOpacity = sprite_get_texture(_sprite, 0);
		}
	}));

bbmod_sprite_add_async(
	global.day ? "Data/BBMOD/Skies/IBL+60.png" : "Data/BBMOD/Skies/IBL-15.png",
	method(self, function (_err, _sprite) {
		if (!_err)
		{
			skyLight = new BBMOD_ImageBasedLight(sprite_get_texture(_sprite, 0));
			bbmod_ibl_set(skyLight);
		}
	}));

lensFlare = undefined;

if (global.day)
{
	sunLight.Color = BBMOD_C_WHITE;
	sunLight.Direction.Set(0.30, 0.30, -0.87);

	lensFlare = new BBMOD_LensFlare();
	lensFlare.Direction = sunLight.Direction.Scale(-1.0);

	var _e;

	_e = new BBMOD_LensFlareElement(new BBMOD_Vec2(0.0), Sprite2);
	_e.Scale.Set(3.0);
	lensFlare.add_element(_e);

	for (var i = 0.1; i <= 1.0; i += 0.2)
	{
		if (i > 0.3)
		{
			_e = new BBMOD_LensFlareElement(new BBMOD_Vec2(i), Sprite1);
			_e.Scale.Set((1.0 - i) * 0.5);
			_e.Color = BBMOD_C_BLUE;
			_e.FadeOut = true;
			lensFlare.add_element(_e);
		}

		_e = new BBMOD_LensFlareElement(new BBMOD_Vec2(1.0 + i), Sprite1);
		_e.Scale.Set(i * 0.7);
		_e.Color = BBMOD_C_BLUE;
		_e.FadeOut = true;
		lensFlare.add_element(_e);
	}

	_e = new BBMOD_LensFlareElement(new BBMOD_Vec2(1.5), Sprite3);
	_e.Scale.Set(10.0);
	_e.FadeOut = true;
	_e.FlareRays = true;
	_e.AngleRelative = true;
	_e.Color.Alpha = 0.5;
	lensFlare.add_element(_e);

	bbmod_lens_flare_add(lensFlare);
}
else
{
	sunLight.Color = new BBMOD_Color().FromHex($2a2a32);
	sunLight.Direction.Set(0, -1, -1);
}

bbmod_fog_set(BBMOD_C_SILVER, 0.8, 200.0, 1500.0);
