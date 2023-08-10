# Changelog 3.18.1
This is a small patch release that mainly fixes dynamic batching that was broken in 3.18.0.

* Fixed dynamic batches rendering only a single instance of a model.
* Fixed method `present` of `BBMOD_BaseRenderer`, which did not reset the world matrix to identity before drawing surfaces.
