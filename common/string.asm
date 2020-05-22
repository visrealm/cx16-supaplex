; Commander X16
;
; String subroutines
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


CMN_STRING_ASM_ = 1


; -----------------------------------------------------------------------------
; strLen: Length of a null-terminated string
; -----------------------------------------------------------------------------
; Inputs:
;  X: address LSB
;  Y: address MSB
; Outputs:
;  A: length
; -----------------------------------------------------------------------------
strLen:
!zone
  phy
  stx .loop + 1        ; save string pointer LSB
  sty .loop + 2        ; save string pointer MSB
  ldy #0               ; starting string index

.loop:
  lda SELF_MODIFY_ADDR, y         ; get a character
  beq .end             ; end of string
  iny                  ; next
  bra .loop

.end:
  tya
  ply
  rts
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; printStr: Print a null-terminated string
; -----------------------------------------------------------------------------
; Inputs:
;  X: address LSB
;  Y: address MSB
; -----------------------------------------------------------------------------
printStr:
!zone 
  stx .loop + 1        ; save string pointer LSB
  sty .loop + 2        ; save string pointer MSB
  ldy #0               ; starting string index

.loop:
  lda SELF_MODIFY_ADDR, y         ; get a character
  beq .end             ; end of string

  jsr CHROUT           ; print character
  iny                  ; next
  bra .loop

.end:
  rts
; -----------------------------------------------------------------------------


!macro printStr stringAddr {
  ldx #<stringAddr
  ldy #>stringAddr
  jsr printStr
}