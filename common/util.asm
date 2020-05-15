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