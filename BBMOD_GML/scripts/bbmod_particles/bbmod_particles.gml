#macro BBMOD_VFORMAT_PARTICLE __bbmod_vformat_particle()

#macro BBMOD_VFORMAT_PARTICLE_BATCHED __bbmod_vformat_particle_batched()

#macro BBMOD_SHADER_PARTICLE __bbmod_shader_particle()

#macro BBMOD_MATERIAL_PARTICLE __bbmod_material_particle()

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

function __bbmod_shader_particle()
{
	static _shader = new BBMOD_DefaultShader(BBMOD_ShParticles, BBMOD_VFORMAT_PARTICLE_BATCHED);
	return _shader;
}

function __bbmod_material_particle()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_DefaultMaterial(BBMOD_SHADER_PARTICLE)
		_material.BaseOpacity = sprite_get_texture(SprParticle, 0);
		_material.NormalSmoothness = sprite_get_texture(SprParticle, 1);
		_material.AlphaTest = 0.01;
		_material.AlphaBlend = true;
		_material.ZWrite = false;
		_material.Culling = cull_noculling;
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
		vertex_position_3d(_vbuffer, -0.5, -0.5, 0.0);
		vertex_texcoord(_vbuffer, 0.0, 0.0);
		vertex_position_3d(_vbuffer, +0.5, +0.5, 0.0);
		vertex_texcoord(_vbuffer, 1.0, 1.0);
		vertex_position_3d(_vbuffer, -0.5, +0.5, 0.0);
		vertex_texcoord(_vbuffer, 0.0, 1.0);
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
		_model.Materials = [BBMOD_MATERIAL_PARTICLE];
	}
	return _model;
}
