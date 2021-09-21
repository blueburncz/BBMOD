# Core shaders
Xpanda .\shaders\BBMOD_ShDefault --x .\Xshaders\ ANIMATED=false BATCHED=false PBR=false
Xpanda .\shaders\BBMOD_ShDefaultAnimated --x .\Xshaders\ ANIMATED=true BATCHED=false PBR=false
Xpanda .\shaders\BBMOD_ShDefaultBatched --x .\Xshaders\ ANIMATED=false BATCHED=true PBR=false

# PBR shaders
Xpanda .\shaders\BBMOD_ShPBR --x .\Xshaders\ ANIMATED=false BATCHED=false PBR=true
Xpanda .\shaders\BBMOD_ShPBRAnimated --x .\Xshaders\ ANIMATED=true BATCHED=false PBR=true
Xpanda .\shaders\BBMOD_ShPBRBatched --x .\Xshaders\ ANIMATED=false BATCHED=true PBR=true
