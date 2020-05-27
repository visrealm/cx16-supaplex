; Supaplex - Commander X16
;
; ECS falling objects
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;


ECS_FALLING_ASM_ = 1

!ifndef CMN_QUEUE_ASM_ !error "Requires queue"



; =============================================================================
!zone ecsFallingComponent {
; -----------------------------------------------------------------------------
; Used to set and get the fall attributes for a given entity
; =============================================================================


} ; ecsFallingComponent


ecsDoFall:
  jsr ecsLocationSwap2
  jsr vSetCurrent
  lda tileBlank
  sta VERA_DATA0  
  lda tileBlank + 1
  sta VERA_DATA0

  lda #$08
  jsr ecsSetState

  jsr ecsFallingPush
  rts



; =============================================================================
!zone ecsFallingSystem {
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; falling "awake" queues
; -----------------------------------------------------------------------------
.entityLsbQueueId:  !byte $00
.entityMsbQueueId:  !byte $00

.entityLsbQueueMsb: !byte $00
.entityMsbQueueMsb: !byte $00


; -----------------------------------------------------------------------------
; ecsFallingSystemInit
; -----------------------------------------------------------------------------
; Initialise the falling system
; -----------------------------------------------------------------------------
ecsFallingSystemInit:
  +qCreate .entityLsbQueueId, .entityLsbQueueMsb
  sta .smcEntityLsb - 1

  +qCreate .entityMsbQueueId, .entityMsbQueueMsb
  sta .smcEntityMsb - 1
  rts

; -----------------------------------------------------------------------------
; ecsFallingPush
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; -----------------------------------------------------------------------------
ecsFallingPush:
  lda ZP_ECS_CURRENT_ENTITY_LSB
  ldx .entityLsbQueueId
  jsr qPush

  lda ZP_ECS_CURRENT_ENTITY_MSB
  ldx .entityMsbQueueId
  jsr qPush

  rts


; -----------------------------------------------------------------------------
; ecsFallingSystemTick
; -----------------------------------------------------------------------------
; Called for each frame
; -----------------------------------------------------------------------------
ecsFallingSystemTick:
  
  +vchannel0
  ldx .entityLsbQueueId
  jsr qSize
  bne +
  rts
+

  sta R9 ; store queue size in R9
  
  jsr qIterate ; get starting point (y)

.loop:
  lda SELF_MODIFY_MSB_ADDR, y   ; modified to address of .entityLsbQueueId
.smcEntityLsb:
  sta ZP_ECS_CURRENT_ENTITY_LSB

  lda SELF_MODIFY_MSB_ADDR, y   ; modified to address of .entityMsbQueueId
.smcEntityMsb:
  sta ZP_ECS_CURRENT_ENTITY_MSB

  phy
  jsr ecsGetState

  dec
  beq +
  jsr ecsSetState
  bra ++
+
  lda #ENTITY_TYPE_EMPTY
  jsr ecsEntitySetType

  ldx .entityLsbQueueId
  jsr qPop
  ldx .entityMsbQueueId
  jsr qPop

  ; need to do this before we start peeking
  
  jsr ecsGetLocation

  jsr ecsLocationPeekDown
  jsr ecsTempEntityGetType
  bne ++
  jsr ecsDoFall
++

  ply
  iny
  dec R9
  clc ; I don't understand why this is necessary. but it is
  bne .loop

.end:
  rts




} ; ecsFallingSystem