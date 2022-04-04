# Using a camera
In [Transforming models](./TransformingModels.html) you have learnt that each
vertex of a model is first multiplied with the `world * view * projection` matrix
before it is drawn on the screen, that the world matrix controls model position,
scale and orientation in space and that the view and projection matrices are
related to *cameras*.

Same as with the world matrix, view and projection matrices can be accessed
and changed using the [built-in GML functions](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Maths_And_Numbers/Matrix_Functions/Matrix_Functions.htm?rhsearch=matrix&rhhlterm=matrix).
Aside from these, GameMaker Studio 2 also introduced a new camera system, which
is also described in the [official manual](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Cameras_And_Display/Cameras_And_Viewports/Cameras_And_View_Ports.htm?rhsearch=camera&rhhlterm=camera).

BBMOD comes with its own [camera](./BBMOD_Camera.html) struct, which abstracts
these built-in functions even further, allowing you to create typical
first-person and third-person cameras with mouselook much faster:

```gml
/// @desc Create event
camera = new BBMOD_Camera();
camera.AspectRatio = window_get_width() / window_get_height();
camera.Fov = 60.0;
camera.FollowObject = OPlayer;
camera.Zoom = 5.0; // 0.0 would be first-person camera

/// @desc Step event
if (mouse_check_button_pressed(mb_any))
{
    // Enable mouselook and hide cursor
    camera.set_mouselook(true);
    window_set_cursor(cr_none);
}
else if (keyboard_check_pressed(vk_escape))
{
    // Disable mouselook and show cursor
    camera.set_mouselook(false);
    window_set_cursor(cr_default);
}

camera.update(delta_time);

/// @desc Draw event
// This needs to be called before any model is drawn, otherwise they wont be
// drawn from the camera's perspective.
camera.apply();
```

A typical RTS-style orthographic camera can be created like so:

```gml
/// @desc Create event
camera = new BBMOD_Camera();
camera.AspectRatio = window_get_width() / window_get_height();
camera.Orthographic = true;
camera.Width = 300.0; // Height is computed using the aspect ratio
camera.Direction = 45.0;
camera.DirectionUp = -45.0;
camera.ZFar *= 0.5;
camera.ZNear = -camera.ZFar;

/// @desc Step event
camera.update(delta_time);

/// @desc Draw event
// This needs to be called before any model is drawn, otherwise they wont be
// drawn from the camera's perspective.
camera.apply();
```

For more info about the individual camera properties, please see its
[documentation](./BBMOD_Camera.html).
