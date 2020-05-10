z_Regs equ $20
	include "\srcAll\BasicMacros.asm"

	macro SetVeraAddr,val		;SetVeraHML $123456
		lda #(\val>>16 & $FF)		;$12 - Top byte
		sta V_H	
		lda #(\val>>8 & $FF)		;$34 - Mid Byte
		sta V_M
		lda #(\val & $FF)			;$56 - Low Byte
		sta V_L
	endm
	


SPpage equ $0100

V_L  equ $9f20			;VERA_ADDR_LO  LLLLLLLL	20 Bit address L
V_M  equ $9f21			;VERA_ADDR_MID MMMMMMMM	20 Bit address M
V_H  equ $9f22			;VERA_ADDR_HI  IIIIHHHH	20 Bit address H  I=Increment
V_D1 equ $9f23			;VERA_DATA1    DDDDDDDD	Data Port 1

VERA_CTRL equ $9F25 	;$9F25 R------A   R=Reset A=Address (port 1 / 2)


*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $30, $36, $34, $29, $00, $00, $00  ;Start at $0810
*=$0810
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	     ;R------A		R=Reset A=Address (port 1 / 2)
	lda #%00000000
	sta VERA_CTRL  		 ;$9F25 - set ADDR1 active
	
	
		
	SetVeraAddr $1F0000 ;DC_VIDEO 
	
		 ;F----COO		F=current field (RO) C=Chroma disable O=Out mode (1=vga)	 
	lda #%00000001		
	sta V_D1 			;DC_VIDEO 

	lda #64				; Hscale - 128=Normal 64=2x
	sta V_D1 			;DC_HSCALE
	
	lda #64				; Vscale - 128=Normal 64=2x
	sta V_D1 			;DC_VSCALE
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Palette Setup
	SetVeraAddr $1F1000 ;Color 0 Green/Blue

	ldx #2				;2 bytes x 256 entries ($GB $-R )
	ldy #0
	lda #<palette
	sta z_l
	lda #>palette
	sta z_h
	
PaletteLoop:	
	lda (z_hl),y		
	sta V_D1		
	iny
	bne PaletteLoop
	inc z_h
	dex
	bne PaletteLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Layer Setup
	
	;Tile Pattern Defs @ $08000
	;Tilemap		   @ $00000
	;Define 64x64 Tilemap 4bpp
	
	SetVeraAddr $1F2000	;L0_CTRL0 (Autoinc $01)
	
		 ;MMM----E M=Mode E=Enable
	lda #%01100001 	;4=8bpp tile 3=4bpp tile
	sta V_D1		;$F2000	L0_CTRL0		MMM----E	(M=Mode E=Enable)
	;    %--HWhhww	H=tile Height / W=tile Width / m=map height  (32/64/128/256)
	lda #%00000101								; / w=map width (32/64/128/256) 
	sta V_D1		;$F2001	L0_CTRL1		--HWhhww	H=tile Height / W=tile Width
	lda #$00									; / m=map height / w=map width
	sta V_D1		;$F2002	L0_MAP_BASE_L 	LLLLLLLL	Map Base (9:2)   (address>>2)
	lda #%00000000
	sta V_D1		;$F2003	L0_MAP_BASE_H	HHHHHHHH	Map Base (17:10) (address>>2)
	lda #0
	sta V_D1		;$F2004	L0_TILE_BASE_L 	LLLLLLLL	Tile Base (9:2)  (address>>2)
	lda #%00100000
	sta V_D1		;$F2005	L0_TILE_BASE_H  HHHHHHHH	Tile Base (17:10)(address>>2)
	stz V_D1		;$F2006	L0_HSCROLL_L	LLLLLLLL	Hscroll (7:0)
	stz V_D1		;$F2007	L0_HSCROLL_H 	----HHHH	Vscroll (11:8)
	stz V_D1		;$F2008	L0_VSCROLL_L  	LLLLLLLL	Hscroll (7:0)
	stz V_D1		;$F2009	L0_VSCROLL_H 	----HHHH	Vscroll (11:8)
	
	lda #$1F
	ldy #$30
	ldx #$00
	jsr SetVeraHML		;$0F 30 00	L2_CTRL0 (Autoinc $01)
	
	;MMM----E M=Mode E=Enable
	lda #%11100000
	sta V_D1		;Disable Layer 2
	
	
	;Copy Tile Patterns to VRAM
	
	SetVeraAddr $108000 			;Dest:      Tile Pattern VRAM	
	LoadPair z_hl,Tile				;Source:    Tile Data
	LoadPair z_bc,(Tile_end-Tile)	;ByteCount: Length of Tile Data
	jsr VLDIR						;Copy z_BC bytes from z_HL to VRAM
	
	
	loadpair z_hl,TileMap	;Source:Tilemap
	SetVeraAddr $100000		;Dest:  $00000 in Vram (TileMap)

	ldy #38					;Height of Tilemap Data
