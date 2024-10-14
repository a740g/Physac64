'======================================================================================================================================================================================================
' Physics Tower Game
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' Programmed by RokCoder
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' Experimenting with a tower building concept using the Physac library
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' V0.1 - 03/10/2024 - First release
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' https://github.com/rokcoder-qb64/physics-tower-game
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' https://www.rokcoder.com
' https://www.github.com/rokcoder
' https://www.facebook.com/rokcoder
' https://www.youtube.com/rokcoder
'======================================================================================================================================================================================================
' TODO
' This didn't even pass preliminary testing stages due to physac library
' - It doesn't handle non-regular polygons well so the initial concept of using various rectangle sizes was a no-go
' - Bricks never really settle
' - And lots more...
'======================================================================================================================================================================================================

$VERSIONINFO:CompanyName='RokSoft'
$VERSIONINFO:FileDescription='QB64 Physics Tower Game'
$VERSIONINFO:InternalName='physics-tower-game.exe'
$VERSIONINFO:ProductName='Physics Tower Game'
$VERSIONINFO:OriginalFilename='physics-tower-game.exe'
$VERSIONINFO:LegalCopyright='(c)2024 RokSoft'
$VERSIONINFO:FILEVERSION#=0,1,0,0
$VERSIONINFO:PRODUCTVERSION#=0,1,0,0

'======================================================================================================================================================================================================

OPTION _EXPLICIT
OPTION _EXPLICITARRAY

'======================================================================================================================================================================================================

'$INCLUDE:'include/physac.bi'

'======================================================================================================================================================================================================

CONST FALSE = 0
CONST TRUE = NOT FALSE

CONST USE_RECTANGLES = TRUE ' Unfortunately Physac doesn't handle rectangles very well so I'm defaulting to using squares

CONST SCREEN_WIDTH = 480 ' Resolution of the unscaled game area
CONST SCREEN_HEIGHT = 360

CONST VERSION = 1

CONST STATE_NEW_GAME = 0 ' Different game states used in the game
CONST STATE_GAME_OVER = 1
CONST STATE_WAIT_TO_START = 2
CONST STATE_WAIT_TO_DROP_SECTION = 3
CONST STATE_PLAY_TURN = 4
CONST STATE_DROP_SECTION = 5
CONST STATE_WAIT_TO_LAND = 6

CONST START_BUTTON_WIDTH = 231
CONST START_BUTTON_HEIGHT = 87
CONST START_BUTTON_Y = 360 - 220

CONST BRICK_SCALE = 0.15
CONST BRICK_WIDTH = 80 * BRICK_SCALE
CONST BRICK_HEIGHT = 40 * BRICK_SCALE
CONST MAX_SECTION_SIZE = 4

CONST MAX_SECTIONS = 50

'======================================================================================================================================================================================================

TYPE GAME
    fps AS INTEGER
    score AS LONG
    hiscore AS LONG
    sectionCount AS INTEGER
    floorPtr AS _UNSIGNED _OFFSET
END TYPE

TYPE STATE
    state AS INTEGER
    substate AS INTEGER
    counter AS INTEGER
END TYPE

TYPE GLDATA
    initialised AS INTEGER
    executing AS INTEGER
    background AS LONG
    normal AS LONG
    brick AS LONG
END TYPE

TYPE SFX
    handle AS LONG
    oneShot AS INTEGER
    looping AS INTEGER
END TYPE

TYPE SECTION
    bodyPtr AS _UNSIGNED _OFFSET
    width AS INTEGER
    height AS INTEGER
END TYPE

'======================================================================================================================================================================================================

' Not a fan of globals but this is QB64 so what can you do?

DIM SHARED state AS STATE
DIM SHARED glData AS GLDATA
DIM SHARED virtualScreen& ' Handle to virtual screen which is drawn to and then blitted/stretched to the main display
DIM SHARED game AS GAME ' General game data
DIM SHARED sfx(3) AS SFX
DIM SHARED quit AS INTEGER
DIM SHARED exitProgram AS INTEGER
DIM SHARED section(MAX_SECTIONS) AS SECTION

'===== Game loop ======================================================================================================================================================================================

PrepareGame
DO: _LIMIT (game.fps%)
    UpdateFrame
    _PUTIMAGE , virtualScreen&, 0, (0, 0)-(SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1) ' Copy from virtual screen to target screen which allows for automatic upscaling
    _DISPLAY
    IF exitProgram THEN _FREEIMAGE virtualScreen&: ClosePhysics: SYSTEM
LOOP

'===== Error handling =================================================================================================================================================================================

