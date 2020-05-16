; Supaplex - Commander X16
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

!source "../common/kernal/constants.asm"
!source "../common/vera/constants.asm"
!source "../common/bootstrap.asm"

SCROLL_X      = $a0
SCROLL_X_L    = SCROLL_X
SCROLL_X_H    = SCROLL_X + 1
SCROLL_Y      = $a2
SCROLL_Y_L    = SCROLL_Y
SCROLL_Y_H    = SCROLL_Y + 1

PLAYER_X      = $a4
PLAYER_X_L    = PLAYER_X
PLAYER_X_H    = PLAYER_X + 1
PLAYER_Y      = $a6
PLAYER_Y_L    = PLAYER_Y
PLAYER_Y_H    = PLAYER_Y + 1

PLAYER_SPEED = 2


PLAYER_CELL_X = $b0
PLAYER_CELL_Y = $b1
PLAYER_INPUT  = $b4

NUM_INFOTRONS   = $c3
PLAYER_SPEED_X  = $c4
PLAYER_OFFSET_X = $c5
PLAYER_SPEED_Y  = $c6
PLAYER_OFFSET_Y = $c7

PLAYER_FACING = $c8

FRAME_INDEX   = $d3

SPRITE_TYPE_TABLE = $d0 ; - $91 ; lookup to spriteTypes in gameobj.asm

; set up sprite types table
lda #<spriteTypes
sta SPRITE_TYPE_TABLE
lda #>spriteTypes
sta SPRITE_TYPE_TABLE + 1

;stz PLAYER_SPEED_X
;stz PLAYER_OFFSET_X
;stz PLAYER_SPEED_Y
;stz PLAYER_OFFSET_Y
;stz PLAYER_FACING

jmp entry


; VERA memory map:
;    $00     (0) -   $9FF  (2559) - (2560 bytes): UNUSED
;   $A00  (2560) -  $19FF  (6655) - (64 x 32 x 2 = 4096 bytes): even frame map
;  $1A00  (6656) -  $29FF (10751) - (64 x 32 x 2 = 4096 bytes): odd frame map
;  $2A00 (10752) -  $3FFF (16383) - (5632 bytes): UNUSED
;  $4000 (16384) -  $BFFF (49151) - (16 x 16 x 128 = 32768 bytes): L0 tiles
;  $C000 (49152) - $155FF (87551) - (320 x 240 / 2 = 38400 bytes): L1 overlay
; $15600 (87552) - $1F9BF (129471) - (41920 bytes): UNUSED

TILE_SIZE         = 16
HALF_TILE_SIZE    = TILE_SIZE / 2
MAP_TILES_X = 60
MAP_TILES_Y = 24
MAP_TILES   = MAP_TILES_X * MAP_TILES_Y
MAP_PIXELS_X = MAP_TILES_X * TILE_SIZE
MAP_PIXELS_Y = MAP_TILES_Y * TILE_SIZE

DISPLAY_SIZE_X  = 320
DISPLAY_SIZE_Y  = 240
BOTTOM_PANEL_SIZE_Y  = 24
VISIBLE_AREA_X  = DISPLAY_SIZE_X
VISIBLE_AREA_Y  = DISPLAY_SIZE_Y - BOTTOM_PANEL_SIZE_Y
VISIBLE_AREA_CX = VISIBLE_AREA_X / 2
VISIBLE_AREA_CY = VISIBLE_AREA_Y / 2

BORDER_SIZE = 8
MAX_SCROLL_X = MAP_PIXELS_X - VISIBLE_AREA_X - BORDER_SIZE
MAX_SCROLL_Y = MAP_PIXELS_Y - VISIBLE_AREA_Y - BORDER_SIZE

MAP_BASE_ADDRESS_EVEN  =  $A00
MAP_BASE_ADDRESS_ODD   = $1A00
TILE_BASE_ADDRESS = $4000


!source "../common/util.asm"
!source "../common/string.asm"
!source "../common/vera/vsync.asm"
!source "../common/vera/macros.asm"

; a: = Cell X index
; y: = Cell y index
; returns:
; x: contents of cell
vTile:
  sty R4
  asl
  asl
  lsr R4
  ror
  sta VERA_ADDRx_L
  lda R4
  adc #>MAP_BASE_ADDRESS_ODD
  sta VERA_ADDRx_M
  stz VERA_ADDRx_H
  ldx #$10
  lda VERA_DATA0
  stx VERA_ADDRx_H
  rts

