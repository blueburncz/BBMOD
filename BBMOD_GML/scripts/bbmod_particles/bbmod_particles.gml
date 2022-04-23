#macro BBMOD_VFORMAT_PARTICLE __bbmod_vformat_particle()

#macro BBMOD_VFORMAT_PARTICLE_BATCHED __bbmod_vformat_particle_batched()

#macro BBMOD_SHADER_PARTICLE_LIT __bbmod_shader_particle_lit()

#macro BBMOD_SHADER_PARTICLE_UNLIT __bbmod_shader_particle_unlit()

#macro BBMOD_SHADER_PARTICLE_DEPTH __bbmod_shader_particle_depth()

#macro BBMOD_MATERIAL_PARTICLE_LIT __bbmod_material_particle_lit()

#macro BBMOD_MATERIAL_PARTICLE_UNLIT __bbmod_material_particle_unlit()

/// @var {Struct.BBMOD_Model} A particle model.
#macro BBMOD_MODEL_PARTICLE __bbmod_model_particle()

function __bbmod_vformat_particle()
{
	static _vformat = new BBMOD_VertexFormat(true, false, true, false, false, false, false);
	return _vformat;
}

function __bbmod_vformat_particle_batched()
{
	static _vformat = new BBMOD_VertexFormat(true, false, true, false, false, false, true);
	return _vformat;
}

function __bbmod_shader_particle_lit()
{
	static _shader = new BBMOD_DefaultShader(BBMOD_ShParticleLit, BBMOD_VFORMAT_PARTICLE_BATCHED);
	return _shader;
}

function __bbmod_shader_particle_unlit()
{
	static _shader = new BBMOD_DefaultShader(BBMOD_ShParticleUnlit, BBMOD_VFORMAT_PARTICLE_BATCHED);
	return _shader;
}

function __bbmod_shader_particle_depth()
{
	static _shader = new BBMOD_DefaultShader(BBMOD_ShParticleDepth, BBMOD_VFORMAT_PARTICLE_BATCHED);
	return _shader;
}

function __bbmod_material_particle_lit()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_DefaultMaterial(BBMOD_SHADER_PARTICLE_LIT)
		_material.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_PARTICLE_DEPTH);
		_material.BaseOpacity = sprite_get_texture(BBMOD_SprParticle, 0);
		_material.AlphaTest = 0.01;
		_material.AlphaBlend = true;
		_material.ZWrite = false;
		_material.ShadowmapBias = 0.01;
	}
	return _material;
}

function __bbmod_material_particle_unlit()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = BBMOD_MATERIAL_PARTICLE_LIT.clone();
		_material.set_shader(BBMOD_ERenderPass.Forward, BBMOD_SHADER_PARTICLE_UNLIT);
		_material.remove_shader(BBMOD_ERenderPass.Shadows);
	}
	return _material;
}

function __bbmod_model_particle()
{
	static _model = undefined;
	if (_model == undefined)
	{
		var _mesh = new BBMOD_Mesh(BBMOD_VFORMAT_PARTICLE);
		var _model = new BBMOD_Model();
		var _node = new BBMOD_Node(_model);

		var _vbuffer = vertex_create_buffer();
		vertex_begin(_vbuffer, BBMOD_VFORMAT_PARTICLE.Raw);
		// 1
		// |\
		// 3-2
		vertex_position_3d(_vbuffer, -0.5, -0.5, 0.0);
		vertex_texcoord(_vbuffer, 0.0, 0.0);
		vertex_position_3d(_vbuffer, +0.5, +0.5, 0.0);
		vertex_texcoord(_vbuffer, 1.0, 1.0);
		vertex_position_3d(_vbuffer, -0.5, +0.5, 0.0);
		vertex_texcoord(_vbuffer, 0.0, 1.0);
		// 1-2
		//  \|
		//   3
		vertex_position_3d(_vbuffer, -0.5, -0.5, 0.0);
		vertex_texcoord(_vbuffer, 0.0, 0.0);
		vertex_position_3d(_vbuffer, +0.5, -0.5, 0.0);
		vertex_texcoord(_vbuffer, 1.0, 0.0);
		vertex_position_3d(_vbuffer, +0.5, +0.5, 0.0);
		vertex_texcoord(_vbuffer, 1.0, 1.0);
		vertex_end(_vbuffer);
		_mesh.VertexBuffer = _vbuffer;

		_node.Name = "Root";
		_node.Meshes = [0];
		_node.IsRenderable = true;

		_model.VertexFormat = BBMOD_VFORMAT_PARTICLE;
		_model.Meshes = [_mesh];
		_model.NodeCount = 1;
		_model.RootNode = _node;
		_model.MaterialCount = 1;
		_model.MaterialNames = ["Material"];
		_model.Materials = [BBMOD_MATERIAL_PARTICLE_LIT];
	}
	return _model;
}
