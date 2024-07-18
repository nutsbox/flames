' ///////////////////////////////////////////////////////////////////
'
'  Program:       Flames
'
'  Version:       0.52
'
'  Module:        FLAMES.BAS
'
'  Description:   This program demonstrate the use of BASIC common
'                 string functions.  First, it asks for the name
'                 of a lover and a beloved, then it performs the
'                 FLAMES routine game.
'
'                 NOTE:  This program is dedicated to my
'                        INTRO. TO. PROG. students and my friends.
'                        Remember, life is too short not to love.
'
'  Tools:         PowerBasic 3.50, PB/Vision Professional 1.0,
'                 MS-DOS 6.22
'
'  Rev. History:  10/09/1999 v0.50 - Initial Release
'                 12/21/2015 v0.51 - Added new routine that highlights
'                                    letter in "FLAMES"
'
'  Last Modif.:   10/01/2018 - Converted to PB/Vision version
'                              utilizing forms, windows, and mouse
'
'  Programmer:    Nestor A. Jaba-an
'
'  License:       MIT License
'
'  Copyright (c) 1999 - present By Nestor A. Jaba-an
'      #6 Mercury St., Bricktown Subd., Phase III - Moonwalk
'      Paranaque City 1709, Philippines.
'      Tel.: (632) 8821-8979
'      Mobile: (63) 9178580461
'      Email: nestor.jabaan@gmail.com
'

%ISPBU = 0             ' not a .PBU
DEFINT A-Z             ' treat A-Z as high speed integer variables
$DYNAMIC               ' use dynamic memory allocation

'---------------------------------
'  PB/VISION routine definitions
'---------------------------------
$INCLUDE "WINDOW.BI"
$INCLUDE "EVENT.BI"
$INCLUDE "MOUSE.BI"
$INCLUDE "FORM.BI"
$INCLUDE "CMNDLG.BI"

%hcNoHelp = 0
%cmOk = 1001
%cmQuit = 1002


'--------------------------------------------
'  Constants
'--------------------------------------------
TRUE = 1 : FALSE = 0


'--------------------------------------------
'  Function declarations
'--------------------------------------------
DECLARE SUB matchFlames (s1$, s2$)
DECLARE SUB burnFlames (nFg%, nPos%)
DECLARE SUB dispFace (nMood%)


'--------------------------------------------
'  Define some variables...
'--------------------------------------------
LET nMode = 0
LET nMatch = 0
LET sw% = TRUE


'----------------------------------------
' Define our variable type for our form
'----------------------------------------
TYPE FlamesData
    lover   AS STRING * 100
    beloved AS STRING * 100
    command AS INTEGER
END TYPE

DIM InFlames AS SHARED FlamesData


'--------------------------------------------
'  Define some variables...
'--------------------------------------------
DIM wSignOn AS SHARED INTEGER
DIM wFlames AS SHARED INTEGER
DIM cmn AS cmnDialogTYPE

WINUSEUMB = 1               ' use UMB if available


'--------------------------------------------
'  Setup common dialog control
'--------------------------------------------
cmn.kolor = &H3F30
cmn.border = 1
cmn.borderKolor = &H3F
cmn.titleKolor = &H5F
cmn.style = 4
cmn.cmdKolor = &H1F17
cmn.cmdHighlight = &H7470
cmn.flags = %DRAGBAR OR %SHADOW


'--------------------------------------------
'  General App setup
'--------------------------------------------
App.attr = &H00
App.Pattern = -1            ' no desktop
APP.BIT9FIX = 1             ' correct 9 bit VGA card quirk
APP.GRAPHICSMODE = 1        ' switch to graphics mode
APP.GRAPHICSMOUSE = 0       ' don't use graphics mouse

APPINIT                    ' initialize PB/VISION desktop

ON TIMER(1) GOSUB blink

' Open new window to display our
' sign-on message
wSignOn = WINOPEN( _
             14, 53, _     ' height, width
             &H10, _       ' attribute (black on blue [bg,fg])
             1, &H1F, _    ' with border, border color (bright white text)
             "Flames v0.52", _  ' title
             &HF0, _       ' title color
             %DRAGBAR OR %SHADOW)      ' window flag (w/ shadow)

formHandle% = FORMOPEN(5, 53, 4, &H70, 1, &H70, "Lover & Beloved Box", &H5F, %DRAGBAR OR %SHADOW)

TEXTBUTTON formHandle%, 1, 2, 10, 31, 100, 0, &H3F30, &HB0, ASC("L"), %hcNoHelp, 5, %tSTRING
TEXTBUTTON formHandle%, 2, 4, 10, 31, 100, 2, &H3F30, &HB0, ASC("B"), %hcNoHelp, 5, %tSTRING

