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
  jsr vTile
  beq +
  cmp #$31
  beq +
  cmp #$50
  bne ++
  dec NUM_INFOTRONS
  jsr hudSetInfotrons
+

  lda #-PLAYER_SPEED
  sta PLAYER_SPEED_X
  lda #16
  sta PLAYER_OFFSET_X

  ldy PLAYER_CELL_Y
  lda PLAYER_CELL_X
  jsr clearTile
  dec PLAYER_CELL_X
  jmp .doneTests
++
.testRight:
  lda PLAYER_INPUT
  bit #JOY_RIGHT
  beq .testUp
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
  jsr hudSetInfotrons
+

  lda #PLAYER_SPEED
  sta PLAYER_SPEED_X
  lda #-16
  sta PLAYER_OFFSET_X
  
  ldy PLAYER_CELL_Y
  lda PLAYER_CELL_X
  jsr clearTile
  inc PLAYER_CELL_X
  jmp .doneTests
++
.testUp:
  lda PLAYER_INPUT
  bit #JOY_UP
  beq .testDown
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
  jsr hudSetInfotrons
+
  
  lda #-PLAYER_SPEED
  sta PLAYER_SPEED_Y
  lda #16
  sta PLAYER_OFFSET_Y

  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  jsr clearTile
  dec PLAYER_CELL_Y
  jmp .doneTests
++
.testDown:
  lda PLAYER_INPUT
  bit #JOY_DOWN
  beq .doneTests
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
  jsr hudSetInfotrons
+

  lda #PLAYER_SPEED
  sta PLAYER_SPEED_Y
  lda #-16
  sta PLAYER_OFFSET_Y

  lda PLAYER_CELL_X
  ldy PLAYER_CELL_Y
  jsr clearTile
  inc PLAYER_CELL_Y
++
.doneTests:
  rts

; -----------------------------------------------------------------------------