fileReadError:
InitialiseHiscore
RESUME NEXT

fileWriteError:
ON ERROR GOTO 0
RESUME NEXT

'===== One time initialisations =======================================================================================================================================================================

SUB PrepareGame
    DIM m%
    quit = _EXIT
    exitProgram = FALSE
    _DISPLAYORDER _SOFTWARE
    m% = INT((_DESKTOPHEIGHT - 80) / SCREEN_HEIGHT) ' Ratio for how much we can scale the game up (integer values) whilst still fitting vertically on the screen
    virtualScreen& = _NEWIMAGE(SCREEN_WIDTH, SCREEN_HEIGHT, 32) ' This is the same resolution as the original arcade game
    SCREEN _NEWIMAGE(SCREEN_WIDTH * m%, SCREEN_HEIGHT * m%, 32) ' The screen we ultimately display is the defined size multiplied by a ratio as determined above
    DO: _DELAY 0.5: LOOP UNTIL _SCREENEXISTS
    _SCREENMOVE _MIDDLE
    $RESIZE:STRETCH
    _ALLOWFULLSCREEN _SQUAREPIXELS , _SMOOTH
    _TITLE "Poly Blaster"
    'TODO    $ExeIcon:'./assets/physics-tower-game.ico'
    _DEST virtualScreen&
    game.fps% = 30 ' 30 frames per second
    RANDOMIZE TIMER
    glData.executing = TRUE
    _DISPLAYORDER _HARDWARE , _GLRENDER , _SOFTWARE
    LoadAllSFX
    ReadHiscore ' Read high scores from file (or create them if the file doesn't exist or can't be read)
    SetGameState STATE_WAIT_TO_START ' Set the game state in its initial state
    InitPhysics TRUE
    SetPhysicsGravity 0, -9.81 / game.fps% ' This works much better with the fps taken into account (but only for regular polygons)
END SUB

'===== High score code ================================================================================================================================================================================

' ReadHiscores
' - Read high scores from local storage (with fallback to initialising data if there's an error while reading the file for any reason)
SUB ReadHiscore
    DIM handle&, s&, v%
    ON ERROR GOTO fileReadError
    IF NOT _FILEEXISTS("scores.txt") THEN InitialiseHiscore: EXIT SUB
    handle& = FREEFILE
    OPEN "scores.txt" FOR INPUT AS #handle&
    INPUT #handle&, s&
    IF EOF(handle&) THEN
        ' This was a high score file containing only hard level high score (before a version number was introduced)
        game.hiscore& = 0
    ELSE
        v% = s&
        INPUT #handle&, game.hiscore&
    END IF
    CLOSE #handle&
    ON ERROR GOTO 0
END SUB

' InitialiseHiscores
' - Set up default high score values
SUB InitialiseHiscore
    game.hiscore& = 0
END SUB

' WriteHiscores
' - Store high scores to local storage (trapping any errors that might occur - write-protected, out of space, etc)
SUB WriteHiscore
    DIM handle&
    ON ERROR GOTO fileWriteError
    handle& = FREEFILE
    OPEN "scores.txt" FOR OUTPUT AS #handle&
    PRINT #handle&, VERSION
    PRINT #handle&, game.hiscore&
    CLOSE #handle&
    ON ERROR GOTO 0
END SUB

'===== Simple asset loading functions =================================================================================================================================================================

SUB AssetError (fname$)
    SCREEN 0
    PRINT "Unable to load "; fname$
    PRINT "Please make sure EXE is in same folder as poly-blaster.bas"
    PRINT "(Set Run/Output EXE to Source Folder option in the IDE before compiling)"
    END
END SUB

FUNCTION LoadImage& (fname$)
    DIM asset&, f$
    f$ = "./assets/" + fname$ + ".png"
    asset& = _LOADIMAGE(f$, 32)
    IF asset& = -1 THEN AssetError (f$)
    LoadImage& = asset&
END FUNCTION

FUNCTION SndOpen& (fname$)
    DIM asset&, f$
    f$ = "./assets/" + fname$
    asset& = _SNDOPEN(f$)
    IF asset& = -1 THEN AssetError (f$)
    SndOpen& = asset&
END FUNCTION

'===== Sound manager ==================================================================================================================================================================================

SUB LoadSfx (sfx%, sfx$, oneShot%)
    sfx(sfx%).handle& = _SNDOPEN("assets/" + sfx$ + ".ogg")
    IF sfx(sfx%).handle& = 0 THEN AssetError sfx$
    sfx(sfx%).oneShot% = oneShot%
END SUB

SUB LoadAllSFX
END SUB

