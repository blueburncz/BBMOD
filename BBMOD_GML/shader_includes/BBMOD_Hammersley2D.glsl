// @include BBMOD_VanDerCorpus

/// @desc Gets the i-th point from the Hammersley 2D low-discrepancy sequence.
/// @param i The point index in the sequence.
/// @param n The total size of the sequence.
/// @return 2D Hammersley point on the unit square.
/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
vec2 BBMOD_Hammersley2D(int i, int n)
{
	return vec2(float(i) / float(n), BBMOD_VanDerCorpus(i, 2));
}
