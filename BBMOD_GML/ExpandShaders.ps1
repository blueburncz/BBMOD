# Core shaders
Xpanda .\shaders\BBMOD_ShDefault --x .\Xshaders\ ANIMATED=false BATCHED=false PBR=false OUTPUT_DEPTH=false
Xpanda .\shaders\BBMOD_ShDefaultAnimated --x .\Xshaders\ ANIMATED=true BATCHED=false PBR=false OUTPUT_DEPTH=false
Xpanda .\shaders\BBMOD_ShDefaultBatched --x .\Xshaders\ ANIMATED=false BATCHED=true PBR=false OUTPUT_DEPTH=false

# PBR shaders
Xpanda .\shaders\BBMOD_ShPBR --x .\Xshaders\ ANIMATED=false BATCHED=false PBR=true OUTPUT_DEPTH=false
Xpanda .\shaders\BBMOD_ShPBRAnimated --x .\Xshaders\ ANIMATED=true BATCHED=false PBR=true OUTPUT_DEPTH=false
Xpanda .\shaders\BBMOD_ShPBRBatched --x .\Xshaders\ ANIMATED=false BATCHED=true PBR=true OUTPUT_DEPTH=false

# Depth shaders
Xpanda .\shaders\BBMOD_ShDepth --x .\Xshaders\ ANIMATED=false BATCHED=false PBR=false OUTPUT_DEPTH=true
Xpanda .\shaders\BBMOD_ShDepthAnimated --x .\Xshaders\ ANIMATED=true BATCHED=false PBR=false OUTPUT_DEPTH=true
Xpanda .\shaders\BBMOD_ShDepthBatched --x .\Xshaders\ ANIMATED=false BATCHED=true PBR=false OUTPUT_DEPTH=true
