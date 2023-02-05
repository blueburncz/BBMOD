#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os

CMD_XPANDA = "python3 Xpanda/Xpanda.py"
PATH_XSHADERS = "Xshaders"
PATH_UBER_VS = os.path.join(PATH_XSHADERS, "Uber_VS.xsh")
PATH_UBER_PS = os.path.join(PATH_XSHADERS, "Uber_PS.xsh")

def dict_to_args_str(_dict: dict) -> str:
    _arg_str = ""
    for k in _dict:
        _arg_str += f"{k}={_dict[k]} "
    return _arg_str.rstrip()

def expand_shader(_name: str, _defines: dict={}) -> bool:
    path_out = os.path.join("shaders", _name)
    vsh_out = os.path.join(path_out, f"{_name}.vsh")
    fsh_out = os.path.join(path_out, f"{_name}.fsh")
    args = f"--x {PATH_XSHADERS} -ci " + dict_to_args_str(_defines)
    command_vs = f"{CMD_XPANDA} {PATH_UBER_VS} --o {vsh_out} {args}"
    command_ps = f"{CMD_XPANDA} {PATH_UBER_PS} --o {fsh_out} {args}"
    print(command_vs)
    os.system(command_vs)
    print(command_ps)
    os.system(command_ps)
    return True

# Default shaders
expand_shader("BBMOD_ShDefault", { "X_PBR": 1 })
expand_shader("BBMOD_ShDefaultAnimated", { "X_PBR": 1, "X_ANIMATED": 1 })
expand_shader("BBMOD_ShDefaultBatched", { "X_PBR": 1, "X_BATCHED": 1 })
expand_shader("BBMOD_ShDefaultLightmap", { "X_PBR": 1, "X_LIGHTMAP": 1 })
expand_shader("BBMOD_ShDefaultSprite", { "X_PBR": 1, "X_2D": 1 })

expand_shader("BBMOD_ShDefaultDepth", { "X_OUTPUT_DEPTH": 1 })
expand_shader("BBMOD_ShDefaultDepthAnimated", { "X_OUTPUT_DEPTH": 1, "X_ANIMATED": 1 })
expand_shader("BBMOD_ShDefaultDepthBatched", { "X_OUTPUT_DEPTH": 1, "X_BATCHED": 1 })
expand_shader("BBMOD_ShDefaultDepthLightmap", { "X_OUTPUT_DEPTH": 1, "X_LIGHTMAP": 1 })

expand_shader("BBMOD_ShDefaultUnlit")
expand_shader("BBMOD_ShDefaultUnlitAnimated", { "X_ANIMATED": 1 })
expand_shader("BBMOD_ShDefaultUnlitBatched", { "X_BATCHED": 1 })

# Gizmo shaders
expand_shader("BBMOD_ShInstanceID", { "X_ID": 1 })
expand_shader("BBMOD_ShInstanceIDAnimated", { "X_ID": 1, "X_ANIMATED": 1 })
expand_shader("BBMOD_ShInstanceIDBatched", { "X_ID": 1, "X_BATCHED": 1 })
expand_shader("BBMOD_ShInstanceIDLightmap", { "X_ID": 1, "X_LIGHTMAP": 1 })

# Particle shaders
expand_shader("BBMOD_ShParticleLit", { "X_PARTICLES": 1, "X_PBR": 1 })
expand_shader("BBMOD_ShParticleUnlit", { "X_PARTICLES": 1 })
expand_shader("BBMOD_ShParticleDepth", { "X_PARTICLES": 1, "X_OUTPUT_DEPTH": 1 })

# Terrain shaders
expand_shader("BBMOD_ShTerrain", { "X_TERRAIN": 1, "X_PBR": 1 })
expand_shader("BBMOD_ShTerrainUnlit", { "X_TERRAIN": 1 })

# Zombie shaders
expand_shader("ShZombie", { "X_ZOMBIE": 1, "X_ANIMATED": 1, "X_PBR": 1 })
expand_shader("ShZombieDepth", { "X_ZOMBIE": 1, "X_ANIMATED": 1, "X_OUTPUT_DEPTH": 1 })
