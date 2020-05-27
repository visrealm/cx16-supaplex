; Supaplex - Commander X16
;
; Computer terminal
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

!zone terminal {


OBJ_TYPE_EXIT = 7
OBJ_TYPE_TERM = 19

createSwitch:
  lda ZP_CURRENT_OBJECT_TYPE
  cmp #OBJ_TYPE_EXIT
  bne +
  bra createExit
+
  bra createTerminal

; -----------------------------------------------------------------------------
; createTerminal
; -----------------------------------------------------------------------------
; Inputs:
;  ZP_ECS_CURRENT_ENTITY
;  ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y are set
; -----------------------------------------------------------------------------
createTerminal:
  +ldaAnimId animTermGreen
  sta ZP_ECS_CURRENT_ANIM_ID
  lda #ANIM_FLAG_REPEAT
  sta ZP_ECS_CURRENT_ANIM_FL
  jsr ecsSetAnimation

  jmp ecsAnimationPush
  ;rts
; -----------------------------------------------------------------------------

createExit:
  rts


} ; terminal