; Supaplex - Commander X16
;
; Transitioning entities
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

; As a cell transitions, its actual location is immediately
; the new cell. However, the old cell can't yet be occupied
; So, this entity type is used as a placeholder. 
; While it's transitioning, it can be given an animation
; (explosions or explode to infotron) but usually empty



ECS_TRANSITIONING_ASM_ = 1

!ifndef CMN_QUEUE_ASM_ !error "Requires queue"


ecsEntitySetTransitioning:
  lda #ENTITY_TYPE_TRANSITION
  jsr ecsEntitySetType

  ; TODO. We don't necessarily need to waste an animation
  ;       slot with this (unless it's an explosion)
  ;       perhaps a separate queue
  +ldaAnimId animBlank
  sta ZP_ECS_CURRENT_ANIM_ID
  lda #0
  sta ZP_ECS_CURRENT_ANIM_FL

  jsr ecsSetAnimation
  jmp ecsAnimationPush

  rts


transitionAnimCB:
  lda #ENTITY_TYPE_EMPTY
  jsr ecsEntitySetType

  ; need to do this before we start peeking
  jsr ecsGetLocation

  jsr ecsLocationPeekUp
  jsr ecsTempEntityGetType

  tax
  lda entityTypeFlags1, x
  bit #ENTITY_FLAGL_CANFALL
  beq +
  jsr ecsLocationSwap2
+

  ; Here, we want to notify our surrounding cells
  ; that this cell just opened up

  rts




; =============================================================================
!zone ecsTransitioningComponent {
; -----------------------------------------------------------------------------



} ; ecsTransitioningComponent





; =============================================================================
!zone ecsTransitioningSystem {
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; transitioning queues
; -----------------------------------------------------------------------------
.entityLsbQueueId:  !byte $00
.entityMsbQueueId:  !byte $00

.entityLsbQueueMsb: !byte $00
.entityMsbQueueMsb: !byte $00




; -----------------------------------------------------------------------------
; animation callbacks
; -----------------------------------------------------------------------------
; Animation callback (when an animation completes)
;
; Inputs:
;  ZP_ECS_CURRENT_ENTITY
;  ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y
;  ZP_ECS_CURRENT_ANIM_ID, ZP_ECS_CURRENT_ANIM_FL
; -----------------------------------------------------------------------------

checkBelowCallbacks:
  !word nullCheckBelowCB
  !word fallingCheckBelowCB
  !word nullCheckBelowCB
  !word nullCheckBelowCB
  !word nullCheckBelowCB
  !word nullCheckBelowCB
  !word fallingCheckBelowCB
  !word nullCheckBelowCB
  !word nullCheckBelowCB
  !word nullCheckBelowCB
  !word fallingCheckBelowCB
  !word nullCheckBelowCB
  !word nullCheckBelowCB
  !word nullCheckBelowCB
  !word nullCheckBelowCB
  !word nullCheckBelowCB

; -----------------------------------------------------------------------------
; placeholder callbacks (not yet implemented)
; -----------------------------------------------------------------------------
nullCheckBelowCB:
fallingCheckBelowCB:
  rts

  
; -----------------------------------------------------------------------------
; JSR wrapper called for checkBelowCallbacks
; -----------------------------------------------------------------------------
checkBelowCallback:
  jsr ecsEntityGetType
  asl
  tax
  jmp (checkBelowCallbacks, x)
  ; above jump will rts

; -----------------------------------------------------------------------------
; ecsTransitioningSystemInit
; -----------------------------------------------------------------------------
; Initialise the falling system
; -----------------------------------------------------------------------------
ecsTransitioningSystemInit:
  rts



; -----------------------------------------------------------------------------
; ecsTransitioningSystemTick
; -----------------------------------------------------------------------------
; Called for each frame
; -----------------------------------------------------------------------------
ecsTransitioningSystemTick:
  rts



} ; ecsTransitioningSystem