# Changelog 3.21.2
This release fixes few bugs in the new post-processing system and adds a new "lens dirt strength" option to the sun shafts effect, using which you can modulate the strength of the lens dirt effect for sun shafts.

* Added new property `LensDirtStrength` to `BBMOD_SunShafts`, which modules the strength of the lens dirt effect when applied to sun shafts. Default value is 1.
* Added new optional argument `_lensDirtStrength` to the constructor of `BBMOD_SunShafts`, using which you can change the initial value of the `LensDirtStrength` property.
* Fixed `BBMOD_LensDistortionEffect`, which did not work with negative strength.
* Fixed `BBMOD_ColorGradingEffect`, which did not actually apply color grading.
