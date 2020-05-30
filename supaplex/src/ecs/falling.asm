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

  jsr vSetCurrent
  ldx VERA_DATA0
  ldy VERA_DATA0

  jsr vSetTemp
  stx VERA_DATA0  
  sty VERA_DATA0

  jsr ecsLocationSwap

  lda #$09
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
  bra .next
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
  beq +  
  cmp #$ff
  bne ++
+  
  jsr ecsDoFall
  bra .next
++
  jsr hudOutputDebug
  bra .next
  jsr ecsLocationPeekAll
  ldx #0
  ldy #9
-
  lda currentNine, x
  sta ZP_ECS_CURRENT_ENTITY_LSB
  inx
  lda currentNine, x
  sta ZP_ECS_CURRENT_ENTITY_MSB
  jsr ecsGetLocation
  jsr vSetCurrent
  lda tileExplod1
  sta VERA_DATA0  
  lda tileExplod1 + 1
  sta VERA_DATA0
  
  ;+ldaAnimId animExplode
  ;sta ZP_ECS_CURRENT_ANIM_ID
  ;stz ZP_ECS_CURRENT_ANIM_FL
  ;phy
  ;phx
  ;jsr ecsSetAnimation
  ;jsr ecsAnimationPush
  ;plx
  ;ply
  
  inx
  dey
  bne -



.next:
  ply
  iny
  dec R9
  clc ; I don't understand why this is necessary. but it is
  bne .loop

.end:
  rts




} ; ecsFallingSystem