COMMANDBUTTON formHandle%, 3, 2, 43, &H2F20, &H2F2E, "  ~O~k  ", %hcNoHelp, 1, 2, %cmOk
COMMANDBUTTON formHandle%, 4, 4, 43, &H2F20, &H2F2E, " ~Q~uit ", %hcNoHelp, 1, 2, %cmQuit

WINHOTPRINT formHandle%, 2, 4, &H7F70, "~L~over"
WINHOTPRINT formHandle%, 4, 2, &H7F70, "~B~eloved"

FORMINSTALLTYPE formHandle%, InFlames

GottaMouse% = MOUSEINIT(buttons%)
MOUSECURSORON

' Show window in the given coordinates
WINSHOW wSignOn, _         ' window handle
        1, _               ' row (0 will center the window in that plane)
        0, _               ' column
        24, _              ' height
        80                 ' width

' Display our sign-on
FIRE
WINPRINT wSignOn, 8, 26, &H17, "Copyright (c) 1999 - 2018"
WINPRINT wSignOn, 9, 31, &H17, "by Nestor A. Jaba-an"

WINPRINT wSignOn, 14, 2, &H17, "Type the lover's name..."

' Display our form
FORMSHOW formHandle%, 18, 0, 24, 80
BUTTONSET formHandle%, 1

' Display face
dispFace(0)

TIMER ON

'-----------------------
' Here's our event loop
'-----------------------
DO
    EventID = GetEvent(0)

    SELECT CASE EventID

        CASE 102, %cmQuit   ' <ESC> key event
            retVal = ButtonBox(0, 0, "Are you sure? Please Confirm.", " ~Y~es ", " ~N~o ", "", cmn)
            IF retVal = 1 THEN
               EXIT DO
            END IF

        'CASE 17 'Timer

        CASE 407 ' TextButton contents changed
            WINPRINT wSignOn, 13, 18, &H17, "                                 "
            WINPRINT wSignOn, 14, 2, &H17, "Press ESC or Alt-Q to exit...                  "
            sw% = TRUE
            UPDATE

        CASE 403 ' Control got focus
            sw% = TRUE
            WINPRINT wSignOn, 13, 18, &H17, "                                 "
            IF BUTTONGET%(formHandle%) = 1 THEN
                WINPRINT wSignOn, 14, 2, &H17, "Type the lover's name...                       "
            ELSEIF BUTTONGET%(formHandle%) = 2 THEN
                WINPRINT wSignOn, 14, 2, &H17, "Type the beloved's name...                     "
            ELSE
                WINPRINT wSignOn, 14, 2, &H17, "Press ESC or Alt-Q to exit...                  "
            END IF

        CASE %cmOk
            sw% = FALSE
            matchFlames LTRIM$(RTRIM$(InFlames.lover)), LTRIM$(RTRIM$(InFlames.beloved))

            FORMFILL formHandle%
            BUTTONSET formHandle%, 1

        CASE ELSE
            IF sw% = TRUE THEN
                UPDATE
            END IF

    END SELECT

LOOP

FORMCLOSE formHandle%

WINCLOSE wSignOn       ' close sign-on window

MOUSECURSOROFF
APPCLOSE               ' close PB/VISION app and remove desktop

END


' -------------------------------------------------------------------
'
'  Subroutine:     dispFace
'
'  Description:    This subroutine updates the face in the
'                  FLAMES to show different facial expressions:
'                  NORMAL, SAD, HAPPY and ANGRY.
'
'  Parameters:     nMood%    An integer value that specifies
'                            the mode of facial expression.
'
SUB dispFace (nMood%)
    WINPRINT wSignOn, 8, 4, &H1F, " --   -- "
    WINPRINT wSignOn, 9, 4, &H1F, "(ЎЏ) (ЎЏ)"
    WINPRINT wSignOn, 10, 8, &H1F, CHR$(127)

    SELECT CASE nMood%
        CASE 1
                WINPRINT wSignOn, 11, 6, &H1F, "РФФФй"
        CASE 2
                WINPRINT wSignOn, 11, 6, &H1F, "кФФФП"
        CASE 3
                WINPRINT wSignOn, 11, 6, &H1F, ">ФФФ<"
        CASE ELSE
                WINPRINT wSignOn, 11, 6, &H1F, "ФФФФФ"
    END SELECT
END SUB


'----------------------------------------
'
'  The subroutine that blinks the face
'----------------------------------------
blink:
    COLOR 15, 2
    IF nMode = 0 THEN
        WINPRINT wSignOn, 8, 4, &H1F, " --   -- "
        WINPRINT wSignOn, 9, 4, &H1F, "(ЎЏ) (ЎЏ)"
        LET nMode = 1
    ELSE
        WINPRINT wSignOn, 8, 4, &H1F, "         "
        WINPRINT wSignOn, 9, 4, &H1F, "(--) (--)"
        LET nMode = 0
    END IF
