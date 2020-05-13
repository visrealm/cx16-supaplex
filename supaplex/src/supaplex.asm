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

  STATIC_ADDR = TILE_BASE_ADDRESS
  PODIZO_ADDR = (STATIC_ADDR + (128*32))
  MURPHY_ADDR = (PODIZO_ADDR + (128*32))
  INFOTR_ADDR = (MURPHY_ADDR + (128*16))
  SNIKSN_ADDR = (INFOTR_ADDR + (128*16))
  TERMIN_ADDR = (SNIKSN_ADDR + (128*16))
  BUGBAS_ADDR = (TERMIN_ADDR + (128*16))
  EXPLOD_ADDR = (BUGBAS_ADDR + (128*16))
  ELECTR_ADDR = (EXPLOD_ADDR + (128*16))
  OVERLAY_ADDR = (ELECTR_ADDR + (128*16))
  OVERLAY_BOTTOM_ADDR = (OVERLAY_ADDR + (160*(240 - 24)))

  +vClear OVERLAY_ADDR, OVERLAY_BOTTOM_ADDR - OVERLAY_ADDR

  +vLoadPcx staticPcx, STATIC_ADDR, 1
  +vLoadPcx podizoPcx, PODIZO_ADDR, 2
  +vLoadPcx murphyPcx, MURPHY_ADDR, 3
  +vLoadPcx infotrPcx, INFOTR_ADDR, 4
  +vLoadPcx sniksnPcx, SNIKSN_ADDR, 5
  +vLoadPcx terminPcx, TERMIN_ADDR, 6
  +vLoadPcx bugbasPcx, BUGBAS_ADDR, 7
  +vLoadPcx explodPcx, EXPLOD_ADDR, 8
  +vLoadPcx electrPcx, ELECTR_ADDR, 9
  +vLoadPcx overlayPcx, OVERLAY_BOTTOM_ADDR, 10
  
  jsr loadMap

  jsr configDisplay
  
  jsr registerVsyncIrq

loop:
  lda VSYNC_FLAG
  beq tick  
  jmp loop


tick:
  ;jsr JOYSTICK_SCAN
  jsr JOYSTICK_GET
.testLeft:  
  bit #JOY_LEFT
  bne .testRight
  inc $00
  inc $00
.testRight:
  bit #JOY_RIGHT
  bne .testUp
  dec $00
  dec $00
.testUp:
  bit #JOY_UP
  bne .testDown
  dec $01
  dec $01
.testDown:
  bit #JOY_DOWN
  bne .doneTests
  inc $01
  inc $01

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

  ldy #24

.nextMapRow:
  ldx #60

.nextMapCell:
  phy
.label1
  lda levelDat
  asl
  tay

  inc .label1 + 1 
  bne +
  inc .label1 + 2
+

  lda tileMap,y
  sta VERA_DATA0
  iny
  lda tileMap,y
  sta VERA_DATA0
  ply
  dex
  bne .nextMapCell
  stz VERA_DATA0
  stz VERA_DATA0
  stz VERA_DATA0
  stz VERA_DATA0
  stz VERA_DATA0
  stz VERA_DATA0
  stz VERA_DATA0
  stz VERA_DATA0
  dey
  bne .nextMapRow

.doneLoad
  rts


configDisplay:
  +vreg VERA_L0_MAPBASE, MAP_BASE_ADDRESS >> 9
  +vreg VERA_L0_TILEBASE, (TILE_BASE_ADDRESS >> 9) | VERA_TILE_WIDTH_16 | VERA_TILE_HEIGHT_16
  +vreg VERA_L0_CONFIG, VERA_CONFIG_MAP_WIDTH_64 | VERA_CONFIG_MAP_HEIGHT_32 | VERA_CONFIG_4BPP
  +vreg VERA_L0_HSCROLL_H, 1

  +vreg VERA_L1_TILEBASE, (OVERLAY_ADDR >> 9)
  +vreg VERA_L1_CONFIG, VERA_CONFIG_BITMAP_MODE | VERA_CONFIG_4BPP
  +vreg VERA_L1_HSCROLL_H, 10

  +vreg VERA_DC_VIDEO, VERA_VIDEO_LAYER0_ENABLED | VERA_VIDEO_LAYER1_ENABLED | VERA_VIDEO_OUTPUT_VGA
  +vreg VERA_DC_HSCALE, VERA_SCALE_2x
  +vreg VERA_DC_VSCALE, VERA_SCALE_2x
  +vreg VERA_IEN, 1
  +vreg VERA_ISR, 1
  rts


!source "src/strings.asm"
!source "../common/vera/vera.asm"
!source "../common/vera/pcx.asm"


!align 255, 0
tileMap:
!binary "src/tilemap.bin"

levelDat:
!binary "bin/level1.dat"
