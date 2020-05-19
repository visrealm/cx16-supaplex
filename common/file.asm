; Commander X16
;
; File utilities
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

; -----------------------------------------------------------------------------
; loadFile:   helper to load a file into ram
; -----------------------------------------------------------------------------
; filename:  zero-terminated string
; ramArress: address to load the raw data
; -----------------------------------------------------------------------------
!macro loadFile filename, address {
  ldx #<filename
  ldy #>filename
  jsr strLen

  jsr SETNAM

  lda #>address

  jsr loadFile
}

; -----------------------------------------------------------------------------
; loadFile: load raw data file into ram
; -----------------------------------------------------------------------------
; xy contains address of filename
; a  contains MSB of output address
; -----------------------------------------------------------------------------
loadFile:
  pha
  lda #$01
  ldx #$08      ; default to device 8
  ldy #$00      ; $00 means: load to new address
  jsr SETLFS

  ldx #$04        ; account for address header 
  ply
  lda #$00      ; $00 means: load to memory (not verify)
  jsr LOAD
  bcs .errorLoad    ; if carry set, a load error has happened

  stx R2L
  sty R2H

  rts
.errorLoad
  brk
  rts
