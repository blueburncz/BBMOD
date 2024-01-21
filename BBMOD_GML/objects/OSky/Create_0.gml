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

if (global.day)
{
	sunLight.Color = BBMOD_C_WHITE;
	sunLight.Direction.Set(0, 1, -1);
}
else
{
	sunLight.Color = new BBMOD_Color().FromHex($2a2a32);
	sunLight.Direction.Set(0, -1, -1);
}

bbmod_fog_set(BBMOD_C_SILVER, 0.8, 200.0, 1500.0);