SUB PlaySfx (sfx%)
    IF sfx(sfx%).oneShot% THEN
        _SNDPLAY sfx(sfx%).handle&
    ELSE
        _SNDPLAYCOPY sfx(sfx%).handle&
    END IF
END SUB

SUB PlaySfxLooping (sfx%)
    IF sfx(sfx%).oneShot% THEN
        _SNDLOOP sfx(sfx%).handle&
    END IF
END SUB

SUB StopSfx (sfx%)
    IF sfx(sfx%).oneShot% THEN _SNDSTOP sfx(sfx%).handle&
END SUB

FUNCTION IsPlayingSfx% (sfx%)
    IsPlayingSfx% = _SNDPLAYING(sfx(sfx%).handle&)
END FUNCTION

SUB SetGameState (s%)
    state.state% = s%
    state.substate% = 0
    state.counter% = 0
    IF s% = STATE_NEW_GAME THEN InitialiseGame: SetGameState STATE_PLAY_TURN
    IF s% = STATE_PLAY_TURN THEN ChooseSectionToDrop: SetGameState STATE_WAIT_TO_DROP_SECTION
    IF s% = STATE_GAME_OVER THEN WriteHiscore
END SUB

'======================================================================================================================================================================================================

SUB UpdateFrame
    DO WHILE _MOUSEINPUT: LOOP
    IF state.state% = STATE_WAIT_TO_START THEN WaitToStart
    IF state.state% = STATE_WAIT_TO_DROP_SECTION THEN WaitToDropSection
    IF state.state% = STATE_WAIT_TO_LAND THEN WaitToLand
    state.counter% = state.counter% + 1
END SUB

'======================================================================================================================================================================================================

SUB InitialiseGame
    DIM vec AS Vector2
    DIM body AS PhysicsBody
    game.score& = 0
    game.sectionCount% = 0
    SetVector2 vec, SCREEN_WIDTH / 2, 20
    game.floorPtr = CreatePhysicsBodyRectangle(vec, 480, 40, 10)
    GetPtrBody body, game.floorPtr
    body.enabled = FALSE
    SetPtrBody game.floorPtr, body
END SUB

'======================================================================================================================================================================================================

FUNCTION mouseOverStartButton%
    DIM mousePos AS Vector2
    mousePos.x! = (_MOUSEX - _WIDTH(0) / 2) * SCREEN_WIDTH / _WIDTH(0)
    mousePos.y! = (_HEIGHT(0) - _MOUSEY) * SCREEN_HEIGHT / _HEIGHT(0)
    DIM w%, h%
    w% = START_BUTTON_WIDTH
    h% = START_BUTTON_HEIGHT
    mouseOverStartButton% = ABS(mousePos.x!) < w% / 2 AND ABS(mousePos.y! - START_BUTTON_Y) < h% / 2
END FUNCTION

SUB WaitToStart
    STATIC mouseDown%, selected%
    IF _MOUSEBUTTON(1) AND NOT mouseDown% THEN
        selected% = mouseOverStartButton%
    ELSE
        IF NOT _MOUSEBUTTON(1) AND mouseDown% THEN
            IF selected% AND mouseOverStartButton% THEN
                SetGameState STATE_NEW_GAME
                mouseDown% = FALSE
                selected% = FALSE
                EXIT SUB
            ELSE
                selected% = FALSE
            END IF
        END IF
    END IF
    mouseDown% = _MOUSEBUTTON(1)
    IF NOT mouseDown% THEN selected% = FALSE
END SUB

'======================================================================================================================================================================================================

SUB ChooseSectionToDrop
    DIM vec AS Vector2
    DIM body AS PhysicsBody
    section(game.sectionCount%).width% = 1 + INT(RND * MAX_SECTION_SIZE)
    IF USE_RECTANGLES THEN
        section(game.sectionCount%).height% = 1 + INT(RND * MAX_SECTION_SIZE)
    ELSE
        section(game.sectionCount%).height% = section(game.sectionCount%).width% * 2
    END IF
    SetVector2 vec, SCREEN_WIDTH / 2, SCREEN_HEIGHT - BRICK_HEIGHT * MAX_SECTION_SIZE / 2
    IF USE_RECTANGLES THEN
        section(game.sectionCount%).bodyPtr = CreatePhysicsBodyRectangle(vec, section(game.sectionCount%).width% * BRICK_WIDTH, section(game.sectionCount%).height% * BRICK_HEIGHT, 10)
    ELSE
        section(game.sectionCount%).bodyPtr = CreatePhysicsBodyPolygon(vec, section(game.sectionCount%).width% * BRICK_WIDTH, 4, 10)
        SetPhysicsBodyRotation section(game.sectionCount%).bodyPtr, _PI / 4
    END IF
    GetPtrBody body, section(game.sectionCount%).bodyPtr
    body.position.x! = SCREEN_WIDTH / 2 + (SCREEN_WIDTH - BRICK_WIDTH * section(game.sectionCount%).width%) / 2 * COS(state.counter% / 40)
    body.enabled = 0 ' If I do this here, it doesn't modify the orientation! If I don't do this here then gravity is going to apply to this block
    SetPtrBody section(game.sectionCount%).bodyPtr, body
    game.sectionCount% = game.sectionCount% + 1
