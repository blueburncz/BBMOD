# Core shaders
Xpanda .\shaders\BBMOD_ShDefault --x .\Xshaders\
Xpanda .\shaders\BBMOD_ShDefaultAnimated --x .\Xshaders\ X_ANIMATED=true
Xpanda .\shaders\BBMOD_ShDefaultBatched --x .\Xshaders\ X_BATCHED=true

# PBR shaders
Xpanda .\shaders\BBMOD_ShPBR\BBMOD_ShPBR.fsh --x .\Xshaders\ X_PBR=true
Xpanda .\shaders\BBMOD_ShPBR\BBMOD_ShPBR.vsh --x .\Xshaders\ X_PBR=true
Xpanda .\shaders\BBMOD_ShPBRAnimated\BBMOD_ShPBRAnimated.fsh --x .\Xshaders\ X_ANIMATED=true X_PBR=true
Xpanda .\shaders\BBMOD_ShPBRAnimated\BBMOD_ShPBRAnimated.vsh --x .\Xshaders\ X_ANIMATED=true X_PBR=true
Xpanda .\shaders\BBMOD_ShPBRBatched\BBMOD_ShPBRBatched.fsh --x .\Xshaders\ X_BATCHED=true X_PBR=true
Xpanda .\shaders\BBMOD_ShPBRBatched\BBMOD_ShPBRBatched.vsh --x .\Xshaders\ X_BATCHED=true X_PBR=true

# Depth shaders
Xpanda .\shaders\BBMOD_ShDepth --x .\Xshaders\ X_OUTPUT_DEPTH=true
Xpanda .\shaders\BBMOD_ShDepthAnimated --x .\Xshaders\ X_ANIMATED=true X_OUTPUT_DEPTH=true
Xpanda .\shaders\BBMOD_ShDepthBatched --x .\Xshaders\ X_BATCHED=true X_OUTPUT_DEPTH=true

# 2D shaders
Xpanda .\shaders\BBMOD_ShSprite --x .\Xshaders\ X_2D=true
