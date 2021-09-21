# Rendering models
When you have prepared your models and their materials, you can render them using
method [submit](./BBMOD_Model.submit.html). It is very important that every block
of code that submits models starts and ends with the function
[bbmod_material_reset](./bbmod_material_reset.html). Not calling this function
can result into unexpected behavior!

```gml
/// @desc Draw event
bbmod_material_reset();
matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, direction, 1, 1, 1));
modSword.submit();
bbmod_material_reset();
```
