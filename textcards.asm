; Text cards generator for Lootera Coming Soon video.
; Created by rdagger 2025
; MIT License
; Assembled with Zmac 1.3 which is available on Bally Alley
; zmac -i -o textcards.bin textcards.asm
INCLUDE "HVGLIB.H"                      ; Home Video Game Library Header

AQUA    EQU     $BE                     ; Define colors
BLACK   EQU     $00
BLUE    EQU     $FC
CYAN    EQU     $EE
GREEN   EQU     $AC
ORANGE  EQU     $63
FUCHSIA EQU     $42
RED     EQU     $5A
VIOLET  EQU     $13
WHITE   EQU     $07
YELLOW  EQU     $87

VERTLN	EQU     90                      ; Number of rows used for screen data

STACK   EQU    $4F53                    ; Stack area
        ORG    FIRSTC                   ; First byte of Cartridge
        JP     PRGST                    ; No menu, just start program (required)

PRGST:                                  ; Program Start	
        DI                              ; Disable interrupts
        LD      SP, STACK               ; Initialize stack (required if no menu)
        SYSTEM (INTPC)                  ; Start System Interpreter

        DO     (SETOUT)                 ; Set Display Ports
        DB     (VERTLN*2)               ; Vertical Blanking Line (90 lines)
        DB     00101000b                ; ... 00: Background, 101000=40 (160/4):Left/Right color boundary at 160
        DB     $08                      ; Interrupt Mode

        DO     (COLSET)                 ; Set Color Registers
        DW     COLTAB                   ; Color Table

        DO     (FILL)                   ; Screen Fill
        DW     $4000                    ; Destination
        DW     (VERTLN*40)              ; Bytes to move
        DB     $00                      ; Fill with black

        EXIT                            ; Exit System Interpreter
        SYSTEM ACTINT                   ; Enable automatic interrupt service

INITCODEHERE:
        LD      B, 9                    ; Counter for current card (10 cards, zero based)

CHECKTRIGGER:   
        IN      A, (SW0)                ; Load accumulator with controller 1 switches
        BIT     CHTRIG, A               ; Test trigger bit
        JR      Z, CHECKTRIGGER         ; Loop until the trigger is pulled
        
DRAWTEXTCARD:
        PUSH    BC                      ; Preserve text card counter B which increments with every trigger press.
        SYSSUK  FILL                    ; Blank screen FILL
        DW      $4000                   ; Destination (first byte of video RAM)
        DW      VERTLN*40               ; Total bytes to clear (Screen height in lines x width in bytes)
        DB      $00                     ; Fill with zero for black
        POP     BC                      ; Restore text card counter
        
        LD      HL, COLORS              ; Load address of color order
        LD      A, B                    ; Load index of current text card
        SYSTEM  INDEXB                  ; Get color for current card
        OUT     (COL1L), A              ; Set text color (Port $5, COLor 1 Left)

        LD      HL, TEXTS               ; Load address of text order
        LD      A, B                    ; Load index of current text card
        SYSTEM  INDEXW                  ; Get text string address of current text card

; ******STRDIS Parameters & Output
; HL = String address
; C  = Standard options byte
; DE = XY coordinates (NOTE: control codes used for spacing & line height, horizontal alignment fixed in Premiere)
; IX = Alternate Font descriptor address (optional)
; Output:  DE = Updated to next frame
        EX      DE, HL                  ; Swap text string address to HL
        LD      C, 01000100b            ; 01= enlarge x2, 00= plop, 0100=foreground/background color
        LD      DE, $0000               ; Set X, Y coordinates of text to top left of screen
        SYSTEM  STRDIS                  ; Draw text

        PUSH    BC                      ; Preserve text card counter B which increments with every trigger press.
        SYSSUK  PAWS                    ; Pause program to debounce trigger pull
        DB      30                      ; .. for 30 interrupts (about half a second)
        POP     BC                      ; Restore text card counter
       
        DEC     B                       ; Decrement text card counter
        JP      P, CHECKTRIGGER         ; Repeat loop until counter is less than zero
        LD      A, RED                  ; Load color value red to accumulator
        SYSSUK  PAWS                    ; Pause program
        DB      60                      ; .. for 60 interrupts about 1 second
COLORCYCLE:
        OUT     (COL1L), A              ; Set text color
        INC     A                       ; Increment color
        SYSSUK  PAWS                    ; Pause program
        DB      3                       ; .. for 3 interrupts about 50 ms
        JR      COLORCYCLE              ; Repeat color cycle indefinitely

; Color Table
; https://ballyalley.com/ml/ml_docs/astrocade_palette.html
COLTAB: 
        DB      RED                     ; Color 3 Left (Not used)
        DB      BLUE                    ; Color 2 Left (Not used)
        DB      WHITE                   ; Color 1 Left (Text color)
        DB      BLACK                   ; Color 0 Left (Background)
        DB      RED                     ; Color 3 Right (Not used)
        DB      BLUE                    ; Color 2 Right (Not used)
        DB      WHITE                   ; Color 1 Right (Not used)
        DB      BLACK                   ; Color 0 Right (Not used)

; Card Text (using control codes for placement and spacing)
TEXT1:  DB      $0C, "CAN YOU", $03, "ESCAPE?", $00
TEXT2:  DB      $0C, "A VAST", $05, "MAZE", $00
TEXT3:  DB      $0D, "SOLVE", $04, "PUZZLES", $00
TEXT4:  DB      $0C, "UNEARTH", $03, "SECRETS" ,$00
TEXT5:  DB      $0C, "UNLOCK", $04, "VAULTS", $00
TEXT6:  DB      $0C, "PLUNDER", $02, "TREASURES", $00
TEXT7:  DB      $0D, "EVADE", $03, "CREATURES", $00
TEXT8:  DB      $0C, "DEVOUR", $04, "SNACKS", $00
TEXT9:  DB      $0C, "AVOID", $05, "TRAPS", $00
TEXT10: DB      $0C, "LOOTERA", $00

; Text order
TEXTS:
        DW      TEXT10
        DW      TEXT9
        DW      TEXT8
        DW      TEXT7
        DW      TEXT6
        DW      TEXT5
        DW      TEXT4
        DW      TEXT3
        DW      TEXT2
        DW      TEXT1

; Color order
COLORS:
        DB      RED
        DB      ORANGE
        DB      AQUA
        DB      FUCHSIA
        DB      GREEN
        DB      YELLOW
        DB      VIOLET
        DB      BLUE
        DB      CYAN
        DB      WHITE

COPYRIGHT: 
        DB      "RDAGGER 2025", $00
