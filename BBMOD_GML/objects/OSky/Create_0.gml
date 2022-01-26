event_inherited();

day = choose(true, false);

modSky = global.resourceManager.load(
	"Data/BBMOD/Models/Sphere.bbmod",
	undefined,
	function (_err, _model) {
		if (!_err)
		{
			_model.freeze();
		}
	});

matSky = BBMOD_MATERIAL_SKY.clone();
matSky.BaseOpacity = -1;

sunLight = new BBMOD_DirectionalLight();
sunLight.CastShadows = true;
bbmod_light_directional_set(sunLight);

bbmod_sprite_add_async(
	day ? "Data/BBMOD/Skies/Sky+60.png" : "Data/BBMOD/Skies/Sky-15.png",
	method(self, function (_err, _sprite) {
		if (!_err)
		{
			matSky.BaseOpacity = sprite_get_texture(_sprite, 0);
		}
	}));

if (day)
{
	bbmod_light_ambient_set_up(new BBMOD_Color().FromHex($6581b0));
	bbmod_light_ambient_set_down(new BBMOD_Color().FromHex($babac3));
	sunLight.Color = BBMOD_C_WHITE;
	sunLight.Direction.Set(-1, 0, -1);
}
else
{
	bbmod_light_ambient_set_up(new BBMOD_Color().FromHex($171e2a));
	bbmod_light_ambient_set_down(new BBMOD_Color().FromHex($0b1016));
	sunLight.Color = new BBMOD_Color().FromHex($2a2a32);
	sunLight.Direction.Set(1, 0, -1);
}