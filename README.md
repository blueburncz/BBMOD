<p align="center">
  <img src="BBMOD3Light.svg" height="200px" alt="Logo"/>
</p>

> Make 3D games in GameMaker!

[![License](https://img.shields.io/github/license/blueburncz/BBMOD)](LICENSE)
[![Discord](https://img.shields.io/discord/298884075585011713?label=Discord)](https://discord.gg/ep2BGPm)

## Table of Contents

* [About](#about)
* [Screenshots](#screenshots)
* [Documentation, tutorials, samples and help](#documentation-tutorials-samples-and-help)
* [Building BBMOD CLI and DLL](#building-bbmod-cli-and-dll)
* [License](#license)
* [Logo terms of use](#logo-terms-of-use)
* [Links](Links)
* [Special thanks](#special-thanks)

## About

BBMOD is a library that makes creating 3D games in GameMaker easier! Whether you just need to draw 3D models in 2D games
or you are building fully immersive 3D worlds, BBMOD helps you bring your vision to life! For more info, please see its
homepage https://blueburn.cz/bbmod/.

> [!TIP]
> **BBMOD 4 is currently in development!** See the design document [here](https://github.com/blueburncz/BBMOD/issues/105)
> and its branch [here](https://github.com/blueburncz/BBMOD/tree/bbmod4).

## Screenshots

![Sponza](screenshots/Sponza.png)
*[Sponza](https://github.com/kraifpatrik/Sponza-BBMOD)*

![Vehice demo](screenshots/VehicleDemo.png)
*[Vehicle demo](https://github.com/blueburncz/BBMOD-Vehicle-Demo)*

![Zombie demo](screenshots/ZombieDemo.png)
*[Zombie demo](https://github.com/blueburncz/BBMOD-Zombie-Demo)*

## Documentation, tutorials, samples and help

An online documentation for the latest release of BBMOD is always available at https://blueburn.cz/bbmod/docs/3. Tutorials for BBMOD can be found on its homepage at https://blueburn.cz/bbmod/tutorials and sample projects at https://blueburn.cz/bbmod/samples. If you need any additional help, you can join our [Discord server](https://discord.gg/ep2BGPm).

## Building BBMOD CLI and DLL

Requires [CMake](https://cmake.org) version 3.23 or newer!

### 1. Build Assimp

Normally this can be omitted, since Assimp binaries are included in this repo, but in case of need, here's how to build them from scratch:

```sh
git clone https://github.com/assimp/assimp.git
cd assimp
git checkout v5.4.3
cmake -S . -B build # Use -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" on macOS!
cmake --build build --config=Release
```

When finished, copy

* `assimp-vc143-mt.dll` into `/BBMOD_CLI/bin/` on Windows,
* `assimp-vc143-mt.lib` into `/BBMOD_CLI/lib/`
* and `libassimp.5.4.3.dylib` into `/BBMOD_CLI/lib/libassimp.5.dylib` on macOS.

Up-to-date license text of Assimp (from its `LICENSE` file) should be kept in `/BBMOD_CLI/bin/LICENSE-Assimp`‼️

### 2. Build BBMOD CLI and DLL

```sh
cd BBMOD_CLI
cmake -S . -B build
cmake --build build --config=Release
```

This builds both BBMOD CLI and DLL into `/BBMOD_CLI/build/`. **Do not forget to copy the files to `/BBMOD_GML/datafiles/Data/BBMOD/` on release!** On Windows, these are `BBMOD.exe`, `assimp-vc143-mt.dll` and `LICENSE-Assimp`. On macOS it's `BBMOD`, `libassimp.5.dylib`, `libBBMOD.dylib` and `LICENSE-Assimp`.

### 3. Fix rpaths and codesign (for macOS)

* Check rpaths:

```sh
otool -l libBBMOD.dylib | grep -B 1 -A 2 LC_RPATH
```

* Remove bad rpaths:

```sh
install_name_tool -delete_rpath "/Volumes/KINGSTON/Git/BBMOD/BBMOD_CLI/lib" libBBMOD.dylib # Replace with the path you got from the previous command
```

* Add rpaths:

```sh
install_name_tool -add_rpath "@executable_path/data/bbmod" libBBMOD.dylib
install_name_tool -add_rpath "@loader_path/" libBBMOD.dylib
install_name_tool -add_rpath "@executable_path/../Resources/Data/BBMOD" libBBMOD.dylib

install_name_tool -add_rpath "@executable_path/data/bbmod" libassimp.5.dylib
install_name_tool -add_rpath "@loader_path/" libassimp.5.dylib
install_name_tool -add_rpath "@executable_path/../Resources/Data/BBMOD" libassimp.5.dylib
```

* Codesign:

```sh
codesign --force --timestamp --sign "Developer ID Application: Your Name (Y0URT3AM1D)" BBMOD
codesign --force --timestamp --sign "Developer ID Application: Your Name (Y0URT3AM1D)" libBBMOD.dylib
codesign --force --timestamp --sign "Developer ID Application: Your Name (Y0URT3AM1D)" libassimp.5.dylib
```

## License

BBMOD is available under the MIT license. Full text is available [here](LICENSE).

## Logo terms of use

BBMOD logo is property of [BlueBurn](https://blueburn.cz) and you're not allowed to do any modifications to it! **Only uniform scaling is allowed, to change the logo size as required.**

## Links

* [Homepage](https://blueburn.cz/bbmod)
* [Discord](https://discord.gg/ep2BGPm)

## Special thanks

* To [Assimp](https://github.com/assimp/assimp) for making BBMOD CLI possible!
* To [Bane-Me Please](https://vk.com/banemeplease) for extensive testing of BBMOD on Android devices.
* To Gabor Szauer and their [Game Physics Cookbook](https://github.com/gszauer/GamePhysicsCookbook) for making the Raycasting module possible!
