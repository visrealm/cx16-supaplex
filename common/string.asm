

; Print a null-terminated string
; Inputs:
;  X: address LSB
;  Y: address MSB

printStr:
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