!macro vset .addr {
	lda #<(.addr >> 16) | $10
	sta VERA_ADDRx_H
	lda #<(.addr >> 8)
	sta VERA_ADDRx_M
	lda #<(.addr)
	sta VERA_ADDRx_L
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


!macro vLoadRaw filename, vramAddress {
  +vset vramAddress

  ldx #<filename
  ldy #>filename
  jsr strLen

  jsr loadRaw
}


!macro vLoadPcx filename, vramAddress, palOffset {
  
  +vchannel1
  
  +vset VERA_PALETTE + palOffset
  +vchannel0
  +vset vramAddress

  ldx #<filename
  ldy #>filename
  jsr strLen
  
  jsr loadPcxFile
}