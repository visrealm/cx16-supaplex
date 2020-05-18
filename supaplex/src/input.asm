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

!zone input {

playBaseSound:
  phx
  pha
  +vreg VERA_AUDIO_CTRL, $1f
  +vreg VERA_AUDIO_RATE, $0

  +vchannel0
  +vset $3f00

  ldx #91

.loop:
  lda VERA_DATA0
  sta $9F3D
  dex
  bne .loop

  +vreg VERA_AUDIO_RATE, $10

  pla
  plx
  rts

; A = X
; Y = Y
testCell:
  jsr vTile
  bne +
  jsr playBaseSound
  bra .cellPassable
+
  cmp #$31
  beq .cellPassable
  cmp #$50
  bne .cellNotPassable
  dec NUM_INFOTRONS
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

.testLeft:  
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
  lda #16
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
  lda #-16
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
  lda #16
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
  lda #-16
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