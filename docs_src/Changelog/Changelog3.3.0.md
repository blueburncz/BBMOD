# Changelog 3.3.0
This release mainly adds two new modules - *2D*, with which you can use BBMOD
materials on regular GameMaker sprites, and *Raycasting*, using which you can cast
rays against the most basic 3D shapes.

## GML API:
### 2D module:
* Added new module - 2D - using which you can use BBMOD materials on regular GameMaker sprites.
* Added new struct `BBMOD_DefaultSpriteShader`, which is a variant of the default shader, usable with sprites.
* Added new macro `BBMOD_VFORMAT_SPRITE`, which is the vertex format of GameMaker sprites.
* Added new macro `BBMOD_SHADER_SPRITE`, which is an instance of `BBMOD_DefaultSpriteShader`.
* Added new macro `BBMOD_MATERIAL_SPRITE`, which is a variant of the default material, usable with sprites. You can `clone()` this to make your own sprite materials.

### Raycasting module:
* Added new module - Raycasting - which contains raycasting of basic shapes.
* Added new struct `BBMOD_Collider`, which is a base struct for colliders.
* Added new struct `BBMOD_AABBCollider`, which is an axis-aligned bounding box collider.
* Added new struct `BBMOD_PlaneCollider`, which is a plane collider.
* Added new struct `BBMOD_SphereCollider`, which is a sphere collider.
* Added new struct `BBMOD_Ray`, using which you can cast rays against colliders.
* Added new struct `BBMOD_RaycastResult`, which is a container for additional raycast hit data.