; a: = Cell X index
; y: = Cell y index
clearTile:
  jsr vTile
  lda #$31
  sta VERA_DATA0
  lda #$20
  sta VERA_DATA0
  rts  



; tileToWorldX: convert horizontal cell index to map pixel
; inputs:   a - Cell index
; outputs:  a - Low byte
;           x - High byte
tileToWorldX:
  ldx #0

  ; times player position by 16 
  ; (1-59, so can safely shift twice before checking carry)
  asl 
  asl
  asl
  bcc+
  ldx #$02  ; set x to 2, because we're 
            ; going to shift one more time
            ; this way we can ignore x in that
+
  asl
  bcc+
  inx
+
  rts
; end tileToWorldX

; tileToWorldY: convert horizontal cell index to map pixel
; inputs:   a - Cell index
; outputs:  a - Low byte
;           x - High byte
tileToWorldY:
  ldx #0
  
  ; (1-22, so can safely shift thrice before checking carry)
  asl
  asl
  asl
  asl
  bcc+
  inx
+
  rts
; end tileToWorldY





; vcell2px: convert vertical   cell index to map pixel
; map





centreMap:

; set starting scroll position 
; based on player location
  lda PLAYER_CELL_X
  jsr tileToWorldX

  sta PLAYER_X_L

  lda PLAYER_OFFSET_X
  beq .afterOffset
  bpl .posOffset
  ; neg offset
  clc
  adc PLAYER_X_L
  sta PLAYER_X_L
  bcs .afterOffset
  dex
  bra  .afterOffset
.posOffset:
  clc
  adc PLAYER_X_L
  sta PLAYER_X_L
  bcc .afterOffset
  inx
  bra  .afterOffset

.afterOffset:
  lda PLAYER_X_L
  stx PLAYER_X_H

; adjust to screen centre
  sec
  sbc #(VISIBLE_AREA_CX - HALF_TILE_SIZE)
  bcs +
  dex  
+

  cpx #$00
  bpl +
-
  lda #BORDER_SIZE
  stz SCROLL_X_H
  sta SCROLL_X_L
  bra .afterSetScrollX
+
  bne +
  cmp #BORDER_SIZE
  bcs +
  bra -
+
  +cmp16xa MAX_SCROLL_X
  bcc +
  ldx #>MAX_SCROLL_X
  lda #<MAX_SCROLL_X
+

  stx SCROLL_X_H
  sta SCROLL_X_L
.afterSetScrollX:


  lda PLAYER_CELL_Y
  jsr tileToWorldY

  sta PLAYER_Y_L

  lda PLAYER_OFFSET_Y
  beq .afterOffsetY
  bpl .posOffsetY
  ; neg offset
  clc
  adc PLAYER_Y_L
  sta PLAYER_Y_L
  bcs .afterOffsetY
  dex
  bra  .afterOffsetY
.posOffsetY:
  clc
  adc PLAYER_Y_L
  sta PLAYER_Y_L
  bcc .afterOffsetY
  inx
  bra  .afterOffsetY

.afterOffsetY:
  lda PLAYER_Y_L
  stx PLAYER_Y_H
  ; adjust to screen centre
  sec
  sbc #(VISIBLE_AREA_CY - HALF_TILE_SIZE)
  bcs +
  dex
+

  cpx #$00
  bpl +
-
  lda #BORDER_SIZE
  stz SCROLL_Y_H
  sta SCROLL_Y_L
  bra .afterSetScrollY
+
  bne +
  cmp #BORDER_SIZE
  bcs +
  bra -
+
  +cmp16xa MAX_SCROLL_Y
  bcc +
  ldx #>MAX_SCROLL_Y
  lda #<MAX_SCROLL_Y
+

  stx SCROLL_Y_H
  sta SCROLL_Y_L
.afterSetScrollY:



  ;lda PLAYER_INPUT
  ;sta PLAYER_X_L


  rts


doInput:
  stz PLAYER_SPEED_X
  stz PLAYER_OFFSET_X
  stz PLAYER_SPEED_Y
  stz PLAYER_OFFSET_Y


.testLeft:  
  lda PLAYER_INPUT
  bit #JOY_LEFT
  bne .testRight
  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  dec
  jsr vTile
  beq +
  cmp #$31
  beq +
  cmp #$50
  bne ++
  dec NUM_INFOTRONS
  jsr updateNumInfotrons
+

  lda #-PLAYER_SPEED
  sta PLAYER_SPEED_X
  lda #16
  sta PLAYER_OFFSET_X

  ldy PLAYER_CELL_Y
  lda PLAYER_CELL_X
  jsr clearTile
  dec PLAYER_CELL_X
  rts
