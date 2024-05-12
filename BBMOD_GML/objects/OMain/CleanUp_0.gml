renderer = renderer.destroy();
gizmo = gizmo.destroy();
postProcessor = postProcessor.destroy();

batchSphere = batchSphere.destroy();

matSphere = matSphere.destroy();

sprite_delete(sprIBL);
sprite_delete(sprSky);

matSky = matSky.destroy();

bbmod_ibl_set(undefined);
bbmod_light_directional_set(undefined);
bbmod_reflection_probe_clear();

terrain = terrain.destroy();
terrainMaterial = terrainMaterial.destroy();

BBMOD_RESOURCE_MANAGER.clear();
