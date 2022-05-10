# Core shaders
Xpanda .\shaders\BBMOD_ShDefault --x .\Xshaders\
Xpanda .\shaders\BBMOD_ShDefaultAnimated --x .\Xshaders\ X_ANIMATED=1
Xpanda .\shaders\BBMOD_ShDefaultBatched --x .\Xshaders\ X_BATCHED=1

# X_PBR shaders
Xpanda .\shaders\BBMOD_ShPBR\BBMOD_ShPBR.fsh --x .\Xshaders\ X_PBR=1
Xpanda .\shaders\BBMOD_ShPBR\BBMOD_ShPBR.vsh --x .\Xshaders\ X_PBR=1
Xpanda .\shaders\BBMOD_ShPBRAnimated\BBMOD_ShPBRAnimated.fsh --x .\Xshaders\ X_ANIMATED=1 X_PBR=1
Xpanda .\shaders\BBMOD_ShPBRAnimated\BBMOD_ShPBRAnimated.vsh --x .\Xshaders\ X_ANIMATED=1 X_PBR=1
Xpanda .\shaders\BBMOD_ShPBRBatched\BBMOD_ShPBRBatched.fsh --x .\Xshaders\ X_BATCHED=1 X_PBR=1
Xpanda .\shaders\BBMOD_ShPBRBatched\BBMOD_ShPBRBatched.vsh --x .\Xshaders\ X_BATCHED=1 X_PBR=1

# Depth shaders
Xpanda .\shaders\BBMOD_ShDepth --x .\Xshaders\ X_OUTPUT_DEPTH=1
Xpanda .\shaders\BBMOD_ShDepthAnimated --x .\Xshaders\ X_ANIMATED=1 X_OUTPUT_DEPTH=1
Xpanda .\shaders\BBMOD_ShDepthBatched --x .\Xshaders\ X_BATCHED=1 X_OUTPUT_DEPTH=1

# Terrain shaders
Xpanda .\shaders\BBMOD_ShTerrain --x .\Xshaders\ X_TERRAIN=1

# 2D shaders
Xpanda .\shaders\BBMOD_ShSprite --x .\Xshaders\ X_2D=1

# ID shaders
Xpanda .\shaders\BBMOD_ShID --x .\Xshaders\ X_ID=1
Xpanda .\shaders\BBMOD_ShIDAnimated --x .\Xshaders\ X_ID=1 X_ANIMATED=1
Xpanda .\shaders\BBMOD_ShIDBatched --x .\Xshaders\ X_ID=1 X_BATCHED=1
