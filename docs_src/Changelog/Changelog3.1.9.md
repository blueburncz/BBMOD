# Changelog 3.1.9
This release fixes how optional arguments were handled in the library, which caused unexpected errors on YYC targets. Issues with post-processing effects when "Generate mipmaps for separate texture pages" is enabled in `Game Options` > `Main` (which allows you to use anisotropic filtering in HTML5) were also fixed.

## GML API:
### Rendering module:
#### Renderer submodule:
* `BBMOD_Renderer` now checks if `application_surface` exists before using it (when `UseAppSurface` is enabled).
