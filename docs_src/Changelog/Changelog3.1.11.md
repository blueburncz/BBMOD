# Changelog 3.1.11
This tiny release mainly adds support for orthographic camera projection, as requested by one of our Patrons.

## GML API:
### Core module:
* Added new methods `ApplyWorld`, `ApplyView` and `ApplyProjection` to `BBMOD_Matrix`, using which you can set it as the current world/view/projection matrix respectively.

### Camera module:
* Added new property `BBMOD_Camera.Orthographic`, using which you can enable orthographic projection.
* Added new property `BBMOD_Camera.Width`, using which you can configure the width of orthographic projection. Height is computed from `BBMOD_Camera.AspectRation`.
