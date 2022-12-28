# Changelog 3.16.2
This is a tiny release that fixes `BBMOD_BaseCamera` and model serialization
to buffers.

## Scripting API changes
* Fixed method `update_matrices` of `BBMOD_BaseCamera`.
* Added missing method `ToBuffer` to `BBMOD_Quaternion`.
* Fixed method `to_buffer` of `BBMOD_Model`.
* Fixed method `to_buffer` of `BBMOD_Mesh`.
