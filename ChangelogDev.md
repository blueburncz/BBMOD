# Changelog dev

> This file is used to accumulate changes before a changelog for a release is created.

## 3.23.1

### Post-processing

* Fixed `BBMOD_LightBloomEffect` uniforms not resolving correctly at runtime due to mismatched uniform names between shaders and GML code.
* Fixed `BBMOD_DepthOfFieldEffect` producing incorrect near-field blur due to wrong CoC downsample sampling offsets and incorrect texel sizes passed to each downsample pass.
