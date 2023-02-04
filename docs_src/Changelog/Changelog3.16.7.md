# Changelog 3.16.7
This release reconfigures Assimp and adds new options to BBMOD CLI and DLL to give you more control over model conversion.

* Reconfigured Assimp to do less post-processing on models by default, as the old settings could sometime cause issues and make the model unusable.
* Added new option `--apply-scale` (or `-as`) to BBMOD CLI, which applies global scaling factor defined in the model file if enabled. For backwards compatibility this is by default disabled.
* Added new option `--pre-transform` (or `-pt`) to BBMOD CLI, which pre-transforms the models and collapses all nodes into one if possible. For backwards compatibility this is by default disabled.
* Added new method `get_apply_scale` to `BBMOD_DLL`, which checks whether the new "apply scale" option is enabled.
* Added new method `set_apply_scale` to `BBMOD_DLL`, which enables/disables the new "apply scale" option.
* Added new method `get_pre_transform` to `BBMOD_DLL`, which checks whether the new "pre-transform" option is enabled.
* Added new method `set_pre_transform` to `BBMOD_DLL`, which enables/disables the new "pre-transform" option.
