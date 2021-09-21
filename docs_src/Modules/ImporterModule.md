# Importer module
This module defines an abstract interface for models importers, as well as
importers of specific file formats. Using these you can load models without
converting them to BBMOD first. This is especially handy during development, as
it allows for faster iterations, but for production you should aim to use BBMOD
files, because they are faster to load an they take less disk space compared to
plaintext file formats like OBJ.

## Requirements
Requires [Mesh builder module](./MeshBuilderModule.html).

## Scripting API
### Structs
* [BBMOD_Importer](./BBMOD_Importer.html)
* [BBMOD_OBJImporter](./BBMOD_OBJImporter.html)
