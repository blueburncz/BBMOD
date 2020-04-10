# Converting models
Converting models to BBMOD is extremely simple, just run the conversion tool
from the command line with path to the model you want to convert as the first
parameter:

```cmd
BBMOD.exe Character.fbx
```

This command would output a `Character.bbmod` file into the same directory
where the original fbx is. You can optionally specify the output file path as
the second parameter. To see all possible parameters, run the tool with
`BBMOD.exe -h`, which will display a help message.

If the converted model contains animations, they are stored into the same
directory, each having a `_animation_name.bbanim` suffix, e.g.
`Character_idle.bbanim`, `Character_walk.bbanim` etc. Thanks to this you can
share animations between multiple models with the same skeleton.

Lastly, a `_log.txt` file is created, which contains additional info about the
converted model, like its vertex format, bones' and materials' names and indices
etc.
