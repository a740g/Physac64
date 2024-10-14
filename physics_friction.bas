'********************************************************************************************
'
'   Physac - Physics friction
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

' Initialization
'--------------------------------------------------------------------------------------
CONST SCREENWIDTH& = 800&
CONST SCREENHEIGHT& = 450&
CONST LOGOTEXT = "Powered by"

SCREEN _NEWIMAGE(SCREENWIDTH, SCREENHEIGHT, 32)

DO: LOOP UNTIL _SCREENEXISTS

_TITLE "physac - Friction demo"
_PRINTMODE _KEEPBACKGROUND

' Physac logo drawing position
DIM AS LONG logoX: logoX = SCREENWIDTH - _PRINTWIDTH(LOGOTEXT) - 10
DIM AS LONG logoY: logoY = 15

DIM logo AS LONG: logo = _LOADIMAGE("physac.ico")

' Initialize physics and default physics bodies
InitPhysics TRUE

DIM vec AS Vector2, body AS PhysicsBody

' Create floor rectangle physics body (PhysicsBody)
SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT
DIM AS _UNSIGNED _OFFSET floor: floor = CreatePhysicsBodyRectangle(vec, SCREENWIDTH, 100, 10)
GetPhysicsBodyOffset body, floor ' read type from ptr
body.enabled = FALSE ' Disable body state to convert it to static (no dynamics, but collisions)
SetPhysicsBodyOffset floor, body ' write type to ptr

' Create wall rectangle physics body
SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT * 0.8!
DIM AS _UNSIGNED _OFFSET wall: wall = CreatePhysicsBodyRectangle(vec, 10, 80, 10)
GetPhysicsBodyOffset body, wall ' read type from ptr
body.enabled = FALSE ' Disable body state to convert it to static (no dynamics, but collisions)
SetPhysicsBodyOffset wall, body ' write type to ptr

' Create left ramp rectangle physics body
SetVector2 vec, 25, SCREENHEIGHT - 5
DIM AS _UNSIGNED _OFFSET rectLeft: rectLeft = CreatePhysicsBodyRectangle(vec, 250, 250, 10)
GetPhysicsBodyOffset body, rectLeft
body.enabled = FALSE
SetPhysicsBodyOffset rectLeft, body
SetPhysicsBodyRotation rectLeft, 30! * PHYSAC_DEG2RAD

' Create right ramp rectangle physics body
SetVector2 vec, SCREENWIDTH - 25, SCREENHEIGHT - 5
DIM AS _UNSIGNED _OFFSET rectRight: rectRight = CreatePhysicsBodyRectangle(vec, 250, 250, 10)
GetPhysicsBodyOffset body, rectRight
body.enabled = FALSE
SetPhysicsBodyOffset rectRight, body
SetPhysicsBodyRotation rectRight, 330! * PHYSAC_DEG2RAD

' Create dynamic physics bodies
SetVector2 vec, 35, SCREENHEIGHT * 0.6!
DIM AS _UNSIGNED _OFFSET bodyA: bodyA = CreatePhysicsBodyRectangle(vec, 40, 40, 10)
GetPhysicsBodyOffset body, bodyA
body.staticFriction = 0.1!
body.dynamicFriction = 0.1!
SetPhysicsBodyOffset bodyA, body
SetPhysicsBodyRotation bodyA, 30! * PHYSAC_DEG2RAD

SetVector2 vec, SCREENWIDTH - 35, SCREENHEIGHT * 0.6!
DIM AS _UNSIGNED _OFFSET bodyB: bodyB = CreatePhysicsBodyRectangle(vec, 40, 40, 10)
GetPhysicsBodyOffset body, bodyB
body.staticFriction = 1!
body.dynamicFriction = 1!
SetPhysicsBodyOffset bodyB, body
SetPhysicsBodyRotation bodyB, 330! * PHYSAC_DEG2RAD

' Main game loop
DO
    ' Update
    '----------------------------------------------------------------------------------
    ' Add any physics updates here if needed
    '----------------------------------------------------------------------------------

    ' Draw
    '----------------------------------------------------------------------------------
    CLS , Black

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
            PSET (vertexA.x, vertexA.y), Black

            FOR j = 1 TO vertexCount - 1
                DIM vertexB AS Vector2: GetPhysicsShapeVertex bodyPtr, j, vertexB
                LINE -(vertexB.x, vertexB.y), Green
            NEXT

            LINE -(vertexA.x, vertexA.y), Green
        END IF
    NEXT

    ' Draw FPS
    COLOR White
    _PRINTSTRING (SCREENWIDTH - 90, SCREENHEIGHT - 30), STR$(GetHertz) + " FPS"

    ' Draw UI elements
    _PRINTSTRING ((SCREENWIDTH - _PRINTWIDTH("Friction amount")) \ 2, 75), "Friction amount"
    GetPhysicsBodyOffset body, bodyA
    _PRINTSTRING (body.position.x - _PRINTWIDTH("0.1") \ 2, body.position.y - 7), "0.1"
    GetPhysicsBodyOffset body, bodyB
    _PRINTSTRING (body.position.x - _PRINTWIDTH("1") \ 2, body.position.y - 7), "1"

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