SetTilesYAgain:	
	ldx #48					;Width of Tilemap Data
SetTilesXAgain:
	
	lda (z_hl)				;Read Tilenum
	sta V_D1				;TTTTTTTT - Tilenumber
	jsr IncHL
	
	stz V_D1				;PPPPVHTT - Tilenumber / Palette / Vflip / Hflip
	
	dex
	bne SetTilesXAgain		;Repeat for next Tile
	
	ldx #16					;Pad Tilemap to 64 wide
PadTilesXAgain:
	stz V_D1
	stz V_D1
	dex
	bne PadTilesXAgain		;Repeat Pad
	
	dey						
	bne SetTilesYAgain		;Repeat for next line
	
	
TileScroll:	
	pha
		SetVeraAddr $0F2006	;L0_HSCROLL_L (X offset)
	pla
	sta V_D1
	
	pha
		SetVeraAddr $0F2008 ;L0_VSCROLL_L (Y offset)
	pla
	sta V_D1
	clc
	adc #1					;Inc Scroll and wrap
	and #%00111111
	
	jsr pause
	jmp TileScroll

pause:
	ldx #255
pauseagain:
	ldy #255
pauseagain2:
	nop
	nop
	dey
	bne pauseagain2
	dex
	bne pauseagain2
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		
CursorX: db 0
CursorY: db 0

NewLine:		
		stz CursorX
		inc CursorY
	rts
	
PrintChar:
	sec
	sbc #32					;Our charactrer has no space
	sta z_as
	
	phx						;Backup the registers we use
	phy
	lda z_h
	pha
	lda z_l
	pha
		lda z_as			;8 bytes per character in our font
		stz z_H
		asl
		rol	z_H
		asl 
		rol	z_H
		asl 
		rol	z_H
		
		adc #<BitmapFont	;Add the address of our font
		sta z_L
		lda z_H
		adc #>BitmapFont
		sta z_H	
	
	
		stz z_d				;For the 24 bits we'll use z_d  z_e and A
			
		lda CursorY	 ;CursorY* 320*8 = Cursor Y * %00000000 00001010 00000000
		asl					;320 bytes per line 8 lines per char
		rol z_d
		sta z_e				;Shift one bit left and store
		
		asl
		rol z_d
		asl
		rol z_d				;Shift 2 bits left
		
		clc
		adc z_e				;Add carry to M byte
		tay
		
		lda z_d				
		adc #0				;Add carry to H byte
		sta z_d
		
		stz z_e
		lda CursorX	;CursorX* 8 = Cursor Y * %00000000 00000000 00001000
		
		asl
		rol z_e
		asl
		rol z_e
		asl
		rol z_e				;Shift 3 bits left
		
		tax					;X contains L byte 
		
		tya 				;Add carry to M byte
		adc z_e				
		tay					;Y contains M byte
		
		lda z_d				;Add carry to H byte & set AutoInc
		adc #$10			;A contains H byte  
		
		jsr SetVeraHML		;Set Screen Address
		
		
		ldy #0						;Line in Font Char
CharLineAgain:
		phy
			lda (z_hl),y
			sta z_as
			ldx #8				;8 Bytes (pixels) Per Line
