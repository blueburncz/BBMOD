# Changelog 3.1.4

## GML API:
### Core module:
* Added new property `Enabled` to `BBMOD_Light` using which you can enable/disable lights without having to call appropriate set/add/remove functions.
* Fixed `BBMOD_Animation.create_transition` which did not round transition duration, causing errors in animation playback.
* Added new member `BBMOD_ERenderPass.Id`.
