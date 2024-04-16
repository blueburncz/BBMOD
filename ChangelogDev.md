# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Fixed method `present` of renderers.
* Fixed wrong comparisons with the epsilon value, which caused getting `NaN` in various places (e.g. `BBMOD_Vec3.Normalize`).
* Fixed error in `BBMOD_Material.from_json` when given JSON included string "undefined".
