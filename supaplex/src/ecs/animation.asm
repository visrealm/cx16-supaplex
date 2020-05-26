; Supaplex - Commander X16
;
; Animation component and system
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

ECS_ANIMATION_ASM_ = 1


!ifndef CMN_QUEUE_ASM_ !error "Requires queue"

; =============================================================================
!zone ecsAnimationComponent {
; -----------------------------------------------------------------------------
; Used to set and get the animation attributes for a given entity
; =============================================================================

.ANIM_COMPONENT_BANK = RAM_BANK_ANIM_COMPONENT
.ADDR_ANIM_ID_TABLE  = BANKED_RAM_START
.ADDR_ANIM_FL_TABLE  = BANKED_RAM_START + $1000

ANIM_FLAG_REPEAT  = $80
ANIM_FLAG_REVERSE = $40   ; reverse the order of frames

; -----------------------------------------------------------------------------
; ecsAnimSetCurrentEntityType
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; -----------------------------------------------------------------------------
ecsAnimSetCurrentEntityType:
  lda ZP_ECS_CURRENT_ENTITY_MSB
  ; TODO - check for index (11:8)
  and #$0f
  ora #>.ADDR_ANIM_ID_TABLE
  sta ZP_ECS_ANIM_ID_TABLE_MSB
  clc
  adc #>(.ADDR_ANIM_FL_TABLE - .ADDR_ANIM_ID_TABLE)
  sta ZP_ECS_ANIM_FL_TABLE_MSB
  rts

.debugCurrentEntityTypeSanityCheck:
  pha
  lda ZP_ECS_ANIM_ID_TABLE_MSB
  and #$0f
  cmp ZP_ECS_CURRENT_ENTITY_MSB
  beq +
  +dbgSanityCheckBreak
+
  pla
  rts

; -----------------------------------------------------------------------------
; setAnimation
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   ZP_ECS_CURRENT_ANIM_ID
;   ZP_ECS_CURRENT_ANIM_FL
; -----------------------------------------------------------------------------
setAnimation:

!ifdef SANITY {
  jsr .debugCurrentEntityTypeSanityCheck
}

  +setRamBank .ANIM_COMPONENT_BANK
  phy

  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; set animation id
  lda ZP_ECS_CURRENT_ANIM_ID
  sta (ZP_ECS_ANIM_ID_TABLE), y
  
  ; set animation flags
  lda ZP_ECS_CURRENT_ANIM_FL
  sta (ZP_ECS_ANIM_FL_TABLE), y

  ply
  rts


; -----------------------------------------------------------------------------
; setAnimation
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   ZP_ECS_CURRENT_ANIM_ID
;   ZP_ECS_CURRENT_ANIM_FL
; -----------------------------------------------------------------------------
setAnimationTemp:
  lda ZP_ECS_TEMP_ENTITY_MSB
  ; TODO - check for index (11:8)
  and #$0f
  ora #>.ADDR_ANIM_ID_TABLE
  sta R9L
  clc
  adc #>(.ADDR_ANIM_FL_TABLE - .ADDR_ANIM_ID_TABLE)
  sta R9H

  +setRamBank .ANIM_COMPONENT_BANK
  phy

  ; index
  ldy ZP_ECS_TEMP_ENTITY_LSB

  ; set animation id
  lda #0
  sta (R9), y
  
  ; set animation flags
  lda #0
  sta (R9), y

  ply
  rts

; -----------------------------------------------------------------------------
; getAnimation
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; Outputs:
;   ZP_ECS_CURRENT_ANIM_ID
;   ZP_ECS_CURRENT_ANIM_FL
; -----------------------------------------------------------------------------
getAnimation:

!ifdef SANITY {
  jsr .debugCurrentEntityTypeSanityCheck
}

  +setRamBank .ANIM_COMPONENT_BANK
  
  phy

  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; set animation id
  lda (ZP_ECS_ANIM_ID_TABLE), y
  sta ZP_ECS_CURRENT_ANIM_ID
  
  ; set animation flags
  lda (ZP_ECS_ANIM_FL_TABLE), y
  sta ZP_ECS_CURRENT_ANIM_FL

  ply
  rts

} ; ecsAnimationComponent




