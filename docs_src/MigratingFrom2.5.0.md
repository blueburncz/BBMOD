# Migrating from 2.5.0
BBMOD 3.0.0 has brought great new features, some of which required breaking
changes to to the Scripting API and the file formats. In this section you can
find a quick guide to upgrading your existing project from 2.5.0 to 3.0.0. For
the full list of changes, please see the [changelog](./Changelog3.0.0.html).

## Re-convert your models
BBMOD 3.0.0 has different format of `*.bbmod` and `*.bbanim`. You need to first
re-convert all your assets to be able to use them in the new BBMOD.

## Update your materials
In 3.0.0 PBR is now its own [module](./PBRModule.html) and no longer the default
shader/material. Also in 2.5.0 you could pass a regular GM shader resource to
[BBMOD_Material](./BBMOD_Material.html)s, but in 3.0.0 there is a new struct
[BBMOD_Shader](./BBMOD_Shader.html), which is a wrapper for the regular shader
resources. `BBMOD_Material` now accepts only instances of `BBMOD_Shader`! For
PBR materials there are new structs [BBMOD_PBRMaterial](./BBMOD_PBRMaterial.html)
and [BBMOD_PBRShader](./BBMOD_PBRShader.html) defined in the PBR module.

What previously was:

```gml
matCharacter = new BBMOD_Material(BBMOD_ShDefaultAnimated);
```

now becomes:

```gml
matCharacter = new BBMOD_PBRMaterial(BBMOD_SHADER_PBR_ANIMATED);
```

or alternatively:

```gml
matCharacter = BBMOD_MATERIAL_PBR_ANIMATED.clone();
```

## Draw models using method submit instead of render
BBMOD 3.0.0 introduces [render queues](./BBMOD_RenderCommand.html) and
[renderers](BBMOD_Renderer.html), using which you can draw meshes sorted by
material they use, define custom render pipelines etc. The old `render` method
of `BBMOD_Model` was renamed to [submit](./BBMOD_Model.submit.html) and a new
[render](./BBMOD_Model.render.html) method was added, which only enqueues render
commands into materials' render queues. Same applies to `BBMOD_DynamicBatch` -
its old method `render_object` was renamed to
[submit_object](./BBMOD_DynamicBatch.submit_object.html) and a new method
[render_object](./BBMOD_DynamicBatch.render_object.html) was added. The enqueued
commands then have to be picked up and executed by a renderer.

## Update animation event listeners
Previously only a single animation event listener could be defined for an
animation player using:

```gml
animationPlayer.OnEvent = function (_event, _data) {
    switch (_event)
    {
    case BBMOD_EV_ANIMATION_END:
        // Handle event...
        break;
    }
};
```

In BBMOD 3.0.0 more animation events were added and you can even define custom
animation events. The single event listener would not work well with this change
and so a new system for aniamtion event listeners was created:

```gml
animationPlayer.on_event(BBMOD_EV_ANIMATION_END, function (_data) {
    // Handle event...
});
```

See the [Animation events](./QuickstartAnimationEvents.html) section for more
info.

## Use the new math library
BBMOD no longer includes library [CE](https://github.com/kraifpatrik/CE) and
instead it now comes with its own math library. You now have to use structs
[BBMOD_Vec2](./BBMOD_Vec2.html), [BBMOD_Vec3](./BBMOD_Vec3.html),
[BBMOD_Vec4](./BBMOD_Vec4.html), [BBMOD_Quaternion](./BBMOD_Quaternion.html) and
[BBMOD_DualQuaternion](./BBMOD_DualQuaternion.html) instead of their CE
counterparts.

## Use dual quaternions instead of matrices for node transformations
All node transformations and animation data now use dual quaternions instead of
matrices, which means that method
[get_node_transform](./BBMOD_AnimationPlayer.get_node_transform.html) also
returns a dual quaternion instead of a matrix.

What previously was:

```gml
var _handId = model.find_node_id("HandRight");
var _handMatrix = animationPlayer.get_node_transform(_handId);
matrix_set(matrix_world, _handMatrix);
```

now becomes:

```gml
var _handId = model.find_node_id("HandRight");
var _handDq = animationPlayer.get_node_transform(_handId);
var _handMatrix = _handDq.ToMatrix();
matrix_set(matrix_world, _handMatrix);
```

## Use the new utilities
A bunch of new utility methods have been added in BBMOD 3.0.0. For example the
animation player now has a method [change](./BBMOD_AnimationPlayer.change.html),
using which you do not have to keep track of the last played animation and call
method [play](./BBMOD_AnimationPlayer.play.html) only if it changes, it is now
taken care of by the animation player. Also the animation player now has its
own methods [submit](./BBMOD_AnimationPlayer.submit.html) and
[render](./BBMOD_AnimationPlayer.render.html) so you do not have to write
`model.render(materials, animationPlayer.get_transform())` anymore, it can be
just `animationPlayer.render(materials)`.

## If you still have issues
Do not be afraid and come join the official Discord server or the GameMaker
Community forum thread (see [Links](./Links.html)), where you can get help with
using the new BBMOD.
