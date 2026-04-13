# Changelog dev

> This file is used to accumulate changes before a changelog for a release is created.

## Asset pipeline

* Updated Assimp to [v6.0.2](https://github.com/assimp/assimp/releases/tag/v6.0.2).
* Added new option `-lf|--log-file=true|false` to BBMOD CLI, using which you can enable/disable creating a `_log.txt` file for converted models. Defaults to `true` (log file is enabled).

## Resource management

* Added new method `remove(_resourceOrPath)` to `BBMOD_ResourceManager`, which removes a resource from the manager, keeping its reference count.
* Added new method `load_sync(_path[, _sha1])`, which synchronously loads a resource from a file or retrieves a reference to it, if it is already loaded.
* Added new method `load_async(_path[, _sha1[, _onLoad]])`, which asynchronously loads a resource from a file or retrieves a reference to it, if it is already loaded.
* Method `load` of `BBMOD_ResourceManager` is now **deprecated**! Please use method `BBMOD_ResourceManager.load_async` instead.

## Rendering

* Fixed rendering of gizmo on the screen when there are instances selected.
* Fixed SSAO sampling kernel not scaling with depth. You will need to increase `SSAORadius` to get the same look as before!
* Added Toksvig specular antialiasing.
* Added Karis average to reduce fireflies in post-processing effect `BBMOD_LightBloomEffect`.
* Constructor of `BBMOD_LightBloomEffect` now takes brightness threshold and soft knee values instead of RGB bias and scale vectors!
* Member `Bias` of struct `BBMOD_LightBloomEffect` was changed to `Threshold`, which is the brightness threshold for bloom.
* Member `Scale` of struct `BBMOD_LightBloomEffect` was changed to `Knee`, which is the soft knee width for smooth threshold transition.

## Particles

* Fixed particle MixFromSpeed modules calculating velocity magnitude incorrectly (Y velocity was being added instead of multiplied).
* Fixed potential division by zero in `BBMOD_AddRealOverTimeModule`, `BBMOD_AddVec2OverTimeModule`, `BBMOD_AddVec3OverTimeModule`, and `BBMOD_AddVec4OverTimeModule` when `Period` is zero.
* Fixed potential division by zero in MixFromSpeed modules when `Min` equals `Max`.
* Fixed potential division by zero in `BBMOD_AttractorModule` when particle is exactly at attractor position.

## Math

* Added new function `bbmod_matrix_transpose(_matrix[, _dest])` to compute the transpose of a matrix (swaps rows and columns).
* Using GameMaker's new function `matrix_inverse` in method `InverseSelf` of struct `BBMOD_Matrix` for better performance.
* Added new method `ToEuler` to `BBMOD_Quaternion`, which retrieves euler angles from the quaternion.
* Added new function `bbmod_matrix_transpose(_matrix[, _dest])` to compute the transpose of a matrix (swaps rows and columns).
* Fixed `BBMOD_Quaternion.Exp` and `ExpSelf` missing exponential factor on vector components.
* Fixed `BBMOD_Quaternion.Slerp` and `SlerpSelf` incorrectly multiplying by length instead of dividing during normalization.
* Fixed `BBMOD_DualQuaternion.Clone` creating shallow copy instead of deep copy.
* Fixed `BBMOD_DualQuaternion.Copy` creating shallow copy instead of properly copying quaternion components.
* Fixed `BBMOD_DualQuaternion.Normalize` and `NormalizeSelf` dividing by magnitude squared instead of magnitude.
* Fixed `BBMOD_Vec2.ClampLengthSelf` and `BBMOD_Vec4.ClampLengthSelf` returning new vector instead of modifying self when vector length is near zero.
* Fixed `BBMOD_Matrix.FromColumns` and `FromRows` having swapped implementations due to GameMaker's column-major matrix format.
* Fixed missing semicolons in `BBMOD_Quaternion.ToMatrix` and after `gml_pragma("forceinline")` statements.
* Fixed trailing commas in `BBMOD_Vec2.MinComponent`, `BBMOD_Vec3.MinComponent`, and `BBMOD_Vec4.MinComponent`.
* Fixed potential `arccos` domain errors in quaternion methods.
* Fixed potential division by zero in multiple quaternion, dual quaternion, and matrix methods.
* Optimized `BBMOD_Camera.update_matrices` to reduce vector rotation operations from 9 to 5.
* Optimized `BBMOD_Gizmo.update` by using `ToMatrix()` and `bbmod_matrix_transpose()`.
* Optimized quaternion, vector, matrix, and dual quaternion methods by inlining scalar math and reducing temporary allocations.

## Miscellaneous

* Added new method `get_node_array()` to `BBMOD_Model`, which returns an array of all nodes of the model.
* Methods `get_material` and `set_material` of struct `BBMOD_Model` can now also accept the material index instead of the name of the slot.

* Added new module *D3D11* and extension `BBMOD_D3D11`. Use function `bbmod_d3d11_init()` to initialize the extension. This is for **Windows only!**
* Added new module *VTF* for vertex texture fetching techniques. Moved functions `bbmod_vtf_is_supported` and `bbmod_texture_set_stage_vs` from *Core* into it.

## ColMesh

* Fixed function `bbmod_model_to_colmesh` ignoring node transforms when adding individual meshes to a ColMesh.
