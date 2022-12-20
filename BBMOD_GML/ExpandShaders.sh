# Default shaders
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefault/BBMOD_ShDefault.vsh --x ./Xshaders/ -ci X_PBR=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefault/BBMOD_ShDefault.fsh --x ./Xshaders/ -ci X_PBR=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefaultAnimated/BBMOD_ShDefaultAnimated.vsh --x ./Xshaders/ X_PBR=1 -ci X_ANIMATED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefaultAnimated/BBMOD_ShDefaultAnimated.fsh --x ./Xshaders/ X_PBR=1 -ci X_ANIMATED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefaultBatched/BBMOD_ShDefaultBatched.vsh --x ./Xshaders/ X_PBR=1 -ci X_BATCHED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefaultBatched/BBMOD_ShDefaultBatched.fsh --x ./Xshaders/ X_PBR=1 -ci X_BATCHED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefaultLightmap/BBMOD_ShDefaultLightmap.vsh --x ./Xshaders/ -ci X_PBR=1 X_LIGHTMAP=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefaultLightmap/BBMOD_ShDefaultLightmap.fsh --x ./Xshaders/ -ci X_PBR=1 X_LIGHTMAP=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefaultSprite/BBMOD_ShDefaultSprite.vsh --x ./Xshaders/ -ci X_PBR=1 X_2D=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefaultSprite/BBMOD_ShDefaultSprite.fsh --x ./Xshaders/ -ci X_PBR=1 X_2D=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefaultDepth/BBMOD_ShDefaultDepth.vsh --x ./Xshaders/ -ci X_OUTPUT_DEPTH=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefaultDepth/BBMOD_ShDefaultDepth.fsh --x ./Xshaders/ -ci X_OUTPUT_DEPTH=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefaultDepthAnimated/BBMOD_ShDefaultDepthAnimated.vsh --x ./Xshaders/ -ci X_ANIMATED=1 X_OUTPUT_DEPTH=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefaultDepthAnimated/BBMOD_ShDefaultDepthAnimated.fsh --x ./Xshaders/ -ci X_ANIMATED=1 X_OUTPUT_DEPTH=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefaultDepthBatched/BBMOD_ShDefaultDepthBatched.vsh --x ./Xshaders/ -ci X_BATCHED=1 X_OUTPUT_DEPTH=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefaultDepthBatched/BBMOD_ShDefaultDepthBatched.fsh --x ./Xshaders/ -ci X_BATCHED=1 X_OUTPUT_DEPTH=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefaultDepthLightmap/BBMOD_ShDefaultDepthLightmap.vsh --x ./Xshaders/ -ci X_LIGHTMAP=1 X_OUTPUT_DEPTH=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefaultDepthLightmap/BBMOD_ShDefaultDepthLightmap.fsh --x ./Xshaders/ -ci X_LIGHTMAP=1 X_OUTPUT_DEPTH=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefaultUnlit/BBMOD_ShDefaultUnlit.vsh --x ./Xshaders/ -ci
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefaultUnlit/BBMOD_ShDefaultUnlit.fsh --x ./Xshaders/ -ci
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefaultUnlitAnimated/BBMOD_ShDefaultUnlitAnimated.vsh --x ./Xshaders/ -ci X_ANIMATED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefaultUnlitAnimated/BBMOD_ShDefaultUnlitAnimated.fsh --x ./Xshaders/ -ci X_ANIMATED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShDefaultUnlitBatched/BBMOD_ShDefaultUnlitBatched.vsh --x ./Xshaders/ -ci X_BATCHED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShDefaultUnlitBatched/BBMOD_ShDefaultUnlitBatched.fsh --x ./Xshaders/ -ci X_BATCHED=1
# Gizmo shaders
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShInstanceID/BBMOD_ShInstanceID.vsh --x ./Xshaders/ -ci X_ID=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShInstanceID/BBMOD_ShInstanceID.fsh --x ./Xshaders/ -ci X_ID=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShInstanceIDAnimated/BBMOD_ShInstanceIDAnimated.vsh --x ./Xshaders/ -ci X_ID=1 X_ANIMATED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShInstanceIDAnimated/BBMOD_ShInstanceIDAnimated.fsh --x ./Xshaders/ -ci X_ID=1 X_ANIMATED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShInstanceIDBatched/BBMOD_ShInstanceIDBatched.vsh --x ./Xshaders/ -ci X_ID=1 X_BATCHED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShInstanceIDBatched/BBMOD_ShInstanceIDBatched.fsh --x ./Xshaders/ -ci X_ID=1 X_BATCHED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShInstanceIDLightmap/BBMOD_ShInstanceIDLightmap.vsh --x ./Xshaders/ -ci X_ID=1 X_LIGHTMAP=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShInstanceIDLightmap/BBMOD_ShInstanceIDLightmap.fsh --x ./Xshaders/ -ci X_ID=1 X_LIGHTMAP=1
# Particle shaders
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShParticleDepth/BBMOD_ShParticleDepth.vsh --x ./Xshaders/ -ci X_PBR=1 X_PARTICLES=1 X_OUTPUT_DEPTH=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShParticleDepth/BBMOD_ShParticleDepth.fsh --x ./Xshaders/ -ci X_PBR=1 X_PARTICLES=1 X_OUTPUT_DEPTH=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShParticleLit/BBMOD_ShParticleLit.vsh --x ./Xshaders/ -ci X_PBR=1 X_PARTICLES=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShParticleLit/BBMOD_ShParticleLit.fsh --x ./Xshaders/ -ci X_PBR=1 X_PARTICLES=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShParticleUnlit/BBMOD_ShParticleUnlit.vsh --x ./Xshaders/ -ci X_PARTICLES=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShParticleUnlit/BBMOD_ShParticleUnlit.fsh --x ./Xshaders/ -ci X_PARTICLES=1
# Terrain shaders
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShTerrain/BBMOD_ShTerrain.vsh --x ./Xshaders/ -ci X_PBR=1 X_TERRAIN=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShTerrain/BBMOD_ShTerrain.fsh --x ./Xshaders/ -ci X_PBR=1 X_TERRAIN=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/BBMOD_ShTerrainUnlit/BBMOD_ShTerrainUnlit.fsh --x ./Xshaders/ -ci X_TERRAIN=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/BBMOD_ShTerrainUnlit/BBMOD_ShTerrainUnlit.vsh --x ./Xshaders/ -ci X_TERRAIN=1
# Zombie shaders
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/ShZombie/ShZombie.vsh --x ./Xshaders/ -ci X_PBR=1 X_ZOMBIE=1 X_ANIMATED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/ShZombie/ShZombie.fsh --x ./Xshaders/ -ci X_PBR=1 X_ZOMBIE=1 X_ANIMATED=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_VS.xsh --o ./shaders/ShZombieDepth/ShZombieDepth.vsh --x ./Xshaders/ -ci X_PBR=1 X_ZOMBIE=1 X_ANIMATED=1 X_OUTPUT_DEPTH=1
python ../../Xpanda/Xpanda.py ./Xshaders/Uber_PS.xsh --o ./shaders/ShZombieDepth/ShZombieDepth.fsh --x ./Xshaders/ -ci X_PBR=1 X_ZOMBIE=1 X_ANIMATED=1 X_OUTPUT_DEPTH=1
