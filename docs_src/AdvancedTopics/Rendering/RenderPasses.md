# Render passes
In [Using a renderer](./UsingARenderer.md) we have mentioned that
[render queues](./BBMOD_BaseMaterial.RenderCommands.html) and
[render commands](./BBMOD_RenderCommand.html) that they contain can be traversed
and executed multiple times, each time using a different shader, different
configuration etc. The individual steps when rendering a scene this way are
commonly referred to as "render passes". BBMOD library comes with a defined set
of these passes and you can find them in enumeration
[BBMOD_ERenderPass](./BBMOD_ERenderPass.html).

## Default rendering pipeline
The default [renderer](./BBMOD_Renderer.html) currently implements a simple
two-pass rendering pipeline, where shadow-casting models are first rendered into
an off-screen surface (shadowmap) in the [Shadows](./BBMOD_ERenderPass.Shadows.html)
render pass and the surface is then used in a [Forward](./BBMOD_ERenderPass.Forward.html)
render pass, during which is the final shaded scene rendered into the application
surface. Please note that post-processing stands outside of this system and it
is handled separately when the application surface is drawn onto the screen.

It is possible to create a custom renderer with a custom rendering pipeline, but
that is a topic outside of the scope of this section.

## Defining shaders for individual render passes
When you see the documentation of [BBMOD_BaseMaterial](./BBMOD_BaseMaterial.html),
you will learn that the shader passed to its constructor is used in the
[Forward](./BBMOD_ERenderPass.Forward.html) render pass. This means that any mesh
that uses the material will be rendered *only* in a forward render pass, unless
you specify shaders used in other render passes too. For this you can use the
method [set_shader](./BBMOD_BaseMaterial.set_shader.html).

For example, when you use the default renderer and you want to render models
using a material into the shadowmap (so they cast shadows), you can configure
the material to use [BBMOD_SHADER_DEPTH](./BBMOD_SHADER_DEPTH.html) in the
[Shadows](./BBMOD_ERenderPass.Shadows.html) render pass like so:

```gml
material = BBMOD_MATERIAL_DEFAULT.clone()
    .set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH);
```

There are also methods [has_shader](./BBMOD_BaseMaterial.has_shader.html),
[get_shader](BBMOD_BaseMaterial.get_shader.html) and
[remove_shader](BBMOD_BaseMaterial.remove_shader.html), using which you can
check if a material has a shader defined for a specific render pass, retrieve
the shader or remove it respectively.
