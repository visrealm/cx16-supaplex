


checkTime:
  lda FRAME_INDEX
  cmp #60
  bne +
  stz FRAME_INDEX
  inc TIME_SECONDS
  jsr updateSeconds
  lda TIME_SECONDS
  cmp #60
  bne +
  stz TIME_SECONDS
  inc TIME_MINUTES
  jsr updateMinutes
  lda TIME_MINUTES
  cmp #60
  bne +
  stz TIME_MINUTES
  jsr updateMinutes
  inc TIME_HOURS
  jsr updateHours
+ 



updateSeconds:
  jsr setPixelOperationLSR

  lda TIME_SECONDS
  jsr bin2bcd8

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 3) + 104

  lda R8L
  jsr output2BcdDigits

  +vchannel0
  rts


updateMinutes:
  jsr setPixelOperationLSR

  lda TIME_MINUTES
  jsr bin2bcd8
  
  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 3) + 92

  lda R8L
  jsr output2BcdDigits

  +vchannel0
  rts


updateHours:
  jsr setPixelOperationLSR

  lda TIME_HOURS
  jsr bin2bcd8

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 3) + 80

  lda R8L
  jsr output2BcdDigits

  +vchannel0
  rts
