#pragma once

#include <string>

template<typename T>
T BBMOD_PeekBuffer(char* buffer)
{
	if constexpr (std::is_same_v<T, std::string>)
	{
		return std::string(buffer);
	}
	else
	{
		T value;
		memcpy(&value, buffer, sizeof(T));
		return value;
	}
}

template<typename T>
T BBMOD_ReadBuffer(char*& buffer)
{
	if constexpr (std::is_same_v<T, std::string>)
	{
		std::string str(buffer);
		buffer += str.size() + 1;
		return str;
	}
	else
	{
		T value;
		memcpy(&value, buffer, sizeof(T));
		buffer += sizeof(T);
		return value;
	}
}

template<typename T>
void BBMOD_PokeBuffer(char* buffer, const T& value)
{
	if constexpr (std::is_same_v<T, std::string>)
	{
		memcpy(buffer, value.c_str(), value.size() + 1);
	}
	else
	{
		memcpy(buffer, &value, sizeof(T));
	}
}

template<typename T>
void BBMOD_WriteBuffer(char*& buffer, const T& value)
{
	if constexpr (std::is_same_v<T, std::string>)
	{
		memcpy(buffer, value.c_str(), value.size() + 1);
		buffer += value.size() + 1;
	}
	else
	{
		memcpy(buffer, &value, sizeof(T));
		buffer += sizeof(T);
	}
}
