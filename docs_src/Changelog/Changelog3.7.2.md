# Changelog 3.7.2
This release mainly fixes shader compilation issues on some Android devices, which were caused by `#pragma include` lines in shaders. Names of files output by BBMOD CLI were also fixed, as previously it could merge multiple animations onto one BBANIM filename, even though the animations were called differently.
