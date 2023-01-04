# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Added new property `Persistent` to `BBMOD_Resource`. If it is `true`, then the resource is persistent and it is not destroyed when method `free` is used. Default value is `false`.
* Added new method `clear` to `BBMOD_ResourceManager`, which destroys all non-persistent resources.
* Added new macro `BBMOD_RESOURCE_MANAGER`, which is the default resource manager.
