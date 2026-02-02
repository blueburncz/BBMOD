#pragma once

#include <cstdio>
#include <cstdlib>

#ifdef _WIN32
#	include <windows.h>
#else
#	include <unistd.h>
#endif

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
	printf("%s Success: %s " fmt "\n", \
		TermColor::Code(TC2(TC_B_GREEN, TC_F_BLACK)), \
		TermColor::Code(TC1(TC_RESET)), \
		##__VA_ARGS__)

#define PRINT_INFO(fmt, ...) \
	printf("%s Info: %s " fmt "\n", \
		TermColor::Code(TC2(TC_B_CYAN, TC_F_BLACK)), \
		TermColor::Code(TC1(TC_RESET)), \
		##__VA_ARGS__)

#define PRINT_WARNING(fmt, ...) \
	printf("%s Warning: %s " fmt "\n", \
		TermColor::Code(TC2(TC_B_YELLOW, TC_F_BLACK)), \
		TermColor::Code(TC1(TC_RESET)), \
		##__VA_ARGS__)

#define PRINT_ERROR(fmt, ...) \
	printf("%s Error: %s " fmt "\n", \
		TermColor::Code(TC2(TC_B_RED, TC_F_BLACK)), \
		TermColor::Code(TC1(TC_RESET)), \
		##__VA_ARGS__)

class TermColor final
{
public:
	static bool Init()
	{
#ifdef _WIN32
		HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
		if (hOut == INVALID_HANDLE_VALUE)
		{
			return false;
		}

		DWORD mode = 0;
		if (!GetConsoleMode(hOut, &mode))
		{
			return false;
		}

		mode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
		if (!SetConsoleMode(hOut, mode))
		{
			return false;
		}

		s_enabled = true;
		return true;
#else
		// If stdout isn't a terminal, don't bother
		if (!isatty(fileno(stdout)))
		{
			return false;
		}

		// Respect NO_COLOR if user explicitly hates fun
		if (std::getenv("NO_COLOR"))
		{
			return false;
		}
		
		s_enabled = true;
		return true;
#endif
	}

	static const char* Code(const char* ansi)
	{
		return s_enabled ? ansi : "";
	}

private:
	static inline bool s_enabled = false;
};
