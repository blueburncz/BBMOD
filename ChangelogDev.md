# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Fixed punctual lights not working in the default shaders.
* Fixed light bloom threshold shader modifying the original color.
* Fixed crash in method `BBMOD_MeshRenderQueue.submit` for command `BBMOD_ERenderCommand.DrawMesh`.
* Added new function `bbmod_matrix_get_identity()`, which retrieves the identity matrix.
* Added new function `bbmod_matrix_set_identity(_matrix)`, which turns given matrix into an identity matrix.
* Added new function `bbmod_matrix_set_translation(_matrix, _x, _y, _z)`, which writes translation into given matrix.
* Added new function `bbmod_matrix_set_rotation_x(_matrix, _angle)`, which writes rotation around the X axis into an identity matrix.
* Added new function `bbmod_matrix_set_rotation_y(_matrix, _angle)`, which writes rotation around the Y axis into an identity matrix.
* Added new function `bbmod_matrix_set_rotation_z(_matrix, _angle)`, which writes rotation around the Z axis into an identity matrix.
* Added new function `bbmod_matrix_set_scale(_matrix, _x, _y, _z)`, which writes scale into an identity matrix.
* Fixed infinite loop in method `Transpose` of struct `BBMOD_Matrix`.
* Added new method `SetIdentity()` to struct `BBMOD_Matrix`, which turns the matrix into an identity matrix.
* Added new method `clear_draw_cache()` to struct `BBMOD_Model`, which clears cached data that speeds up rendering of the model. This should be used when properties like `BBMOD_Node.Visible` change!
* Added new method `Equals(_q)` to struct `BBMOD_Quaternion`, which checks whether two quaternions are equal.
* Added new method `Equals(_dq)` to struct `BBMOD_DualQuaternion`, which checks whether two dual quaternions are equal.
