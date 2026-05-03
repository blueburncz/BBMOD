/// @module Particles

/// @func BBMOD_ParticleMaterial([_shader])
///
/// @extends BBMOD_DefaultMaterial
///
/// @desc A material that can be used for rendering particles.
///
/// @param {Struct.BBMOD_Shader} [_shader] A shader that the material uses in
/// the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you would
/// like to use {@link BBMOD_Material.set_shader} to specify shaders used in
/// specific render passes.
///
/// @see BBMOD_ParticleShader
function BBMOD_ParticleMaterial(_shader = undefined): BBMOD_DefaultMaterial(_shader) constructor
{
	static DefaultMaterial_copy = copy;
	static DefaultMaterial_get_hash = get_hash;

	/// @var {Real} Distance over which the particle smoothly disappears when
	/// getting closer to geometry rendered in the depth buffer. Use values less
	/// or equal to 0 to disable the effect. Default value is 0.
	SoftDistance = 0.0;

	static copy = function (_dest)
	{
		DefaultMaterial_copy(_dest);
		_dest.SoftDistance = SoftDistance;
		_dest.HashDirty = true;
		return self;
	};

	static clone = function ()
	{
		var _clone = new BBMOD_ParticleMaterial();
		copy(_clone);
		return _clone;
	};

	static get_hash = function ()
	{
		if (!HashDirty)
		{
			return __hash;
		}

		var _hash = DefaultMaterial_get_hash();
		_hash = bbmod_hash_combine(_hash, SoftDistance);

		__hash = _hash;
		HashDirty = false;

		return __hash;
	};
}
