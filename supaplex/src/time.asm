


checkTime:
  lda FRAME_INDEX
  cmp #60
  bne +
  stz FRAME_INDEX
  +incBcd TIME_SECONDS_BCD
  jsr updateSeconds
  lda TIME_SECONDS_BCD
  cmp #$60
  bne +
  stz TIME_SECONDS_BCD
  +incBcd TIME_MINUTES_BCD
  jsr updateMinutes
  lda TIME_MINUTES_BCD
  cmp #$60
  bne +
  stz TIME_MINUTES_BCD
  jsr updateMinutes
  +incBcd TIME_HOURS_BCD
  jsr updateHours
+ 



updateSeconds:
  jsr setPixelOperationLSR

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 3) + 104

  lda TIME_SECONDS_BCD
  jsr output2BcdDigits

  +vchannel0
  rts


updateMinutes:
  jsr setPixelOperationLSR

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 3) + 92

  lda TIME_MINUTES_BCD
  jsr output2BcdDigits

  +vchannel0
  rts


updateHours:
  jsr setPixelOperationLSR

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 3) + 80

  lda TIME_HOURS_BCD
  jsr output2BcdDigits

  +vchannel0
  rts
