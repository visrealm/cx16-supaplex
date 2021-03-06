; Supaplex - Commander X16
;
; Murphy (the main character)
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

!zone murphy {

; -----------------------------------------------------------------------------
; createPlayer
; -----------------------------------------------------------------------------
; Inputs:
;  ZP_ECS_CURRENT_ENTITY
;  ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y are set
; -----------------------------------------------------------------------------
createPlayer:
  lda ZP_CURRENT_CELL_X
  sta ZP_PLAYER_CELL_X
  lda ZP_CURRENT_CELL_Y
  sta ZP_PLAYER_CELL_Y
  lda ZP_ECS_CURRENT_ENTITY_LSB
  sta ZP_PLAYER_ENTITY_LSB
  lda ZP_ECS_CURRENT_ENTITY_MSB
  sta ZP_PLAYER_ENTITY_MSB

  +ldaTileId tileBlank
  jsr ecsSetTile

  rts


; -----------------------------------------------------------------------------
; update the murphy sprite
;
; HACK: this code is very temporary. just a hack to get some animation
; -----------------------------------------------------------------------------
updateMurphy:
  lda ZP_PLAYER_ENTITY_LSB
  sta ZP_ECS_CURRENT_ENTITY_LSB
  lda ZP_PLAYER_ENTITY_MSB
  sta ZP_ECS_CURRENT_ENTITY_MSB


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

  
; -----------------------------------------------------------------------------

} ; murphy