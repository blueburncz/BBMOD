/// @func BBMOD_ParticleMaterial([_shader])
/// @extends BBMOD_DefaultMaterial
/// @desc A material that can be used for rendering particles.
/// @param {Struct.BBMOD_Shader/Undefined} [_shader]  A shader that the
/// material uses in the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined`
/// if you would like to use {@link BBMOD_Material.set_shader} to specify shaders
/// used in specific render passes.
/// @see BBMOD_ParticleShader
function BBMOD_ParticleMaterial(_shader=undefined)
	: BBMOD_DefaultMaterial(_shader) constructor
{
	static Super_DefaultMaterial = {
		copy: copy,
	};

	/// @var {Real}
	SoftDistance = 0.0;

	static copy = function (_dest) {
		method(self, Super_DefaultMaterial.copy)(_dest);
		_dest.SoftDistance = SoftDistance;
		return self;
	};

	static clone = function () {
		var _clone = new BBMOD_ParticleMaterial();
		copy(_clone);
		return _clone;
	};
}
