'-----------------------------------------------------------------------------------------------------------------------
' physac, reasings and raymath support library
' Copyright (c) 2024 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$INCLUDEONCE

$IF VERSION < 4.0.0 OR 32BIT THEN
    $ERROR 'Physac-64 requires the latest 64-bit version of QB64-PE from https://github.com/QB64-Phoenix-Edition/QB64pe/releases/latest'
$END IF

CONST NULL~%% = 0~%%

' Vector2, 2 components
TYPE Vector2
    x AS SINGLE ' Vector x component
    y AS SINGLE ' Vector y component
END TYPE
CONST SIZE_OF_VECTOR2~& = 8~&

' Vector3, 3 components
TYPE Vector3
    x AS SINGLE ' Vector x component
    y AS SINGLE ' Vector y component
    z AS SINGLE ' Vector z component
END TYPE
CONST SIZE_OF_VECTOR3~& = 12~&

' Vector4, 4 components
TYPE Vector4
    x AS SINGLE ' Vector x component
    y AS SINGLE ' Vector y component
    z AS SINGLE ' Vector z component
    w AS SINGLE ' Vector w component
END TYPE
CONST SIZE_OF_VECTOR4~& = 16~&

' Matrix, 4x4 components, column major, OpenGL style, right-handed
TYPE Matrix
    m0 AS SINGLE ' Matrix first row (4 components)
    m4 AS SINGLE ' Matrix first row (4 components)
    m8 AS SINGLE ' Matrix first row (4 components)
    m12 AS SINGLE ' Matrix first row (4 components)
    m1 AS SINGLE ' Matrix second row (4 components)
    m5 AS SINGLE ' Matrix second row (4 components)
    m9 AS SINGLE ' Matrix second row (4 components)
    m13 AS SINGLE ' Matrix second row (4 components)
    m2 AS SINGLE ' Matrix third row (4 components)
    m6 AS SINGLE ' Matrix third row (4 components)
    m10 AS SINGLE ' Matrix third row (4 components)
    m14 AS SINGLE ' Matrix third row (4 components)
    m3 AS SINGLE ' Matrix fourth row (4 components)
    m7 AS SINGLE ' Matrix fourth row (4 components)
    m11 AS SINGLE ' Matrix fourth row (4 components)
    m15 AS SINGLE ' Matrix fourth row (4 components)
END TYPE
CONST SIZE_OF_MATRIX~& = 64~&

