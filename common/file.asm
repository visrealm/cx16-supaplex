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


CMN_FILE_ASM_ = 1

; -----------------------------------------------------------------------------
; setFile:   set the current file to work with
; -----------------------------------------------------------------------------
; filename:  address of zero-terminated string
; -----------------------------------------------------------------------------
!macro setFile filename {
  ldx #<filename
  ldy #>filename
  jsr strLen
  jsr SETNAM
}

; -----------------------------------------------------------------------------
; loadFile:   helper to load a file into ram
; -----------------------------------------------------------------------------
; filename:  zero-terminated string
; ramArress: address to load the raw data
; -----------------------------------------------------------------------------
!macro loadFile filename, address {

  !if <address != $00 {
    !error "output address must be aligned to a page boundry"
  }

  +setFile filename

  lda #>address

  jsr loadFile
}

; -----------------------------------------------------------------------------
; loadFile: load raw data file into ram
; -----------------------------------------------------------------------------
; Prerequisites:
;   SETNAME called 
; Inputs:
;   A: MSB of output address
; -----------------------------------------------------------------------------
loadFile:
  pha
  lda #$01
  ldx #$08      ; default to device 8
  ldy #$00      ; $00 means: load to new address
  jsr SETLFS

  ldx #$02        ; account for address header 
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
