event_inherited();

global.day = true;//!global.day;

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
sunLight.ShadowmapArea = 1500;
bbmod_light_directional_set(sunLight);

// TODO: Fix memory leaks
bbmod_sprite_add_async(
	global.day ? "Data/BBMOD/Skies/Sky+20.png" : "Data/BBMOD/Skies/Sky-15.png",
	method(self, function (_err, _sprite) {
		if (!_err)
		{
			matSky.BaseOpacity = sprite_get_texture(_sprite, 0);
		}
	}));

bbmod_sprite_add_async(
	global.day ? "Data/BBMOD/Skies/IBL+20.png" : "Data/BBMOD/Skies/IBL-15.png",
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
	//sunLight.Direction.Set(0.30, 0.30, -0.87);
	sunLight.Direction.Set(0.54, 0.77, -0.34);

	lensFlare = new BBMOD_LensFlare();
	lensFlare.Direction = sunLight.Direction;
	lensFlare.add_ghosts(BBMOD_SprLensFlareHeptagon, 0, 8, 0.1, 1.0, 0.5, 0.1, 3.0, BBMOD_C_BLUE);

	_e = new BBMOD_LensFlareElement(BBMOD_SprLensFlareStreak, 0, new BBMOD_Vec2(0.0));
	_e.Scale.Set(2.0, 1.0);
	_e.Color = BBMOD_C_ORANGE;
	_e.Color.Alpha = 0.5;
	lensFlare.add_element(_e);

	_e = new BBMOD_LensFlareElement(BBMOD_SprLensFlareHoop, 0, new BBMOD_Vec2(0.75));
	_e.Scale.Set(5.0);
	_e.ScaleByDistanceMin.Set(0.0);
	_e.ScaleByDistanceMax.Set(1.0);
	_e.ApplyStarburst = true;
	_e.AngleRelative = true;
	_e.Color.Alpha = 0.5;
	lensFlare.add_element(_e);

	bbmod_lens_flare_add(lensFlare);

	var _sunshafts = new BBMOD_SunShaftsEffect(sunLight.Direction);
	_sunshafts.Color = BBMOD_C_ORANGE.Mix(BBMOD_C_WHITE, 0.5);
	_sunshafts.BlendMode = bm_max;
	OMain.postProcessor.add_effect(_sunshafts);
}
else
{
	sunLight.Color = new BBMOD_Color().FromHex($2a2a32);
	sunLight.Direction.Set(0, -1, -1);
}

//bbmod_fog_set(BBMOD_C_SILVER, 0.8, 200.0, 1500.0);
