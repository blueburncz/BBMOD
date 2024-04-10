modTree = modTree.destroy();
if (treeBatch != undefined)
{
	treeBatch = treeBatch.destroy();
}
batchShell = batchShell.destroy();
renderer = renderer.destroy();
postProcessor = postProcessor.destroy();
bbmod_reflection_probe_clear();
