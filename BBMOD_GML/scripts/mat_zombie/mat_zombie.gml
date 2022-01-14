function mat_zombie()
{
	static _shader = undefined;
	static _material = undefined;
	if (_material == undefined)
	{
		_shader = new BBMOD_DefaultShader(ShZombie, BBMOD_VFORMAT_DEFAULT_ANIMATED);
		_material = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone()
			.set_shader(BBMOD_ERenderPass.Forward, _shader)
			.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH_ANIMATED); // Enable casting shadows
	}
	return _material;
}