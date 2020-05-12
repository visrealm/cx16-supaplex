!source "../common/kernal/constants.asm"
!source "../common/vera/constants.asm"
!source "../common/bootstrap.asm"

jmp entry


!source "../common/string.asm"
!source "../common/vera/vsync.asm"
!source "../common/vera/macros.asm"

; program entry
; --------------------------------
entry:

  +vLoadPcx staticPcx, TILE_BASE_ADDRESS, $20
  +vLoadPcx murphyPcx, TILE_BASE_ADDRESS + (128*32), $40
  

  jsr loadMap

  jsr configDisplay
  
  jsr registerVsyncIrq

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



loadMap:

  TILE_BASE_ADDRESS = $4000
  MAP_BASE_ADDRESS  = $A00
  
  
  +vreg VERA_CTRL, $00   
  +vset MAP_BASE_ADDRESS

  ldy #32

.nextMapRow:
  ldx #32

.nextMapCell:
  +vWriteByte0 $20
  +vWriteByte0 $20
  dex
  bne .nextMapCell
  dey
  bne .nextMapRow

  +vset MAP_BASE_ADDRESS + $08
  +vWriteWord0 $0010

  +vset TILE_BASE_ADDRESS

.doneLoad
  rts


configDisplay:
  +vreg VERA_L0_MAPBASE, MAP_BASE_ADDRESS >> 9
  +vreg VERA_L0_TILEBASE, (TILE_BASE_ADDRESS >> 9) | VERA_TILE_WIDTH_16 | VERA_TILE_HEIGHT_16
  +vreg VERA_L0_CONFIG, VERA_CONFIG_MAP_WIDTH_32 | VERA_CONFIG_MAP_HEIGHT_32 | VERA_CONFIG_4BPP
  +vreg VERA_DC_VIDEO, VERA_VIDEO_LAYER0_ENABLED | VERA_VIDEO_OUTPUT_VGA
  +vreg VERA_DC_HSCALE, VERA_SCALE_2x
  +vreg VERA_DC_VSCALE, VERA_SCALE_2x
  +vreg VERA_IEN, 1
  +vreg VERA_ISR, 1
  rts


!source "../common/vera/vera.asm"

!source "../common/vera/pcx.asm"

!source "src/strings.asm"

