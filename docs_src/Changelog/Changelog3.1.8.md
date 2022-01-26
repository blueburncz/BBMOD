# Changelog 3.1.8
This is a small hotfix release that patches the camera module, which caused errors on YYC and HTML5 platforms.

## GML API:
### Camera module
* Fixed a bug where Windows YYC (and possibly other YYC targets) did not work if `_positionHandler` argument was not passed to `BBMOD_Camera.update`.
* Fixed method `BBMOD_Camera.get_proj_mat`, which did not work in HTML5.