END SUB

SUB WaitToDropSection
    STATIC mouseDown%
    DIM body AS PhysicsBody
    GetPtrBody body, section(game.sectionCount% - 1).bodyPtr
    body.position.x! = SCREEN_WIDTH / 2 + (SCREEN_WIDTH - BRICK_WIDTH * section(game.sectionCount% - 1).width%) / 2 * COS(state.counter% / 40)
    SetPtrBody section(game.sectionCount% - 1).bodyPtr, body
    IF _MOUSEBUTTON(1) AND NOT mouseDown% THEN
        SetGameState STATE_DROP_SECTION
        body.enabled = 1
        SetPtrBody section(game.sectionCount% - 1).bodyPtr, body
        SetGameState STATE_WAIT_TO_LAND
        EXIT SUB
    END IF
    mouseDown% = _MOUSEBUTTON(1)
END SUB

'======================================================================================================================================================================================================

SUB WaitToLand
    IF state.counter% > 30 THEN 'TODO This ought to be when all sections have settled but that never really happens (and this project is going nowhere anyway)
        SetGameState STATE_PLAY_TURN
    END IF
END SUB

'======================================================================================================================================================================================================

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

'======================================================================================================================================================================================================

SUB RenderBackground
    _GLCOLOR4F 1, 1, 1, 0
    _GLENABLE _GL_TEXTURE_2D
    _GLBINDTEXTURE _GL_TEXTURE_2D, glData.background&
    _GLBEGIN _GL_QUADS
    _GLTEXCOORD2F 0, 1
    _GLVERTEX2F -240, 180
    _GLTEXCOORD2F 1, 1
    _GLVERTEX2F 240, 180
    _GLTEXCOORD2F 1, 0
    _GLVERTEX2F 240, -180
    _GLTEXCOORD2F 0, 0
    _GLVERTEX2F -240, -180
    _GLEND
    _GLDISABLE _GL_TEXTURE_2D
END SUB

SUB RenderStart
    DIM w%, h%, x%, y%
    w% = START_BUTTON_WIDTH
    h% = START_BUTTON_HEIGHT
    x% = SCREEN_WIDTH / 2
    y% = START_BUTTON_Y
    _GLCOLOR4F 1, 1, 1, 1
    _GLENABLE _GL_TEXTURE_2D
    _GLENABLE _GL_BLEND
    _GLBLENDFUNC _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    IF mouseOverStartButton% THEN _GLCOLOR3F 1, 1, 1 ELSE _GLCOLOR3F 0.5, 0.5, 0.5
    _GLBINDTEXTURE _GL_TEXTURE_2D, glData.normal&
    _GLBEGIN _GL_QUADS
    _GLTEXCOORD2F 0, 1
    _GLVERTEX2F x% - w% / 2, y% + h% / 2
    _GLTEXCOORD2F 1, 1
    _GLVERTEX2F x% + w% / 2, y% + h% / 2
    _GLTEXCOORD2F 1, 0
    _GLVERTEX2F x% + w% / 2, y% - h% / 2
    _GLTEXCOORD2F 0, 0
    _GLVERTEX2F x% - w% / 2, y% - h% / 2
    _GLEND
    _GLDISABLE _GL_BLEND
    _GLDISABLE _GL_TEXTURE_2D
END SUB

