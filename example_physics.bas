'********************************************************************************************
'
'   physac demo
'
'   This example uses physac 1.1 (https://github.com/raysan5/raylib/blob/master/src/physac.h)
'
'********************************************************************************************

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

$COLOR:32
$EXEICON:'./physac.ico'

'$INCLUDE:'include/physac.bi'

' Initialization
'--------------------------------------------------------------------------------------
CONST FALSE%% = 0%%, TRUE%% = NOT FALSE
CONST NULL~& = 0~&
CONST SCREENWIDTH& = 800&
CONST SCREENHEIGHT& = 450&
CONST LOGOTEXT = "Powered by"

SCREEN _NEWIMAGE(SCREENWIDTH, SCREENHEIGHT, 32)

DO: LOOP UNTIL _SCREENEXISTS

_TITLE "physac demo"
_PRINTMODE _KEEPBACKGROUND

' Physac logo drawing position
DIM AS LONG logoX: logoX = SCREENWIDTH - _PRINTWIDTH(LOGOTEXT) - 10
DIM AS LONG logoY: logoY = 15

DIM logo AS LONG: logo = _LOADIMAGE("physac.ico")

' Initialize physics and default physics bodies
InitPhysics

DIM vec AS Vector2, body AS PhysicsBody, bodyPtr AS _UNSIGNED _OFFSET

' Create floor rectangle physics body (PhysicsBody)
SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT
DIM AS _UNSIGNED _OFFSET floor: floor = CreatePhysicsBodyRectangle(vec, 500, 100, 10)
GetPtrBody body, floor ' read type from ptr
body.enabled = FALSE ' Disable body state to convert it to static (no dynamics, but collisions)
SetPtrBody floor, body ' write type to ptr

' Create obstacle circle physics body (PhysicsBody)
SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT / 2!
DIM AS _UNSIGNED _OFFSET circl: circl = CreatePhysicsBodyCircle(vec, 45, 10)
GetPtrBody body, circl ' read type from ptr
body.enabled = FALSE ' Disable body state to convert it to static (no dynamics, but collisions)
SetPtrBody circl, body ' write type to ptr
'--------------------------------------------------------------------------------------

DIM k AS LONG

' Main game loop
DO
    ' Update
    '----------------------------------------------------------------------------------
    UpdatePhysics ' Update physics system

    k = _KEYHIT

    IF k = 114 _ORELSE k = 82 THEN ' Reset physics system
        ResetPhysics

        SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT
        floor = CreatePhysicsBodyRectangle(vec, 500, 100, 10)
        GetPtrBody body, floor ' read type from ptr
        body.enabled = FALSE ' Disable body state to convert it to static (no dynamics, but collisions)
        SetPtrBody floor, body ' write type to ptr

        SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT / 2!
        circl = CreatePhysicsBodyCircle(vec, 45, 10)
        GetPtrBody body, circl ' read type from ptr
        body.enabled = FALSE ' Disable body state to convert it to static (no dynamics, but collisions)
        SetPtrBody circl, body ' write type to ptr
    END IF

    WHILE _MOUSEINPUT: WEND

    ' Physics body creation inputs
    IF _MOUSEBUTTON(1) THEN
        SetVector2 vec, _MOUSEX, _MOUSEY
        bodyPtr = CreatePhysicsBodyPolygon(vec, GetRandomValue(20, 80), GetRandomValue(3, 8), 10)
    ELSEIF _MOUSEBUTTON(2) THEN
        SetVector2 vec, _MOUSEX, _MOUSEY
        bodyPtr = CreatePhysicsBodyCircle(vec, GetRandomValue(10, 45), 10)
    END IF

    ' Destroy falling physics bodies
    DIM AS LONG bodiesCount: bodiesCount = GetPhysicsBodiesCount

    DIM i AS LONG: FOR i = bodiesCount - 1 TO 0 STEP -1
        bodyPtr = GetPhysicsBody(i)
        IF bodyPtr <> NULL THEN
            GetPtrBody body, bodyPtr ' read type from ptr
            IF body.position.y > SCREENHEIGHT * 2 THEN DestroyPhysicsBody bodyPtr
        END IF
    NEXT
    '----------------------------------------------------------------------------------

    ' Draw
    '----------------------------------------------------------------------------------

    CLS , Black

    ' Draw created physics bodies
    bodiesCount = GetPhysicsBodiesCount
    i = 0
    WHILE i < bodiesCount
        bodyPtr = GetPhysicsBody(i)

        IF bodyPtr <> NULL THEN
            DIM AS LONG vertexCount: vertexCount = GetPhysicsShapeVerticesCount(i)

            ' Get physics bodies shape vertices to draw lines
            DIM j AS LONG: j = 0

            ' Note: GetPhysicsShapeVertex() already calculates rotation transformations
            DIM AS Vector2 vertexA: GetPhysicsShapeVertex bodyPtr, j, vertexA
            PSET (vertexA.x, vertexA.y), Black

            WHILE j < vertexCount
                IF j THEN
                    DIM AS Vector2 vertexB: GetPhysicsShapeVertex bodyPtr, j, vertexB
                    LINE -(vertexB.x, vertexB.y), Green
                END IF

                j = j + 1
            WEND

            LINE -(vertexA.x, vertexA.y), Green
        END IF

        i = i + 1
    WEND

    COLOR White
    _PRINTSTRING (SCREENWIDTH - 90, SCREENHEIGHT - 30), STR$(GetHertz) + " FPS"
    _PRINTSTRING (10, 10), "Left mouse button to create a polygon"
    _PRINTSTRING (10, 25), "Right mouse button to create a circle"
    _PRINTSTRING (10, 40), "Press 'R' to reset example"

    _PUTIMAGE (SCREENWIDTH - 100, 0)-(SCREENWIDTH - 1, 99), logo
    COLOR Black
    _PRINTSTRING (logoX, logoY), LOGOTEXT

    _DISPLAY

    _LIMIT 60
    '----------------------------------------------------------------------------------
LOOP UNTIL k = 27

' De-Initialization
'--------------------------------------------------------------------------------------
ClosePhysics ' Unitialize physics
'--------------------------------------------------------------------------------------

SYSTEM


SUB GetPtrBody (body AS PhysicsBody, bodyPtr AS _UNSIGNED _OFFSET)
    $CHECKING:OFF
    PeekType bodyPtr, 0, _OFFSET(body), LEN(body) ' read type from ptr
    $CHECKING:ON
END SUB


SUB SetPtrBody (bodyPtr AS _UNSIGNED _OFFSET, body AS PhysicsBody)
    $CHECKING:OFF
    PokeType bodyPtr, 0, _OFFSET(body), LEN(body) ' write type to ptr
    $CHECKING:ON
END SUB


FUNCTION GetRandomValue& (lo AS LONG, hi AS LONG)
    $CHECKING:OFF
    GetRandomValue = lo + RND * (hi - lo)
    $CHECKING:ON
END FUNCTION


FUNCTION GetHertz~&
    $CHECKING:OFF
    STATIC AS _UNSIGNED LONG eventCounter, frequency
    STATIC lastTick AS _UNSIGNED _INTEGER64

    DIM currentTick AS _UNSIGNED _INTEGER64: currentTick = GetTicks

    IF currentTick >= lastTick + 1000 THEN
        lastTick = currentTick
        frequency = eventCounter
        eventCounter = 0
    END IF

    eventCounter = eventCounter + 1

    GetHertz = frequency
    $CHECKING:ON
END FUNCTION
