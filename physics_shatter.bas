'********************************************************************************************
'
'   Physac - Body shatter
'
'   This example uses Physac (https://github.com/victorfisac/Physac)
'
'********************************************************************************************

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

$COLOR:32
$EXEICON:'./physac.ico'

' Include physac library
'$INCLUDE:'include/physac.bi'
'$INCLUDE:'include/raymath.bi'

' Constants
CONST SHATTER_FORCE! = 200!

' Initialization
'--------------------------------------------------------------------------------------
CONST SCREENWIDTH& = 800&
CONST SCREENHEIGHT& = 450&
CONST LOGOTEXT = "Powered by"

SCREEN _NEWIMAGE(SCREENWIDTH, SCREENHEIGHT, 32)

DO: LOOP UNTIL _SCREENEXISTS

_TITLE "physac - Shatter demo"
_PRINTMODE _KEEPBACKGROUND

' Physac logo drawing position
DIM AS LONG logoX: logoX = SCREENWIDTH - _PRINTWIDTH(LOGOTEXT) - 10
DIM AS LONG logoY: logoY = 15
DIM shatter AS _BYTE: shatter = FALSE

DIM logo AS LONG: logo = _LOADIMAGE("physac.ico")

SetRandomSeed TIMER

' Initialize physics and default physics bodies
InitPhysics TRUE
SetPhysicsGravity 0, 0

' Create random polygon physics body to shatter
DIM vec AS Vector2
SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT / 2!
DIM currentBody AS _UNSIGNED _OFFSET: currentBody = CreatePhysicsBodyPolygon(vec, GetRandomValue(80, 200), GetRandomValue(3, 8), 10)

DIM i AS LONG

' Main game loop
DO
    ' Update
    '----------------------------------------------------------------------------------
    WHILE _MOUSEINPUT: WEND

    IF NOT shatter AND _MOUSEBUTTON(1) THEN
        shatter = TRUE

        DIM count AS LONG: count = GetPhysicsBodiesCount
        FOR i = count - 1 TO 0 STEP -1
            currentBody = GetPhysicsBody(i)

            IF currentBody <> NULL THEN
                DIM mousePos AS Vector2: SetVector2 mousePos, _MOUSEX, _MOUSEY
                PhysicsShatter currentBody, mousePos, SHATTER_FORCE
            END IF
        NEXT
    END IF
    '----------------------------------------------------------------------------------

    ' Draw
    '----------------------------------------------------------------------------------
    CLS , Black

    ' Draw created physics bodies
    DIM bodiesCount AS LONG: bodiesCount = GetPhysicsBodiesCount

    FOR i = 0 TO bodiesCount - 1
        currentBody = GetPhysicsBody(i)

        IF currentBody <> NULL THEN
            DIM vertexCount AS LONG: vertexCount = GetPhysicsShapeVerticesCount(i)

            ' Get physics bodies shape vertices to draw lines
            DIM j AS LONG
            DIM vertexA AS Vector2: GetPhysicsShapeVertex currentBody, 0, vertexA
            PSET (vertexA.x, vertexA.y), White

            FOR j = 1 TO vertexCount - 1
                DIM vertexB AS Vector2: GetPhysicsShapeVertex currentBody, j, vertexB
                LINE -(vertexB.x, vertexB.y), Green
            NEXT

            LINE -(vertexA.x, vertexA.y), Green
        END IF
    NEXT

    ' Draw FPS
    COLOR White
    _PRINTSTRING (SCREENWIDTH - 90, SCREENHEIGHT - 30), STR$(GetHertz) + " FPS"

    ' Draw UI elements
    _PRINTSTRING (10, 10), "Left mouse button in polygon area to shatter body"
    _PUTIMAGE (SCREENWIDTH - 100, 0)-(SCREENWIDTH - 1, 99), logo
    COLOR Black
    _PRINTSTRING (logoX, logoY), LOGOTEXT

    _DISPLAY

    _LIMIT 60
    '----------------------------------------------------------------------------------
LOOP UNTIL _KEYHIT = 27

' De-Initialization
'--------------------------------------------------------------------------------------
ClosePhysics
'--------------------------------------------------------------------------------------

SYSTEM


SUB GetPtrBody (body AS PhysicsBody, bodyPtr AS _UNSIGNED _OFFSET)
    $CHECKING:OFF
    PeekType bodyPtr, 0, _OFFSET(body), LEN(body)
    $CHECKING:ON
END SUB

SUB SetPtrBody (bodyPtr AS _UNSIGNED _OFFSET, body AS PhysicsBody)
    $CHECKING:OFF
    PokeType bodyPtr, 0, _OFFSET(body), LEN(body)
    $CHECKING:ON
END SUB
