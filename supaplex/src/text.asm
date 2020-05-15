
; vera addr0 set to output location
; vera addr1 set to font location
; Inputs:
;  X: address LSB
;  Y: address MSB
outputText:
  stx .getChar + 1
  sty .getChar + 2

  +vchannel0
  lda VERA_ADDRx_L
  sta R0L
  lda VERA_ADDRx_M
  sta R0H

  +vchannel1
  lda VERA_ADDRx_M
  sta R1H

.getChar
  lda $1000
  beq .done
  sec
  sbc #32
  clc
  rol
  rol
  rol
  rol
  rol
  sta R1L
  rol
  and #$1f
  tay
  lda #$e0
  and R1L
  sta VERA_ADDRx_L
  tya
  clc
  adc R1H
  sta VERA_ADDRx_M

  +vchannel0

  jsr outputCharacter

  +vchannel0

  lda R0L
  clc
  adc #4
  sta R0L
  sta VERA_ADDRx_L
  lda R0H
  bcc +
  inc 
+
  sta R0H
  sta VERA_ADDRx_M

  inc .getChar + 1
  bcc +
  inc .getChar + 2
+
  +vchannel1
  bra .getChar

.done:
  +vchannel0
  rts



; vera addr0 set to output location
; vera addr1 set to character location
outputCharacter:
  phy
  phx
  pha

  ldy #8
  
.nextRow: 
  ldx #4 ; 4 bytes per row

.nextCol:
  lda VERA_DATA1
  sta VERA_DATA0

  dex
  bne .nextCol

  clc
  lda VERA_ADDRx_L
  adc #160 - 4
  sta VERA_ADDRx_L
  bcc +
  inc VERA_ADDRx_M
+
  dey
  bne .nextRow

  pla
  plx
  ply

  rts
  
  
