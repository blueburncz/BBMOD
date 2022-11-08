# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

## Core module:
* Added new function `bbmod_matrix_build_normalmatrix`, which creates a matrix using which you can safely transform normal vectors in shaders.
* Struct `BBMOD_StaticBatch` is now deprecated. We recommend using a `BBMOD_DynamicBatch` instead.
* Added new property `ShadowmapResolution` to `BBMOD_Light`, which is the shadowmap resolution.
* Added new property `ShadowmapArea` to `BBMOD_DirectionalLight`, which is the area captured by the shadowmap.

## Gizmo module:
* Added new property `EnableGridSnap` to `BBMOD_Gizmo`, which enables snapping to grid when moving objects.
* Added new property `GridSize` to `BBMOD_Gizmo`, which is the size of the grid.
* Added new property `EnableAngleSnap` to `BBMOD_Gizmo`, which enables angle snapping when rotating objects.
* Added new property `AngleSnap` to `BBMOD_Gizmo`, which is the angle snapping size.
* Added new property `KeyCancel` to `BBMOD_Gizmo`, which is the virtual key used to cancel editing and revert changes. Default is `vk_escape`.
* Added new property `KeyIgnoreSnap` to `BBMOD_Gizmo`, which is the virtual key used to ignore grid and angle snapping when they are enabled. Default is `vk_alt`.
* Added new method `GetInstanceGlobalMatrix` to `BBMOD_Gizmo`, which is a function that the gizmo uses to retrieve an instance's global matrix. Normally this is an identity matrix. If the instance is attached to another instance for example, then this will be that instance's transformation matrix.
* Fixed the gizmo to work independently on from which direction is the camera looking at it and whether it's moving or not.

## Rendering module:
### Renderer module:
* Property `ShadowmapResolution` of `BBMOD_Renderer` is now obsolete. Please use `BBMOD_Light.ShadowmapResolution` instead.
* Property `ShadowmapArea` of `BBMOD_Renderer` is now obsolete. Please use `BBMOD_DirectionalLight.ShadowmapArea` instead.

### Sky submodule:
* Fixed shader `BBMOD_ShSky` ignoring matrix rotation.

## Terrain module:
* Fixed terrain normals when using non-uniform scaling.