++
.testRight:
  lda PLAYER_INPUT
  bit #JOY_RIGHT
  bne .testUp
  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  inc
  jsr vTile
  beq +
  cmp #$31
  beq +
  cmp #$50
  bne ++
  dec NUM_INFOTRONS
  jsr updateNumInfotrons
+

  lda #PLAYER_SPEED
  sta PLAYER_SPEED_X
  lda #-16
  sta PLAYER_OFFSET_X
  
  ldy PLAYER_CELL_Y
  lda PLAYER_CELL_X
  jsr clearTile
  inc PLAYER_CELL_X
  rts
++
.testUp:
  lda PLAYER_INPUT
  bit #JOY_UP
  bne .testDown
  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  dey
  jsr vTile
  beq +
  cmp #$31
  beq +
  cmp #$50
  bne ++
  dec NUM_INFOTRONS
  jsr updateNumInfotrons
+
  
  lda #-PLAYER_SPEED
  sta PLAYER_SPEED_Y
  lda #16
  sta PLAYER_OFFSET_Y

  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  jsr clearTile
  dec PLAYER_CELL_Y
  rts
++
.testDown:
  lda PLAYER_INPUT
  bit #JOY_DOWN
  bne .doneTests
  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  iny
  jsr vTile
  beq +
  cmp #$31
  beq +
  cmp #$50
  bne ++
  dec NUM_INFOTRONS
  jsr updateNumInfotrons
+

  lda #PLAYER_SPEED
  sta PLAYER_SPEED_Y
  lda #-16
  sta PLAYER_OFFSET_Y

  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  jsr clearTile
  inc PLAYER_CELL_Y
  rts
++
.doneTests:
  rts


; program entry
; --------------------------------
entry:
  +vreg VERA_DC_VIDEO, $00

  STATIC_ADDR = TILE_BASE_ADDRESS
  PODIZO_ADDR = (STATIC_ADDR + (128*32))
  MURPHY_ADDR = (PODIZO_ADDR + (128*32))
  INFOTR_ADDR = (MURPHY_ADDR + (128*16))
  SNIKSN_ADDR = (INFOTR_ADDR + (128*16))
  TERMIN_ADDR = (SNIKSN_ADDR + (128*16))
  BUGBAS_ADDR = (TERMIN_ADDR + (128*16))
  EXPLOD_ADDR = (BUGBAS_ADDR + (128*16))
  ELECTR_ADDR = (EXPLOD_ADDR + (128*16))
  FONT_ADDR =   (ELECTR_ADDR + (128*16)) 
  OVERLAY_ADDR = $C000
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
  +vLoadPcx fontPcx,    FONT_ADDR, 10
  
  jsr loadMap

  jsr centreMap

  jsr configDisplay
  
  stz FRAME_INDEX

  jsr registerVsyncIrq
  

loop:
  lda VSYNC_FLAG

  beq tick
  jmp loop


tick:

  jsr JOYSTICK_GET
  sta PLAYER_INPUT

.afterTest
  lda FRAME_INDEX
  and #$07
  cmp #$04
  bne .afterInput
  
  jsr doInput

.afterInput
  jsr centreMap

  +vset VERA_SPRITES + 2

  +sub16 PLAYER_X, SCROLL_X
  stx VERA_DATA0
  sta VERA_DATA0
  +sub16 PLAYER_Y, SCROLL_Y
  stx VERA_DATA0

  lda SCROLL_X_L
  sta VERA_L0_HSCROLL_L

  lda SCROLL_X_H
  sta VERA_L0_HSCROLL_H

  ldy SCROLL_Y_L
  lda SCROLL_Y_H

  ; update vert scroll
  sty VERA_L0_VSCROLL_L
  sta VERA_L0_VSCROLL_H
 
  
  clc
  lda PLAYER_OFFSET_X
  adc PLAYER_SPEED_X
  sta PLAYER_OFFSET_X

  lda PLAYER_SPEED_X
  beq .notMovingX
  
  +vset VERA_SPRITES

  lda FRAME_INDEX
  bit #$04
  beq .sprOne
  bit #$02
  beq .sprTwo
  +vWriteByte0 ((MURPHY_ADDR + 256) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 256) >> 13) & $ff
  bra .doneSpr
.sprOne
  +vWriteByte0 ((MURPHY_ADDR + 384) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 384) >> 13) & $ff
  bra .doneSpr
.sprTwo
  +vWriteByte0 ((MURPHY_ADDR + 128) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 128) >> 13) & $ff

