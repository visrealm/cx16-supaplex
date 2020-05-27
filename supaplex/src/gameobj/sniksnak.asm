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
  lda #ENEMY_FACING_UP
  jsr ecsSetEnemyState

  +ldaAnimId animSnikU2L
  sta ZP_ECS_CURRENT_ANIM_ID
  lda #0
  sta ZP_ECS_CURRENT_ANIM_FL

  jsr ecsSetAnimation

  jmp ecsAnimationPush
  ; rts


animationIdTable:
.l2lId: +byteAnimId animSnikL2L
.l2uId: +byteAnimId animSnikU2L
.l2rId: !byte 0
.l2dId: +byteAnimId animSnikL2D
.u2lId: +byteAnimId animSnikU2L
.u2uId: +byteAnimId animSnikU2U
.u2rId: +byteAnimId animSnikR2U
.u2dId: !byte 0
.r2lId: !byte 0
.r2uId: +byteAnimId animSnikR2U
.r2rId: +byteAnimId animSnikR2R
.r2dId: +byteAnimId animSnikD2R
.d2lId: +byteAnimId animSnikL2D
.d2uId: !byte 0
.d2rId: +byteAnimId animSnikD2R
.d2dId: +byteAnimId animSnikD2D


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