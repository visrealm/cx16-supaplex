; Supaplex - Commander X16
;
; ECS enemy
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

; contains search logic for dynamic enemies (snik snaks and electrons)

ECS_LOCATION_ASM_ = 1

!ifndef CMN_QUEUE_ASM_ !error "Requires queue"



; =============================================================================
!zone ecsEnemyComponent {
; -----------------------------------------------------------------------------
; Used to set and get the enemy attributes for a given entity
; =============================================================================

.ENEMY_COMPONENT_BANK = RAM_BANK_ENEMY_COMPONENT
.ADDR_ENEMY_STATE_TABLE  = BANKED_RAM_START

; the direction we're facing
ENEMY_FACING_LEFT  = $00
ENEMY_FACING_UP    = $01
ENEMY_FACING_RIGHT = $02
ENEMY_FACING_DOWN  = $03

ENEMY_FLAG_MOVING  = $10

; enemy state
; -----------
; facing    1:0
; moving     :4


; -----------------------------------------------------------------------------
; ecsEnemySetCurrentEntityType
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; -----------------------------------------------------------------------------
ecsEnemySetCurrentEntityType:
  lda ZP_ECS_CURRENT_ENTITY_MSB
  ; TODO - check for index (11:8)
  and #$0f
  ora #>.ADDR_ENEMY_STATE_TABLE
  sta ZP_ECS_ENEMY_STATE_TABLE_MSB
  rts

.debugCurrentEntityTypeSanityCheck:
  pha
  lda ZP_ECS_ENEMY_STATE_TABLE_MSB
  and #$0f
  cmp ZP_ECS_CURRENT_ENTITY_MSB
  beq +
  +dbgBreak
+
  pla
  rts

; -----------------------------------------------------------------------------
; setEnemyState
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   A: State
; -----------------------------------------------------------------------------
setEnemyState:

!ifdef DEBUG {
  jsr .debugCurrentEntityTypeSanityCheck
}

  +setRamBank .ENEMY_COMPONENT_BANK
  phy

  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; set enemy state
  sta (ZP_ECS_ENEMY_STATE_TABLE), y

  ply
  rts

; -----------------------------------------------------------------------------
; getEnemyState
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; Outputs:
;   A: State
; -----------------------------------------------------------------------------
getEnemyState:

!ifdef DEBUG {
  jsr .debugCurrentEntityTypeSanityCheck
}

  +setRamBank .ENEMY_COMPONENT_BANK
  
  phy

  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; get enemy state
  lda (ZP_ECS_ENEMY_STATE_TABLE), y
  ply

  rts

} ; ecsEnemyComponent





; =============================================================================
!zone ecsEnemySystem {
; -----------------------------------------------------------------------------



; -----------------------------------------------------------------------------
; ecsEnemySystemTick
; -----------------------------------------------------------------------------
; Called for each frame
; -----------------------------------------------------------------------------
ecsEnemySystemTick:
  rts


; -----------------------------------------------------------------------------
; order of cells to search
; we only search three.
; if no matches found, we do the first one (which will result in a left rotation)
; -----------------------------------------------------------------------------
enemySearchTable:
  !word ecsLocationPeekLeft       ; <- start here if facing up
  !word ecsLocationPeekUp         ; <- start here if facing right
  !word ecsLocationPeekRight      ; <- start here if facing down
  !word ecsLocationPeekDown       ; <- start here if facing left
  !word ecsLocationPeekLeft
  !word ecsLocationPeekUp



; y - set to index into enemySearchTable
.enemyPeek:
  jmp (enemySearchTable, x)
  ; above jump will rts

; -----------------------------------------------------------------------------
; enemyAnimCB
; -----------------------------------------------------------------------------
; Animation callback (when an enemy animation completes)
; Inputs:
;  ZP_ECS_CURRENT_ENTITY
;  ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y
;  ZP_ECS_CURRENT_ANIM_ID, ZP_ECS_CURRENT_ANIM_FL
; -----------------------------------------------------------------------------
enemyAnimCB:

  jsr getEnemyState
  and #$0f
  sta ZP_ECS_ENEMY_STATE_CURRENT
  asl   ; double it because we're searching words
  tax
  lda #-1
  sta TS_TESTING

!for i, 1, 3 {
  jsr .enemyPeek
;+dbgBreak
  lda ZP_ECS_TEMP_ENTITY_MSB
  and #$0f
  beq .endSearch
  inc TS_TESTING
  inx ; try next location
  inx
}

.endSearch
  ; here. ZP_ECS_TEMP_ENTITY_MSB is where we're going (if we're going)
  ; R5 contains relative direction from UP
  lda TS_TESTING
  bne +
  ; same direction... we're moving!
  jsr ecsLocationSwap
  bra .doneTest

+
  ; different direction, we're rotating
  cmp #1   ; if offset is 1, we're turning right. otherwise, left
  beq .turnRight
.turnLeft
  lda ZP_ECS_ENEMY_STATE_CURRENT
  dec
  bpl .saveState
  clc
  adc #4
  bra .saveState

.turnRight
;+dbgBreak
  lda ZP_ECS_ENEMY_STATE_CURRENT
  inc
  cmp #4
  bne .saveState
  lda #0
.saveState

  sta ZP_ECS_ENEMY_STATE_CURRENT
  jsr setEnemyState

.doneTest:

  ;sta ZP_ECS_CURRENT_ANIM_ID
  stz ZP_ECS_CURRENT_ANIM_FL
  jsr ecsAnimationPush


  rts



} ; ecsEnemySystem