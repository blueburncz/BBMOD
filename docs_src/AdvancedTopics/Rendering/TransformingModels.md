# Transforming models
In the [Rendering models](./QuickstartRenderingModels.html) section of the
[Quickstart guide](./QuickstartGuide.html) you have learnt how to draw models on
screen, but we have not explained you have you can control its position, scale
and orientation in space.

When a mesh is rendered, each of its vertices goes through a series of matrix
multiplications before it finally gets on the screen. These matrices are knows
as the *world*, *view* and *projection* matrices. While the view and the
projection matrix control where is the camera, which direction is it looking and
how is the 3D scene projected onto the screen (i.e. orthographic or perspective
projection), the world matrix is the one that moves, rotates and scales the
models.

# The world matrix
GML comes with a few built-in functions using which you can control mentioned
matrices and you can find them in the [official manual](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Maths_And_Numbers/Matrix_Functions/Matrix_Functions.htm?rhsearch=matrix&rhhlterm=matrix).
As you may have noticed, we are using them in the
[Rendering models](./QuickstartRenderingModels.html) section too:

```gml
matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, direction, 1, 1, 1));
modSword.submit();
```

The code above creates a new matrix using `matrix_build`, which leaves the scale
of the model at 1, rotates the model around the Z axis and moves it to position
`[x, y, z]`. The created matrix is then set as the current world matrix using
`matrix_set(matrix_world, ...)` and then the model is rendered using the method
[submit](./BBMOD_Model.submit.html). This is the general idea behind transforming
models.

At some point you should also "reset" the world matrix to an identity matrix.
Simply put, an identity matrix is a matrix that does not change a matrix/vector
that it is multiplied with - the result of the multiplication is the same
matrix/vector. After you call the following line of code, the things drawn will
have their original position, rotation and scale:

```gml
matrix_set(matrix_world, matrix_build_identity());
```

# Matrix utilities
The example code above is pretty straight forward, but sometimes you may need to
do more complicated transformations that require multiple matrix multiplications.
In that case `matrix_build` and `matrix_multiply` can feel a little clunky. For
that reason BBMOD comes with a struct [BBMOD_Matrix](./BBMOD_Matrix.html), which
simplifies chained transformations into method calls. Here is how would you
rewrite the code above using `BBMOD_Matrix`:

```gml
new BBMOD_Matrix()
    .RotateZ(direction)
    .Translate(x, y, z)
    .ApplyWorld();
```

The code became much more self-explanatory, without having to learn in which
specific order is translation, rotation and scale executed when you use
`matrix_build`. Not to mention that you do not need to fill in all 9 arguments
even in case you just wanted to move a model on one axis. For the full list of
`BBMOD_Matrix` methods, please see its [documentation](./BBMOD_Matrix.html).
