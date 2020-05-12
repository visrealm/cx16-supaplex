!source "..\common\kernal\constants.asm"
!source "..\common\vera\constants.asm"
!source "..\common\bootstrap.asm"

jmp entry

Default_irq_handler: !le16 $0000

VSYNC_FLAG = $30

!source "..\common\string.asm"
!source "..\common\vera\vera.asm"

!macro vLoadPcx filename, vramAddress, palOffset {
  
  +vchannel1
  
  +vset VERA_PALETTE + 32 ;+vset $1FA20;(VERA_PALETTE + (palOffset << 4))
  +vchannel0
  +vset vramAddress

  ldx #<filename
  ldy #>filename
  jsr strLen
  
  jsr loadPcxFile
}

; program entry
; --------------------------------
entry:

  
 jsr video_init
+vLoadRaw murphyBin, $4080
  +vLoadPcx murphyPcx, $4080, $02

  ;+vset $1F9C0
  ;+vdata016 590
  ;+vdata0 $7f
  ;+vdata0 $3f

  ;+vLoadRaw murphyBin, $4080
  ;+vLoadPcx murphyPcx, $4080, $02
 ; +vset $4080

    lda $0314
    sta Default_irq_handler
    lda $0315
    sta Default_irq_handler+1

    lda #<custom_irq_handler
    sta $0314
    lda #>custom_irq_handler+1
    sta $0315

  stz $00


anykeyloop:
  jsr JOYSTICK_SCAN
  jsr JOYSTICK_GET
  cmp #$ff
  bne anykeyloop


loop:
  lda VSYNC_FLAG
  beq tick  
  jmp loop


tick:
  jsr JOYSTICK_SCAN
  jsr JOYSTICK_GET
.testLeft:  
  bit #JOY_LEFT
  bne .testRight
  ldx $00
  inx
  stx $00
.testRight:
  bit #JOY_RIGHT
  bne .testUp
  ldx $00
  dex
  stx $00
.testUp:
  bit #JOY_UP
  bne .testDown
  ldx $01
  dex
  stx $01
.testDown:
  bit #JOY_DOWN
  bne .doneTests
  ldx $01
  inx
  stx $01

.doneTests  
  lda $00
  sta VERA_L0_HSCROLL_L
  lda $01
  sta VERA_L0_VSCROLL_L

  lda #1
  sta VSYNC_FLAG
	jmp loop


custom_irq_handler:
    lda $9F27
    and #$01
    beq irq_done

    ; Whatever code your program
    ; wanted to execute...
    stz VSYNC_FLAG


    lda #$01
    
    sta $9F27

    ; Return to whatever had been interrupted:
irq_done:
    jmp (Default_irq_handler)

murphyPcx:  
!text "murphy.pcx",0
murphyBin:  
!text "murphy.bin",0


!source "..\common\vera\pcx.asm"

errorStr:  !pet "error",13,0
leftStr:  !pet "left",13,0
rightStr: !pet "right",13,0