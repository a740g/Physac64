//-----------------------------------------------------------------------------------------------------------------------
// physac, reasings and raymath support library
// Copyright (c) 2024 Samuel Gomes
//-----------------------------------------------------------------------------------------------------------------------

#pragma once

#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <algorithm>

typedef int8_t qb_bool;

// QB64 FALSE is 0 and TRUE is -1 (sad, but true XD)
#ifndef QB_TRUE
#define QB_TRUE -1
#endif
#ifndef QB_FALSE
#define QB_FALSE 0
#endif

// We have to do this for the QB64 side
#define TO_QB_BOOL(_exp_) (qb_bool(-(bool(_exp_))))

#if !defined(RL_VECTOR2_TYPE)
// Vector2, 2 components
struct Vector2
{
    float x; // Vector x component
    float y; // Vector y component
};
#define RL_VECTOR2_TYPE 1
#endif

#if !defined(RL_VECTOR3_TYPE)
// Vector3, 3 components
struct Vector3
{
    float x; // Vector x component
    float y; // Vector y component
    float z; // Vector z component
};
#define RL_VECTOR3_TYPE 1
#endif

#if !defined(RL_VECTOR4_TYPE)
// Vector4, 4 components
struct Vector4
{
    float x; // Vector x component
    float y; // Vector y component
    float z; // Vector z component
    float w; // Vector w component
};
#define RL_VECTOR4_TYPE 1
#endif

#if !defined(RL_MATRIX_TYPE)
// Matrix, 4x4 components, column major, OpenGL style, right-handed
struct Matrix
{
    float m0;  // Matrix first row (4 components)
    float m4;  // Matrix first row (4 components)
    float m8;  // Matrix first row (4 components)
    float m12; // Matrix first row (4 components)
    float m1;  // Matrix second row (4 components)
    float m5;  // Matrix second row (4 components)
    float m9;  // Matrix second row (4 components)
    float m13; // Matrix second row (4 components)
    float m2;  // Matrix third row (4 components)
    float m6;  // Matrix third row (4 components)
    float m10; // Matrix third row (4 components)
    float m14; // Matrix third row (4 components)
    float m3;  // Matrix fourth row (4 components)
    float m7;  // Matrix fourth row (4 components)
    float m11; // Matrix fourth row (4 components)
    float m15; // Matrix fourth row (4 components)
};
#define RL_MATRIX_TYPE 1
#endif

// Various interop functions that make life easy when working with external libs

template <typename T>
inline void __SetMemory(T *dst, T value, size_t elements)
{
    std::fill(dst, dst + elements, value);
}

#define __SetMemoryByte(_dst_, _ch_, _cnt_) memset((void *)(_dst_), (int)(_ch_), (size_t)(_cnt_))
#define __SetMemoryInteger(_dst_, _ch_, _cnt_) __SetMemory<int16_t>(reinterpret_cast<int16_t *>(_dst_), (_ch_), (_cnt_))
#define __SetMemoryLong(_dst_, _ch_, _cnt_) __SetMemory<int32_t>(reinterpret_cast<int32_t *>(_dst_), (_ch_), (_cnt_))
#define __SetMemorySingle(_dst_, _ch_, _cnt_) __SetMemory<float>(reinterpret_cast<float *>(_dst_), (_ch_), (_cnt_))
#define __SetMemoryInteger64(_dst_, _ch_, _cnt_) __SetMemory<int64_t>(reinterpret_cast<int64_t *>(_dst_), (_ch_), (_cnt_))
#define __SetMemoryDouble(_dst_, _ch_, _cnt_) __SetMemory<double>(reinterpret_cast<double *>(_dst_), (_ch_), (_cnt_))
#define __CopyMemory(_dst_, _src_, _cnt_) memcpy((void *)(_dst_), (const void *)(_src_), (size_t)(_cnt_))
#define __MoveMemory(_dst_, _src_, _cnt_) memmove((void *)(_dst_), (const void *)(_src_), (size_t)(_cnt_))

/// @brief Peeks a BYTE (8-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @return BYTE value
inline int8_t PeekByte(uintptr_t p, uintptr_t o)
{
    return *(reinterpret_cast<const int8_t *>(p) + o);
}

/// @brief Poke a BYTE (8-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @param n BYTE value
inline void PokeByte(uintptr_t p, uintptr_t o, int8_t n)
{
    *(reinterpret_cast<int8_t *>(p) + o) = n;
}

