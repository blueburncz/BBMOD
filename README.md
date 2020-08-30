# BBMOD
> 3D model format for GameMaker Studio 2.3+

[![License](https://img.shields.io/github/license/blueburn-cz/BBMOD)](LICENSE)
[![Discord](https://img.shields.io/discord/298884075585011713?label=Discord)](https://discord.gg/v4Qf4Dq)

# Table of Contents
* [About](#about)
* [Getting Started](#getting-started)
  * [Download](#download)
  * [Installation](#installation)
  * [Converting models](#converting-models)
    * [Using CLI](#using-cli)
    * [Using DLL](#using-dll)
* [Links](#links)

# About
BBMOD is a 3D model and animation format specially crafted for GameMaker Studio 2. It is accompanied by a conversion tool, as well as GML library that allows you to load, animate and render BBMOD files without any hassle. The conversion tool utilizes [Assimp](https://github.com/assimp/assimp) to load third-party model formats, so any model format that Assimp can load can be loaded into GMS2 using BBMOD. A few examples of such model formats are `OBJ`, `COLLADA` or the industry standard `FBX`.

# Getting Started

## Download
The latest release of the BBMOD can be found under [Releases](https://github.com/blueburn-cz/BBMOD/releases). `BBMOD.yymps` is the GML library required to load and render converted models. `BBMOD_Win32.zip` contains a command line interface (CLI) for converting models.

## Installation
To import the `BBMOD.yymps` package into your GameMaker Studio 2 project, use `Tools > Import Local Package` from the top menu bar.

## Converting models

### Using CLI

### Using DLL

# Links
* [GameMaker Community](https://forum.yoyogames.com/index.php?threads/60628)
* [Discord](https://discord.gg/ep2BGPm)
* [Assimp](https://github.com/assimp/assimp)
* [CE](https://github.com/slagtand-org/ce)
* [Xpanda](https://github.com/GameMakerDiscord/Xpanda)
