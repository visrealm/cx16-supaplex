; Supaplex - Commander X16
;
; Level structure
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


SP_LEVEL_ASM_ = 1

; level structure:
; infotrons required
; name
; gravity

; -----------------------------------------------------------------------------
; constants
; -----------------------------------------------------------------------------
MAP_TILES_X       = 60
MAP_TILES_Y       = 24
MAP_TILES         = MAP_TILES_X * MAP_TILES_Y
MAP_PIXELS_X      = MAP_TILES_X * TILE_SIZE
MAP_PIXELS_Y      = MAP_TILES_Y * TILE_SIZE


LEVEL_TILES_BYTES          = 1440
LEVEL_HAS_GRAVITY_OFFSET   = LEVEL_TILES_BYTES + 4
LEVEL_NAME_OFFSET          = LEVEL_TILES_BYTES + 6
LEVEL_NAME_LENGTH          = 23
LEVEL_FREEZE_ZONKS_OFFSET  = LEVEL_TILES_BYTES + 29
LEVEL_NUM_INFOTRONS_OFFSET = LEVEL_TILES_BYTES + 30
LEVEL_NUM_SPECIAL_OFFSET   = LEVEL_TILES_BYTES + 31
LEVEL_SPECIAL_OFFSET 	     = LEVEL_TILES_BYTES + 32
LEVEL_NUM_SPECIAL 		     = 10
LEVEL_SPECIAL_BYTES 		   = 6

; -----------------------------------------------------------------------------
; load the map
; -----------------------------------------------------------------------------
loadMap:
 
  ; load to both odd and even locations
  +vchannel1
  +vset VRADDR_MAP_BASE_EVEN

  +vchannel0
  +vset VRADDR_MAP_BASE_ODD

  lda #<levelDat
  sta .loadLevelValue + 1
  lda #>levelDat
  sta .loadLevelValue + 2

  stz ZP_CURRENT_CELL_Y
  ldy #MAP_TILES_Y

.nextMapRow:
  stz ZP_CURRENT_CELL_X
  ldx #MAP_TILES_X

.nextMapCell:
  phx

.loadLevelValue
  lda levelDat
  sta ZP_CURRENT_OBJECT_TYPE
  
  jsr createGameObject

  ; double the index since our map lookup has 
  ; 2 bytes per tile type and store in y
  asl
  tax

  ; increment the lda address above
  +inc16 .loadLevelValue + 1

  ; restore y
  inc ZP_CURRENT_CELL_X
  plx
  dex

  ; pad to 64 tiles wide
  bne .nextMapCell
  !for i, 0, 3 {
    lda tileBlank
    sta VERA_DATA0
    sta VERA_DATA1
    lda tileBlank + 1
    sta VERA_DATA0
    sta VERA_DATA1
  }
  inc ZP_CURRENT_CELL_Y
  dey
  bne .nextMapRow

.doneLoad

updateMapBorder:

  TILE_BORDER_BR = 16
  TILE_BORDER_BL = 17
  TILE_BORDER_TR = 18
  TILE_BORDER_TL = 19
  TILE_BORDER_R  = 20
  TILE_BORDER_L  = 21
  TILE_BORDER_B  = 22
  TILE_BORDER_T  = 23

  ; load to both odd and even locations
  +vchannel1
  +vset VRADDR_MAP_BASE_EVEN, VERA_INCR_2

  +vchannel0
  +vset VRADDR_MAP_BASE_ODD, VERA_INCR_2

  lda #TILE_BORDER_TL
  sta VERA_DATA0
  sta VERA_DATA1

  lda #TILE_BORDER_T
  ldx #MAP_TILES_X - 2

.topCell:
  sta VERA_DATA0
  sta VERA_DATA1
  dex
  bne .topCell

  lda #TILE_BORDER_TR
  sta VERA_DATA0
  sta VERA_DATA1

  +vchannel1
  +vset VRADDR_MAP_BASE_EVEN + 128, VERA_INCR_128

  +vchannel0
  +vset VRADDR_MAP_BASE_ODD + 128, VERA_INCR_128

  lda #TILE_BORDER_L
  ldx #MAP_TILES_Y - 2

.leftCell:
  sta VERA_DATA0
  sta VERA_DATA1
  dex
  bne .leftCell

  +vchannel1
  +vset VRADDR_MAP_BASE_EVEN + 246, VERA_INCR_128

  +vchannel0
  +vset VRADDR_MAP_BASE_ODD + 246, VERA_INCR_128

  lda #TILE_BORDER_R
  ldx #MAP_TILES_Y - 2

.rightCell:
  sta VERA_DATA0
  sta VERA_DATA1
  dex
  bne .rightCell


  ; load to both odd and even locations
  +vchannel1
  +vset VRADDR_MAP_BASE_EVEN + (128 * 23), VERA_INCR_2

  +vchannel0
  +vset VRADDR_MAP_BASE_ODD + (128 * 23), VERA_INCR_2

  lda #TILE_BORDER_BL
  sta VERA_DATA0
  sta VERA_DATA1

  lda #TILE_BORDER_B
  ldx #MAP_TILES_X - 2

.bottomCell:
  sta VERA_DATA0
  sta VERA_DATA1
  dex
  bne .bottomCell

  lda #TILE_BORDER_BR
  sta VERA_DATA0
  sta VERA_DATA1

  rts
; -----------------------------------------------------------------------------



; -----------------------------------------------------------------------------
; vSetCurrent: set vram address to current tile
; -----------------------------------------------------------------------------
; inputs:
;  ZP_CURRENT_CELL_X/Y set
; -----------------------------------------------------------------------------
vSetCurrent:
  lda ZP_CURRENT_CELL_Y
  sta R7
  lda ZP_CURRENT_CELL_X
  asl
  asl
  lsr R7
  ror
  sta VERA_ADDRx_L
  lda R7
  adc #>VRADDR_MAP_BASE_ODD
  sta VERA_ADDRx_M
  lda #$10
  sta VERA_ADDRx_H
  rts

  ; -----------------------------------------------------------------------------
; vSetTemp: set vram address to temp tile
; -----------------------------------------------------------------------------
; inputs:
;  ZP_TEMP_CELL_X/Y set
; -----------------------------------------------------------------------------
vSetTemp:
  lda ZP_TEMP_CELL_Y
  sta R7
  lda ZP_TEMP_CELL_X
  asl
  asl
  lsr R7
  ror
  sta VERA_ADDRx_L
  lda R7
  adc #>VRADDR_MAP_BASE_ODD
  sta VERA_ADDRx_M
  lda #$10
  sta VERA_ADDRx_H
  rts

; -----------------------------------------------------------------------------
; vTile: get the contents of a cell using its x/y coordinates
; -----------------------------------------------------------------------------
; inputs:
;  a: Cell X index
;  y: Cell y index
; returns:
;  a: contents of cell
; -----------------------------------------------------------------------------
vTile:
  sty R4
  asl
  asl
  lsr R4
  ror
  sta VERA_ADDRx_L
  lda R4
  adc #>VRADDR_MAP_BASE_ODD
  sta VERA_ADDRx_M
  stz VERA_ADDRx_H ; disable auto-increment
  ldx #$10
  lda VERA_DATA0
  stx VERA_ADDRx_H
  rts
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; clearTile: clear a tile by coordinates
; -----------------------------------------------------------------------------
; inputs:
;  a: Cell X index
;  y: Cell y index
; -----------------------------------------------------------------------------
clearTile:
  jsr vTile
  lda tileBlank
  sta VERA_DATA0
  lda tileBlank + 1
  sta VERA_DATA0
  rts  
; -----------------------------------------------------------------------------

