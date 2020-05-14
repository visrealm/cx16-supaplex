; Commander X16
;
; VERA helper subroutines
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


!zone vera {


loadRaw:
tempLoadAddress = $8000
  jsr SETNAM

  lda #$01
  ldx $BA       ; last used device number
  bne .skip
  ldx #$08      ; default to device 8
.skip
  ldy #$00      ; $00 means: load to new address
  jsr SETLFS

  ldx #<tempLoadAddress
  ldy #>tempLoadAddress
  lda #$00      ; $00 means: load to memory (not verify)
  jsr LOAD
  bcs .error    ; if carry set, a load error has happened

  ldy #0

.nextByte:        
  lda tempLoadAddress, Y
  sta VERA_DATA0
  iny
  dex
  bne .nextByte

  rts
.error

  ; Accumulator contains BASIC error code

  ; most likely errors:
  ; A = $05 (DEVICE NOT PRESENT)
  ; A = $04 (FILE NOT FOUND)
  ; A = $1D (LOAD ERROR)
  ; A = $00 (BREAK, RUN/STOP has been pressed during loading)

  ;... error handling ...
  rts
}