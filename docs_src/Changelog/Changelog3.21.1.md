# Changelog 3.21.1
This release is a hotfix for an issue where renderers did not display the application surface if they did not use a post-processor.

* Fixed method `present` of `BBMOD_BaseRenderer`, `BBMOD_DefaultRenderer` and `BBMOD_DeferredRenderer`, which did not draw the application surface if post-processor was not defined or was disabled.
* Fixed wrong comparisons with the epsilon value, which caused getting `NaN` in various places (e.g. `BBMOD_Vec3.Normalize`). Thanks to [@xgreffe](https://github.com/xgreffe) for the pull request!
* Fixed error that occured when `BBMOD_Material.from_json` was given a JSON that included string "undefined" as a value for a shader (which is a valid option).
