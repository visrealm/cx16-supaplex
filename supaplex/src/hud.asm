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
OVERLAY_BOTTOM_ADDR = VRADDR_OVERLAY + (DISPLAY_BYTES_PER_ROW * VISIBLE_AREA_Y)

HUD_INFOTRONS_POS_X = 136
HUD_INFOTRONS_POS_Y = 14

HUD_LEVELNUM_POS_X = 8
HUD_LEVELNUM_POS_Y = 14

HUD_LEVELNAME_POS_X = 32
HUD_LEVELNAME_POS_Y = 13

HUD_PLAYERNAME_POS_X = 44
HUD_PLAYERNAME_POS_Y = 3

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

  lda levelDat + LEVEL_NUM_INFOTRONS_OFFSET
  sta ZP_NUM_INFOTRONS

  jsr hudSetInfotrons

  stz ZP_TIME_SECONDS_BCD
  stz ZP_TIME_MINUTES_BCD
  stz ZP_TIME_HOURS_BCD

  jsr updateHours
  jsr updateMinutes
  jsr updateSeconds

  rts

hudOutputDebug:
  pha
  phx
  phy
  php

  jsr bin2bcd8
  jsr setPixelOperationNone

  +vchannel1
  +vpush
  +vset FONT_ADDR

  +vchannel0
  +vpush
  +vset VRADDR_OVERLAY + (DISPLAY_BYTES_PER_ROW * 10) + 10

  ldx R8H
  lda R8L
  jsr output3BcdDigits

  +vpop
  +vpop

  +vchannel0

  plp
  ply
  plx
  pla
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
  +vset OVERLAY_BOTTOM_ADDR + (DISPLAY_BYTES_PER_ROW * HUD_PLAYERNAME_POS_Y) + HUD_PLAYERNAME_POS_X

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
  +vset OVERLAY_BOTTOM_ADDR + (DISPLAY_BYTES_PER_ROW * HUD_LEVELNAME_POS_Y) + HUD_LEVELNAME_POS_X

  ; just ensure there is a null terminator
  LEVEL_NAME_END = levelDat + LEVEL_NAME_OFFSET + LEVEL_NAME_LENGTH  
  lda LEVEL_NAME_END
  pha
  stz LEVEL_NAME_END

  ldx #<levelDat + LEVEL_NAME_OFFSET
  ldy #>levelDat + LEVEL_NAME_OFFSET

  jsr setPixelOperationNone

  jsr outputText

  pla
  sta LEVEL_NAME_END
  
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
  +vset OVERLAY_BOTTOM_ADDR + (DISPLAY_BYTES_PER_ROW * HUD_LEVELNUM_POS_Y) + HUD_LEVELNUM_POS_X

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
  +vset OVERLAY_BOTTOM_ADDR + (DISPLAY_BYTES_PER_ROW * HUD_INFOTRONS_POS_Y) + HUD_INFOTRONS_POS_X

  ldx R8H
  lda R8L
  jsr output3BcdDigits

  +vchannel0
  rts
; -----------------------------------------------------------------------------

}