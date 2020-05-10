
!macro vset .addr {
	lda #<(.addr >> 16) | $10
	sta VERA_ADDRx_H
	lda #<(.addr >> 8)
	sta VERA_ADDRx_M
	lda #<(.addr)
	sta VERA_ADDRx_L
}

!macro vstore .addr {
	pha
	+vset .addr
	pla
	sta VERA_DATA0
}

!macro vload .addr {
	+vset .addr
	lda VERA_DATA0
}

!macro vreg register, value {
  lda #value
  sta register
}

!macro vdata0 value {
  +vreg VERA_DATA0, value
}

!macro vreg16 register, value {
  lda #<value
  sta register
  lda #>value
  sta register
}

!macro vdata016 value {
  +vreg16 VERA_DATA0, value
}


!macro video_init {
  +vreg VERA_CTRL, $80

  +vset $200

  ldy #32

.nextMapRow:
  ldx #16

.nextMapCell:
  +vdata0 $01
  +vdata0 $10
  +vdata0 $01
  +vdata0 $00
  +vdata0 $01
  +vdata0 $20
  dex
  bne .nextMapCell
  dey
  bne .nextMapRow

  +vset $4000

  ldy #16

.nextTileRow:
  +vdata0 $00
  +vdata0 $00
  +vdata0 $00
  +vdata0 $00
  +vdata0 $55
  +vdata0 $55
  +vdata0 $11
  +vdata0 $11
  +vdata0 $00
  dey
  bne .nextTileRow
  
	+vdata0 $00
  +vdata0 $00
  +vdata0 $34
  +vdata0 $55
  +vdata0 $55
  +vdata0 $42
  +vdata0 $00
  +vdata0 $00
  +vdata0 $00
  +vdata0 $24
  +vdata0 $56
  +vdata0 $66
 
	+vdata0 $66
  +vdata0 $65
  +vdata0 $30
  +vdata0 $00
  +vdata0 $02
  +vdata0 $45
  +vdata0 $66
  +vdata0 $99
  +vdata0 $99
  +vdata0 $96
  +vdata0 $63
  +vdata0 $00
 
	+vdata0 $04
  +vdata0 $56
  +vdata0 $69
  +vdata0 $9B
  +vdata0 $BC
  +vdata0 $C9
  +vdata0 $96
  +vdata0 $30
  +vdata0 $85
  +vdata0 $66
  +vdata0 $9E
  +vdata0 $BB
 
	+vdata0 $DD
  +vdata0 $DC
  +vdata0 $96
  +vdata0 $50
  +vdata0 $45
  +vdata0 $66
  +vdata0 $7E
  +vdata0 $BC
  +vdata0 $DD
  +vdata0 $DD
  +vdata0 $B9
  +vdata0 $52
 
	+vdata0 $45
  +vdata0 $66
  +vdata0 $69
  +vdata0 $BC
  +vdata0 $DD
  +vdata0 $DC
  +vdata0 $B9
  +vdata0 $64
  +vdata0 $45
  +vdata0 $66
  +vdata0 $99
  +vdata0 $BB
 
	+vdata0 $CD
  +vdata0 $CC
  +vdata0 $99
  +vdata0 $64
  +vdata0 $04
  +vdata0 $56
  +vdata0 $99
  +vdata0 $9B
  +vdata0 $BB
  +vdata0 $BB
  +vdata0 $96
  +vdata0 $64
 
	+vdata0 $00
  +vdata0 $07
  +vdata0 $77
  +vdata0 $49
  +vdata0 $BB
  +vdata0 $99
  +vdata0 $96
  +vdata0 $53
  +vdata0 $00
  +vdata0 $77
  +vdata0 $77
  +vdata0 $59
 
	+vdata0 $99
  +vdata0 $99
  +vdata0 $66
  +vdata0 $50
  +vdata0 $07
  +vdata0 $88
  +vdata0 $84
  +vdata0 $69
  +vdata0 $99
  +vdata0 $66
  +vdata0 $65
  +vdata0 $40
 
	+vdata0 $08
  +vdata0 $A8
  +vdata0 $36
  +vdata0 $66
  +vdata0 $66
  +vdata0 $66
  +vdata0 $54
  +vdata0 $20
  +vdata0 $01
  +vdata0 $34
  +vdata0 $55
  +vdata0 $56
 
	+vdata0 $66
  +vdata0 $55
  +vdata0 $42
  +vdata0 $00
  +vdata0 $00
  +vdata0 $13
  +vdata0 $44
  +vdata0 $55
  +vdata0 $55
  +vdata0 $44
  +vdata0 $20
  +vdata0 $00
 
	+vdata0 $00
  +vdata0 $00
  +vdata0 $03
  +vdata0 $44
  +vdata0 $43
  +vdata0 $00
  +vdata0 $00
  +vdata0 $00

.doneLoad


  +vreg VERA_CTRL, $00   
  +vreg VERA_L0_MAPBASE, $01    ; map data starting at 0x00
  +vreg VERA_L0_TILEBASE, $23   ; 16x16 tiles starting at 0 0100 0000 0000 0000
  +vreg VERA_L0_CONFIG, $02  ; 32x32, 4bpp
  +vreg VERA_L0_HSCROLL_L, $00
  +vreg VERA_L0_HSCROLL_H, $00
  +vreg VERA_L0_VSCROLL_L, $00
  +vreg VERA_L0_VSCROLL_H, $00
  +vreg VERA_DC_VIDEO, $11
  +vreg VERA_DC_HSCALE, 64   
  +vreg VERA_DC_VSCALE, 64   

  +vset $1FA20 ; palette
  +vdata016 $0000 ;0  -RGB
  +vdata016 $0500 ;1  -RGB
  +vdata016 $0600 ;2  -RGB
  +vdata016 $0900 ;3  -RGB
  +vdata016 $0A00 ;4  -RGB
  +vdata016 $0C00 ;5  -RGB
  +vdata016 $0E10 ;6  -RGB
  +vdata016 $0555 ;7  -RGB
  +vdata016 $0777 ;8  -RGB
  +vdata016 $0F52 ;9  -RGB
  +vdata016 $0888 ;10  -RGB
  +vdata016 $0F72 ;11  -RGB
  +vdata016 $0F94 ;12  -RGB
  +vdata016 $0FD0 ;13  -RGB
  +vdata016 $0DDD ;14  -RGB
  +vdata016 $0FFF ;15  -RGB
    


}