# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Fixed method `BBMOD_Sprite.from_file_async` passing `Asset.GMSprite` instead of `Struct.BBMOD_Sprite` into the callback function.
* Fixed method `BBMOD_ResourceManager.load` crashing when callback function is not provided.
