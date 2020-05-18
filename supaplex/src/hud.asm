; Supaplex - Commander X16
;
; HUD routines
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

!zone hud {

; -----------------------------------------------------------------------------
; initial hud setup
; -----------------------------------------------------------------------------
hudSetup:
  ldx #<playerName
  ldy #>playerName
  jsr hudSetPlayerName

  ldx #<levelDat + LEVEL_NAME_OFFSET
  ldy #>levelDat + LEVEL_NAME_OFFSET
  jsr hudSetLevelName

  lda levelNumber
  jsr hudSetLevelNumber

  lda levelDat + LEVEL_NUM_INFOTRONS_OFFSET
  sta NUM_INFOTRONS

  jsr hudSetInfotrons

  stz TIME_SECONDS_BCD
  stz TIME_MINUTES_BCD
  stz TIME_HOURS_BCD

  jsr updateHours
  jsr updateMinutes
  jsr updateSeconds

  rts

; -----------------------------------------------------------------------------
; set player name
; -----------------------------------------------------------------------------
; inputs:
;  xy:  zero-terminated player name address
; -----------------------------------------------------------------------------
hudSetPlayerName:
  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 3) + 44

  jsr setPixelOperationLSR

  jsr outputText

  rts
; -----------------------------------------------------------------------------



; -----------------------------------------------------------------------------
; set level name
; -----------------------------------------------------------------------------
; inputs:
;  xy:  zero-terminated level name address
; -----------------------------------------------------------------------------
hudSetLevelName:
  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 13) + 32

  ldx #<levelDat + LEVEL_NAME_OFFSET
  ldy #>levelDat + LEVEL_NAME_OFFSET

  jsr setPixelOperationNone

  jsr outputText
  
  rts
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; set level number
; -----------------------------------------------------------------------------
; inputs:
;  a:  level number (binary)
; -----------------------------------------------------------------------------
hudSetLevelNumber:

  jsr bin2bcd8

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 14) + 8

  ldx R8H
  lda R8L
  jsr output3BcdDigits

  rts
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; set number of infotrons remaining
; -----------------------------------------------------------------------------
hudSetInfotrons:

  +vreg VERA_AUDIO_CTRL, $1f
  +vreg VERA_AUDIO_RATE, $0

  +vchannel0
  +vset $2a00

  ldx #$75
  ldy #$0f

.loop:
  lda VERA_DATA0
  sta $9F3D
  dex
  bne +
  dey
+
  bne .loop

  +vreg VERA_AUDIO_RATE, $10

  jsr setPixelOperationNone

  lda NUM_INFOTRONS
  jsr bin2bcd8

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 14) + 136

  ldx R8H
  lda R8L
  jsr output3BcdDigits

  +vchannel0
  rts
; -----------------------------------------------------------------------------

}