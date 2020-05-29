; Supaplex - Commander X16
;
; ECS rolling objects
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;


ECS_ROLLING_ASM_ = 1

!ifndef CMN_QUEUE_ASM_ !error "Requires queue"



; =============================================================================
!zone ecsRollingComponent {
; -----------------------------------------------------------------------------
; Used to set and get the roll attributes for a given entity
; =============================================================================


} ; ecsRollingComponent


ecsDoRoll:

  jsr vSetCurrent
  ldx VERA_DATA0
  ldy VERA_DATA0

  jsr vSetTemp
  stx VERA_DATA0  
  sty VERA_DATA0

  jsr ecsLocationSwap

  lda #$08
  jsr ecsSetState

  jsr ecsRollingPush
  rts



; =============================================================================
!zone ecsRollingSystem {
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; rolling "awake" queues
; -----------------------------------------------------------------------------
.entityLsbQueueId:  !byte $00
.entityMsbQueueId:  !byte $00

.entityLsbQueueMsb: !byte $00
.entityMsbQueueMsb: !byte $00


; -----------------------------------------------------------------------------
; ecsRollingSystemInit
; -----------------------------------------------------------------------------
; Initialise the rolling system
; -----------------------------------------------------------------------------
ecsRollingSystemInit:
  +qCreate .entityLsbQueueId, .entityLsbQueueMsb
  sta .smcEntityLsb - 1

  +qCreate .entityMsbQueueId, .entityMsbQueueMsb
  sta .smcEntityMsb - 1
  rts

; -----------------------------------------------------------------------------
; ecsRollingPush
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; -----------------------------------------------------------------------------
ecsRollingPush:
  lda ZP_ECS_CURRENT_ENTITY_LSB
  ldx .entityLsbQueueId
  jsr qPush

  lda ZP_ECS_CURRENT_ENTITY_MSB
  ldx .entityMsbQueueId
  jsr qPush

  rts


; -----------------------------------------------------------------------------
; ecsRollingSystemTick
; -----------------------------------------------------------------------------
; Called for each frame
; -----------------------------------------------------------------------------
ecsRollingSystemTick:
  
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
;  lda #ENTITY_TYPE_EMPTY
;  jsr ecsEntitySetType

  ldx .entityLsbQueueId
  jsr qPop
  ldx .entityMsbQueueId
  jsr qPop

  ; need to do this before we start peeking
  
  jsr ecsGetLocation

  jsr ecsLocationPeekDown
  jsr ecsTempEntityGetType
  bne ++
  jsr ecsDoRoll
++

  ply
  iny
  dec R9
  clc ; I don't understand why this is necessary. but it is
  bne .loop

.end:
  rts




} ; ecsRollingSystem