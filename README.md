# BBMOD
> The most powerful 3D rendering solution for GameMaker

[![License](https://img.shields.io/github/license/blueburncz/BBMOD)](LICENSE)
[![Discord](https://img.shields.io/discord/298884075585011713?label=Discord)](https://discord.gg/ep2BGPm)

# Table of Contents
* [About](#about)
* [Features](#features)
* [Tutorials, documentation and help](#tutorials-documentation-and-help)
* [Demo project](#demo-project)
* [Support the development](#support-the-development)
* [Links](Links)
* [Special thanks](#special-thanks)

# About
BBMOD is the most powerful 3D rendering solution for GameMaker. We at BlueBurn believe that making 3D games in GameMaker should be for everyone and BBMOD fully reflects this idea with its simple workflow and powerful, yet easy to use GML Code library. Using our model conversion tool BBMOD CLI, you first convert your model from a common format like `FBX`, `COLLADA`, `OBJ` or `glTF` (the full list can be found [here](https://blueburn.cz/bbmod/docs/3/SupportedFileFormats.html)) into a custom binary format specially crafted for fast loading in GameMaker. Then, using the GML library, you can easily load the converted model (and its animations) and render it in just a few lines of code:

```gml
// Load model
model = new BBMOD_Model("Data/Model.bbmod");

// Create and assign material
material = BBMOD_MATERIAL_DEFAULT.clone();
material.BaseOpacity = sprite_get_texture(SprTexture, 0);
model.set_material("Material", material);

// Render model
bbmod_material_reset();
model.submit();
bbmod_material_reset();
```

Thanks to the BBMOD's powerful material system and physically based shaders, you can even use assets created in professional, industry standard software!

# Features
For the full feature list, please see https://blueburn.cz/bbmod/features.

# Tutorials, documentation and help
Tutorials for BBMOD can be found on its homepage at https://blueburn.cz/bbmod/tutorials. An online documentation for the latest release of BBMOD is always available at https://blueburn.cz/bbmod/docs/3. If you need any additional help, you can join our [Discord server](https://discord.gg/ep2BGPm) or contact us on [GMC forums](https://forum.yoyogames.com/index.php?threads/60628).

# Demo project
![Day](screenshots/Day.png)
![Night](screenshots/Night.png)
![Vignette and grayscale](screenshots/VignetteAndGrayscale.png)

To help you get started, BBMOD comes with a little demo project for you to explore, modify and maybe turn into your first complete 3D game! You can play it right now in your browser at https://blueburn.cz/bbmod/demo.

*Assets used in the demo project are created by [Kenney.nl](https://www.kenney.nl/) and [Poly Haven](https://polyhaven.com/).*

# Support the development
Support us in developing BBMOD, get priority assistance and more of our amazing tools as a reward! [Become our Patron](https://www.patreon.com/blueburn).

![BBMOD GUI](screenshots/GUI.png)
*[BBMOD GUI](https://blueburn.cz/index.php?menu=bbmod_gui) - Model converter with live preview, material editor and more*

![PushEd 2](https://blueburn.cz/images/ped_1.png)
*[PushEd 2](https://blueburn.cz/index.php?menu=pushed2) - 2D & 3D level editor for GameMaker*

# Links
* [BBMOD GUI](https://blueburn.cz/index.php?menu=bbmod_gui)
* [Discord](https://discord.gg/ep2BGPm)
* [Documentation](https://blueburn.cz/bbmod/docs/3)
* [Tutorials](https://blueburn.cz/bbmod/tutorials)
* [GameMaker Community](https://forum.yoyogames.com/index.php?threads/60628)
* [Official website](https://blueburn.cz/index.php?menu=bbmod)
* [Patreon](https://www.patreon.com/blueburn)
* [Play demo](https://blueburn.cz/bbmod/demo)
* [PushEd 2](https://blueburn.cz/index.php?menu=pushed2)
* [YoYo Games Marketplace](https://marketplace.yoyogames.com/assets/10210/bbmod-3)

# Special thanks
* To [Assimp](https://github.com/assimp/assimp) for making BBMOD CLI possible!
* To Gabor Szauer and their [Game Physics Cookbook](https://github.com/gszauer/GamePhysicsCookbook) for making the Raycasting module possible!
* To [Kenney.nl](https://www.kenney.nl/) for CC0 assets used in the demo project!
* To [Poly Haven](https://polyhaven.com/) for CC0 textures used in the demo project!