.doneSpr

  +vset VERA_SPRITES + 6
  +vWriteByte0 $08  
  +vset VERA_SPRITES + 6
  lda PLAYER_SPEED_X
  and #$80
  bne .afterMovingX
  +vWriteByte0 $09  
  bra .afterMovingX

.notMovingX:
  +vset VERA_SPRITES
  +vWriteByte0 ((MURPHY_ADDR) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR) >> 13) & $ff
.afterMovingX:

  clc
  lda PLAYER_OFFSET_Y
  adc PLAYER_SPEED_Y
  sta PLAYER_OFFSET_Y


  lda PLAYER_SPEED_Y
  beq .afterMovingY
  
  +vset VERA_SPRITES

  lda FRAME_INDEX
  bit #$04
  beq .sprOneY
  bit #$02
  beq .sprTwoY
  +vWriteByte0 ((MURPHY_ADDR + 256) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 256) >> 13) & $ff
  bra .doneSprY
.sprOneY
  +vWriteByte0 ((MURPHY_ADDR + 384) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 384) >> 13) & $ff
  bra .doneSprY
.sprTwoY
  +vWriteByte0 ((MURPHY_ADDR + 128) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 128) >> 13) & $ff

.doneSprY


.afterMovingY:

  inc FRAME_INDEX


  lda #1
  sta VSYNC_FLAG

	jmp loop



; configure the display
; -----------------------------------------------------------------------------
configDisplay:
  +vreg VERA_L0_MAPBASE, MAP_BASE_ADDRESS_ODD >> 9
  +vreg VERA_L0_TILEBASE, (TILE_BASE_ADDRESS >> 9) | VERA_TILE_WIDTH_16 | VERA_TILE_HEIGHT_16
  +vreg VERA_L0_CONFIG, VERA_CONFIG_MAP_WIDTH_64 | VERA_CONFIG_MAP_HEIGHT_32 | VERA_CONFIG_4BPP
  +vreg VERA_L0_HSCROLL_H, 1

  +vreg VERA_L1_TILEBASE, (OVERLAY_ADDR >> 9)
  +vreg VERA_L1_CONFIG, VERA_CONFIG_BITMAP_MODE | VERA_CONFIG_4BPP
  +vreg VERA_L1_HSCROLL_H, 10

  +vreg VERA_DC_VIDEO, VERA_VIDEO_LAYER0_ENABLED | VERA_VIDEO_LAYER1_ENABLED | VERA_VIDEO_SPRITES_ENABLED | VERA_VIDEO_OUTPUT_VGA
  +vreg VERA_DC_HSCALE, VERA_SCALE_2x
  +vreg VERA_DC_VSCALE, VERA_SCALE_2x
  +vreg VERA_IEN, 1
  +vreg VERA_ISR, 1

  +vset VERA_SPRITES
  +vWriteByte0 (MURPHY_ADDR >> 5) & $ff
  +vWriteByte0 (MURPHY_ADDR >> 13) & $ff
  +vWriteByte0 VISIBLE_AREA_CX - HALF_TILE_SIZE
  +vWriteByte0 0
  +vWriteByte0 VISIBLE_AREA_CY - HALF_TILE_SIZE
  +vWriteByte0 0
  +vWriteByte0 $08
  +vWriteByte0 $53

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 3) + 44

  ldx #<playerName
  ldy #>playerName

  jsr outputText


  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 13) + 32

  ldx #<levelDat + LEVEL_NAME_OFFSET
  ldy #>levelDat + LEVEL_NAME_OFFSET

  jsr outputText

  lda levelDat + LEVEL_NUM_INFOTRONS_OFFSET
  sta NUM_INFOTRONS

  jsr updateNumInfotrons

  rts

updateNumInfotrons:
  lda NUM_INFOTRONS
  jsr bin2bcd8

  +vchannel1
  +vset FONT_ADDR

  +vchannel0
  +vset OVERLAY_BOTTOM_ADDR + (160 * 14) + 136

  ldx R8H
  lda R8L
  jsr output3BcdDigits

  +vchannel0
  rts


!source "src/strings.asm"
!source "src/text.asm"
!source "src/level.asm"
!source "../common/vera/vera.asm"
!source "../common/vera/pcx.asm"


!align 255, 0
tileMap:
!binary "src/tilemap.bin"

levelDat:
!binary "bin/level2.dat"

!source "src/gameobj.asm"

playerName:
!text "TROY",0


levelRows:
!for i, 0, MAP_TILES_Y - 1 {
  !word levelDat + (i * MAP_TILES_X)
}