event_inherited();

day = true;

sprSkyDay = sprite_add("Data/BBMOD/Skies/Sky+60.png", 0, false, true, 0, 0);
sprIblDay = sprite_add("Data/BBMOD/Skies/IBL+60.png", 0, false, true, 0, 0);

matSkyDay = BBMOD_MATERIAL_SKY.clone();
matSkyDay.BaseOpacity = sprite_get_texture(sprSkyDay, 0);

sprSkyNight = sprite_add("Data/BBMOD/Skies/Sky-15.png", 0, false, true, 0, 0);
sprIblNight = sprite_add("Data/BBMOD/Skies/IBL-15.png", 0, false, true, 0, 0);

matSkyNight = BBMOD_MATERIAL_SKY.clone();
matSkyNight.BaseOpacity = sprite_get_texture(sprSkyNight, 0);

SetSky = function (_day) {
	OMain.modSky.Materials[@ 0] = _day ? matSkyDay : matSkyNight;
	bbmod_set_ibl_sprite(_day ? sprIblDay : sprIblNight, 0);
	day = _day;
};

SetSky(day);