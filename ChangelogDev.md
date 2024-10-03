# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Added new method `update_bbox` to `BBMOD_Mesh`.
* Methods `from_buffer` and `to_buffer` of `BBMOD_Mesh` now throw a `BBMOD_Exception` if used when property `Model` is `undefined`. Previously this would cause a crash.
* Fix `ClearColor` of `BBMOD_DeferredRender` resulting into a wrong color because of gamma correction.
