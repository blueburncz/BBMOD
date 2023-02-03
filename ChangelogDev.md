# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Added option `--apply-scale` (or `-as`), which applies global scaling factor defined in the model file if enabled. For backwards compatibility this is by default disabled.
* Added option `--pre-transform` (or `-as`), which pre-transforms the models and collapses all nodes into one if possible. For backwards compatibility this is by default disabled.
* Reconfigured Assimp to do less post-processing on the models by default, as the old settings caused issues with some models.
