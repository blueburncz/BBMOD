/// @module Rendering

/// @func BBMOD_DefaultLightmapShader(_shader, _vertexFormat)
///
/// @extends BBMOD_Shader
///
/// @desc Shader used by lightmapped materials.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
///
/// @see BBMOD_Shader
///
/// @deprecated This struct is obsolete. Please use {@link BBMOD_Shader}
/// instead. All properties and methods previously in
/// BBMOD_DefaultLightmapShader are now available directly in BBMOD_Shader.
function BBMOD_DefaultLightmapShader(_shader, _vertexFormat): BBMOD_Shader(_shader, _vertexFormat) constructor {}

/// @func bbmod_lightmap_get()
///
/// @desc Retrieves the default lightmap texture used by all lightmapped
/// materials in the current scene.
///
/// @return {Pointer.Texture} The default RGBM encoded lightmap texture.
///
/// @deprecated Please use {@link BBMOD_Scene.Lightmap} instead.
function bbmod_lightmap_get()
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().Lightmap;
}

/// @func bbmod_lightmap_set(_texture)
///
/// @desc Changes the default lightmap texture used by all lightmapped
/// materials in the current scene.
///
/// @param {Pointer.Texture} _texture The new default RGBM encoded lightmap
/// texture.
///
/// @deprecated Please use {@link BBMOD_Scene.Lightmap} instead.
function bbmod_lightmap_set(_texture)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().Lightmap = _texture;
}
