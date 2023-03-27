if (keyboard_check_pressed(vk_enter))
{
	bbmod_ibl_set(OSky.skyLight);

	cubemap.Position.X = OPlayer.x;
	cubemap.Position.Y = OPlayer.y;
	cubemap.Position.Z = OPlayer.z + 20;

	var _gbuffer = renderer.EnableGBuffer;
	//var _shadows = renderer.EnableShadows;

	renderer.EnableGBuffer = false;
	//renderer.EnableShadows = false;

	while (cubemap.set_target())
	{
		draw_clear(c_black);
		renderer.render(false);
		cubemap.reset_target();
	}

	renderer.EnableGBuffer = _gbuffer;
	//renderer.EnableShadows = _shadows;

	cubemap.to_single_surface();
	cubemap.to_octahedron();

	var _x = 0;

	gpu_push_state();
	gpu_set_state(bbmod_gpu_get_default_state());
	gpu_set_tex_filter(true);
	gpu_set_blendenable(false);

	probe = surface_create(cubemap.Resolution * 8, cubemap.Resolution);
	surface_set_target(probe);

	shader_set(__BBMOD_ShPrefilterSpecular);
	var _uRoughness = shader_get_uniform(__BBMOD_ShPrefilterSpecular, "u_fRoughness");
	for (var i = 0; i <= 6; ++i)
	{
		shader_set_uniform_f(_uRoughness, i / 6);
		draw_surface(cubemap.SurfaceOctahedron, _x, 0);
		_x += cubemap.Resolution;
	}
	shader_reset();

	shader_set(__BBMOD_ShPrefilterDiffuse);
	draw_surface(cubemap.SurfaceOctahedron, _x, 0);
	_x += cubemap.Resolution;
	shader_reset();

	surface_reset_target();

	gpu_pop_state();

	var _ibl = new BBMOD_ImageBasedLight(surface_get_texture(probe));
	bbmod_ibl_set(_ibl);
}

with (OPlayer)
{
	bbmod_set_instance_id(id);

	matrix_set(matrix_world, matrixBody);
	animationPlayer.render([matPlayer]);

	if (ammo > 0)
	{
		matrix_set(matrix_world, matrixGun);
		OMain.modGun.render();
	}
}

draw_clear(c_black);
OPlayer.camera.apply();
renderer.render();

if (debugOverlay)
{
	matrix_set(matrix_world, matrix_build_identity());

	with (OZombie)
	{
		collider.DrawDebug();
	}
}
