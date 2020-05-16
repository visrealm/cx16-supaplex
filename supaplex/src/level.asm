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

; level structure:
; infotrons required
; name
; gravity

	
	LEVEL_TILES_BYTES          = 1440
  LEVEL_HAS_GRAVITY_OFFSET   = LEVEL_TILES_BYTES + 4
  LEVEL_NAME_OFFSET          = LEVEL_TILES_BYTES + 6
	LEVEL_FREEZE_ZONKS_OFFSET  = LEVEL_TILES_BYTES + 29
	LEVEL_NUM_INFOTRONS_OFFSET = LEVEL_TILES_BYTES + 30
	LEVEL_NUM_SPECIAL_OFFSET   = LEVEL_TILES_BYTES + 31
	LEVEL_SPECIAL_OFFSET 	     = LEVEL_TILES_BYTES + 32
	LEVEL_NUM_SPECIAL 		     = 10
	LEVEL_SPECIAL_BYTES 		   = 6

  
; load the map
; -----------------------------------------------------------------------------
loadMap:
 
  ; load to both odd and even locations
  +vchannel1
  +vset MAP_BASE_ADDRESS_EVEN

  +vchannel0
  +vset MAP_BASE_ADDRESS_ODD

  lda #<levelDat
  sta .loadLevelValue + 1
  lda #>levelDat
  sta .loadLevelValue + 2

  ldy #24

.nextMapRow:
  ldx #60

.nextMapCell:
  phy

.loadLevelValue
  lda levelDat
  
  ; check for player cell
  cmp #3
  bne +
  stx PLAYER_CELL_X
  sty PLAYER_CELL_Y
+
  ; double the index since our map lookup has 
  ; 2 bytes per tile type and store in y
  asl
  tay

  ; increment the lda address above
  +inc16 .loadLevelValue + 1

  ; load the two tile bytes for vera
  lda tileMap,y
  sta VERA_DATA0
  sta VERA_DATA1
  iny
  lda tileMap,y
  sta VERA_DATA0
  sta VERA_DATA1

  ; restore y
  ply
  dex

  ; pad to 64 tiles wide
  bne .nextMapCell
  !for i, 0, 3 {
    lda tileMap
    sta VERA_DATA0
    sta VERA_DATA1
    lda tileMap + 1
    sta VERA_DATA0
    sta VERA_DATA1
  }
  dey
  bne .nextMapRow

.doneLoad

  ; adjust the player offset
  sec
  lda #60
  sbc PLAYER_CELL_X
  sta PLAYER_CELL_X
  lda #24
  sbc PLAYER_CELL_Y
  sta PLAYER_CELL_Y

  ; update borders

  ; load to both odd and even locations
  +vchannel1
  +vset MAP_BASE_ADDRESS_EVEN, VERA_INCR_2

  +vchannel0
  +vset MAP_BASE_ADDRESS_ODD, VERA_INCR_2

  lda #19 ; top left
  sta VERA_DATA0
  sta VERA_DATA1

  lda #23
  ldx #58

.topCell:
  sta VERA_DATA0
  sta VERA_DATA1
  dex
  bne .topCell

  lda #18 ; top right
  sta VERA_DATA0
  sta VERA_DATA1

  +vchannel1
  +vset MAP_BASE_ADDRESS_EVEN + 128, VERA_INCR_128

  +vchannel0
  +vset MAP_BASE_ADDRESS_ODD + 128, VERA_INCR_128

  lda #21
  ldx #22

.leftCell:
  sta VERA_DATA0
  sta VERA_DATA1
  dex
  bne .leftCell

  +vchannel1
  +vset MAP_BASE_ADDRESS_EVEN + 246, VERA_INCR_128

  +vchannel0
  +vset MAP_BASE_ADDRESS_ODD + 246, VERA_INCR_128

  lda #20
  ldx #22

.rightCell:
  sta VERA_DATA0
  sta VERA_DATA1
  dex
  bne .rightCell


  ; load to both odd and even locations
  +vchannel1
  +vset MAP_BASE_ADDRESS_EVEN + (128 * 23), VERA_INCR_2

  +vchannel0
  +vset MAP_BASE_ADDRESS_ODD + (128 * 23), VERA_INCR_2

  lda #17 ; bottom left
  sta VERA_DATA0
  sta VERA_DATA1

  lda #22
  ldx #58

.bottomCell:
  sta VERA_DATA0
  sta VERA_DATA1
  dex
  bne .bottomCell

  lda #16 ; bottom right
  sta VERA_DATA0
  sta VERA_DATA1



  rts

; end loadMap

