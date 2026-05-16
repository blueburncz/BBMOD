#macro CM_TRIANGLE_GET_CAPSULE_REF	var e00 = v2x - v1x, e01 = v2y - v1y, e02 = v2z - v1z;\
									var e0 = dot_product_3d(e00, e01, e02, e00, e01, e02);\
									var e10 = v3x - v2x, e11 = v3y - v2y, e12 = v3z - v2z;\
									var e1 = dot_product_3d(e10, e11, e12, e10, e11, e12);\
									var e20 = v1x - v3x, e21 = v1y - v3y, e22 = v1z - v3z;\
									var e2 = dot_product_3d(e20, e21, e22, e20, e21, e22);\
									var pd = -1;\ //Penetration depth, basically how far the central axis of the capsule penetrates the triangle
									var dp = dot_product_3d(xup, yup, zup, nx, ny, nz);\
									if (dp != 0)\
									{\
										var trace = dot_product_3d(v1x - X, v1y - Y, v1z - Z, nx, ny, nz) / dp;\
										var traceX = X + xup * trace;\
										var traceY = Y + yup * trace;\
										var traceZ = Z + zup * trace;\
										var tx = traceX - v1x, ty = traceY - v1y, tz = traceZ - v1z;\
										var e = e0, ex = e00, ey = e01, ez = e02;\
										if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)\
										{\
											tx = traceX - v2x; ty = traceY - v2y; tz = traceZ - v2z;\
											e = e1; ex = e10; ey = e11; ez = e12;\
											if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)\
											{\
												tx = traceX - v3x; ty = traceY - v3y; tz = traceZ - v3z;\
												e = e2; ex = e20; ey = e21; ez = e22;\
												if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)\
												{\
													pd = clamp(trace, 0, height);\
												}\
											}\
										}\
										if (pd < 0)\
										{\	//The trace is outside an edge of the triangle. Find the closest point along the edge.
											var dx = X + tx - traceX;\
											var dy = Y + ty - traceY;\
											var dz = Z + tz - traceZ;\
											var upDp = dot_product_3d(ex, ey, ez, xup, yup, zup);\
											if (upDp * upDp == e) pd = clamp(dot_product_3d(dx, dy, dz, xup, yup, zup), 0, height);\
											else\
											{\
												var w1 = dot_product_3d(dx, dy, dz, ex, ey, ez);\
												var w2 = dot_product_3d(dx, dy, dz, xup, yup, zup);\
												var s = clamp((w1 - w2 * upDp) / (e - upDp * upDp), 0, 1);\
												pd = clamp(dot_product_3d(ex * s - dx, ey * s - dy, ez * s - dz, xup, yup, zup), 0, height);\
											}\
										}\
									}\
									else\
									{\
										pd = clamp(dot_product_3d(v1x - X, v1y - Y, v1z - Z, xup, yup, zup), 0, height);\
									}\
									var refX = X + xup * pd;\
									var refY = Y + yup * pd;\
									var refZ = Z + zup * pd