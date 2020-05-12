

; Length of a null-terminated string
; Inputs:
;  X: address LSB
;  Y: address MSB
; Outputs:
;  A: length
strLen:
!zone 
  stx .loop + 1        ; save string pointer LSB
  sty .loop + 2        ; save string pointer MSB
  ldy #0               ; starting string index

.loop:
  lda $1000, y         ; get a character
  beq .end             ; end of string
  iny                  ; next
  jmp .loop

.end:
  tya
  rts


; Print a null-terminated string
; Inputs:
;  X: address LSB
;  Y: address MSB
printStr:
!zone 
  stx .loop + 1        ; save string pointer LSB
  sty .loop + 2        ; save string pointer MSB
  ldy #0               ; starting string index

.loop:
  lda $1000, y         ; get a character
  beq .end             ; end of string

  jsr CHROUT           ; print character
  iny                  ; next
  jmp .loop

.end:
  rts

!macro printStr stringAddr {
  ldx #<stringAddr
  ldy #>stringAddr
  jsr printStr
}