RETURN


SUB FIRE
    WINPRINT wSignOn, 2, 4, &H1F, "ллллл   л         л     л     л   ллллл   ллллл"
    WINPRINT wSignOn, 3, 4, &H1F, "л       л        л л    лл   лл   л       л    "
    WINPRINT wSignOn, 4, 4, &H1F, "ллл     л       л   л   л л л л   ллл     ллллл"
    WINPRINT wSignOn, 5, 4, &H1F, "л       л       ллллл   л  л  л   л           л"
    WINPRINT wSignOn, 6, 4, &H1F, "л       ллллл   л   л   л     л   ллллл   ллллл"
END SUB



' ---------------------------------------------
'  Highlight corresponding letter in "FLAMES"
' ---------------------------------------------
SUB burnFlames (nFg%, nPos%)
    COLOR nFg%,1
    SELECT CASE nPos%
        CASE 1
                WINPRINT wSignOn, 2, 4, nFg%, "ллллл"
                WINPRINT wSignOn, 3, 4, nFg%, "л    "
                WINPRINT wSignOn, 4, 4, nFg%, "ллл  "
                WINPRINT wSignOn, 5, 4, nFg%, "л    "
                WINPRINT wSignOn, 6, 4, nFg%, "л    "

        CASE 2
                WINPRINT wSignOn, 2, 12, nFg%, "л    "
                WINPRINT wSignOn, 3, 12, nFg%, "л    "
                WINPRINT wSignOn, 4, 12, nFg%, "л    "
                WINPRINT wSignOn, 5, 12, nFg%, "л    "
                WINPRINT wSignOn, 6, 12, nFg%, "ллллл"

        CASE 3
                WINPRINT wSignOn, 2, 20, nFg%, "  л  "
                WINPRINT wSignOn, 3, 20, nFg%, " л л "
                WINPRINT wSignOn, 4, 20, nFg%, "л   л"
                WINPRINT wSignOn, 5, 20, nFg%, "ллллл"
                WINPRINT wSignOn, 6, 20, nFg%, "л   л"

        CASE 4
                WINPRINT wSignOn, 2, 28, nFg%, "л     л"
                WINPRINT wSignOn, 3, 28, nFg%, "лл   лл"
                WINPRINT wSignOn, 4, 28, nFg%, "л л л л"
                WINPRINT wSignOn, 5, 28, nFg%, "л  л  л"
                WINPRINT wSignOn, 6, 28, nFg%, "л     л"

        CASE 5
                WINPRINT wSignOn, 2, 38, nFg%, "ллллл"
                WINPRINT wSignOn, 3, 38, nFg%, "л    "
                WINPRINT wSignOn, 4, 38, nFg%, "ллл  "
                WINPRINT wSignOn, 5, 38, nFg%, "л    "
                WINPRINT wSignOn, 6, 38, nFg%, "ллллл"

        CASE 6
                WINPRINT wSignOn, 2, 46, nFg%, "ллллл"
                WINPRINT wSignOn, 3, 46, nFg%, "л    "
                WINPRINT wSignOn, 4, 46, nFg%, "ллллл"
                WINPRINT wSignOn, 5, 46, nFg%, "    л"
                WINPRINT wSignOn, 6, 46, nFg%, "ллллл"
    END SELECT
END SUB


'-------------------------
' UPDATE Subroutine
'-------------------------
SUB UPDATE

    WINREFRESHMODE 0        ' disable instant refreshing

    WINPRINT wSignOn, 11, 18, &H17, "                                 "
    LET col% = 51 - LEN(LTRIM$(RTRIM$(InFlames.lover)))
    WINPRINT wSignOn, 11, col%, &H17, LTRIM$(RTRIM$(InFlames.lover))

    WINPRINT wSignOn, 12, 18, &H17, "                                 "
    LET col% = 51 - LEN(LTRIM$(RTRIM$(InFlames.beloved)))
    WINPRINT wSignOn, 12, col%, &H17, LTRIM$(RTRIM$(InFlames.beloved))

    WINREFRESHMODE 1        ' re-enabled instant refreshing

    WINREFRESH wSignOn      ' refresh output window

END SUB


