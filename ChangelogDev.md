# Changelog dev

> This file is used to accumulate changes before a changelog for a release is created.

## Animation playback

* Added missing property `PlaybackSpeed` to `BBMOD_AnimationPlayer` (default value is `1.0`), which fixes a crash in animation playback.
* Fixed `BBMOD_AnimationPlayer.update` occasionally re-processing the same queued animation entry.
* Optimized transitions in `BBMOD_AnimationPlayer` to blend frames on demand with a reusable buffer, reducing transition-time memory spikes while preserving crossfades.
* Added new method `sample_transition_frame(_timeFrom, _animTo, _timeTo, _factor[, _destination])` to `BBMOD_Animation` for reusable transition frame sampling.
* Method `create_transition` of `BBMOD_Animation` now uses shared blend and time-wrapping rules for more consistent transition results.

## Resource management

* Improved resource lifecycle handling in `BBMOD_ResourceManager` and `BBMOD_Resource`.
* Fixed invalid lookups during `remove`, `get`, and `free` operations.
* Fixed async model material load completion counting.
* Resources added under unique names are now removed from manager tracking more reliably when destroyed.

## Rendering

* Fixed `BBMOD_DynamicBatch` object-draw callback material argument forwarding.
* Fixed instance removal in `BBMOD_DynamicBatch` so internal remapping stays correct after compaction.
* Fixed `BBMOD_PostProcessor.remove_effect` not always matching the requested effect instance correctly.

## Particles

* Fixed particle compaction in `BBMOD_ParticleEmitter` to preserve particle IDs correctly when particles are swapped or removed.

## Miscellaneous

* Updated `BBMOD_Model.destroy` to clear cached hierarchy/traversal data after mesh cleanup.

## Asset pipeline

* Added support for loading triangle fans to `BBMOD_OBJImporter`. Thanks [@danielpancake](https://github.com/danielpancake) for contributing!
