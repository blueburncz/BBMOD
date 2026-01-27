renderer = renderer.destroy();
gizmo = gizmo.destroy();
postProcessor = postProcessor.destroy();

batchSphere = batchSphere.destroy();

// Resets all scene settings (lights, fog, reflection probes, ...)
bbmod_scene_get_current().clear();

// Destroys all resources that aren't persistent
BBMOD_RESOURCE_MANAGER.clear();
