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

; -----------------------------------------------------------------------------
; update the murphy sprite
;
; HACK: this code is very temporary. just a hack to get some animation
; -----------------------------------------------------------------------------
updateMurphy:
  lda ZP_PLAYER_SPEED_X
  beq .notMovingX
  
  +vset VERA_SPRITES

  lda ZP_FRAME_INDEX
  bit #16 / PLAYER_SPEED
  beq +
  bit #8 / PLAYER_SPEED
  beq ++
  +vWriteWord0 (MURPHY_ADDR + 256) >> 5
  bra +++
+
  +vWriteWord0 (MURPHY_ADDR + 384) >> 5
  bra +++
++
  +vWriteWord0 (MURPHY_ADDR + 128) >> 5
+++

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
  beq +++
  
  +vset VERA_SPRITES

  lda ZP_FRAME_INDEX
  bit #16 / PLAYER_SPEED
  beq +
  bit #8 / PLAYER_SPEED
  beq ++
  +vWriteWord0 (MURPHY_ADDR + 256) >> 5
  bra +++
+
  +vWriteWord0 (MURPHY_ADDR + 384) >> 5
  bra +++
++
  +vWriteWord0 (MURPHY_ADDR + 128) >> 5
+++

  rts