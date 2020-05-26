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
ENEMY_FACING_LEFT      = $00
ENEMY_FACING_UP        = $01
ENEMY_FACING_RIGHT     = $02
ENEMY_FACING_DOWN      = $03

ENEMY_FLAG_JUST_TURNED = $04
ENEMY_FLAG_MOVING = $10

; enemy state
; --------------
; facing     1:0
; justTurned  :2
; moving      :4

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

!ifdef SANITY {
.debugCurrentEntityTypeSanityCheck:
  pha
  lda ZP_ECS_ENEMY_STATE_TABLE_MSB
  and #$0f
  cmp ZP_ECS_CURRENT_ENTITY_MSB
  beq +
  +dbgSanityCheckBreak
+
  pla
  rts
}

; -----------------------------------------------------------------------------
; setEnemyState
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   A: State
; -----------------------------------------------------------------------------
setEnemyState:

!ifdef SANITY {
  jsr .debugCurrentEntityTypeSanityCheck
}
  pha
  +setRamBank .ENEMY_COMPONENT_BANK
  pla

  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; set enemy state
  sta (ZP_ECS_ENEMY_STATE_TABLE), y

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

!ifdef SANITY {
  jsr .debugCurrentEntityTypeSanityCheck
}

  +setRamBank .ENEMY_COMPONENT_BANK
  
  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; get enemy state
  lda (ZP_ECS_ENEMY_STATE_TABLE), y

  rts

} ; ecsEnemyComponent





; =============================================================================
!zone ecsEnemySystem {
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; ecsEnemySystemInit
; -----------------------------------------------------------------------------
; Initialise the enemy system
; -----------------------------------------------------------------------------
ecsEnemySystemInit:
  rts


; -----------------------------------------------------------------------------
; ecsEnemySystemTick
; -----------------------------------------------------------------------------
; Called for each frame
; -----------------------------------------------------------------------------
ecsEnemySystemTick:
  rts


; -----------------------------------------------------------------------------
; order of cells to search. we only search three.
; if no matches found, we do the first one (which will result in a left rotation)
;
; the normal search sequence for an enemy is (relative to its direction):
;   left, forward, right
;
; immediately after an enemy turns, its search sequence changes
;   forward, left, right
;


; -----------------------------------------------------------------------------
; these are mapped to the enemy state flag
; -----------------------------------------------------------------------------
enemySearchStep1:
  !word ecsLocationPeekDown   ; left
  !word ecsLocationPeekLeft   ; up
  !word ecsLocationPeekUp     ; right
  !word ecsLocationPeekRight  ; down
  !word ecsLocationPeekLeft   ; left - just turned
  !word ecsLocationPeekUp     ; up - just turned
  !word ecsLocationPeekRight  ; right - just turned
  !word ecsLocationPeekDown   ; down - just turned

enemySearchStep2:
  !word ecsLocationPeekLeft
  !word ecsLocationPeekUp
  !word ecsLocationPeekRight
  !word ecsLocationPeekDown
  !word ecsLocationPeekDown
  !word ecsLocationPeekLeft
  !word ecsLocationPeekUp
  !word ecsLocationPeekRight

enemySearchStep3:
  !word ecsLocationPeekUp
  !word ecsLocationPeekRight
  !word ecsLocationPeekDown
  !word ecsLocationPeekLeft
  !word ecsLocationPeekUp
  !word ecsLocationPeekRight
  !word ecsLocationPeekDown
  !word ecsLocationPeekLeft

newStateLookup:
newStateAfterStep1:
  !byte ENEMY_FACING_DOWN  | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_LEFT  | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_UP    | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_RIGHT | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_LEFT  | ENEMY_FLAG_MOVING
  !byte ENEMY_FACING_UP    | ENEMY_FLAG_MOVING
  !byte ENEMY_FACING_RIGHT | ENEMY_FLAG_MOVING
  !byte ENEMY_FACING_DOWN  | ENEMY_FLAG_MOVING

newStateAfterStep2:
  !byte ENEMY_FACING_LEFT  | ENEMY_FLAG_MOVING
  !byte ENEMY_FACING_UP    | ENEMY_FLAG_MOVING
  !byte ENEMY_FACING_RIGHT | ENEMY_FLAG_MOVING
  !byte ENEMY_FACING_DOWN  | ENEMY_FLAG_MOVING
  !byte ENEMY_FACING_DOWN  | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_LEFT  | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_UP    | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_RIGHT | ENEMY_FLAG_JUST_TURNED


newStateAfterStep3:
  !byte ENEMY_FACING_UP    | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_RIGHT | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_DOWN  | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_LEFT  | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_UP    | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_RIGHT | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_DOWN  | ENEMY_FLAG_JUST_TURNED
  !byte ENEMY_FACING_LEFT  | ENEMY_FLAG_JUST_TURNED




; y - set to index into enemySearchTable
.enemyPeekStep1:
  jmp (enemySearchStep1, x)
  
.enemyPeekStep2:
  jmp (enemySearchStep2, x)

.enemyPeekStep3:
  jmp (enemySearchStep3, x)

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
  jsr ecsLocationGetEntity

  jsr ecsEnemySetCurrentEntityType
  jsr getEnemyState
  sta ZP_ECS_ENEMY_STATE_CURRENT

  and #$07 ; only care about first 3 bits
  asl   ; double it because we're searching words
  tax
  stz R5H ; count of tests

  jsr .enemyPeekStep1
  lda ZP_ECS_TEMP_ENTITY_MSB
  and #$0f
  beq .endSearch ;  is empty?
  inc R5H

  jsr .enemyPeekStep2
  lda ZP_ECS_TEMP_ENTITY_MSB
  and #$0f
  beq .endSearch ;  is empty?
  inc R5H

  jsr .enemyPeekStep3
  lda ZP_ECS_TEMP_ENTITY_MSB
  and #$0f
  beq .endSearch ;  is empty?
  stz R5H  ; clear count.. do the first one

  ; no match found. doesn't matter we just turned in that case
  ; reset that flag
  lda ZP_ECS_ENEMY_STATE_CURRENT
  and #$03;!ENEMY_FLAG_JUST_TURNED
  sta ZP_ECS_ENEMY_STATE_CURRENT


.endSearch

  lda ZP_ECS_ENEMY_STATE_CURRENT
  and #$07 ; only care about first 3 bits

; now we want to find our new state, so need to look it up
;  address is computed by taking current state and adding
;  8 for the number of steps taken to find our new state
  ldx R5H
.stateLookupLoop  
  beq +
  clc
  adc #8  ; skip 8 bytes in our lookup
  dex
  bra .stateLookupLoop
+
  tax
  lda newStateLookup, x
  ; set the new state. but ZP_ECS_ENEMY_STATE_CURRENT 
  ; can still be used to compare with old state
  sta R5H
  jsr setEnemyState 
  
  bit #ENEMY_FLAG_MOVING
  beq +

  ; moving
  jsr ecsEntityCreateTransitioning
  jsr ecsLocationSwap

+
  lda R5H
  and #$03
  sta R5H

  ; now, in A, we'll store the old and new directions
  ; so our spscific enemy can animate it if he feels so inclined
  ; (3:2) old direction   (1:0) new direction
  lda ZP_ECS_ENEMY_STATE_CURRENT ; load old state
  and #$03 ; only care about direction
  asl
  asl
  ora R5H
  and #$0f


  rts



} ; ecsEnemySystem