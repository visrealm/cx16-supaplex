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


SP_HUD_ASM_ = 1

OVERLAY_PAL = 15
OVERLAY_BOTTOM_ADDR = (VRADDR_OVERLAY + (VISIBLE_AREA_X * VISIBLE_AREA_Y) / 2)

!zone hud {

; -----------------------------------------------------------------------------
; load the overlay layer
; -----------------------------------------------------------------------------
loadOverlay:
  +vLoadPcx fontPcx,    FONT_ADDR,              OVERLAY_PAL
  +vLoadPcx overlayPcx, OVERLAY_BOTTOM_ADDR,    OVERLAY_PAL
  +vClear VRADDR_OVERLAY, OVERLAY_BOTTOM_ADDR - VRADDR_OVERLAY
  rts

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

  lda levelDat + LEVEL_ZP_NUM_INFOTRONS_OFFSET
  sta ZP_NUM_INFOTRONS

  jsr hudSetInfotrons

  stz ZP_TIME_SECONDS_BCD
  stz ZP_TIME_MINUTES_BCD
  stz ZP_TIME_HOURS_BCD

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
  jsr setPixelOperationNone

  lda ZP_NUM_INFOTRONS
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