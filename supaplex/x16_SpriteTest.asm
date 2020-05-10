z_Regs equ $20		;We need some Zeropage space for our work
	include "\srcAll\BasicMacros.asm"

V_L  equ $9f20			;VERA_ADDR_LO  LLLLLLLL	20 Bit address L
V_M  equ $9f21			;VERA_ADDR_MID MMMMMMMM	20 Bit address M
V_H  equ $9f22			;VERA_ADDR_HI  IIIIHHHH	20 Bit address H  I=Increment
V_D1 equ $9f23			;VERA_DATA1    DDDDDDDD	Data Port 1
SPpage equ $0100


	macro SetVeraAddr,val		;SetVeraHML $123456
		lda #(\val>>16 & $FF)		;$12
		sta V_H	
		
		lda #(\val>>8 & $FF)		;$34
		sta V_M
		
		lda #(\val & $FF)			;$56
		sta V_L
	endm
	
	
	

VERA_CTRL equ $9F25 	;$9F25 R------A   R=Reset A=Address (port 1 / 2)


*=$0801
        BYTE $0E,$08,$0A,$00,$9E,$20,$28,$32,$30,$36,$34,$29,$00,$00,$00  ;Start at $0810
*=$0810
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Screen Setup
	
	     ;R------A		R=Reset A=Address (port 1 / 2)
	lda #%00000000
	sta VERA_CTRL  		 ;$9F25 - set ADDR1 active
	
	SetVeraAddr $1F0000 ;40040 address with inc DC_VIDEO 
	
		 ;F----COO		F=current field (RO) 
	lda #%00000001			;C=Chroma disable O=Out mode (1=vga)	 
	sta V_D1 			;$40040	DC_VIDEO 

	lda #64				; Hscale - 128=Normal 64=2x
	sta V_D1 			;$40041	DC_HSCALE
	
	lda #64				; Vscale - 128=Normal 64=2x
	sta V_D1 			;$40042	DC_VSCALE
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Palette Setup
	SetVeraAddr $1F1000	;$40200	Color 0 Green/Blue

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
	;Layer 1 Setup
	SetVeraAddr $1F2000 	;L1_CTRL0 (Autoinc $01)
	
		 ;MMM----E M=Mode E=Enable (mode 6=4bpp)
	lda #%11000001
	sta V_D1		;$40000	L1_CTRL0		MMM----E	(M=Mode E=Enable)
	stz V_D1		;$40001	L1_CTRL1		--HWhhww	H=tile Height / W=tile Width / m=map height / w=map width
	stz V_D1		;$40002	L1_MAP_BASE_L 	LLLLLLLL	Map Base (9:2)
	stz V_D1		;$40003	L1_MAP_BASE_H	HHHHHHHH	Map Base (17:10)

	;Layer at $000000-$009600
	stz V_D1		;$40004	L1_TILE_BASE_L 	LLLLLLLL	Tile Base (9:2)		
	stz V_D1		;$40005	L1_TILE_BASE_H  HHHHHHHH	Tile Base (17:10)
	
	stz V_D1		;$40006	L1_HSCROLL_L	LLLLLLLL	Hscroll (7:0)
	stz V_D1		;$40007	L1_HSCROLL_H 	----HHHH	Vscroll (11:8)
	stz V_D1		;$40008	L1_VSCROLL_L  	LLLLLLLL	Hscroll (7:0)
	stz V_D1		;$40009	L1_VSCROLL_H 	----HHHH	Vscroll (11:8)
		
	
	lda #$1F
	ldy #$30
	ldx #$00
	jsr SetVeraHML		;$0F 30 00	L2_CTRL0 (Autoinc $01)
	
	;MMM----E M=Mode E=Enable
	lda #%11100000
	sta V_D1		;Disable Layer 2
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Test Pattern Loop

	SetVeraAddr $100000 ;Bitmap ram $-0 00 00 (Autoinc $01)
	

	ldx #$01+1			;320x240=$12C00
	ldy #$2C+1
	lda #$00+1
TestPatternLoop:	
	stz V_D1			;Write test byte to screen
	sec
	sbc #1
	bne TestPatternLoop
	dey
	bne TestPatternLoop
	dex
	bne TestPatternLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
	
	lda #<MyText
	sta z_L
	lda #>MyText
	sta z_H
	jsr PrintString
	jsr newline
	jsr PrintString
	

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;Copy Sprite BMP to Vram

	SetVeraAddr $110000	;Dest Addr for Sprite Bitmaps
	
	;lda #<sprite		;Sprite Bitmap Source
	;sta z_l
	;lda #>sprite
	;sta z_h
	
	LoadPair z_hl,sprite
	
	;lda #<(sprite_end-sprite) ;Sprite Destination
	;sta z_c
	;lda #>(sprite_end-sprite)
	;sta z_b
	
	LoadPair z_bc,(sprite_end-sprite)
	
	jsr VLDIR			;Copy Sprite data to VRAM
	
	
	
	SetVeraAddr $1F4000	;Enable Sprites
	lda #1
	sta v_d1			;Sprite on
	
	
	;LoadPair z_hl,$0800	;RamAddr & Colordepth (4bpp - 16 color)
	LoadPair z_hl,$8808	;RamAddr & Colordepth (8bpp - 256 color)
	LoadPair z_ix,$10	;Xpos
	LoadPair z_iy,$10	;Ypos
