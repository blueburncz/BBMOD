# Changelog 3.7.1
This release mostly focuses on compatibility issues with Feather and errors in
code and documentation that were discovered thanks to Feather. New style for
documentation comments of functions was also adopted to make them easier to read.

## GML API:
### Core module:
* Fixed methods `MulComponentwise`, `AddComponentwise`, `SubComponentwise` and `ScaleComponentwise` of `BBMOD_Matrix`.

### Camera module:
* Fixed crash that would occur if mouselook was enabled in browsers that do not support it (HTML5 exports).

### Gizmo module:
* Fixed gizmo model for moving objects, which was rotated wrongly after release 3.6.1.
