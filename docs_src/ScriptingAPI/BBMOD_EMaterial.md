# BBMOD_EMaterial
`enum`
## Description
An enumeration of members of a Material structure.

### Members
| Name | Description |
| ---- | ----------- |
| `RenderPath` | A render path. See macros  	 [BBMOD_RENDER_FORWARD](./BBMOD_RENDER_FORWARD.html) and  	 [BBMOD_RENDER_DEFERRED](./BBMOD_RENDER_DEFFERED.html). |
| `Shader` | A shader that the material uses. |
| `OnApply` | A script that is executed when the shader is applied.  	 Must take the material structure as the first argument. Use  	 `undefined` if you don't want to execute any script. |
| `BlendMode` | A blend mode. |
| `Culling` | A culling mode. |
| `Diffuse` | A diffuse texture. |
| `Normal` | A normal texture. |
| `SIZE` | The size of the Material structure. |