CharPixelAgain:				
			lda #0
			rol z_as			;Pop a bit off our font byte
			rol
			sta V_D1			;Send to screen ram
			
			dex 
			bne CharPixelAgain	;Next Pixel
			
			ldy #>(320-8)
			ldx #<(320-8)
			jsr AddVHML_YX			;Move down screen line (320 byte)
		ply
		iny							;Move down a line in our font
		tya
		cmp #8
		bne CharLineAgain			;8 lines per character
		
		inc CursorX
		lda CursorX
		cmp #40						;40 Characters per screen line
		bne NoNewLine
		jsr NewLine
NoNewLine:	
	pla								;Restore the registers
	sta z_l
	pla
	sta z_h	
	ply
	plx
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


		
		
SetVeraHML:		;Select Memory address %----AAAA YYYYYYYYY XXXXXXXX
				;Set Inc to            %AAAA----
						
		sta V_H	
		sty V_M
		stx V_L
	rts


AddVHML_YX		;add 24 bit %00000000 YYYYYYYYY XXXXXXXX to V_HML
		lda #0
AddVHML_AYX		;add 24 bit %AAAAAAAA YYYYYYYYY XXXXXXXX to V_HML
		pha
			clc
			txa
			adc V_L
			sta V_L
			tya
			adc V_M
			sta V_M
		pla
		adc V_H
		sta V_H
		rts	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

VLDIR:					;Copy z_BC bytes from z_HL to V_D1 
		ldy #0			;(address must be already selected)
        lda (z_HL),Y	
        sta V_D1		;Copy byte to V_D1
		INC z_L
		BNE	VLDIR_SkipInc1
		INC	z_H
VLDIR_SkipInc1:
		DEC z_C			;Repeat until z_BC =0
		BNE VLDIR
		LDA z_B
		BEQ	VLDIR_Done
		DEC z_B
		jmp VLDIR
VLDIR_Done:
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Tile:		
	incbin "\ResAll\Sprites\TileSamples_4bit.RAW"
	;incbin "\ResAll\Sprites\TileSamples_8bit.RAW"
Tile_end:	
		
BitmapFont:
	incbin "\resall\Font96.FNT"

MyText
    db "Hello worlds!",  255
	
	include "\SrcAll\monitor.asm"
	include "\SrcAll\BasicFunctions.asm"
	
	
palette:
    dw $0000 ;0  -RGB
    dw $0800 ;1  -RGB
    dw $0080 ;2  -RGB
    dw $0880 ;3  -RGB
    dw $0008 ;4  -RGB
    dw $0808 ;5  -RGB
    dw $0088 ;6  -RGB
    dw $0CCC ;7  -RGB
    dw $0888 ;8  -RGB
    dw $0F00 ;9  -RGB
    dw $00F0 ;10  -RGB
    dw $0FF0 ;11  -RGB
    dw $000F ;12  -RGB
    dw $0F0F ;13  -RGB
    dw $00FF ;14  -RGB
    dw $0FFF ;15  -RGB
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TileMap:
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,2,2,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,2,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,2,0,0,0,0,0,0,0,0,0,2,0,0,2,0,0,2,0,0,0,0,0,0,0,2,0,0,2,0,0,0,0,2,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,0,0,0,3,0,3,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,2,0,0,2,0,0,0,0,0,0,0,0,0,0,0,4,0,4,0,4,0,4,0
  db 0,0,3,3,3,4,3,4,3,0,0,0,0,0,0,0,0,0,0,0,3,3,0,0,0,0,0,0,0,0,0,3,3,0,3,0,3,3,0,0,4,0,4,0,4,0,4,0
  db 0,3,4,4,4,4,4,4,4,3,0,5,0,0,0,0,0,3,3,3,4,4,3,3,0,0,0,0,0,3,3,4,4,3,4,3,4,4,3,0,4,0,4,0,4,0,4,0
  db 3,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,4,4,4,4,4,4,4,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,3,4,4,4,4,4,4,4,4
  db 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
  db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
  db 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
  db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
  db 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
  db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
  db 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
  db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	