/// @brief Peek an INTEGER (16-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @return INTEGER value
inline int16_t PeekInteger(uintptr_t p, uintptr_t o)
{
    return *(reinterpret_cast<const int16_t *>(p) + o);
}

/// @brief Poke an INTEGER (16-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @param n INTEGER value
inline void PokeInteger(uintptr_t p, uintptr_t o, int16_t n)
{
    *(reinterpret_cast<int16_t *>(p) + o) = n;
}

/// @brief Peek a LONG (32-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @return LONG value
inline int32_t PeekLong(uintptr_t p, uintptr_t o)
{
    return *(reinterpret_cast<const int32_t *>(p) + o);
}

/// @brief Poke a LONG (32-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @param n LONG value
inline void PokeLong(uintptr_t p, uintptr_t o, int32_t n)
{
    *(reinterpret_cast<int32_t *>(p) + o) = n;
}

/// @brief Peek a INTEGER64 (64-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @return INTEGER64 value
inline int64_t PeekInteger64(uintptr_t p, uintptr_t o)
{
    return *(reinterpret_cast<const int64_t *>(p) + o);
}

/// @brief Poke a INTEGER64 (64-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @param n INTEGER64 value
inline void PokeInteger64(uintptr_t p, uintptr_t o, int64_t n)
{
    *(reinterpret_cast<int64_t *>(p) + o) = n;
}

/// @brief Peek a SINGLE (32-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @return SINGLE value
inline float PeekSingle(uintptr_t p, uintptr_t o)
{
    return *((float *)p + o);
}

/// @brief Poke a SINGLE (32-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @param n SINGLE value
inline void PokeSingle(uintptr_t p, uintptr_t o, float n)
{
    *((float *)p + o) = n;
}

/// @brief Peek a DOUBLE (64-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @return DOUBLE value
inline double PeekDouble(uintptr_t p, uintptr_t o)
{
    return *((double *)p + o);
}

/// @brief Poke a DOUBLE (64-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @param n DOUBLE value
inline void PokeDouble(uintptr_t p, uintptr_t o, double n)
{
    *((double *)p + o) = n;
}

/// @brief Peek an OFFSET (32/64-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @return DOUBLE value
inline uintptr_t PeekOffset(uintptr_t p, uintptr_t o)
{
    return *(reinterpret_cast<const uintptr_t *>(p) + o);
}

/// @brief Poke an OFFSET (32/64-bits) value at p + o
/// @param p Pointer base
/// @param o Offset from base
/// @param n DOUBLE value
inline void PokeOffset(uintptr_t p, uintptr_t o, uintptr_t n)
{
    *(reinterpret_cast<uintptr_t *>(p) + o) = n;
}

/// @brief Gets a UDT value from a pointer positon offset by o. Same as t = p[o]
/// @param p The base pointer
/// @param o Offset from base (each offset is t_size bytes)
/// @param t A pointer to the UDT variable
/// @param t_size The size of the UTD variable in bytes
inline void PeekType(uintptr_t p, uintptr_t o, uintptr_t t, size_t t_size)
{
    memcpy((void *)t, (const uint8_t *)p + (o * t_size), t_size);
}

/// @brief Sets a UDT value to a pointer position offset by o. Same as p[o] = t
/// @param p The base pointer
/// @param o Offset from base (each offset is t_size bytes)
/// @param t A pointer to the UDT variable
/// @param t_size The size of the UTD variable in bytes
inline void PokeType(uintptr_t p, uintptr_t o, uintptr_t t, size_t t_size)
{
    memcpy((uint8_t *)p + (o * t_size), (void *)t, t_size);
}

/// @brief Sets a Vector2 variable
/// @param v The Vector2 variable
/// @param x The x component
/// @param y The y component
inline void SetVector2(void *v, float x, float y)
{
    (*reinterpret_cast<Vector2 *>(v)) = {x, y};
}

/// @brief Sets a Vector3 variable
/// @param v The Vector3 variable
/// @param x The x component
/// @param y The y component
/// @param z The z component
inline void SetVector3(void *v, float x, float y, float z)
{
    (*reinterpret_cast<Vector3 *>(v)) = {x, y, z};
}

/// @brief Sets a Vector4 variable
/// @param v The Vector4 variable
/// @param x The x component
/// @param y The y component
/// @param z The z component
/// @param w The w component
inline void SetVector4(void *v, float x, float y, float z, float w)
{
    (*reinterpret_cast<Vector4 *>(v)) = {x, y, z, w};
}
