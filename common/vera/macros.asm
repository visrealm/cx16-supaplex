; Commander X16
;
; Vera macros
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;


CMN_VERA_MACROS_ = 1

; -----------------------------------------------------------------------------
; vset: set the address and incrment
; -----------------------------------------------------------------------------
!macro vset .addr, increment {
	lda #<(.addr >> 16) | increment
	sta VERA_ADDRx_H
	lda #<(.addr >> 8)
	sta VERA_ADDRx_M
	lda #<(.addr)
	sta VERA_ADDRx_L
}

!macro vset .addr {
  +vset .addr, VERA_INCR_1
}

; -----------------------------------------------------------------------------
; vpush: push vera address from stack
; -----------------------------------------------------------------------------
!macro vpush {
  lda VERA_ADDRx_H
  pha
  lda VERA_ADDRx_M
  pha
  lda VERA_ADDRx_L
  pha
  lda VERA_CTRL
  pha
}

; -----------------------------------------------------------------------------
; vpop: pop vera address from stack
; -----------------------------------------------------------------------------
!macro vpop {
  pla
  sta VERA_CTRL
  pla
  sta VERA_ADDRx_L
  pla
  sta VERA_ADDRx_M
  pla
  sta VERA_ADDRx_H
}


; -----------------------------------------------------------------------------
; vchannel: set the current vera channel
; -----------------------------------------------------------------------------
!macro vchannel .channel {
  +vreg VERA_CTRL, .channel 
}

!macro vchannel0 {
  +vchannel $00 
}

!macro vchannel1 {
  +vchannel $01 
}


; -----------------------------------------------------------------------------
; vReadByte: read a byte from vram
; -----------------------------------------------------------------------------
!macro vReadByte0 .addr {
	+vset .addr
	lda VERA_DATA0
}

!macro vReadByte1 .addr {
	+vset .addr
	lda VERA_DATA1
}

; -----------------------------------------------------------------------------
; vreg16: write an 8-bit value to vram
; -----------------------------------------------------------------------------
!macro vreg register, value {
  lda #value
  sta register
}

!macro vWriteByte0 value {
  +vreg VERA_DATA0, value
}

!macro vWriteByte1 value {
  +vreg VERA_DATA1, value
}

; -----------------------------------------------------------------------------
; vreg16: write a 16-bit value to vram
; -----------------------------------------------------------------------------
!macro vreg16 register, value {
  lda #<value
  sta register
  lda #>value
  sta register
}

!macro vWriteWord0 value {
  +vreg16 VERA_DATA0, value
}

!macro vWriteWord1 value {
  +vreg16 VERA_DATA1, value
}

; -----------------------------------------------------------------------------
; vClear: clear a range of vram (set to zeros)
; -----------------------------------------------------------------------------
; start:  start address
; length: length in bytes to clear
; -----------------------------------------------------------------------------
!macro vClear start, length {
  +vset start

  ldx #<length
  ldy #>length
  lda #0

-
  sta VERA_DATA0
  dex
  bne -
  dey
  bne -
}

; -----------------------------------------------------------------------------
; vLoadRaw:   helper to load a file into vram
; -----------------------------------------------------------------------------
; filename:   zero-terminated string
; vramArress: address to load the raw data
; -----------------------------------------------------------------------------
!macro vLoadRaw filename, vramAddress {
  +vset vramAddress

  ldx #<filename
  ldy #>filename
  jsr strLen

  jsr loadRaw
}

; -----------------------------------------------------------------------------
; vLoadRaw:   helper to load an audio file into vram
; -----------------------------------------------------------------------------
; filename:   zero-terminated string
; vramArress: address to load the raw data
; -----------------------------------------------------------------------------
!macro vLoadAudio filename {

  ldx #<filename
  ldy #>filename
  jsr strLen

  jsr loadRawPCM
}


; -----------------------------------------------------------------------------
; filename:   zero-terminated string
; vramArress: address to load the pixel data
; palIndex:  0-15 - high nibble of palette address offset
; -----------------------------------------------------------------------------
!macro vLoadPcx filename, vramAddress, palIndex {

  !if palIndex > 15 {
    !error "Invalid palette index: ", palIndex, ". Must be between 0 and 15"
  }
  
  +vchannel1
  
  +vset VERA_PALETTE + (palIndex << 5)
  +vchannel0
  +vset vramAddress

  ldx #<filename
  ldy #>filename
  jsr strLen
  
  jsr loadPcxFile
}
; -----------------------------------------------------------------------------
