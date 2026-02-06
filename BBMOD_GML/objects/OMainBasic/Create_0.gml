event_inherited();

x = 19.55;
y = -4.31;
z = 4.5;
camera.Direction = -134;
camera.DirectionUp = -23.5;

var _baseMaterial = undefined;
if (useDeferredRenderer)
{
	_baseMaterial = BBMOD_MATERIAL_DEFERRED.clone();
}
else
{
	_baseMaterial = BBMOD_MATERIAL_DEFAULT.clone();
	_baseMaterial.set_shader(BBMOD_ERenderPass.DepthOnly, BBMOD_SHADER_DEFAULT_DEPTH);
}
_baseMaterial.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);

matSphere = _baseMaterial.clone();
matSphere.BaseOpacity = sprite_get_texture(BBMOD_SprWhite, 0);
matSphere.BaseOpacityMultiplier = BBMOD_C_SILVER;
matSphere.set_normal_roughness(BBMOD_VEC3_UP, 0.2);
BBMOD_RESOURCE_MANAGER.add("MatSphere", matSphere);

matSphereMetallic = _baseMaterial.clone();
matSphereMetallic.BaseOpacity = sprite_get_texture(BBMOD_SprWhite, 0);
matSphereMetallic.set_metallic_ao(1, 1);
BBMOD_RESOURCE_MANAGER.add("MatSphereMetallic", matSphereMetallic);

matSphereEmissive = _baseMaterial.clone();
matSphereEmissive.BaseOpacity = sprite_get_texture(BBMOD_SprBlack, 0);
matSphereEmissive.set_normal_roughness(BBMOD_VEC3_UP, 1.0);
matSphereEmissive.set_emissive(new BBMOD_Color(255 * 1.1, 127 * 1.1, 0));
BBMOD_RESOURCE_MANAGER.add("MatSphereEmissive", matSphereEmissive);

// Point light next to the lightmapped cube
// TODO: Move to OLightmap
var _scene = bbmod_scene_get_current();

var _light = new BBMOD_PointLight();
_light.Color = BBMOD_C_AQUA;
_light.Position = new BBMOD_Vec3(22, 22, 2.5);
_light.Range = 10;
_scene.add_punctual_light(_light);

var _lensFlare = new BBMOD_LensFlare();
_lensFlare.Range = 20;
_lensFlare.Position = _light.Position;
_lensFlare.add_ghosts(BBMOD_SprLensFlareHeptagon, 0, 8, 0.1, 1.0, 0.25, 0.1, 1.5, BBMOD_C_AQUA.Mix(BBMOD_C_BLACK, 0.8));
bbmod_lens_flare_add(_lensFlare);
