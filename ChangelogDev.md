# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Added new method `update_bbox` to `BBMOD_Mesh`.
* Methods `from_buffer` and `to_buffer` of `BBMOD_Mesh` now throw a `BBMOD_Exception` if used when property `Model` is `undefined`. Previously this would cause a crash.
* Fix `ClearColor` of `BBMOD_DeferredRender` resulting into a wrong color because of gamma correction.
* Disabled Assimp option `AI_CONFIG_IMPORT_FBX_PRESERVE_PIVOTS`, which should some problems with converting animated FBX models to BBMOD. **TODO: Codesign macOS libraries and rebuild Windows libraries!**
