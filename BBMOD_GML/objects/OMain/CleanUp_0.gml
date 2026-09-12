renderer = renderer.destroy();
postProcessor = postProcessor.destroy();
show_debug_overlay(false);

bbmod_dither_set_enabled(false);
bbmod_dither_set_value(1.0);

batchSphere = batchSphere.destroy();

matSphere = matSphere.destroy();
matSphereMetallic = matSphereMetallic.destroy();
matSphereEmissive = matSphereEmissive.destroy();

sprite_delete(sprIBL);
sprite_delete(sprSky);

matSky = matSky.destroy();

bbmod_ibl_set(undefined);
bbmod_light_directional_set(undefined);
bbmod_light_punctual_clear();
bbmod_reflection_probe_clear();
bbmod_particle_emitter_clear();

terrain = terrain.destroy();
terrainMaterial = terrainMaterial.destroy();

if (particleModuleShowcaseSystems != undefined)
{
	var i = 0;
	repeat(array_length(particleModuleShowcaseEmitters))
	{
		particleModuleShowcaseEmitters[i] = particleModuleShowcaseEmitters[i].destroy();
		++i;
	}

	i = 0;
	repeat(array_length(particleModuleShowcaseSystems))
	{
		particleModuleShowcaseSystems[i] = particleModuleShowcaseSystems[i].destroy();
		++i;
	}
}

characterPlayer = undefined;
characterDesiredAnimation = undefined;

batchSphereInstances = undefined;
punctualLightsTest = undefined;
spotLightTest = undefined;
particleModuleShowcaseEmitters = undefined;
particleModuleShowcaseSystems = undefined;
particleModuleShowcaseNames = undefined;

BBMOD_RESOURCE_MANAGER.clear();
