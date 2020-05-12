!cpu 65c02

CHROUT      = $FFD2	; CHROUT outputs a character (C64 Kernal API)
CHRIN       = $FFCF		; CHRIN read from default input

SETLFS			= $FFBA
SETNAM			= $FFBD
LOAD			  = $FFD5
OPEN        = $FFC0
CLOSE       = $FFC3


; Joystick constants
; ----------------------------------------------------------------------------
; subroutines

JOYSTICK_SCAN = $FF53

; Get joystick state
; A = buttons
; X = xtended buttons (SNES)
; Y = device present ($00) or not ($FF)
JOYSTICK_GET  = $FF56

; constants
JOY_RIGHT  = %00000001
JOY_LEFT   = %00000010
JOY_DOWN   = %00000100
JOY_UP     = %00001000
JOY_START  = %00010000
JOY_SELECT = %00100000
JOY_B      = %01000000
JOY_A      = %10000000

JOYSTICK_PRESENT     = $00
JOYSTICK_NOT_PRESENT = $ff


; Virtual registers
; ----------------------------------------------------------------------------
R0  = $02
R0L = R0
R0H = R0 + $01
R1  = $04
R1L = R1
R1H = R1 + $01
R2  = $06
R2L = R2
R2H = R2 + $01
R3  = (R2 + 2)
R3L = R3
R3H = (R3 + 1)
R4  = (R3 + 2)
R4L = R4
R4H = (R4 + 1)
R5  = (R4 + 2)
R5L = R5
R5H = (R5 + 1)
R6  = (R5 + 2)
R6L = R6
R6H = (R6 + 1)
R7  = (R6 + 2)
R7L = R7
R7H = (R7 + 1)
R8  = (R7 + 2)
R8L = R8
R8H = (R8 + 1)
R9  = (R8 + 2)
R9L = R9
R9H = (R9 + 1)
