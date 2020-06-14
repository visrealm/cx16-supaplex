; Supaplex - Commander X16
;
; Time
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

SP_TIME_ASM_ = 1

checkTime:
  lda ZP_FRAME_INDEX
  cmp #60
  bne +
  stz ZP_FRAME_INDEX
  +incBcd ZP_TIME_SECONDS_BCD
  jsr updateSeconds
  lda ZP_TIME_SECONDS_BCD
  cmp #$60
  bne +
  stz ZP_TIME_SECONDS_BCD
  +incBcd ZP_TIME_MINUTES_BCD
  jsr updateMinutes
  lda ZP_TIME_MINUTES_BCD
  cmp #$60
  bne +
  stz ZP_TIME_MINUTES_BCD
  jsr updateMinutes
  +incBcd ZP_TIME_HOURS_BCD
  jsr updateHours
+ 
  rts

updateSeconds:
  jsr setPixelOperationLSR

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 3) + 104

  lda ZP_TIME_SECONDS_BCD
  jsr output2BcdDigits

  +vchannel0
  rts


updateMinutes:
  jsr setPixelOperationLSR

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 3) + 92

  lda ZP_TIME_MINUTES_BCD
  jsr output2BcdDigits

  +vchannel0
  rts


updateHours:
  jsr setPixelOperationLSR

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 3) + 80

  lda ZP_TIME_HOURS_BCD
  jsr output2BcdDigits

  +vchannel0
  rts
