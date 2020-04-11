#include "terminal.hpp"

#ifdef _WIN32
#include <Windows.h>
#endif

bool InitTerminal()
{
#ifdef _WIN32
	// https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	if (hOut == INVALID_HANDLE_VALUE)
	{
		return false;
	}

	DWORD dwMode = 0;
	if (!GetConsoleMode(hOut, &dwMode))
	{
		return false;
	}

	dwMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
	if (!SetConsoleMode(hOut, dwMode))
	{
		return false;
	}
#endif
	return true;
}
