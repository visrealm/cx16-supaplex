; Commander X16
;
; Raster text subroutines
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

CMN_VERA_TEXT_ASM_ = 1

; -----------------------------------------------------------------------------
; outputText: output a raster string to a vera bitmap
; -----------------------------------------------------------------------------
; vera:
;   addr0 set to output location
;   addr1 set to font location
; inputs:
;   X: string address LSB
;   Y: string address MSB
; -----------------------------------------------------------------------------
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
  lda SELF_MODIFY_ADDR
  beq .done
  sec
  sbc #32
  asl
  asl
  asl
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

  +inc16 .getChar + 1
  
  +vchannel1
  bra .getChar

.done:
  +vchannel0
  rts


; -----------------------------------------------------------------------------
; output3BcdDigits: output 3 bcd digits in raster text
; -----------------------------------------------------------------------------
; vera:
;   addr0 set to output location
;   addr1 set to font location
; inputs:
;   x: first bcd digit
;   a: 2x bcd digits
; -----------------------------------------------------------------------------
output3BcdDigits:
  sta R0
  +vchannel0
  +vpush
  txa
  jsr outputBcdChar
  +vpop
  lda VERA_DATA0
  lda VERA_DATA0
  lda VERA_DATA0
  lda VERA_DATA0
  +vpush
  lda R0
  bra .output2BcdDigitsLateEntry

; WARNING! FLOWS ON THROUGH HERE

; -----------------------------------------------------------------------------
; output2BcdDigits: output 2 bcd digits in raster text
; -----------------------------------------------------------------------------
; vera:
;   addr0 set to output location
;   addr1 set to font location
; inputs:
;   a: 2x bcd digits
; -----------------------------------------------------------------------------
output2BcdDigits:
  sta R0
  +vchannel0 ; save output location
  +vpush
  lda R0
.output2BcdDigitsLateEntry:
  lsr
  lsr
  lsr
  lsr
  jsr outputBcdChar
  +vpop
  lda VERA_DATA0
  lda VERA_DATA0
  lda VERA_DATA0
  lda VERA_DATA0
  lda R0


; WARNING! FLOWS ON THROUGH HERE

; -----------------------------------------------------------------------------
; outputBcdChar: output a bcd digit in raster text
; -----------------------------------------------------------------------------
; vera:
;   addr0 set to output location
;   addr1 set to font location
; inputs:
;   a: 1x bcd digit in low nibble
; -----------------------------------------------------------------------------
outputBcdChar:
  and #$0f
  sta R1L
  +vchannel1
  +vpush
  
  lda R1L
  ora #$10 ; add 16
  asl
  asl
  asl
  asl
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

  +vpop

  rts

; -----------------------------------------------------------------------------
; setPixelOperationNone: updates instruction in outputCharacter to nop
; -----------------------------------------------------------------------------
setPixelOperationNone:
  lda #$ea ; nop
  sta textPixelOperation
  rts

; -----------------------------------------------------------------------------
; setPixelOperationNone: updates instruction in outputCharacter to lsr
; -----------------------------------------------------------------------------
setPixelOperationLSR:
  lda #$0a ; lsr
  sta textPixelOperation
  rts


; -----------------------------------------------------------------------------
; outputCharacter: output a raster character
; -----------------------------------------------------------------------------
; vera:
;   addr0 set to output location
;   addr1 set to character tile location
; -----------------------------------------------------------------------------
outputCharacter:
  phy
  phx
  pha

  ldy #8
  
.nextRow: 
  ldx #4 ; 4 bytes per row

.nextCol:
  lda VERA_DATA1
textPixelOperation:
  nop  ; operation which can be substituted
  sta VERA_DATA0

  dex
  bne .nextCol

  clc
  lda VERA_ADDRx_L
  adc #160 - 4 ; bytes per row, less our current offset
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