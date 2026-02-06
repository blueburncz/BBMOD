#pragma once

#include <cassert>
#include <unordered_map>

class Registry final
{
public:
	static double Add(void* ptr)
	{
		assert(ptr != nullptr);
		auto it = m_ptrToId.find(ptr);
		if (it != m_ptrToId.end())
		{
			return it->second;
		}
		double id = m_idNext++;
		m_ptrToId[ptr] = id;
		m_idToPtr[id] = ptr;
		return id;
	}

	static double GetId(void* ptr)
	{
		assert(ptr != nullptr);
		auto it = m_ptrToId.find(ptr);
		if (it != m_ptrToId.end())
		{
			return it->second;
		}
		return -1.0;
	}

	template<typename T>
	static T* Get(double id)
	{
		auto it = m_idToPtr.find(id);
		if (it != m_idToPtr.end())
		{
			return (T*)(it->second);
		}
		return nullptr;
	}

	static void Remove(double id)
	{
		auto it = m_idToPtr.find(id);
		if (it != m_idToPtr.end())
		{
			m_ptrToId.erase(m_ptrToId.find(it->second));
			m_idToPtr.erase(it);
		}
	}

	static void Remove(void* ptr)
	{
		auto it = m_ptrToId.find(ptr);
		if (it != m_ptrToId.end())
		{
			m_idToPtr.erase(m_idToPtr.find(it->second));
			m_ptrToId.erase(it);
		}
	}

private:
	Registry() {}
	~Registry() {}

	static inline std::unordered_map<void*, double> m_ptrToId{};
	static inline std::unordered_map<double, void*> m_idToPtr{};
	static inline double m_idNext = 0.0;
};
