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

; A = X
; Y = Y
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
  dec NUM_INFOTRONS

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

  stz PLAYER_INPUT
  jsr JOYSTICK_GET
  eor #$ff
  ora PLAYER_INPUT
  sta PLAYER_INPUT

.afterTest
  clc
  lda PLAYER_OFFSET_X
  adc PLAYER_SPEED_X
  sta PLAYER_OFFSET_X
  bne +
  stz PLAYER_SPEED_X
+

  clc
  lda PLAYER_OFFSET_Y
  adc PLAYER_SPEED_Y
  sta PLAYER_OFFSET_Y
  bne +
  stz PLAYER_SPEED_Y
+

  ; no input if player moving
  lda PLAYER_OFFSET_X
  bne .playerMoving

  lda PLAYER_OFFSET_Y
  bne .playerMoving

  bra .allowInput

.playerMoving:

  rts


.allowInput:  
  lda PLAYER_INPUT
  bit #JOY_LEFT
  beq .testRight
  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  dec
  jsr testCell
  bcc +

  lda #-PLAYER_SPEED
  sta PLAYER_SPEED_X
  lda #(16 - PLAYER_SPEED)
  sta PLAYER_OFFSET_X

  ldy PLAYER_CELL_Y
  lda PLAYER_CELL_X
  jsr clearTile
  dec PLAYER_CELL_X
  jmp .doneTests
+
.testRight:
  lda PLAYER_INPUT
  bit #JOY_RIGHT
  beq .testUp
  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  inc

  jsr testCell
  bcc +

  lda #PLAYER_SPEED
  sta PLAYER_SPEED_X
  lda #-(16 - PLAYER_SPEED)
  sta PLAYER_OFFSET_X
  
  ldy PLAYER_CELL_Y
  lda PLAYER_CELL_X
  jsr clearTile
  inc PLAYER_CELL_X
  jmp .doneTests
+
.testUp:
  lda PLAYER_INPUT
  bit #JOY_UP
  beq .testDown
  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  dey
  jsr testCell
  bcc +
  
  lda #-PLAYER_SPEED
  sta PLAYER_SPEED_Y
  lda #(16 - PLAYER_SPEED)
  sta PLAYER_OFFSET_Y

  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  jsr clearTile
  dec PLAYER_CELL_Y
  jmp .doneTests
+
.testDown:
  lda PLAYER_INPUT
  bit #JOY_DOWN
  beq .doneTests
  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  iny

  jsr testCell
  bcc +

  lda #PLAYER_SPEED
  sta PLAYER_SPEED_Y
  lda #-(16 - PLAYER_SPEED)
  sta PLAYER_OFFSET_Y

  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  jsr clearTile
  inc PLAYER_CELL_Y
+
.doneTests:
  rts

; -----------------------------------------------------------------------------

}