SUB RenderPhysics
    DIM w%, h%, x%, y%, i%
    DIM bodyPtr AS _UNSIGNED _OFFSET
    DIM body AS PhysicsBody
    DIM vertex AS Vector2
    w% = START_BUTTON_WIDTH
    h% = START_BUTTON_HEIGHT
    x% = SCREEN_WIDTH / 2
    y% = START_BUTTON_Y
    _GLCOLOR4F 1, 1, 1, 1
    IF game.floorPtr <> 0 THEN
        bodyPtr = game.floorPtr
        GetPtrBody body, bodyPtr
        _GLPUSHMATRIX
        _GLTRANSLATEF body.position.x!, body.position.y!, 0
        _GLBEGIN _GL_QUADS
        _GLVERTEX2F -SCREEN_WIDTH / 2, 20
        _GLVERTEX2F SCREEN_WIDTH / 2, 20
        _GLVERTEX2F SCREEN_WIDTH / 2, -20
        _GLVERTEX2F -SCREEN_WIDTH / 2, -20
        _GLEND
        _GLPOPMATRIX
    END IF
    _GLENABLE _GL_TEXTURE_2D
    _GLBINDTEXTURE _GL_TEXTURE_2D, glData.brick&
    i% = 0
    WHILE i% < game.sectionCount%
        bodyPtr = section(i%).bodyPtr
        GetPtrBody body, bodyPtr
        _GLBEGIN _GL_QUADS
        _GLTEXCOORD2F 0, section(i%).height%
        GetPhysicsShapeVertex bodyPtr, 0, vertex
        _GLVERTEX2F vertex.x!, vertex.y!
        _GLTEXCOORD2F section(i%).width%, section(i%).height%
        GetPhysicsShapeVertex bodyPtr, 1, vertex
        _GLVERTEX2F vertex.x!, vertex.y!
        _GLTEXCOORD2F section(i%).width%, 0
        GetPhysicsShapeVertex bodyPtr, 2, vertex
        _GLVERTEX2F vertex.x!, vertex.y!
        _GLTEXCOORD2F 0, 0
        GetPhysicsShapeVertex bodyPtr, 3, vertex
        _GLVERTEX2F vertex.x!, vertex.y!
        _GLEND
        i% = i% + 1
    WEND
    _GLDISABLE _GL_TEXTURE_2D
END SUB

'======================================================================================================================================================================================================

SUB RenderFrame
    RenderBackground
    RenderPhysics
    IF state.state% = STATE_WAIT_TO_START THEN RenderStart
END SUB

'======================================================================================================================================================================================================

FUNCTION LoadTexture& (fileName$)
    LoadTexture& = LoadTextureInternal&(fileName$, FALSE, 0)
END FUNCTION

FUNCTION LoadTextureWithAlpha& (fileName$, rgb&)
    LoadTextureWithAlpha& = LoadTextureInternal&(fileName$, TRUE, rgb&)
END FUNCTION

FUNCTION LoadTextureInternal& (fileName$, useRgb%, rgb&)
    DIM img&, img2&, myTex&
    DIM m AS _MEM
    img& = _LOADIMAGE(fileName$, 32)
    img2& = _NEWIMAGE(_WIDTH(img&), _HEIGHT(img&), 32)
    _PUTIMAGE (0, _HEIGHT(img&))-(_WIDTH(img&), 0), img&, img2&
    IF useRgb% THEN _SETALPHA 0, rgb&, img2&
    _GLGENTEXTURES 1, _OFFSET(myTex&)
    _GLBINDTEXTURE _GL_TEXTURE_2D, myTex&
    m = _MEMIMAGE(img2&)
    _GLTEXIMAGE2D _GL_TEXTURE_2D, 0, _GL_RGBA, _WIDTH(img&), _HEIGHT(img&), 0, _GL_BGRA_EXT, _GL_UNSIGNED_BYTE, m.OFFSET
    _MEMFREE m
    _FREEIMAGE img&
    _FREEIMAGE img2&
    _GLTEXPARAMETERI _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
    _GLTEXPARAMETERI _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    LoadTextureInternal& = myTex&
END FUNCTION

'======================================================================================================================================================================================================

SUB _GL
    IF NOT glData.executing% THEN EXIT SUB
    IF NOT glData.initialised% THEN
        glData.initialised% = TRUE
        _GLVIEWPORT 0, 0, _WIDTH, _HEIGHT
        glData.background& = LoadTexture&("assets/background.png")
        glData.normal& = LoadTexture&("assets/start button.png")
        glData.brick& = LoadTexture&("assets/brick.png")
    END IF
    _GLMATRIXMODE _GL_PROJECTION
    _GLLOADIDENTITY
    _GLORTHO 0, _WIDTH, 0, _HEIGHT, -5, 5
    _GLMATRIXMODE _GL_MODELVIEW
    _GLLOADIDENTITY
    _GLCLEARCOLOR 0, 0, 0, 1
    _GLCLEAR _GL_COLOR_BUFFER_BIT
    RenderFrame
    _GLFLUSH
    IF _EXIT THEN
        exitProgram = TRUE
    END IF
END SUB

'======================================================================================================================================================================================================