; =============================================================================
!zone ecsAnimationSystem {
; -----------------------------------------------------------------------------
; the animation system runs the animations using data provided by the
; animation components.
; when an animation is started, its data is set in its entity's animation
; component. it is then added to the animation system's queue. each tick
; the queue is processed. if an animation completes, it is removed from the
; queue.
; =============================================================================


; -----------------------------------------------------------------------------
; animation queues
; -----------------------------------------------------------------------------
.entityLsbQueueId:  !byte $00
.entityMsbQueueId:  !byte $00

.entityLsbQueueMsb: !byte $00
.entityMsbQueueMsb: !byte $00


; 0: repeat[7]  reverse[6]  rate? additional id? unused? [5-4] step[3-0]
; 1: animId[7 - 0]

TMP_ANIM_DEF_ADDR =   R3
TMP_ANIM_DEF_ADDR_L = R3L
TMP_ANIM_DEF_ADDR_H = R3H

TMP_ANIM_FL = R2


; -----------------------------------------------------------------------------
; NOTES
; -----------------------------------------------------------------------------

; keep a full level map. 2 bytes per cell
; that way we can go back and get the entity
; or we can set an animation on a cell without
; needing an entity and we limit the entire
; data requirements to 4KB (plus queues)
; need a lookup from entityId to cell x/y

; keep a queue of active cells (or entities)

; all cell animations are 8 frames (16 bytes) long, so can be placed in a queue
; *if* an animation needs to replace the old one (eg. explosion)
; no problem.. it will as the queue will sort it out



; -----------------------------------------------------------------------------
; animation definition macros
; -----------------------------------------------------------------------------
!macro animDefByte tileAddress {
    !byte (tileAddress - tileTable) >> 1
}

!macro animDef id, tile0, tile1, tile2, tile3, tile4, tile5, tile6, tile7 {
  +animDefByte tile0
  +animDefByte tile1
  +animDefByte tile2
  +animDefByte tile3
  +animDefByte tile4
  +animDefByte tile5
  +animDefByte tile6
  +animDefByte tile7
}

; -----------------------------------------------------------------------------
; animation definitions
; -----------------------------------------------------------------------------
animationDefs:
animBlank: +animDef 0, tileBlank, tileBlank, tileBlank, tileBlank, tileBlank, tileBlank, tileBlank, tileBlank
animSnikU2L: +animDef 1, tileSnikUp, tileSnikUp, tileSnikUl, tileSnikUl, tileSnikUl, tileSnikUl, tileSnikL, tileSnikL
animSnikL2D: +animDef 2, tileSnikL, tileSnikL, tileSnikDl, tileSnikDl, tileSnikDl, tileSnikDl, tileSnikDn, tileSnikDn
animSnikD2R: +animDef 3, tileSnikDn, tileSnikDn, tileSnikDr, tileSnikDr, tileSnikDr, tileSnikDr, tileSnikR, tileSnikR
animSnikR2U: +animDef 4, tileSnikR, tileSnikR, tileSnikUr, tileSnikUr, tileSnikUr, tileSnikUr, tileSnikUp, tileSnikUp
animSnikU2U: +animDef 5, tileSnikUp1, tileSnikUp2, tileSnikUp3, tileSnikUp4, tileSnikUp5, tileSnikUp6, tileSnikUp7, tileSnikUp8
animSnikL2L: +animDef 6, tileSnikLeft1, tileSnikLeft2, tileSnikLeft3, tileSnikLeft4, tileSnikLeft5, tileSnikLeft6, tileSnikLeft7, tileSnikLeft8
animSnikD2D: +animDef 7, tileSnikDown1, tileSnikDown2, tileSnikDown3, tileSnikDown4, tileSnikDown5, tileSnikDown6, tileSnikDown7, tileSnikDown8
animSnikR2R: +animDef 8, tileSnikRight1, tileSnikRight2, tileSnikRight3, tileSnikRight4, tileSnikRight5, tileSnikRight6, tileSnikRight7, tileSnikRight8
animTermGreen: +animDef 9, tileConsoleGn1, tileConsoleGn1, tileConsoleGn2, tileConsoleGn2, tileConsoleGn3, tileConsoleGn3, tileConsoleGn4, tileConsoleGn4
animTermReg:   +animDef 10, tileConsoleRd1, tileConsoleRd2, tileConsoleRd3, tileConsoleRd4, tileConsoleRd5, tileConsoleRd6, tileConsoleRd7, tileConsoleRd8
animElectron:  +animDef 11,  tileElectron1, tileElectron2, tileElectron2, tileElectron3, tileElectron4, tileElectron5, tileElectron6, tileElectron6
animElectron2:  +animDef 12, tileElectron7, tileElectron7, tileElectron6, tileElectron5, tileElectron4, tileElectron3, tileElectron2, tileElectron2

; TODO: Add a lookup for the above to save computing the address each time


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

animationCallbacks:
  !word emptyAnimCB
  !word zonkAnimCB
  !word playerAnimCB
  !word baseAnimCB
  !word yellowDiskAnimCB
  !word redDiskAnimCB
  !word orangeDiskAnimCB
  !word switchAnimCB
  !word portAnimCB
  !word bugAnimCB
  !word infotronAnimCB
  !word electronAnimCB
  !word snikSnakAnimCB
  !word ramAnimCB
  !word hardwareAnimCB
  !word transitionAnimCB

; -----------------------------------------------------------------------------
; placeholder callbacks (not yet implemented)
; -----------------------------------------------------------------------------
emptyAnimCB:
zonkAnimCB:
playerAnimCB:
baseAnimCB:
yellowDiskAnimCB:
redDiskAnimCB:
orangeDiskAnimCB:
switchAnimCB:
portAnimCB:
bugAnimCB:
infotronAnimCB:
ramAnimCB:
hardwareAnimCB:
  rts

  
; -----------------------------------------------------------------------------
; JSR wrapper called for animationCallbacks
; -----------------------------------------------------------------------------
animationCompleteCallback:
  lda ZP_ECS_CURRENT_ENTITY_MSB
  asl
  tax
  jmp (animationCallbacks, x)
  ; above jump will rts


; -----------------------------------------------------------------------------
; initialise the animation system
; -----------------------------------------------------------------------------
ecsAnimationSystemInit:
  stz ZP_ECS_ANIM_ID_TABLE_LSB
  stz ZP_ECS_ANIM_FL_TABLE_LSB

  +qCreate .entityLsbQueueId, .entityLsbQueueMsb
  sta .smcEntityLsb - 1

  +qCreate .entityMsbQueueId, .entityMsbQueueMsb
  sta .smcEntityMsb - 1

  rts

; -----------------------------------------------------------------------------
; ecsAnimationPush
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; -----------------------------------------------------------------------------
ecsAnimationPush:
  lda ZP_ECS_CURRENT_ENTITY_LSB
  ldx .entityLsbQueueId
  jsr qPush

  lda ZP_ECS_CURRENT_ENTITY_MSB
  ldx .entityMsbQueueId
  jsr qPush

  rts


ecsAnimationPushTemp:
  lda ZP_ECS_TEMP_ENTITY_LSB
  ldx .entityLsbQueueId
  jsr qPush

  lda ZP_ECS_TEMP_ENTITY_MSB
  ldx .entityMsbQueueId
  jsr qPush

  rts

; -----------------------------------------------------------------------------
; ecsAnimationSystemTick
; -----------------------------------------------------------------------------
; Called for each frame. Animate those who need animating
; -----------------------------------------------------------------------------
ecsAnimationSystemTick:
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
  jsr ecsAnimSetCurrentEntityType ; TODO: can we make this smarter? do it less?
  jsr ecsLocationSetCurrentEntityType
  jsr getAnimation
  jsr getLocation
  
  jsr vSetCurrent

  ; fill ZP_ECS_CURRENT_ANIM_ID and ZP_ECS_CURRENT_ANIM_FL

  lda ZP_ECS_CURRENT_ANIM_ID   ; TODO:  replace this calculation with a lookup

  stz TMP_ANIM_DEF_ADDR_H
  asl 
  rol TMP_ANIM_DEF_ADDR_H
  asl 
  rol TMP_ANIM_DEF_ADDR_H
  asl 
  rol TMP_ANIM_DEF_ADDR_H
  clc
  adc #<animationDefs
  sta TMP_ANIM_DEF_ADDR_L
  lda TMP_ANIM_DEF_ADDR_H
  adc #>animationDefs
  sta TMP_ANIM_DEF_ADDR_H

  lda ZP_ECS_CURRENT_ANIM_FL   ; step (3:0)  TODO: account for (7:4)
  bit #ANIM_FLAG_REVERSE
  bne +
  ; forward
  and #$0f
  tay
  lda (TMP_ANIM_DEF_ADDR), y
  iny
  inc ZP_ECS_CURRENT_ANIM_FL
  bra .afterInc
+
  ; reverse
  and #$0f
  tay
  lda (TMP_ANIM_DEF_ADDR), y
  dey
  dec ZP_ECS_CURRENT_ANIM_FL

.afterInc

  ; here, a is the tile Id
  jsr outputTile

  lda ZP_ECS_CURRENT_ANIM_FL
  and #$0f
  bit #$08
  beq ++
  
  ldx .entityLsbQueueId
  jsr qPop
  ldx .entityMsbQueueId
  jsr qPop

  lda ZP_ECS_CURRENT_ANIM_FL
  bit #ANIM_FLAG_REPEAT
  beq +
  and #$f0
  sta ZP_ECS_CURRENT_ANIM_FL
  jsr ecsAnimationPush
+
  ; callback
  jsr animationCompleteCallback
++
  jsr setAnimation
  ply
  iny
  dec R9
  clc ; I don't understand why this is necessary. but it is
  bne .loop

.end:
  rts


}