function mat_zombie()
{
	static _shader = undefined;
	static _shaderDepth = undefined;
	static _material = undefined;
	if (_material == undefined)
	{
		_shader = new BBMOD_DefaultShader(ShZombie, BBMOD_VFORMAT_DEFAULT_ANIMATED);
		_shaderDepth = new BBMOD_BaseShader(ShZombieDepth, BBMOD_VFORMAT_DEFAULT_ANIMATED);
		_material = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone()
			.set_shader(BBMOD_ERenderPass.Forward, _shader)
			.set_shader(BBMOD_ERenderPass.Shadows, _shaderDepth); // Enable casting shadows
	}
	return _material;
}