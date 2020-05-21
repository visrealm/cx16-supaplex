; Supaplex - Commander X16
;
; Input routines
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


SP_INPUT_ASM_ = 1

!zone input {

; -----------------------------------------------------------------------------
; constants
; -----------------------------------------------------------------------------
PLAYER_SPEED = 2


; -----------------------------------------------------------------------------
; testCell: check a cell for suitability to invade
; -----------------------------------------------------------------------------
; Inputs:
;  A = cell X
;  Y = cell Y
; Returns:
;  C = if set, passable, otherwise, not
; -----------------------------------------------------------------------------
testCell:
  jsr vTile
  bne +
  +sfxPlay SFX_BASE_ID
  bra .cellPassable
+
  cmp #$31
  beq .cellPassable
  cmp #$50
  bne .cellNotPassable
  dec ZP_NUM_INFOTRONS

  +sfxPlay SFX_INFOTRON_ID

  jsr hudSetInfotrons

.cellPassable
  sec
  rts

.cellNotPassable:
  clc
  rts


; -----------------------------------------------------------------------------
; handle input
; -----------------------------------------------------------------------------
doInput:

  stz ZP_PLAYER_INPUT
  jsr JOYSTICK_GET
  eor #$ff
  ora ZP_PLAYER_INPUT
  sta ZP_PLAYER_INPUT

.afterTest
  clc
  lda ZP_PLAYER_OFFSET_X
  adc ZP_PLAYER_SPEED_X
  sta ZP_PLAYER_OFFSET_X
  bne +
  stz ZP_PLAYER_SPEED_X
+

  clc
  lda ZP_PLAYER_OFFSET_Y
  adc ZP_PLAYER_SPEED_Y
  sta ZP_PLAYER_OFFSET_Y
  bne +
  stz ZP_PLAYER_SPEED_Y
+

  ; no input if player moving
  lda ZP_PLAYER_OFFSET_X
  bne .playerMoving

  lda ZP_PLAYER_OFFSET_Y
  bne .playerMoving

  bra .allowInput

.playerMoving:

  rts


.allowInput:  
  lda ZP_PLAYER_INPUT
  bit #JOY_LEFT
  beq .testRight
  lda ZP_PLAYER_CELL_X
  ldy ZP_PLAYER_CELL_Y
  dec
  jsr testCell
  bcc +

  lda #-PLAYER_SPEED
  sta ZP_PLAYER_SPEED_X
  lda #(16 - PLAYER_SPEED)
  sta ZP_PLAYER_OFFSET_X

  ldy ZP_PLAYER_CELL_Y
  lda ZP_PLAYER_CELL_X
  jsr clearTile
  dec ZP_PLAYER_CELL_X
  jmp .doneTests
+
.testRight:
  lda ZP_PLAYER_INPUT
  bit #JOY_RIGHT
  beq .testUp
  lda ZP_PLAYER_CELL_X
  ldy ZP_PLAYER_CELL_Y
  inc

  jsr testCell
  bcc +

  lda #PLAYER_SPEED
  sta ZP_PLAYER_SPEED_X
  lda #-(16 - PLAYER_SPEED)
  sta ZP_PLAYER_OFFSET_X
  
  ldy ZP_PLAYER_CELL_Y
  lda ZP_PLAYER_CELL_X
  jsr clearTile
  inc ZP_PLAYER_CELL_X
  jmp .doneTests
+
.testUp:
  lda ZP_PLAYER_INPUT
  bit #JOY_UP
  beq .testDown
  lda ZP_PLAYER_CELL_X
  ldy ZP_PLAYER_CELL_Y
  dey
  jsr testCell
  bcc +
  
  lda #-PLAYER_SPEED
  sta ZP_PLAYER_SPEED_Y
  lda #(16 - PLAYER_SPEED)
  sta ZP_PLAYER_OFFSET_Y

  lda ZP_PLAYER_CELL_X
  ldy ZP_PLAYER_CELL_Y
  jsr clearTile
  dec ZP_PLAYER_CELL_Y
  jmp .doneTests
+
.testDown:
  lda ZP_PLAYER_INPUT
  bit #JOY_DOWN
  beq .doneTests
  lda ZP_PLAYER_CELL_X
  ldy ZP_PLAYER_CELL_Y
  iny

  jsr testCell
  bcc +

  lda #PLAYER_SPEED
  sta ZP_PLAYER_SPEED_Y
  lda #-(16 - PLAYER_SPEED)
  sta ZP_PLAYER_OFFSET_Y

  lda ZP_PLAYER_CELL_X
  ldy ZP_PLAYER_CELL_Y
  jsr clearTile
  inc ZP_PLAYER_CELL_Y
+
.doneTests:
  rts

; -----------------------------------------------------------------------------

}