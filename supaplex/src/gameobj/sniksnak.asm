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
  jsr ecsEnemySetCurrentEntityType
  lda #ENEMY_FACING_UP
  jsr setEnemyState


  jsr ecsAnimSetCurrentEntityType
  lda #(animSnikU2L - animationDefs) >> 3
  sta ZP_ECS_CURRENT_ANIM_ID
  lda #0
  sta ZP_ECS_CURRENT_ANIM_FL
  jsr setAnimation

  jmp ecsAnimationPush
  ; rts


animationIdTable:
.l2lId: !byte (animSnikL2L - animationDefs) >> 3  ; todo
.l2uId: !byte (animSnikU2L - animationDefs) >> 3  ; r
.l2rId: !byte 0
.l2dId: !byte (animSnikL2D - animationDefs) >> 3
.u2lId: !byte (animSnikU2L - animationDefs) >> 3
.u2uId: !byte (animSnikU2U - animationDefs) >> 3  ; todo
.u2rId: !byte (animSnikR2U - animationDefs) >> 3  ; r
.u2dId: !byte 0
.r2lId: !byte 0
.r2uId: !byte (animSnikR2U - animationDefs) >> 3 
.r2rId: !byte (animSnikR2R - animationDefs) >> 3  ; todo
.r2dId: !byte (animSnikD2R - animationDefs) >> 3  ; r
.d2lId: !byte (animSnikL2D - animationDefs) >> 3  ;IdrId
.d2uId: !byte 0
.d2rId: !byte (animSnikD2R - animationDefs) >> 3 
.d2dId: !byte (animSnikD2D - animationDefs) >> 3 ; todo


animationFlTable:
.l2lFl: !byte 0
.l2uFl: !byte ANIM_FLAG_REVERSE | $07
.l2rFl: !byte 0
.l2dFl: !byte 0
.u2lFl: !byte 0
.u2uFl: !byte 0
.u2rFl: !byte ANIM_FLAG_REVERSE | $07
.u2dFl: !byte 0
.r2lFl: !byte 0
.r2uFl: !byte 0
.r2rFl: !byte 0
.r2dFl: !byte ANIM_FLAG_REVERSE | $07
.d2lFl: !byte ANIM_FLAG_REVERSE | $07
.d2uFl: !byte 0
.d2rFl: !byte 0
.d2dFl: !byte 0



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

  jsr enemyAnimCB

  tax
    
  lda animationIdTable, x
  sta ZP_ECS_CURRENT_ANIM_ID
  lda animationFlTable, x
  sta ZP_ECS_CURRENT_ANIM_FL

  jmp ecsAnimationPush
  ; rts
; -----------------------------------------------------------------------------


} ; sniksnak