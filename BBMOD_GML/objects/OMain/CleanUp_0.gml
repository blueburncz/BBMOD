renderer = renderer.destroy();
gizmo = gizmo.destroy();
postProcessor = postProcessor.destroy();
show_debug_overlay(false);

bbmod_dither_set_enabled(false);
bbmod_dither_set_value(1.0);

batchSphere = batchSphere.destroy();

matSphere = matSphere.destroy();
matSphereMetallic = matSphereMetallic.destroy();
matSphereEmissive = matSphereEmissive.destroy();

scene = scene.destroy();

sprite_delete(sprIBL);
sprite_delete(sprSky);

matSky = matSky.destroy();

terrain = undefined;
terrainMaterial = terrainMaterial.destroy();

if (particleModuleShowcaseSystems != undefined)
{
	var i = 0;
	repeat(array_length(particleModuleShowcaseSystems))
	{
		particleModuleShowcaseSystems[i] = particleModuleShowcaseSystems[i].destroy();
		++i;
	}
}

characterPlayer = undefined;
characterDesiredAnimation = undefined;
character = undefined;

batchSphereInstances = undefined;
punctualLightsTest = undefined;
spotLightTest = undefined;
staticPointLightTest = undefined;
staticSpotLightTest = undefined;
particleModuleShowcaseEmitters = undefined;
particleModuleShowcaseSystems = undefined;
particleModuleShowcaseNames = undefined;

BBMOD_RESOURCE_MANAGER.clear();
