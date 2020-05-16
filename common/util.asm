; Commander X16
;
; Utility subroutines and macros
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

!macro dec16 addr {
  lda addr
  bne +
  dec addr + 1
+
  dec addr
}

!macro inc16 addr {
  inc addr
  bne +
  inc addr + 1
+
}

!macro cmp16 left, right {
  lda left + 1
  cmp right + 1
	bne +
	lda left
	cmp right
+
}

!macro cmp16xa value {
  cpx #>value
	bne +
	cmp #<value
+
}


; subtract 16 bit numbers. 
; result in zb location
!macro sub16 left, right, res {
  sec
  lda left
  sbc right
  sta res
  lda left + 1
  sbc right + 1
  sta res + 1
}

; subtract 16 bit numbers. 
; result high in a, low in x
!macro sub16 left, right {
  sec
  lda left
  sbc right
  tax
  lda left + 1
  sbc right + 1
}

div8by10:
  lsr
  sta R10L
  lsr
  adc R10L
  ror
  lsr
  lsr
  adc R10L
  ror
  adc R10L
  ror
  lsr
  lsr
  sta R10H
  brk
  rts

; convert binary unsigned byte to bcd
; inputs: A: value
; outputs: BCD value in R8
bin2bcd8:
  sta R7L
  stz R8L
  stz R8H
  ldx #8        ;setup the bit counter
  sed           ;enter decimal mode
.loop:
  asl R7L       ;shift a bit out of the binary
  lda R8L       ;and add it into the result, doubling
  adc R8L       ;... it at the same time
  sta R8L
  lda R8H
  adc R8H
  sta R8H
  dex           ;more bits to process?
  bne .loop
  cld   
  rts


  ;bra .two
  jsr div8by10
  ldx R10L
  stx R8L
  jsr div8by10
  sta R8H
  lda R10L
  asl
  asl
  asl
  asl
  ora R8L
  sta R8L
  rts

.two:
  ;asl R8L
  ;asl R8L
  ;asl R8L

  stz R8H
  stz R8L
  sec
  cmp #100
  bmi +
  inc R8H
  sbc #100
+
  cmp #100
  bmi +
  inc R8H
  sbc #100
+
-
  sec
  sbc #10
  bcs +
  inc R8L
  bra -
+
  asl R8L
  asl R8L
  asl R8L
  asl R8L
  clc
  adc #10
  ora R8L
  sta R8L

  rts