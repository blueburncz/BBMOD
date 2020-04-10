# Loading files
Once you have your models and animations converted, you can put the `bbmod` and
`bbanim` files into your `Included Files` folder inside your GameMaker project.

To load the files, use the script [bbmod_load](./bbmod_load.html):

```gml
mod_character = bbmod_load("Character.bbmod");
anim_idle = bbmod_load("Character_idle.bbanim");
anim_walk = bbmod_load("Character_walk.bbanim");
```

If you want to prevent users from modifying the files, you can pass their SHA1
(which can be obtained for example using GameMaker's
[sha1_file](http://docs2.yoyogames.com/source/_build/3_scripting/4_gml_reference/file%20handling/sha1_file.html)
script) as the second argument to the [bbmod_load](./bbmod_load.html) script.
If the provided SHA1 and the SHA1 of the file do not match, it will not be loaded
and the script will return [BBMOD_NONE](./BBMOD_NONE.html).

```gml
if (mod_character == BBMOD_NONE)
{
    // The file is either modified or corrupted...
}
```
