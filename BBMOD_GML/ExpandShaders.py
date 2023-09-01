#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os

PATH_SELF = os.path.dirname(os.path.realpath(__file__))
PATH_XSHADERS = os.path.join(PATH_SELF, "Xshaders")
PATH_UBER_VS = os.path.join(PATH_XSHADERS, "Uber_VS.xsh")
PATH_UBER_PS = os.path.join(PATH_XSHADERS, "Uber_PS.xsh")
CMD_XPANDA = "python3 " + os.path.join(PATH_SELF, "Xpanda", "Xpanda.py")

def dict_to_args_str(_dict: dict) -> str:
    _arg_str = ""
    for k in _dict:
        _arg_str += f"{k}={_dict[k]} "
    return _arg_str.rstrip()

def expand_shader(_name: str, _defines: dict={}) -> bool:
    path_out = os.path.join(PATH_SELF, "shaders", _name)
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

def combine(*_args: list[dict]) -> dict:
    res = {}
    for a in _args:
        res.update(a)
    return res

ANIMATED = { "X_ANIMATED": 1 }
BATCHED = { "X_BATCHED": 1 }
LIGHTMAP = { "X_LIGHTMAP": 1 }
COLOR = { "X_COLOR": 1 }
SPRITE = { "X_2D": 1 }
PARTICLES = { "X_PARTICLES": 1 }
PBR = { "X_PBR": 1 }
TERRAIN = { "X_TERRAIN": 1 }
OUTPUT_DEPTH = { "X_OUTPUT_DEPTH": 1 }
OUTPUT_GBUFFER = combine({ "X_OUTPUT_GBUFFER": 1 }, PBR)
ID = { "X_ID": 1 }

# Default shaders
expand_shader("BBMOD_ShDefault", combine(PBR))
expand_shader("BBMOD_ShDefaultAnimated", combine(PBR, ANIMATED))
expand_shader("BBMOD_ShDefaultBatched", combine(PBR, BATCHED))

expand_shader("BBMOD_ShDefaultColor", combine(PBR, COLOR))
expand_shader("BBMOD_ShDefaultColorAnimated", combine(PBR, COLOR, ANIMATED))
expand_shader("BBMOD_ShDefaultColorBatched", combine(PBR, COLOR, BATCHED))

expand_shader("BBMOD_ShDefaultLightmap", combine(PBR, LIGHTMAP))
expand_shader("BBMOD_ShDefaultSprite", combine(PBR, SPRITE))

expand_shader("BBMOD_ShDefaultDepth", combine(OUTPUT_DEPTH))
expand_shader("BBMOD_ShDefaultDepthAnimated", combine(OUTPUT_DEPTH, ANIMATED))
expand_shader("BBMOD_ShDefaultDepthBatched", combine(OUTPUT_DEPTH, BATCHED))

expand_shader("BBMOD_ShDefaultDepthColor", combine(OUTPUT_DEPTH, COLOR))
expand_shader("BBMOD_ShDefaultDepthColorAnimated", combine(OUTPUT_DEPTH, COLOR, ANIMATED))
expand_shader("BBMOD_ShDefaultDepthColorBatched", combine(OUTPUT_DEPTH, COLOR, BATCHED))

expand_shader("BBMOD_ShDefaultDepthLightmap", combine(OUTPUT_DEPTH, LIGHTMAP))

expand_shader("BBMOD_ShDefaultUnlit", combine())
expand_shader("BBMOD_ShDefaultUnlitAnimated", combine(ANIMATED))
expand_shader("BBMOD_ShDefaultUnlitBatched", combine(BATCHED))

expand_shader("BBMOD_ShDefaultUnlitColor", combine(COLOR))
expand_shader("BBMOD_ShDefaultUnlitColorAnimated", combine(COLOR, ANIMATED))
expand_shader("BBMOD_ShDefaultUnlitColorBatched", combine(COLOR, BATCHED))

# Gizmo shaders
expand_shader("BBMOD_ShInstanceID", combine(ID, COLOR))
expand_shader("BBMOD_ShInstanceIDAnimated", combine(ID, ANIMATED))
expand_shader("BBMOD_ShInstanceIDBatched", combine(ID, BATCHED))
expand_shader("BBMOD_ShInstanceIDLightmap", combine(ID, LIGHTMAP))

expand_shader("BBMOD_ShInstanceIDColor", combine(ID, COLOR))
expand_shader("BBMOD_ShInstanceIDColorAnimated", combine(ID, COLOR, ANIMATED))
expand_shader("BBMOD_ShInstanceIDColorBatched", combine(ID, COLOR, BATCHED))

# Particle shaders
expand_shader("BBMOD_ShParticleUnlit", combine(PARTICLES))
expand_shader("BBMOD_ShParticleLit", combine(PARTICLES, PBR))
expand_shader("BBMOD_ShParticleDepth", combine(PARTICLES, OUTPUT_DEPTH))

# Terrain shaders
expand_shader("BBMOD_ShTerrainUnlit", combine(TERRAIN))
expand_shader("BBMOD_ShTerrain", combine(TERRAIN, PBR))

# G-buffer
expand_shader("BBMOD_ShGBuffer", combine(OUTPUT_GBUFFER))
expand_shader("BBMOD_ShGBufferAnimated", combine(OUTPUT_GBUFFER, ANIMATED))
expand_shader("BBMOD_ShGBufferBatched", combine(OUTPUT_GBUFFER, BATCHED))
expand_shader("BBMOD_ShGBufferColor", combine(OUTPUT_GBUFFER, COLOR))
expand_shader("BBMOD_ShGBufferColorAnimated", combine(OUTPUT_GBUFFER, COLOR, ANIMATED))
expand_shader("BBMOD_ShGBufferColorBatched", combine(OUTPUT_GBUFFER, COLOR, BATCHED))
expand_shader("BBMOD_ShGBufferTerrain", combine(TERRAIN, OUTPUT_GBUFFER))

# Zombie shaders
ZOMBIE = combine({ "X_ZOMBIE": 1 }, ANIMATED)

expand_shader("ShZombie", combine(ZOMBIE, PBR))
expand_shader("ShZombieDepth", combine(ZOMBIE, OUTPUT_DEPTH))
