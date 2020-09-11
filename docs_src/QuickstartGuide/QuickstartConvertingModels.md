# Converting models
Models can be converted into BBMOD either using the BBMOD CLI or directly from
GML using a DLL.

--------------------------------------------------------------------------------

## Using CLI
If you are comfortable with using CMD or PowerShell, all you have to do to convert a model is to run `BBMOD.exe` with path to the model you want to convert as the first parameter.

If you don't have any previous experience with any of those, follow these steps:

 * Press `⊞ Win`+`R` to open the Run app.
 * Type `cmd` into the textbox and press `OK`. This will open a console.
 * Navigate to the directory where you have `BBMOD.exe` using command `cd`, e.g.

```cmd
cd "C:\Users\Username\Documents\GameMakerStudio2\Project\datafiles\BBMOD"
```

 * Run the exe with `BBMOD.exe path_to_the_model`, e.g.

```cmd
BBMOD.exe "C:\Users\Username\Models\Character.fbx"
```

This command would output a `Character.bbmod` file into the same directory where the original fbx is. You can optionally specify the output file path as the second parameter. To see all possible parameters, run the exe with `BBMOD.exe -h`, which will display a help message.

--------------------------------------------------------------------------------

## From GML
Using a DLL you can convert models right from GML:

```gml
var _dll = new BBMOD_DLL();
_dll.convert("Character.fbx", "Character.bbmod");
```

For more information about the `BBMOD_DLL` struct see its [documentation](./BBMOD_DLL.html).

--------------------------------------------------------------------------------

If the converted model contains animations, they are stored into the same
directory, each having a `_animation_name.bbanim` suffix, e.g.
`Character_idle.bbanim`, `Character_walk.bbanim` etc. Thanks to this you can
share animations between multiple models with the same skeleton.

Lastly, a `_log.txt` file is created, which contains additional info about the
converted model, like its vertex format, bones' and materials' names and indices
etc.
