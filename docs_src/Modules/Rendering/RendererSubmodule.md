# Renderer submodule
When working on a 3D game in GameMaker, it is common to replace its default
rendering pipeline by:

  1. Setting the `visible` property of game objects to `false`,
  2. Creating a "renderer" object which draws the game objects itself.

This way it is easier to manage draw calls, texture swaps and shader uniform
changes, as well as to tackle alpha blending issues etc.

In combination with material's [Priority](./BBMOD_BaseMaterial.Priority.html)
property and [render queues](./BBMOD_RenderCommand.html), this module
provides a much more sophisticated way to create such rendering pipelines.

## Scripting API
### Enums
* [BBMOD_EAntialiasing](./BBMOD_EAntialiasing.html)

### Structs
* [BBMOD_Renderer](./BBMOD_Renderer.html)
