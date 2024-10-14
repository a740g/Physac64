' reasings example - easings box anim

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

$COLOR:32

'$INCLUDE:'include/reasings.bi'

CONST screenWidth! = 800!
CONST screenHeight! = 450!

TYPE Rectangle
    x AS SINGLE ' Rectangle top-left corner position x
    y AS SINGLE ' Rectangle top-left corner position y
    w AS SINGLE ' Rectangle width
    h AS SINGLE ' Rectangle height
END TYPE

SCREEN _NEWIMAGE(screenWidth, screenHeight, 32)

DO: LOOP UNTIL _SCREENEXISTS

_TITLE "reasings example - easings box anim"
_PRINTMODE _KEEPBACKGROUND
'_DISPLAYORDER _HARDWARE , _GLRENDER , _HARDWARE1 , _SOFTWARE

DIM rec AS Rectangle: rec.x = screenWidth / 2.0!: rec.y = -100!: rec.w = 100!: rec.h = 100!
DIM rotation AS SINGLE
DIM alpha AS SINGLE: alpha = 1.0!
DIM vec AS Vector2
DIM AS LONG state, framesCounter, k

DO
    ' Update
    SELECT CASE state
        CASE 0 ' Move box down to center of screen
            framesCounter = framesCounter + 1

            ' NOTE: Remember that 3rd parameter of easing function refers to desired value variation, do not confuse it with expected final value!
            rec.y = EaseElasticOut(framesCounter, -100, screenHeight! / 2.0! + 100!, 120!)

            IF framesCounter >= 120 THEN
                framesCounter = 0
                state = 1
            END IF

        CASE 1 ' Scale box to an horizontal bar
            framesCounter = framesCounter + 1
            rec.h = EaseBounceOut(framesCounter, 100!, -90!, 120!)
            rec.w = EaseBounceOut(framesCounter, 100!, screenWidth, 120!)

            IF framesCounter >= 120 THEN
                framesCounter = 0
                state = 2
            END IF

        CASE 2 ' Rotate horizontal bar rectangle
            framesCounter = framesCounter + 1
            rotation = EaseQuadOut(framesCounter, 0.0!, 270.0!, 240!)

            IF framesCounter >= 240 THEN
                framesCounter = 0
                state = 3
            END IF

        CASE 3 ' Increase bar size to fill all screen
            framesCounter = framesCounter + 1
            rec.h = EaseCircOut(framesCounter, 10!, screenWidth, 120!)

            IF framesCounter >= 120 THEN
                framesCounter = 0
                state = 4
            END IF

        CASE 4 ' Fade out animation
            framesCounter = framesCounter + 1
            alpha = EaseSineOut(framesCounter, 1.0!, -1.0!, 160!)

            IF framesCounter >= 160 THEN
                framesCounter = 0
                state = 5
            END IF
    END SELECT

    ' Reset animation at any moment
    k = _KEYHIT

    IF k = 32 THEN
        rec.x = screenWidth / 2.0!: rec.y = -100!: rec.w = 100!: rec.h = 100!
        rotation = 0.0!
        alpha = 1.0!
        state = 0
        framesCounter = 0
    END IF

    ' Draw
    CLS , White
    SetVector2 vec, rec.w / 2!, rec.h / 2!
    DrawRectanglePro rec, vec, rotation, Fade(Black, alpha)

    COLOR Gray
    _PRINTSTRING (30, screenHeight - 30), "PRESS [SPACE] TO RESET BOX ANIMATION!"
    _PRINTSTRING (screenWidth - 90, screenHeight - 30), STR$(GetHertz) + " FPS"

    _DISPLAY

    _LIMIT 60
LOOP UNTIL k = 27

SYSTEM

SUB DrawRectanglePro (rec AS Rectangle, origin AS Vector2, rotation AS SINGLE, clr AS _UNSIGNED LONG)
    DIM rotationRad AS SINGLE: rotationRad = _D2R(rotation)
    DIM sinRotation AS SINGLE: sinRotation = SIN(rotationRad)
    DIM cosRotation AS SINGLE: cosRotation = COS(rotationRad)
    DIM topLeftX AS SINGLE: topLeftX = rec.x - origin.x * cosRotation + origin.y * sinRotation
    DIM topLeftY AS SINGLE: topLeftY = rec.y - origin.x * sinRotation - origin.y * cosRotation
    DIM topRightX AS SINGLE: topRightX = rec.x + (rec.w - origin.x) * cosRotation + origin.y * sinRotation
    DIM topRightY AS SINGLE: topRightY = rec.y + (rec.w - origin.x) * sinRotation - origin.y * cosRotation
    DIM bottomLeftX AS SINGLE: bottomLeftX = rec.x - origin.x * cosRotation - (rec.h - origin.y) * sinRotation
    DIM bottomLeftY AS SINGLE: bottomLeftY = rec.y - origin.x * sinRotation + (rec.h - origin.y) * cosRotation
    DIM bottomRightX AS SINGLE: bottomRightX = rec.x + (rec.w - origin.x) * cosRotation - (rec.h - origin.y) * sinRotation
    DIM bottomRightY AS SINGLE: bottomRightY = rec.y + (rec.w - origin.x) * sinRotation + (rec.h - origin.y) * cosRotation
    PSET (origin.x, origin.y), clr
    _MAPTRIANGLE _SEAMLESS(origin.x, origin.y)-(origin.x, origin.y)-(origin.x, origin.y)TO(topLeftX, topLeftY)-(bottomLeftX, bottomLeftY)-(topRightX, topRightY), , _SMOOTH
    _MAPTRIANGLE _SEAMLESS(origin.x, origin.y)-(origin.x, origin.y)-(origin.x, origin.y)TO(topRightX, topRightY)-(bottomLeftX, bottomLeftY)-(bottomRightX, bottomRightY), , _SMOOTH
END SUB

FUNCTION Fade~& (clr AS _UNSIGNED LONG, a AS SINGLE)
    DIM __a AS SINGLE: __a = a

    IF __a < 0! THEN
        __a = 0!
    ELSEIF __a > 1! THEN
        __a = 1!
    END IF

    Fade = _RGBA32(_RED32(clr), _GREEN32(clr), _BLUE32(clr), 255! * __a)
END FUNCTION
