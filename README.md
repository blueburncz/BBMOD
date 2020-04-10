# BBMOD
> Simple 3D model format for GameMaker Studio 2 + conversion tool

[![License](https://img.shields.io/github/license/blueburn-cz/BBMOD)](LICENSE)
[![Discord](https://img.shields.io/discord/298884075585011713?label=Discord)](https://discord.gg/v4Qf4Dq)

# Table of Contents
* [About](#about)
* [Installation](#installation)
* [Documentation and help](#documentation-and-help)
* [Links](#links)

# About
BBMOD is a 3D model and animation format specially crafted for GameMaker Studio 2.
It is accompanied by a conversion tool written in C++, as well as GML library that
allows you to load, animate and render BBMOD files without any hassle. The conversion
tool utilizes Assimp to load third-party model formats, so any model that Assimp can
load can be loaded into GMS2 using BBMOD. A few examples of such model formats are
`OBJ`, `COLLADA` or the industry standard `FBX`.

# Installation
Using [Catalyst](https://github.com/GameMakerHub/Catalyst), the open-source package manager for GameMaker Studio 2:

```cmd
catalyst require blueburn-cz/bbmod
```

# Documentation and help
The documentation source is available in the `docs_src` folder. It can be built
into an HTML format using [GMDoc](https://github.com/kraifpatrik/gmdoc). If you
need any additional help, feel free to contact us on the
[GMC forums](https://forum.yoyogames.com/index.php?threads/60628), or you can
join our [Discord server](https://discord.gg/ep2BGPm).

# Links
* [Game Maker Hub](https://gamemakerhub.net/package/blueburn-cz/BBMOD)
* [GameMaker Community forums thread](https://forum.yoyogames.com/index.php?threads/60628)
* [Discord](https://discord.gg/ep2BGPm)
* [Assimp](https://github.com/assimp/assimp)
* [CE](https://github.com/slagtand-org/ce)
