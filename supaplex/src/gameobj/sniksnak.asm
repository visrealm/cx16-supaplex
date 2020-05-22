; Supaplex - Commander X16
;
; Snik Snak
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

!zone sniksnak {

; -----------------------------------------------------------------------------
; createSnikSnak
; -----------------------------------------------------------------------------
; Inputs:
;  ZP_ECS_CURRENT_ENTITY, ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y are set
; -----------------------------------------------------------------------------
createSnikSnak:
  jsr ecsLocationSetCurrentEntityType
  jsr setLocation

  jsr ecsAnimSetCurrentEntityType
  lda #(animSnikU2L - animationDefs) >> 3
  sta ZP_ECS_CURRENT_ANIM_ID
  stz ZP_ECS_CURRENT_ANIM_FL
  jsr setAnimation

  jsr pushAnimation
  rts


; -----------------------------------------------------------------------------
; snikSnakAnimCB
; -----------------------------------------------------------------------------
; Animation callback (when an animation completes)
; Inputs:
;  ZP_ECS_CURRENT_ENTITY
;  ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y
;  ZP_ECS_CURRENT_ANIM_ID, ZP_ECS_CURRENT_ANIM_FL
; -----------------------------------------------------------------------------
snikSnakAnimCB:
  lda ZP_ECS_CURRENT_ANIM_ID
  cmp #(animSnikU2L - animationDefs) >> 3
  bne +
  lda #(animSnikL2D - animationDefs) >> 3
  bra .doneSnikSnak
+
  cmp #(animSnikL2D - animationDefs) >> 3
  bne +
  lda #(animSnikD2R - animationDefs) >> 3
  bra .doneSnikSnak
+
  cmp #(animSnikD2R - animationDefs) >> 3
  bne +
  lda #(animSnikR2U - animationDefs) >> 3
  bra .doneSnikSnak
+
  cmp #(animSnikR2U - animationDefs) >> 3
  bne +
  lda #(animSnikU2L - animationDefs) >> 3
  bra .doneSnikSnak
+
.stop
  rts

.doneSnikSnak:  
  sta ZP_ECS_CURRENT_ANIM_ID
  stz ZP_ECS_CURRENT_ANIM_FL
  jsr pushAnimation
  rts

; -----------------------------------------------------------------------------


} ; sniksnak