SpriteAgain:	
	lda #0				;Hardware Spritenumber
	jsr SetSprite
	
	lda z_l
	clc
	
	adc #%00001000	;add $8 to the address (256 bytes ) - 8bpp / 256 colors 
	and #%00011111	;Limit to 4 frames
	
	;adc #%00000100	;add $4 to the address (128 bytes ) - 4bpp / 16 colors 
	;and #%00001111	;Limit to 4 frames
	
	sta z_l
	
	lda z_ixl
	clc
	adc #2
	sta z_ixl
	
	jsr pause
	jmp SpriteAgain
	
pause:
	ldx #255
pauseagain:
	ldy #255
pauseagain2:
	nop
	nop
	nop
	nop
	dey
	bne pauseagain2
	dex
	bne pauseagain2
	rts
	
	
MyText
    db "Hello worlds!",  255
sprite:		
	incbin "\ResAll\Sprites\Sprite_8bit.SPR"
	;incbin "\ResAll\Sprites\Sprite_4bit.SPR"
sprite_end:

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
			
		lda CursorY	 ;CursorY* 160*8 = Cursor Y * %00000000 00000101 00000000
		;asl					
		;rol z_d
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
		lda CursorX	;CursorX* 4 = Cursor Y * %00000000 00000000 00000100
		
		;asl
		;rol z_e
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
			ldx #4				;4 Bytes (2xpixels) Per Line
CharPixelAgain:				
			lda #0
			rol z_as			;Pop a bit off our font byte
			rol
			rol
			rol
			rol
			rol z_as			;Pop a bit off our font byte
			rol
			sta V_D1			;Send to screen ram
			
			dex 
			bne CharPixelAgain	;Next Pixel
			
			ldy #>(160-4)
			ldx #<(160-4)
			jsr AddVHML_YX			;Move down screen line (160 byte)
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

VLDIR:					;Copy z_BC bytes from z_HL to V_D1 
						;(address must be already selected)
        lda (z_HL)
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

;Use HardSprite A ... position to z_IX,z_IY... 
;				Show data at VRAM z_HL >>5

SetSprite:	
	sta z_as
	lda #0
	asl z_as		;x2
	rol
	asl z_as		;x4
	rol
	asl z_as		;x8
	rol
	
	clc
	adc #$50		;Sprite settings base $F5000
	tay
	ldx z_as
	lda #$1F		;$F5000 with Autoinc 
	
	jsr SetVeraHML	;Sprite Setting
		
	lda z_l			;128/4>>5 = %100 per sprite
	sta v_d1		; LLLLLLLL - Low address bits
	
	lda z_h			; Addr: $10000>>5 = $800
	sta v_d1		;C---HHHH  C=colordepth 
								;H=High address bits
	lda z_ixl
	sta v_d1		;XXXXXXXX - X Lbits
		
	lda z_ixh
	sta v_d1		;------XX - X Hbits
	
	lda z_iyl
	sta v_d1		;YYYYYYYY - Y Lbits
	
	lda z_iyh
	sta v_d1		;------YY -  Y Hbits
	
		; CCCCZZVH Z=Zdepth C=collision V=Vdepth H=Hdepth
	lda #%00001100	;Z=3
	sta v_d1	
	
		; HHWWPPPP - H=Height W=Width P=Palette 
	lda #%01010000			;(HW 0123 = 8/16/32/64 px)
	sta v_d1		;16x16 sprite
	
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		
CursorX: db 0
CursorY: db 0

NewLine:		
	stz CursorX				;Zero X
	inc CursorY				;Increase Y
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BitmapFont:
	incbin "\resall\Font96.FNT"
	
	
palette:
    dw $0000 ;0  -RGB
    dw $0808 ;1  -RGB
    dw $00FF ;2  -RGB
    dw $0FFF ;3  -RGB
    dw $0F0F ;4  -RGB
    dw $0FF0 ;5  -RGB
    dw $006D ;6  -RGB
    dw $0770 ;7  -RGB
    dw $00F0 ;8  -RGB
    dw $0080 ;9  -RGB
    dw $0F00 ;10  -RGB
    dw $000F ;11  -RGB
    dw $0CCC ;12  -RGB
    dw $0DDD ;13  -RGB
    dw $0EEE ;14  -RGB
    dw $0FFF ;15  -RGB

	include "\SrcAll\monitor.asm"
	include "\SrcAll\BasicFunctions.asm"	
