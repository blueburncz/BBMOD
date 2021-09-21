#pragma once


#include <cmath> 
#define _USE_MATH_DEFINES
#include <math.h> 

#define LERP(a, b, t) \
	(((1.0f - (t)) * (a)) + ((t) * (b)))

#define DSIN(x) \
	sinf(((x) / 180.0f) * (float)M_PI)

#define DCOS(x) \
	cosf(((x) / 180.0f) * (float)M_PI)
