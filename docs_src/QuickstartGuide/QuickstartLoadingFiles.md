# Loading files
Once you have your models and animations converted, you can put the `bbmod` and `bbanim` files into your `Included Files` folder inside your GameMaker project.

To load the files, use structs [BBMOD_Model](./BBMOD_Model.html) or [BBMOD_Animation](./BBMOD_Animation.html).

```gml
mod_character = new BBMOD_Model("Character.bbmod");
anim_idle = new BBMOD_Animation("Character_idle.bbanim");
anim_walk = new BBMOD_Animation("Character_walk.bbanim");
```

If you want to prevent users from modifying the files, you can pass their SHA1 (which can be obtained for example using GameMaker's [sha1_file](https://docs2.yoyogames.com/source/_build/3_scripting/4_gml_reference/file%20handling/sha1_file.html) script) as the second argument to the constructors. If the provided SHA1 and the SHA1 of the file do not match, a [BBMOD_Error](./BBMOD_Error.html) will be thrown.

```gml
try
{
    mod_character = new BBMOD_Model("Character.bbmod",
        "00ce787894b25cfe48e8d17797daa4009c06add8");
}
catch (e)
{
    // The file is either modified or corrupted...
}
```
