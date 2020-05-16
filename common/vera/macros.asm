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

!macro vpush {
  lda VERA_ADDRx_M
  pha
  lda VERA_ADDRx_L
  pha
}

!macro vpop {
  pla
  sta VERA_ADDRx_L
  pla
  sta VERA_ADDRx_M
}

!macro vpeek {
  tsx
  lda $0100, x
  sta VERA_ADDRx_L
  lda $0101, x
  sta VERA_ADDRx_M
}


!macro vchannel .channel {
  +vreg VERA_CTRL, .channel 
}

!macro vchannel0 {
  +vchannel $00 
}

!macro vchannel1 {
  +vchannel $01 
}

!macro vstore .addr {
	pha
	+vset .addr
	pla
	sta VERA_DATA0
}

!macro vReadByte0 .addr {
	+vset .addr
	lda VERA_DATA0
}

!macro vReadByte1 .addr {
	+vset .addr
	lda VERA_DATA1
}

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

!macro vreg16 register, value {
  lda #>value
  sta register
  lda #<value
  sta register
}

!macro vWriteWord0 value {
  +vreg16 VERA_DATA0, value
}

!macro vWriteWord1 value {
  +vreg16 VERA_DATA1, value
}

!macro vClear start, length {
  +vset start

  ldx #<length
  ldy #>length
  lda #0

-
  sta VERA_DATA0
  dey
  bne -
  dex
  bne -
}

!macro vLoadRaw filename, vramAddress {
  +vset vramAddress

  ldx #<filename
  ldy #>filename
  jsr strLen

  jsr loadRaw
}


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