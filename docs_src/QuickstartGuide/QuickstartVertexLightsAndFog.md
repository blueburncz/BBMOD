# Vertex lights and fog
Since version 3.1.3 materials [BBMOD_MATERIAL_DEFAULT](./BBMOD_MATERIAL_DEFAULT.html),
[BBMOD_MATERIAL_DEFAULT_ANIMATED](./BBMOD_MATERIAL_DEFAULT_ANIMATED.html) and
[BBMOD_MATERIAL_DEFAULT_BATCHED](./BBMOD_MATERIAL_DEFAULT_BATCHED.html) support
per-vertex lights and per-pixel fog, imitating the classic look of GameMaker 3D
games.

## Ambient light
Ambient light represents a light coming in from all directions. When ambient
light is disabled, models that are not lit by any other light source are
completely black. So put another way, ambient light affects the color/brightness
of the darkest spots. In BBMOD ambient light is split into two parts, lighting
coming onto the model from above (+Z) and coming from below (-Z) and the
resulting color for each vertex is computed using its normal vector. To configure
color of the ambient light coming from individual directions, use functions
[bbmod_light_ambient_set_up](./bbmod_light_ambient_set_up.html) and
[bbmod_light_ambient_set_down](./bbmod_light_ambient_set_down.html). You can also
set both to the same color with function [bbmod_light_ambient_set](./bbmod_light_ambient_set.html).
Ambient light is the only light that is by default enabled (set to white color).
If you would like to disable it, simply set its color to black.

## Directional light
Directional light represents a light coming onto the model from a single
direction, as if the light source was infinitely far away. This type of light is
usually used for sunlight. BBMOD supports only one directional light at time. To
enable it, you first need to create a new [BBMOD_DirectionalLight](./BBMOD_DirectionalLight.html)
and then set it as the current one using [bbmod_light_directional_set](./bbmod_light_directional_set.html).

```gml
var _sunLight = new BBMOD_DirectionalLight(
    // The color of the light, you can also use BBMOD_C_* shorthands
    new BBMOD_Color(255, 255, 255),
    // The direction of the light
    new BBMOD_Vec3(-1, -1, -1).Normalize());
bbmod_light_directional_set(_sunLight);
```

The color of the light must be an instance of [BBMOD_Color](./BBMOD_Color.html)!
If you would like to disable the directional light again, simply call
`bbmod_light_directional_set` with `undefined` as the first argument.

## Point lights
Point lights represent lights coming from a single point onto models around it in
a specific radius. The intensity of the lights smoothly drops off with the distance
of the vertex from the point light and it reaches 0 at its radius. By default BBMOD
supports 8 instances of point lights at time. To add a new instance of a point light,
you first need to create a new [BBMOD_PointLight](./BBMOD_PointLight.html) and then
add it using [bbmod_light_point_add](./bbmod_light_point_add.html).

```gml
/// @desc Create event
pointLight = new BBMOD_PointLight(
    // The color of the light
    BBMOD_C_AQUA,
    // The light's position
    new BBMOD_Vec3(x, y, z),
    // The light's radius
    10);
bbmod_light_point_add(pointLight);
```

If you change light's properties (in the Step event for example), you do not need
to re-add it!

```gml
/// @desc Step event
// Use a random light color each step.
// No need to use bbmod_light_point_add again!
pointLight.Color.FromHSV(random(255), 255, 255);
```

If you would like to remove a point light, use function
[bbmod_light_point_remove](./bbmod_light_point_remove.html).

```gml
/// @desc Clean Up event
bbmod_point_light_remove(pointLight);
```

To get number of all added point lights use function
[bbmod_light_point_count](./bbmod_light_point_count.html). To retrieve a light
at specific index you can use [bbmod_light_point_get](./bbmod_light_point_get.html).
You can also remove a light at specific index using
[bbmod_light_point_remove_index](./bbmod_light_point_remove_index.html) or
remove all added lights with [bbmod_light_point_clear](./bbmod_light_point_clear.html).

## Fog
When fog is enabled, all objects at distance start to fade into the color of the
fog. To enable fog use function [bbmod_fog_set](./bbmod_fog_set.html).

```gml
bbmod_fog_set(
    // The color of the fog
    BBMOD_C_SILVER,
    // The maximum intensity of the fog
    0.6,
    // The distance from the camera at which the fog starts
    100,
    // The distance from the camera at which the fog has the maximum intensity
    1000);
```

Individual properties of the fog can also be configured using functions
[bbmod_fog_set_color](./bbmod_fog_set_color.html),
[bbmod_fog_set_intensity](./bbmod_fog_set_intensity.html),
[bbmod_fog_set_start](./bbmod_fog_set_start.html) and
[bbmod_fog_set_end](./bbmod_fog_set_end.html).

To disable the fog again, simply set its intensity to 0.
