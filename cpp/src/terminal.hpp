#pragma once

#include <cstdio>

#define TC_RESET 0

#define TC_F_BLACK 30
#define TC_F_RED 31
#define TC_F_GREEN 32
#define TC_F_YELLOW 33
#define TC_F_BLUE 34
#define TC_F_MAGENTA 35
#define TC_F_CYAN 36
#define TC_F_WHITE 37

#define TC_B_BLACK 40
#define TC_B_RED 41
#define TC_B_GREEN 42
#define TC_B_YELLOW 43
#define TC_B_BLUE 44
#define TC_B_MAGENTA 45
#define TC_B_CYAN 46
#define TC_B_WHITE 47

#define TC_STRINGIFY(v) #v

#define TC1(v) \
	"\x1B[" TC_STRINGIFY(v) "m"

#define TC2(v1, v2) \
	"\x1B[" TC_STRINGIFY(v1) ";" TC_STRINGIFY(v2) "m"

#define PRINT_SUCCESS(fmt, ...) \
	printf(TC2(TC_B_GREEN, TC_F_BLACK) " Success: " TC1(TC_RESET) " " fmt "\n", ##__VA_ARGS__)

#define PRINT_INFO(fmt, ...) \
	printf(TC2(TC_B_CYAN, TC_F_BLACK) " Info: " TC1(TC_RESET) " " fmt "\n", ##__VA_ARGS__)

#define PRINT_WARNING(fmt, ...) \
	printf(TC2(TC_B_YELLOW, TC_F_BLACK) " Warning: " TC1(TC_RESET) " " fmt "\n", ##__VA_ARGS__)

#define PRINT_ERROR(fmt, ...) \
	printf(TC2(TC_B_RED, TC_F_BLACK) " Error: " TC1(TC_RESET) " " fmt "\n", ##__VA_ARGS__)

bool InitTerminal();
