/// @func BBMOD_DefaultSpriteShader(_shader, _vertexFormat)
/// @extends BBMOD_DefaultShader
/// @desc A variant of {@link BBMOD_DefaultShader} which can be used when
/// rendering GameMaker sprites.
/// @param {Resource.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
/// @see BBMOD_DefaultMaterial
function BBMOD_DefaultSpriteShader(_shader, _vertexFormat)
	: BBMOD_DefaultShader(_shader, _vertexFormat) constructor
{
	static Super_DefaultShader = {
		set_material: set_material,
	};

	UBaseOpacityUV = get_uniform("bbmod_BaseOpacityUV");

	UNormalSmoothnessUV = get_uniform("bbmod_NormalSmoothnessUV");

	USpecularColorUV = get_uniform("bbmod_SpecularColorUV");

	static set_material = function (_material) {
		gml_pragma("forceinline");
		method(self, Super_DefaultShader.set_material)(_material);
		var _texture = _material.BaseOpacity;
		if (_texture != pointer_null)
		{
			set_uniform_f_array(UBaseOpacityUV, texture_get_uvs(_texture));
		}
		_texture = _material.NormalSmoothness;
		if (_texture != pointer_null)
		{
			set_uniform_f_array(UNormalSmoothnessUV, texture_get_uvs(_texture));
		}
		_texture = _material.SpecularColor;
		if (_texture != pointer_null)
		{
			set_uniform_f_array(USpecularColorUV, texture_get_uvs(_texture));
		}
		return self;
	};
}