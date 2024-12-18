'********************************************************************************************
'
'   Physac - Physics movement
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

' Constants
CONST VELOCITY! = 0.5!

' Initialization
'--------------------------------------------------------------------------------------
CONST SCREENWIDTH& = 800&
CONST SCREENHEIGHT& = 450&
CONST LOGOTEXT = "Powered by"

SCREEN _NEWIMAGE(SCREENWIDTH, SCREENHEIGHT, 32)

DO: LOOP UNTIL _SCREENEXISTS

_TITLE "physac - Body controller demo"
_PRINTMODE _KEEPBACKGROUND

' Physac logo drawing position
DIM AS LONG logoX: logoX = SCREENWIDTH - _PRINTWIDTH(LOGOTEXT) - 10
DIM AS LONG logoY: logoY = 15

DIM logo AS LONG: logo = _LOADIMAGE("physac.ico")

' Initialize physics and default physics bodies
InitPhysics _TRUE

DIM vec AS Vector2, body AS PhysicsBody

' Create floor and wall rectangle physics bodies
SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT
DIM AS _UNSIGNED _OFFSET floor: floor = CreatePhysicsBodyRectangle(vec, SCREENWIDTH, 100, 10)

SetVector2 vec, SCREENWIDTH * 0.25!, SCREENHEIGHT * 0.6!
DIM AS _UNSIGNED _OFFSET platformLeft: platformLeft = CreatePhysicsBodyRectangle(vec, SCREENWIDTH * 0.25!, 10, 10)

SetVector2 vec, SCREENWIDTH * 0.75!, SCREENHEIGHT * 0.6!
DIM AS _UNSIGNED _OFFSET platformRight: platformRight = CreatePhysicsBodyRectangle(vec, SCREENWIDTH * 0.25!, 10, 10)

SetVector2 vec, -5, SCREENHEIGHT / 2!
DIM AS _UNSIGNED _OFFSET wallLeft: wallLeft = CreatePhysicsBodyRectangle(vec, 10, SCREENHEIGHT, 10)

SetVector2 vec, SCREENWIDTH + 4, SCREENHEIGHT / 2!
DIM AS _UNSIGNED _OFFSET wallRight: wallRight = CreatePhysicsBodyRectangle(vec, 10, SCREENHEIGHT, 10)

' Disable dynamics to floor and walls physics bodies
GetPhysicsBodyOffset body, floor: body.enabled = _FALSE: SetPhysicsBodyOffset floor, body
GetPhysicsBodyOffset body, platformLeft: body.enabled = _FALSE: SetPhysicsBodyOffset platformLeft, body
GetPhysicsBodyOffset body, platformRight: body.enabled = _FALSE: SetPhysicsBodyOffset platformRight, body
GetPhysicsBodyOffset body, wallLeft: body.enabled = _FALSE: SetPhysicsBodyOffset wallLeft, body
GetPhysicsBodyOffset body, wallRight: body.enabled = _FALSE: SetPhysicsBodyOffset wallRight, body

' Create movement physics body
SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT / 2!
DIM AS _UNSIGNED _OFFSET playerBody: playerBody = CreatePhysicsBodyRectangle(vec, 50, 50, 1)
GetPhysicsBodyOffset body, playerBody
body.freezeOrient = _TRUE ' Constrain body rotation to avoid collision torque
SetPhysicsBodyOffset playerBody, body

' Main game loop
DO
    ' Update
    '----------------------------------------------------------------------------------
    GetPhysicsBodyOffset body, playerBody

    ' Horizontal movement input
    IF _KEYDOWN(_KEY_RIGHT) THEN body.velocity.x = VELOCITY ' Right arrow key
    IF _KEYDOWN(_KEY_LEFT) THEN body.velocity.x = -VELOCITY ' Left arrow key

    ' Vertical movement input checking if player physics body is grounded
    IF _KEYDOWN(_KEY_UP) AND body.isGrounded THEN body.velocity.y = -VELOCITY * 4 ' Up arrow key

    SetPhysicsBodyOffset playerBody, body
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
    _PRINTSTRING (10, 10), "Use 'ARROWS' to move player"

    _PUTIMAGE (SCREENWIDTH - 100, 0)-(SCREENWIDTH - 1, 99), logo
    COLOR Black
    _PRINTSTRING (logoX, logoY), LOGOTEXT

    _DISPLAY

    _LIMIT 60
    '----------------------------------------------------------------------------------
LOOP UNTIL _KEYHIT = _KEY_ESC

' De-Initialization
'--------------------------------------------------------------------------------------
ClosePhysics
'--------------------------------------------------------------------------------------

SYSTEM