' Anything with leading underscores here are internal support routines and should not be called directly
DECLARE STATIC LIBRARY "support"
    ' Returns the milliseconds since program start
    FUNCTION GetTicks~&&
    ' Calculates and returns the Hertz when repeatedly called inside a loop
    FUNCTION GetHertz~&
    ' Sets count bytes in dst to ch
    SUB SetMemoryByte ALIAS "__SetMemoryByte" (BYVAL dst AS _UNSIGNED _OFFSET, BYVAL ch AS _UNSIGNED _BYTE, BYVAL count AS _UNSIGNED _OFFSET)
    ' Sets count integers in dst to ch
    SUB SetMemoryInteger ALIAS "__SetMemoryInteger" (BYVAL dst AS _UNSIGNED _OFFSET, BYVAL ch AS INTEGER, BYVAL count AS _UNSIGNED _OFFSET)
    ' Sets count longs in dst to ch
    SUB SetMemoryLong ALIAS "__SetMemoryLong" (BYVAL dst AS _UNSIGNED _OFFSET, BYVAL ch AS LONG, BYVAL count AS _UNSIGNED _OFFSET)
    ' Sets count singles in dst to ch
    SUB SetMemorySingle ALIAS "__SetMemorySingle" (BYVAL dst AS _UNSIGNED _OFFSET, BYVAL ch AS SINGLE, BYVAL count AS _UNSIGNED _OFFSET)
    ' Sets count integer64 in dst to ch
    SUB SetMemoryInteger64 ALIAS "__SetMemoryInteger64" (BYVAL dst AS _UNSIGNED _OFFSET, BYVAL ch AS _INTEGER64, BYVAL count AS _UNSIGNED _OFFSET)
    ' Sets count doubles in dst to ch
    SUB SetMemoryDouble ALIAS "__SetMemoryDouble" (BYVAL dst AS _UNSIGNED _OFFSET, BYVAL ch AS DOUBLE, BYVAL count AS _UNSIGNED _OFFSET)
    ' Copies count bytes from src to dst
    SUB CopyMemory ALIAS "__CopyMemory" (BYVAL dst AS _UNSIGNED _OFFSET, BYVAL src AS _UNSIGNED _OFFSET, BYVAL count AS _UNSIGNED _OFFSET)
    ' Copies count bytes from src to dst (overlap is allowed)
    SUB MoveMemory ALIAS "__MoveMemory" (BYVAL dst AS _UNSIGNED _OFFSET, BYVAL src AS _UNSIGNED _OFFSET, BYVAL count AS _UNSIGNED _OFFSET)
    ' Peeks a BYTE (8-bits) value at ptr + ofs
    FUNCTION PeekByte%% (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET)
    ' Poke a BYTE (8-bits) value at ptr + ofs
    SUB PokeByte (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET, BYVAL n AS _BYTE)
    ' Peek an INTEGER (16-bits) value at ptr + ofs
    FUNCTION PeekInteger% (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET)
    ' Poke an INTEGER (16-bits) value at ptr + ofs
    SUB PokeInteger (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET, BYVAL n AS INTEGER)
    ' Peek a LONG (32-bits) value at ptr + ofs
    FUNCTION PeekLong& (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET)
    ' Poke a LONG (32-bits) value at ptr + ofs
    SUB PokeLong (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET, BYVAL n AS LONG)
    ' Peek a INTEGER64 (64-bits) value at ptr + ofs
    FUNCTION PeekInteger64&& (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET)
    ' Poke a INTEGER64 (64-bits) value at ptr + ofs
    SUB PokeInteger64 (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET, BYVAL n AS _INTEGER64)
    ' Peek a SINGLE (32-bits) value at ptr + ofs
    FUNCTION PeekSingle! (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET)
    ' Poke a SINGLE (32-bits) value at ptr + ofs
    SUB PokeSingle (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET, BYVAL n AS SINGLE)
    ' Peek a DOUBLE (64-bits) value at ptr + ofs
    FUNCTION PeekDouble# (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET)
    ' Poke a DOUBLE (64-bits) value at ptr + ofs
    SUB PokeDouble (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET, BYVAL n AS DOUBLE)
    ' Peek an OFFSET (32/64-bits) value at ptr + ofs
    FUNCTION PeekOffset~%& (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET)
    ' Poke an OFFSET (32/64-bits) value at ptr + ofs
    SUB PokeOffset (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET, BYVAL n AS _UNSIGNED _OFFSET)
    ' Gets a UDT value from a pointer position ptr, offset by ofs. Same as typeVar = ptr[ofs]
    SUB PeekType (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET, BYVAL typeVar AS _UNSIGNED _OFFSET, BYVAL typeSize AS _UNSIGNED _OFFSET)
    ' Sets a UDT value to a pointer position ptr, offset by ofs. Same as ptr[ofs] = typeVar
    SUB PokeType (BYVAL ptr AS _UNSIGNED _OFFSET, BYVAL ofs AS _UNSIGNED _OFFSET, BYVAL typeVar AS _UNSIGNED _OFFSET, BYVAL typeSize AS _UNSIGNED _OFFSET)
    ' Sets a Vector2 variable
    SUB SetVector2 (v AS Vector2, BYVAL x AS SINGLE, BYVAL y AS SINGLE)
    ' Sets a Vector3 variable
    SUB SetVector3 (v AS Vector3, BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE)
    ' Sets a Vector4 variable
    SUB SetVector4 (v AS Vector4, BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE, BYVAL w AS SINGLE)
END DECLARE
