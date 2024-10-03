'********************************************************************************************
'
'   Physac - Physics restitution
'
'   This example uses Physac (https://github.com/victorfisac/Physac)
'
'********************************************************************************************

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

$COLOR:32
$EXEICON: './physac.ico'

' Include physac library
'$INCLUDE: 'physac.bi'

' Initialization
'--------------------------------------------------------------------------------------
CONST FALSE%% = 0%%, TRUE%% = NOT FALSE
CONST NULL~& = 0~&
CONST SCREENWIDTH& = 800&
CONST SCREENHEIGHT& = 450&
CONST LOGOTEXT = "Physac"

SCREEN _NEWIMAGE(SCREENWIDTH, SCREENHEIGHT, 32)

DO: LOOP UNTIL _SCREENEXISTS

_TITLE "physac - Restitution demo"
_PRINTMODE _KEEPBACKGROUND

' Physac logo drawing position
DIM AS LONG logoX: logoX = SCREENWIDTH - _PRINTWIDTH(LOGOTEXT) - 10
DIM AS LONG logoY: logoY = 15

DIM logo AS LONG: logo = _LOADIMAGE("physac.ico")

' Initialize physics and default physics bodies
InitPhysics

DIM vec AS Vector2, body AS PhysicsBody

' Create floor rectangle physics body
SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT
DIM AS _UNSIGNED _OFFSET floor: floor = CreatePhysicsBodyRectangle(vec, SCREENWIDTH, 100, 10)
GetPtrBody body, floor ' read type from ptr
body.enabled = FALSE ' Disable body state to convert it to static (no dynamics, but collisions)
body.restitution = 1
SetPtrBody floor, body

' Create circles physics bodies
SetVector2 vec, SCREENWIDTH * 0.25!, SCREENHEIGHT / 2!
DIM AS _UNSIGNED _OFFSET circleA: circleA = CreatePhysicsBodyCircle(vec, 30, 10)
GetPtrBody body, circleA
body.restitution = 0.0
SetPtrBody circleA, body

SetVector2 vec, SCREENWIDTH * 0.5!, SCREENHEIGHT / 2!
DIM AS _UNSIGNED _OFFSET circleB: circleB = CreatePhysicsBodyCircle(vec, 30, 10)
GetPtrBody body, circleB
body.restitution = 0.5
SetPtrBody circleB, body

SetVector2 vec, SCREENWIDTH * 0.75!, SCREENHEIGHT / 2!
DIM AS _UNSIGNED _OFFSET circleC: circleC = CreatePhysicsBodyCircle(vec, 30, 10)
GetPtrBody body, circleC
body.restitution = 0.9
SetPtrBody circleC, body

LIMIT 60

' Main game loop
DO
    ' Update
    '----------------------------------------------------------------------------------
    ' Add any physics updates here if needed
    '----------------------------------------------------------------------------------

    ' Draw
    '----------------------------------------------------------------------------------
    CLS , BLACK

    ' Draw FPS
    COLOR WHITE
    _PRINTSTRING (SCREENWIDTH - 90, SCREENHEIGHT - 30), STR$(GetHertz) + " FPS"

    ' Draw created physics bodies
    DIM AS LONG bodiesCount: bodiesCount = GetPhysicsBodiesCount
    DIM i AS LONG
    FOR i = 0 TO bodiesCount - 1
        DIM bodyPtr AS _UNSIGNED _OFFSET: bodyPtr = GetPhysicsBody(i)

        IF bodyPtr <> NULL THEN
            DIM vertexCount AS LONG: vertexCount = GetPhysicsShapeVerticesCount(i)

            ' Get physics bodies shape vertices to draw lines
            DIM j AS LONG
            DIM vertexA AS Vector2: GetPhysicsShapeVertex bodyPtr, 0, vertexA
            PSET (vertexA.x, vertexA.y), WHITE

            FOR j = 1 TO vertexCount - 1
                DIM vertexB AS Vector2: GetPhysicsShapeVertex bodyPtr, j, vertexB
                LINE -(vertexB.x, vertexB.y), GREEN
            NEXT

            LINE -(vertexA.x, vertexA.y), GREEN
        END IF
    NEXT

    ' Draw UI elements
    _PRINTSTRING ((SCREENWIDTH - _PRINTWIDTH("Restitution amount")) \ 2, 75), "Restitution amount"
    _PRINTSTRING (circleA->position.x - _PRINTWIDTH("0%") \ 2, circleA->position.y - 7), "0%"
    _PRINTSTRING (circleB->position.x - _PRINTWIDTH("50%") \ 2, circleB->position.y - 7), "50%"
    _PRINTSTRING (circleC->position.x - _PRINTWIDTH("90%") \ 2, circleC->position.y - 7), "90%"

    _PUTIMAGE (SCREENWIDTH - 100, 0)-(SCREENWIDTH - 1, 99), logo
    COLOR BLACK
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

FUNCTION GetHertz~&
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
END FUNCTION