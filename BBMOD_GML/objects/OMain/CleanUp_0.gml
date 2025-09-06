renderer = renderer.destroy();
gizmo = gizmo.destroy();
postProcessor = postProcessor.destroy();

batchSphere = batchSphere.destroy();

// Resets all environment settings (lights, fog, reflection probes, ...)
bbmod_environment_get_current().clear();

// Destroys all resources that aren't persistent
BBMOD_RESOURCE_MANAGER.clear();
