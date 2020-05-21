; Supaplex - Commander X16
;
; The main game loop
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


SP_GAMELOOP_ASM_ = 1

waitForVsync:
  !byte $CB  ; WAI instruction
  lda VSYNC_FLAG
  bne waitForVsync


gameLoop:
  jsr doInput

  jsr checkTime

  jsr centreMap

  inc ZP_FRAME_INDEX

  jsr updateFrame

  lda #1
  sta VSYNC_FLAG

	bra waitForVsync




updateFrame:
  +vset VERA_SPRITES + 2

  +sub16 ZP_PLAYER_X, ZP_SCROLL_X
  stx VERA_DATA0
  sta VERA_DATA0
  +sub16 ZP_PLAYER_Y, ZP_SCROLL_Y
  stx VERA_DATA0

  lda ZP_SCROLL_X_L
  sta VERA_L0_HSCROLL_L

  lda ZP_SCROLL_X_H
  sta VERA_L0_HSCROLL_H

  ldy ZP_SCROLL_Y_L
  lda ZP_SCROLL_Y_H

  ; update vert scroll
  sty VERA_L0_VSCROLL_L
  sta VERA_L0_VSCROLL_H
 
  lda ZP_PLAYER_SPEED_X
  beq .notMovingX
  
  +vset VERA_SPRITES

  lda ZP_FRAME_INDEX
  bit #16 / PLAYER_SPEED
  beq .sprOne
  bit #8 / PLAYER_SPEED
  beq .sprTwo
  +vWriteWord0 (MURPHY_ADDR + 256) >> 5
  bra .doneSpr
.sprOne
  +vWriteWord0 (MURPHY_ADDR + 384) >> 5
  bra .doneSpr
.sprTwo
  +vWriteWord0 (MURPHY_ADDR + 128) >> 5

.doneSpr

  +vset VERA_SPRITES + 6
  +vWriteByte0 $08  
  +vset VERA_SPRITES + 6
  lda ZP_PLAYER_SPEED_X
  and #$80
  bne .afterMovingX
  +vWriteByte0 $09  
  bra .afterMovingX

.notMovingX:
  +vset VERA_SPRITES
  +vWriteWord0 MURPHY_ADDR >> 5
.afterMovingX:


  lda ZP_PLAYER_SPEED_Y
  beq .doneSprY
  
  +vset VERA_SPRITES

  lda ZP_FRAME_INDEX
  bit #16 / PLAYER_SPEED
  beq .sprOneY
  bit #8 / PLAYER_SPEED
  beq .sprTwoY
  +vWriteWord0 (MURPHY_ADDR + 256) >> 5
  bra .doneSprY
.sprOneY
  +vWriteWord0 (MURPHY_ADDR + 384) >> 5
  bra .doneSprY
.sprTwoY
  +vWriteWord0 (MURPHY_ADDR + 128) >> 5

.doneSprY
  rts