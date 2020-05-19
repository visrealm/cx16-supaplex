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


CMN_VERA_ASM_ = 1


!zone vera {

; -----------------------------------------------------------------------------
; loadRaw: load raw data file into VRAM
; -----------------------------------------------------------------------------
; xy contains address of filename
; vera already configured:
;   channel 0 for data
; -----------------------------------------------------------------------------
loadRaw:
TMP_ADDR = $A000
  jsr SETNAM

  lda #$01
  ldx #$08      ; default to device 8
  ldy #$01      ; $00 means: load to new address
  jsr SETLFS

  ldx #<(TMP_ADDR + 2)
  ldy #>(TMP_ADDR + 2)
  lda #$00      ; $00 means: load to memory (not verify)
  jsr LOAD
  bcs .errorRaw    ; if carry set, a load error has happened

  stx R2L
  sty R2H

  lda #<TMP_ADDR
  sta R1L
  lda #>TMP_ADDR
  sta R1H

  ldy #0

.checkNextByteRaw:
  lda R1H
  cmp R2H
  bne +
  tya
  cmp R2L
  beq .doneRaw
+
  lda (R1),y
  sta VERA_DATA0
  iny
  bne +
  inc R1H
+
  bra .checkNextByteRaw
.doneRaw

  rts
.errorRaw

  rts

; -----------------------------------------------------------------------------
; loadRawPCM: load raw data file into VRAM
; -----------------------------------------------------------------------------
; xy contains address of filename
; vera already configured:
;   channel 0 for data
; -----------------------------------------------------------------------------
loadRawPCM:
TMP_ADDR = $A000
  jsr SETNAM

  lda #$01
  ldx #$08      ; default to device 8
  ldy #$01      ; $00 means: load to new address
  jsr SETLFS

  ldx #<(TMP_ADDR + 2)
  ldy #>(TMP_ADDR + 2)
  lda #$00      ; $00 means: load to memory (not verify)
  jsr LOAD
  bcs .errorPcm    ; if carry set, a load error has happened

  stx R2L
  sty R2H

  lda #<TMP_ADDR
  sta R1L
  lda #>TMP_ADDR
  sta R1H

  ldy #0

.checkNextByte:
  lda R1H
  cmp R2H
  bne +
  tya
  cmp R2L
  beq .donePcm
+
  lda (R1),y
  sta $9F3D
  iny
  bne +
  inc R1H
+
  bra .checkNextByte
.donePcm

  rts
.errorPcm

  rts

}