/// @module Rendering

/// @func BBMOD_DefaultLightmapMaterial([_shader])
///
/// @extends BBMOD_Material
///
/// @desc A material that can be used when rendering lightmapped models with
/// two UV channels.
///
/// @param {Struct.BBMOD_Shader} [_shader] A shader that the material
/// uses in the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you
/// would like to use {@link BBMOD_Material.set_shader} to specify shaders
/// used in specific render passes.
///
/// @see BBMOD_Material
/// @see BBMOD_Shader
///
/// @deprecated This struct is obsolete. Please use {@link BBMOD_Material}
/// instead. All properties and methods previously in
/// BBMOD_DefaultLightmapMaterial are now available directly in BBMOD_Material.
function BBMOD_DefaultLightmapMaterial(_shader = undefined): BBMOD_Material(_shader) constructor {}
