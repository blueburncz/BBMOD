renderer = renderer.destroy();
gizmo = gizmo.destroy();
postProcessor = postProcessor.destroy();

batchSphere = batchSphere.destroy();

matSphere = matSphere.destroy();

sprite_delete(sprIBL);
sprite_delete(sprSky);

matSky = matSky.destroy();

terrainMaterial = terrainMaterial.destroy();

scene = scene.destroy();
