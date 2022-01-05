event_inherited();

day = true;

sprSkyDay = sprite_add("Data/BBMOD/Skies/Sky+60.png", 0, false, true, 0, 0);
sprIblDay = sprite_add("Data/BBMOD/Skies/IBL+60.png", 0, false, true, 0, 0);

iblDay = new BBMOD_ImageBasedLight(sprite_get_texture(sprIblDay, 0));

matSkyDay = BBMOD_MATERIAL_SKY.clone();
matSkyDay.BaseOpacity = sprite_get_texture(sprSkyDay, 0);

sprSkyNight = sprite_add("Data/BBMOD/Skies/Sky-15.png", 0, false, true, 0, 0);
sprIblNight = sprite_add("Data/BBMOD/Skies/IBL-15.png", 0, false, true, 0, 0);

iblNight = new BBMOD_ImageBasedLight(sprite_get_texture(sprIblNight, 0));

matSkyNight = BBMOD_MATERIAL_SKY.clone();
matSkyNight.BaseOpacity = sprite_get_texture(sprSkyNight, 0);

sunLight = new BBMOD_DirectionalLight();
sunLight.CastShadows = true;
bbmod_light_directional_set(sunLight);

bbmod_fog_set(BBMOD_C_WHITE, 0.8, 100, 1500);

SetSky = function (_day) {
	// For PBR materials
	bbmod_ibl_set(_day ? iblDay : iblNight);

	// Simulate sky color with dynamic lights for the default materials
	if (_day)
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

	day = _day;
};

SetSky(day);