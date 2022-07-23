# Core shaders
Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShDefault\BBMOD_ShDefault.vsh --x .\Xshaders\ -ci X_PBR=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShDefault\BBMOD_ShDefault.fsh --x .\Xshaders\ -ci X_PBR=1

Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShDefaultAnimated\BBMOD_ShDefaultAnimated.vsh --x .\Xshaders\ X_PBR=1 -ci X_ANIMATED=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShDefaultAnimated\BBMOD_ShDefaultAnimated.fsh --x .\Xshaders\ X_PBR=1 -ci X_ANIMATED=1

Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShDefaultBatched\BBMOD_ShDefaultBatched.vsh --x .\Xshaders\ X_PBR=1 -ci X_BATCHED=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShDefaultBatched\BBMOD_ShDefaultBatched.fsh --x .\Xshaders\ X_PBR=1 -ci X_BATCHED=1

# Depth shaders
Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShDepth\BBMOD_ShDepth.vsh --x .\Xshaders\ -ci X_OUTPUT_DEPTH=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShDepth\BBMOD_ShDepth.fsh --x .\Xshaders\ -ci X_OUTPUT_DEPTH=1

Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShDepthAnimated\BBMOD_ShDepthAnimated.vsh --x .\Xshaders\ -ci X_ANIMATED=1 X_OUTPUT_DEPTH=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShDepthAnimated\BBMOD_ShDepthAnimated.fsh --x .\Xshaders\ -ci X_ANIMATED=1 X_OUTPUT_DEPTH=1

Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShDepthBatched\BBMOD_ShDepthBatched.vsh --x .\Xshaders\ -ci X_BATCHED=1 X_OUTPUT_DEPTH=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShDepthBatched\BBMOD_ShDepthBatched.fsh --x .\Xshaders\ -ci X_BATCHED=1 X_OUTPUT_DEPTH=1

# Terrain shaders
Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShTerrain\BBMOD_ShTerrain.vsh --x .\Xshaders\ -ci X_PBR=1 X_TERRAIN=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShTerrain\BBMOD_ShTerrain.fsh --x .\Xshaders\ -ci X_PBR=1 X_TERRAIN=1

# 2D shaders
Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShSprite\BBMOD_ShSprite.vsh --x .\Xshaders\ -ci X_PBR=1 X_2D=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShSprite\BBMOD_ShSprite.fsh --x .\Xshaders\ -ci X_PBR=1 X_2D=1

# Instance ID shaders
Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShInstanceID\BBMOD_ShInstanceID.vsh --x .\Xshaders\ -ci X_ID=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShInstanceID\BBMOD_ShInstanceID.fsh --x .\Xshaders\ -ci X_ID=1

Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShInstanceIDAnimated\BBMOD_ShInstanceIDAnimated.vsh --x .\Xshaders\ -ci X_ID=1 X_ANIMATED=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShInstanceIDAnimated\BBMOD_ShInstanceIDAnimated.fsh --x .\Xshaders\ -ci X_ID=1 X_ANIMATED=1

# Particle shaders
Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShParticleDepth\BBMOD_ShParticleDepth.vsh --x .\Xshaders\ -ci X_PBR=1 X_PARTICLES=1 X_OUTPUT_DEPTH=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShParticleDepth\BBMOD_ShParticleDepth.fsh --x .\Xshaders\ -ci X_PBR=1 X_PARTICLES=1 X_OUTPUT_DEPTH=1

Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShParticleLit\BBMOD_ShParticleLit.vsh --x .\Xshaders\ -ci X_PBR=1 X_PARTICLES=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShParticleLit\BBMOD_ShParticleLit.fsh --x .\Xshaders\ -ci X_PBR=1 X_PARTICLES=1

Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShParticleUnlit\BBMOD_ShParticleUnlit.vsh --x .\Xshaders\ -ci X_PARTICLES=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShParticleUnlit\BBMOD_ShParticleUnlit.fsh --x .\Xshaders\ -ci X_PARTICLES=1

# Lightmap shaders
Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShLightmap\BBMOD_ShLightmap.vsh --x .\Xshaders\ -ci X_PBR=1 X_LIGHTMAP=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShLightmap\BBMOD_ShLightmap.fsh --x .\Xshaders\ -ci X_PBR=1 X_LIGHTMAP=1

Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\BBMOD_ShLightmapDepth\BBMOD_ShLightmapDepth.vsh --x .\Xshaders\ -ci X_LIGHTMAP=1 X_OUTPUT_DEPTH=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\BBMOD_ShLightmapDepth\BBMOD_ShLightmapDepth.fsh --x .\Xshaders\ -ci X_LIGHTMAP=1 X_OUTPUT_DEPTH=1

# Zombie shaders
Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\ShZombie\ShZombie.vsh --x .\Xshaders\ -ci X_PBR=1 X_ZOMBIE=1 X_ANIMATED=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\ShZombie\ShZombie.fsh --x .\Xshaders\ -ci X_PBR=1 X_ZOMBIE=1 X_ANIMATED=1

Xpanda.exe .\Xshaders\Uber_VS.xsh --o .\shaders\ShZombieDepth\ShZombieDepth.vsh --x .\Xshaders\ -ci X_PBR=1 X_ZOMBIE=1 X_ANIMATED=1 X_OUTPUT_DEPTH=1
Xpanda.exe .\Xshaders\Uber_PS.xsh --o .\shaders\ShZombieDepth\ShZombieDepth.fsh --x .\Xshaders\ -ci X_PBR=1 X_ZOMBIE=1 X_ANIMATED=1 X_OUTPUT_DEPTH=1
