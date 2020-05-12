
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

video_init:
  +vreg VERA_CTRL, $00   
  +vset $A00

  ldy #32

.nextMapRow:
  ldx #2

.nextMapCell:
  +vWriteByte0 $01
  +vWriteByte0 $14
  +vWriteByte0 $02
  +vWriteByte0 $14
  +vWriteByte0 $03
  +vWriteByte0 $14
  +vWriteByte0 $04
  +vWriteByte0 $14
  +vWriteByte0 $05
  +vWriteByte0 $14
  +vWriteByte0 $06
  +vWriteByte0 $14
  +vWriteByte0 $07
  +vWriteByte0 $14
  +vWriteByte0 $08
  +vWriteByte0 $14
  +vWriteByte0 $09
  +vWriteByte0 $14
  +vWriteByte0 $0a
  +vWriteByte0 $14
  +vWriteByte0 $0b
  +vWriteByte0 $14
  dex
  bne .nextMapCell
  dey
  bne .nextMapRow

  +vset $A08
  +vWriteByte0 $01
  +vWriteByte0 $10

  +vset $4000

  ldy #16

.nextTileRow:
  +vWriteByte0 $00
  +vWriteByte0 $00
  +vWriteByte0 $00
  +vWriteByte0 $00
  +vWriteByte0 $55
  +vWriteByte0 $55
  +vWriteByte0 $11
  +vWriteByte0 $11
  dey
  bne .nextTileRow
  
.doneLoad


  +vreg VERA_L0_MAPBASE, $05    ; map data starting at 0x00
  +vreg VERA_L0_TILEBASE, $23   ; 16x16 tiles starting at 0 0100 0000 0000 0000
  +vreg VERA_L0_CONFIG, $02  ; 32x32, 4bpp
  +vreg VERA_L0_HSCROLL_L, $00
  +vreg VERA_L0_HSCROLL_H, $00
  +vreg VERA_L0_VSCROLL_L, $00
  +vreg VERA_L0_VSCROLL_H, $00
  +vreg VERA_DC_VIDEO, $11
  +vreg VERA_DC_HSCALE, 64   
  +vreg VERA_DC_VSCALE, 64   
  +vreg VERA_IEN, 1
  +vreg VERA_ISR, 1

  +vset VERA_PALETTE + $10 ; palette
  +vWriteWord0 $0000 ;0  -RGB
  +vWriteWord0 $0500 ;1  -RGB
  +vWriteWord0 $0600 ;2  -RGB
  +vWriteWord0 $0900 ;3  -RGB
;  +vWriteWord0 $0A00 ;4  -RGB
;  +vWriteWord0 $0C00 ;5  -RGB
;  +vWriteWord0 $0E10 ;6  -RGB
;  +vWriteWord0 $0555 ;7  -RGB
;  +vWriteWord0 $0777 ;8  -RGB
;  +vWriteWord0 $0F52 ;9  -RGB
;  +vWriteWord0 $0888 ;10  -RGB
;  +vWriteWord0 $0F72 ;11  -RGB
;  +vWriteWord0 $0F94 ;12  -RGB
;  +vWriteWord0 $0FD0 ;13  -RGB
;  +vWriteWord0 $0DDD ;14  -RGB
;  +vWriteWord0 $0FFF ;15  -RGB
rts


!macro vLoadRaw filename, vramAddress {
  +vset vramAddress

  ldx #<filename
  ldy #>filename
  jsr strLen

  jsr loadRaw
}

loadRaw:
!zone
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
