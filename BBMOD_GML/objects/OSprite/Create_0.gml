bbmod_light_ambient_set(new BBMOD_Color(32, 32, 32));

light = new BBMOD_DirectionalLight(BBMOD_C_WHITE, new BBMOD_Vec3(-1, 1, -1).Normalize());
bbmod_light_directional_set(light);

pointLight = new BBMOD_PointLight(BBMOD_C_AQUA);
pointLight.Range = 256.0;
bbmod_light_point_add(pointLight);

material = BBMOD_MATERIAL_SPRITE.clone();
material.BaseOpacity = sprite_get_texture(sprite_index, 0);
material.NormalSmoothness = sprite_get_texture(SprNormal, 0);
