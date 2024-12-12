'********************************************************************************************
'
'   Physac - Physics demo
'
'   This example uses Physac (https://github.com/victorfisac/Physac)
'
'********************************************************************************************

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

$COLOR:32
$EXEICON:'./physac.ico'

'$INCLUDE:'include/physac.bi'
'$INCLUDE:'include/raymath.bi'

' Set this to true to make physac run on it's own thread
$LET THREADED_DEMO = FALSE

' Initialization
'--------------------------------------------------------------------------------------
CONST SCREENWIDTH& = 800&
CONST SCREENHEIGHT& = 450&
CONST LOGOTEXT = "Powered by"

SCREEN _NEWIMAGE(SCREENWIDTH, SCREENHEIGHT, 32)

DO: LOOP UNTIL _SCREENEXISTS

$IF THREADED_DEMO = TRUE THEN
    _TITLE "physac demo (threaded)"
$ELSE
    _TITLE "physac demo"
$END IF

_PRINTMODE _KEEPBACKGROUND

' Physac logo drawing position
DIM AS LONG logoX: logoX = SCREENWIDTH - _PRINTWIDTH(LOGOTEXT) - 10
DIM AS LONG logoY: logoY = 15

DIM logo AS LONG: logo = _LOADIMAGE("physac.ico")

SetRandomSeed TIMER

' Initialize physics and default physics bodies
$IF THREADED_DEMO = TRUE THEN
    InitPhysics _TRUE
$ELSE
    InitPhysics _FALSE
$END IF

DIM vec AS Vector2, body AS PhysicsBody, bodyPtr AS _UNSIGNED _OFFSET

' Create floor rectangle physics body (PhysicsBody)
SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT
DIM AS _UNSIGNED _OFFSET floor: floor = CreatePhysicsBodyRectangle(vec, 500, 100, 10)
GetPhysicsBodyOffset body, floor ' read type from ptr
body.enabled = _FALSE ' Disable body state to convert it to static (no dynamics, but collisions)
SetPhysicsBodyOffset floor, body ' write type to ptr

' Create obstacle circle physics body (PhysicsBody)
SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT / 2!
DIM AS _UNSIGNED _OFFSET circl: circl = CreatePhysicsBodyCircle(vec, 45, 10)
GetPhysicsBodyOffset body, circl ' read type from ptr
body.enabled = _FALSE ' Disable body state to convert it to static (no dynamics, but collisions)
SetPhysicsBodyOffset circl, body ' write type to ptr
'--------------------------------------------------------------------------------------

DIM k AS LONG

' Main game loop
DO
    ' Update
    '----------------------------------------------------------------------------------
    $IF THREADED_DEMO = FALSE THEN
        RunPhysicsStep
    $END IF

    k = _KEYHIT

    IF k = 114 _ORELSE k = 82 THEN ' Reset physics system
        ClosePhysics
        $IF THREADED_DEMO = TRUE THEN
            InitPhysics _TRUE
        $ELSE
            InitPhysics _FALSE
        $END IF

        SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT
        floor = CreatePhysicsBodyRectangle(vec, 500, 100, 10)
        GetPhysicsBodyOffset body, floor ' read type from ptr
        body.enabled = _FALSE ' Disable body state to convert it to static (no dynamics, but collisions)
        SetPhysicsBodyOffset floor, body ' write type to ptr

        SetVector2 vec, SCREENWIDTH / 2!, SCREENHEIGHT / 2!
        circl = CreatePhysicsBodyCircle(vec, 45, 10)
        GetPhysicsBodyOffset body, circl ' read type from ptr
        body.enabled = _FALSE ' Disable body state to convert it to static (no dynamics, but collisions)
        SetPhysicsBodyOffset circl, body ' write type to ptr
    END IF

    WHILE _MOUSEINPUT: WEND

    ' Physics body creation inputs
    IF _MOUSEBUTTON(1) THEN
        SetVector2 vec, _MOUSEX, _MOUSEY
        bodyPtr = CreatePhysicsBodyPolygon(vec, GetRandomValue(20, 80), GetRandomValue(3, 8), 10)
        'bodyPtr = CreatePhysicsBodyRectangle(vec, GetRandomValue(20, 80), GetRandomValue(20, 80), 10)
    ELSEIF _MOUSEBUTTON(2) THEN
        SetVector2 vec, _MOUSEX, _MOUSEY
        bodyPtr = CreatePhysicsBodyCircle(vec, GetRandomValue(10, 45), 10)
    END IF

    ' Destroy falling physics bodies
    DIM AS LONG bodiesCount: bodiesCount = GetPhysicsBodiesCount

    DIM i AS LONG: FOR i = bodiesCount - 1 TO 0 STEP -1
        bodyPtr = GetPhysicsBody(i)
        IF bodyPtr <> NULL THEN
            GetPhysicsBodyOffset body, bodyPtr ' read type from ptr
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
LOOP UNTIL k = _KEY_ESC

' De-Initialization
'--------------------------------------------------------------------------------------
ClosePhysics ' Unitialize physics
'--------------------------------------------------------------------------------------

SYSTEM
