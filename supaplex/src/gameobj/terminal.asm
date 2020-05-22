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

; -----------------------------------------------------------------------------
; createTerminal
; -----------------------------------------------------------------------------
; Inputs:
;  ZP_ECS_CURRENT_ENTITY
;  ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y are set
; -----------------------------------------------------------------------------
createTerminal:
  jsr ecsLocationSetCurrentEntityType
  jsr setLocation

  jsr ecsAnimSetCurrentEntityType
  lda #(animTermGreen - animationDefs) >> 3
  sta ZP_ECS_CURRENT_ANIM_ID
  lda #ANIM_FLAG_REPEAT
  sta ZP_ECS_CURRENT_ANIM_FL
  jsr setAnimation

  jsr pushAnimation
  rts

  rts

; -----------------------------------------------------------------------------

} ; terminal