!source "..\common\kernal\constants.asm"
!source "..\common\vera\constants.asm"
!source "..\common\bootstrap.asm"

jmp entry

!source "..\common\string.asm"
!source "..\common\vera\vera.asm"

; program entry
; --------------------------------
entry:

+video_init

	lda	#1			; Logical file number
	ldx	#8			; Device 8 = sd card
	ldy	#0			; 0=ignore address in bin file (2 first bytes)
					; 1=use address in bin file
	jsr	SETLFS

	lda	#(End_fname-Fname)	; Length of filename
	ldx	#<Fname			; Low byte of Fname address
	ldy	#>Fname			; High byte of Fname address
	jsr	SETNAM

	ldy	#$01			; VERA HIGH address
	ldx	#$20			; VERA LOW address
	lda	#$fa			; VERA BANK + 2
	jsr	LOAD			; Load binary file into VRAM, ignoring 2 first bytes

	jmp *
	rts


jmp *

rts		    ; program exit

Fname	!text	"murphy.bin"
End_fname
