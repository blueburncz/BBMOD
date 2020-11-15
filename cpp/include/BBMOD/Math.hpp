#pragma once

#define LERP(a, b, t) \
	(((1 - (t)) * (a)) + ((t) * (b)))