SUB matchFlames (s1$, s2$)

    st1$ = s1$
    st2$ = s2$

    '----------------------------------------------------
    '  Determine and count the number of matches.
    '  The following routines demonstrate the power of
    '  BASIC string functions...
    '----------------------------------------------------
    FOR i=1 TO LEN(s1$)
        cChar$ = UCASE$(MID$(s1$, i, 1))
        IF  cChar$ <> " " AND cChar$ <> "*"  AND cChar$ <> "." THEN

            ' Search for match on the second string
            nMatch = 0
            FOR j=1 TO LEN(s2$)
                IF cChar$ = UCASE$(MID$(s2$, j, 1)) THEN
                    st2$ = LEFT$(st2$, j - 1) + "*" + MID$(st2$, j + 1)
                    nMatch = 1
                END IF
            NEXT j

            ' Then search itself for a match
            IF nMatch = 1 THEN
                FOR j=1 TO LEN(s1$)
                    IF MID$(st1$, j, 1) <> "*" THEN
                        IF cChar$ = UCASE$(MID$(s1$, j, 1)) THEN
                            st1$ = LEFT$(st1$, j - 1) + "*" + MID$(st1$, j + 1)
                        END IF
                    END IF
                NEXT j
            END IF
        END IF
    NEXT i


    '-------------------------------------------------------
    ' Now count the total number of matches on both string
    '-------------------------------------------------------
    LET sTemp$ = st1$ + st2$
    LET nMatch = 0

    FOR i=1 TO LEN(sTemp$)
        IF MID$(sTemp$, i, 1) = "*" THEN
            nMatch = nMatch + 1
        END IF
    NEXT i

    LET s$ = STR$(nMatch) + " letters match"

    WINPRINT wSignOn, 13, 18, &H17, "                                 "
    LET col% = 51 - LEN(s$)
    WINPRINT wSignOn, 13, col%, &H17, s$

    z = nMatch
    IF nMatch = 0 THEN
        nMatch = 7
    ELSEIF nMatch > 6 THEN
        nMatch = nMatch MOD 6
        IF nMatch = 0 THEN
            nMatch = 6
        END IF
    END IF


    '----------------------------------------------
    ' Higlight a corresponding letter in "FLAMES"
    '----------------------------------------------
    FIRE
    IF nMatch < 7 THEN
        FOR i=1 TO z
            j = i
            IF j > 6 THEN
               j = j MOD 6
               IF j = 0 THEN
                  j = 6
               END IF
            END IF
            CALL burnFlames(&H1E, j)
            SOUND 587, 1.0
            DELAY 0.05
            SOUND 587, 0
            IF i < z THEN
               CALL burnFlames(&H1F, j)
            END IF
        NEXT i
    END IF


    '---------------------------------------
    '  Highlight matching letters in names
    '---------------------------------------
    LET l$ = ""
    LET b$ = ""
    FOR i=1 TO LEN(st1$)
        IF MID$(st1$, i, 1) = "*" THEN
            l$ = l$ + "~" + MID$(s1$, i, 1) + "~"
        ELSE
            l$ = l$ + MID$(st1$, i, 1)
        END IF
    NEXT i
    FOR i=1 TO LEN(st2$)
        IF MID$(st2$, i, 1) = "*" THEN
            b$ = b$ + "~" + MID$(s2$, i, 1) + "~"
        ELSE
            b$ = b$ + MID$(s2$, i, 1)
        END IF
    NEXT i

    WINPRINT wSignOn, 11, 18, &H17, "                                 "
    LET col% = 51 - LEN(st1$)
    WINHOTPRINT wSignOn, 11, col%, &H1E17, l$

    WINPRINT wSignOn, 12, 18, &H17, "                                 "
    LET col% = 51 - LEN(st2$)
    WINHOTPRINT wSignOn, 12, col%, &H1E17, b$
   
	' Clear line prompt
	WINPRINT wSignOn, 14, 2, &H1E, "                                                  "

    '----------------------------------
    '  Display the facial expression
    '----------------------------------
	SELECT CASE nMatch
        CASE 1
            CALL dispFace(2)  ' Friends
            WINHOTPRINT wSignOn, 14, 2, &H1E17, "You are just ~FRIENDS~"
        CASE 2
            CALL dispFace(1)  ' Lovers
            WINHOTPRINT wSignOn, 14, 2, &H1E17, "Wow, you are ~LOVERS!~"
        CASE 3
            CALL dispFace(3)  ' Angry with each other
            WINHOTPRINT wSignOn, 14, 2, &H1E17, "Uh oh! you are ~ANGRY~ at each other"
        CASE 4
            CALL dispFace(1)  ' Going to get married
            WINHOTPRINT wSignOn, 14, 2, &H1E17, "Yahoo! you will get ~MARRIED~ - Soulmates!"
        CASE 5
            CALL dispFace(3)  ' Enemies
            WINHOTPRINT wSignOn, 14, 2, &H1E17, "You will never get along well - ~ENEMIES~"
        CASE 6
            CALL dispFace(1)  ' Sweethearts
            WINHOTPRINT wSignOn, 14, 2, &H1E17, "~SWEETHEARTS!~ Hmmm... are you in a relationship?"
        CASE 7
            CALL dispFace(2)  ' No Match
            WINHOTPRINT wSignOn, 14, 2, &H1E17, "You guys are out of this world; ~NO MATCH!~"
        CASE ELSE
            CALL dispFace(0)  ' Normal
    END SELECT

END SUB
