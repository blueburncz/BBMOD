function MatZombie()
{
	static _shader = undefined;
	static _shaderDepth = undefined;
	static _material = undefined;
	if (_material == undefined)
	{
		_shader = new BBMOD_DefaultShader(ShZombie, BBMOD_VFORMAT_DEFAULT_ANIMATED);
		_shaderDepth = new BBMOD_BaseShader(ShZombieDepth, BBMOD_VFORMAT_DEFAULT_ANIMATED);
		_material = BBMOD_MATERIAL_DEFERRED.clone()
			.set_shader(BBMOD_ERenderPass.GBuffer, _shader)
			//.set_shader(BBMOD_ERenderPass.DepthOnly, _shaderDepth)
			.set_shader(BBMOD_ERenderPass.Id, BBMOD_SHADER_INSTANCE_ID) // Enable instance selecting
			.set_shader(BBMOD_ERenderPass.Shadows, _shaderDepth); // Enable casting shadows
		_material.Culling = cull_noculling;
	}
	return _material;
}

function MatZombieMale()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = MatZombie().clone();
		_material.RenderQueue = new BBMOD_MeshRenderQueue("MaleZombies");
		_material.BaseOpacity = sprite_get_texture(SprZombie, 0);
	}
	return _material;
}

function MatZombieFemale()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = MatZombie().clone();
		_material.RenderQueue = new BBMOD_MeshRenderQueue("FemaleZombies");
		_material.BaseOpacity = sprite_get_texture(SprZombie, 1);
	}
	return _material;
}
