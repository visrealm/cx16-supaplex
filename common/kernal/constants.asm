; Commander X16
;
; Constants
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

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

JOYSTICK_SCAN = $ff53

; Get joystick state
; A = buttons
; X = xtended buttons (SNES)
; Y = device present ($00) or not ($FF)
JOYSTICK_GET  = $ff56

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

CLOCK_GET_DATE_TIME = $ff50

; Virtual registers
; ----------------------------------------------------------------------------
R0  = $02
R0L = R0
R0H = R0 + 1
R1  = $04
R1L = R1
R1H = R1 + 1
R2  = $06
R2L = R2
R2H = R2 + 1
R3  = $08
R3L = R3
R3H = R3 + 1
R4  = $0a
R4L = R4
R4H = R4 + 1
R5  = $0c
R5L = R5
R5H = R5 + 1
R6  = $0e
R6L = R6
R6H = R6 + 1
R7  = $10
R7L = R7
R7H = R7 + 1
R8  = $12
R8L = R8
R8H = R8 + 1
R9  = $14
R9L = R9
R9H = R9 + 1
R10  = $16
R10L = R10
R10H = R10 + 1
