# Converting models
Models can be converted into BBMOD either using BBMOD CLI or directly from
GML using a DLL.

--------------------------------------------------------------------------------

## Using BBMOD CLI
If you are comfortable with using CMD or PowerShell, all you have to do to
convert a model is to run `BBMOD.exe` (can be found in the Included Files) with
path to the model you want to convert as the first parameter.

If you do not have any previous experience with any of those, follow these
steps:

 * Press `⊞ Win`+`R` to open the Run app.
 * Type `cmd` into the textbox and press `OK`. This will open a console.
 * Navigate to the directory where you have `BBMOD.exe` using command `cd`, e.g.

```cmd
cd "C:\Users\Username\Documents\GameMakerStudio2\Project\datafiles\Data\BBMOD"
```

 * Run the exe with `BBMOD.exe C:\Path\To\The\Model`, e.g.

```cmd
BBMOD.exe "C:\Users\Username\Models\Character.fbx"
```

This command would output a `Character.bbmod` file into the same directory where
the original fbx is. You can optionally specify the output file path as the
second parameter. To see all possible parameters, run the exe with
`BBMOD.exe -h`, which will display a help message.

--------------------------------------------------------------------------------

## From GML
Using the [DLL module](./DLLModule.html) you can convert models right from GML:

```gml
var _dll = new BBMOD_DLL();
_dll.convert("Character.fbx", "Character.bbmod");
_dll.destroy();
```

--------------------------------------------------------------------------------

If the converted model contains animations, they are stored into the same
directory, each having a `_AnimationName.bbanim` suffix, e.g.
`Character_Idle.bbanim`, `Character_Walk.bbanim` etc. Thanks to this you can
share animations between multiple models with the same skeleton.

Lastly, a `_log.txt` file is created, which contains additional info about the
converted model, like its vertex format, bones' and materials' names and indices
etc.
