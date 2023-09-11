function MatZombie()
{
	static _shader = undefined;
	static _shaderDepth = undefined;
	static _material = undefined;
	if (_material == undefined)
	{
		var _deferred = bbmod_deferred_renderer_is_supported();
		_shader = new BBMOD_DefaultShader(_deferred ? ShZombieGBuffer : ShZombie, BBMOD_VFORMAT_DEFAULT_ANIMATED);
		_shaderDepth = new BBMOD_BaseShader(ShZombieDepth, BBMOD_VFORMAT_DEFAULT_ANIMATED);
		_material = BBMOD_MATERIAL_DEFERRED.clone()
			.set_shader(BBMOD_ERenderPass.Id, BBMOD_SHADER_INSTANCE_ID) // Enable instance selecting
			.set_shader(BBMOD_ERenderPass.Shadows, _shaderDepth); // Enable casting shadows
		if (_deferred)
		{
			_material.set_shader(BBMOD_ERenderPass.GBuffer, _shader);
		}
		else
		{
			_material.set_shader(BBMOD_ERenderPass.Forward, _shader)
				.set_shader(BBMOD_ERenderPass.DepthOnly, _shaderDepth);
		}
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
