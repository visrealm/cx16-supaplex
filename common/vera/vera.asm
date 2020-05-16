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

; -----------------------------------------------------------------------------
; loadRaw: load raw data file into VRAM
; -----------------------------------------------------------------------------
; xy contains address of filename
; vera already configured:
;   channel 0 for data
; -----------------------------------------------------------------------------
loadRaw:
TMP_ADDR = $8000
  jsr SETNAM

  lda #$01
  ldx $BA       ; last used device number
  bne .skip
  ldx #$08      ; default to device 8
.skip
  ldy #$00      ; $00 means: load to new address
  jsr SETLFS

  ldx #<TMP_ADDR
  ldy #>TMP_ADDR
  lda #$00      ; $00 means: load to memory (not verify)
  jsr LOAD
  bcs .error    ; if carry set, a load error has happened

  ldy #0

.nextByte:        
  lda TMP_ADDR, Y
  sta VERA_DATA0
  iny
  dex
  bne .nextByte

  rts
.error

  rts

}